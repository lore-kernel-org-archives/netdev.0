From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] NET: Fix function put_cmsg() which may cause usr application
 memory overflow
Date: Tue, 18 Dec 2007 15:19:09 +0900
Message-ID: <4767665D.20300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:55652 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712AbXLRGTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 01:19:41 -0500
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id lBI6Jd4a000396
	for <netdev@vger.kernel.org> (envelope-from yjwei@cn.fujitsu.com);
	Tue, 18 Dec 2007 15:19:39 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 348032AC029
	for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 15:19:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CCEB12C064
	for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 15:19:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5 [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BD1FB161C00B
	for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 15:19:38 +0900 (JST)
Received: from vs01.gw.fujitsu.co.jp (vs01.gw.fujitsu.co.jp [133.161.11.21])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B2E5161C00E
	for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 15:19:38 +0900 (JST)
Received: from root01.fujitsu.com (root01.fujitsu.com [133.161.11.11])
	by vs01.gw.fujitsu.co.jp (8.13.7/8.13.7) with ESMTP id lBI6Jc2F000833
	for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 15:19:38 +0900
Received: from root01.fujitsu.com (root01 [127.0.0.1])
	by root01.fujitsu.com (Postfix) with ESMTP id 35452282C6A
	for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 15:19:38 +0900 (JST)
Received: from [10.33.110.120] (dhcp110-120.sky.yk.fujitsu.co.jp [10.33.110.120])
	by root01.fujitsu.com (Postfix) with ESMTP id E1AC4282C69
	for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 15:19:37 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When used function put_cmsg() to copy kernel information to user 
application memory, if the memory length given by user application is 
not enough, by the bad length calculate of msg.msg_controllen, 
put_cmsg() function may cause the msg.msg_controllen to be a large 
value, such as 0xFFFFFFF0, so the following put_cmsg() can also write 
data to usr application memory even usr has no valid memory to store 
this. This may cause usr application memory overflow.

int put_cmsg(struct msghdr * msg, int level, int type, int len, void *data)
{
    struct cmsghdr __user *cm
        = (__force struct cmsghdr __user *)msg->msg_control;
    struct cmsghdr cmhdr;
    int cmlen = CMSG_LEN(len);
    ~~~~~~~~~~~~~~~~~~~~~
    int err;

    if (MSG_CMSG_COMPAT & msg->msg_flags)
        return put_cmsg_compat(msg, level, type, len, data);

    if (cm==NULL || msg->msg_controllen < sizeof(*cm)) {
        msg->msg_flags |= MSG_CTRUNC;
        return 0; /* XXX: return error? check spec. */
    }
    if (msg->msg_controllen < cmlen) {
    ~~~~~~~~~~~~~~~~~~~~~~~~
        msg->msg_flags |= MSG_CTRUNC;
        cmlen = msg->msg_controllen;
    }
    cmhdr.cmsg_level = level;
    cmhdr.cmsg_type = type;
    cmhdr.cmsg_len = cmlen;

    err = -EFAULT;
    if (copy_to_user(cm, &cmhdr, sizeof cmhdr))
        goto out;
    if (copy_to_user(CMSG_DATA(cm), data, cmlen - sizeof(struct cmsghdr)))
        goto out;
    cmlen = CMSG_SPACE(len);
~~~~~~~~~~~~~~~~~~~~~~~~~~~
    If MSG_CTRUNC flags is set, msg->msg_controllen is less than 
CMSG_SPACE(len), "msg->msg_controllen -= cmlen" will cause unsinged int 
type msg->msg_controllen to be a large value.
~~~~~~~~~~~~~~~~~~~~~~~~~~~
    msg->msg_control += cmlen;
    msg->msg_controllen -= cmlen;
    ~~~~~~~~~~~~~~~~~~~~~
    err = 0;
out:
    return err;
}

The same promble exists in put_cmsg_compat(). This patch can fix this 
problem.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

--- a/net/core/scm.c	2007-12-11 08:41:57.000000000 -0500
+++ b/net/core/scm.c	2007-12-11 12:10:25.000000000 -0500
@@ -196,6 +196,8 @@ int put_cmsg(struct msghdr * msg, int le
 	if (copy_to_user(CMSG_DATA(cm), data, cmlen - sizeof(struct cmsghdr)))
 		goto out;
 	cmlen = CMSG_SPACE(len);
+	if (msg->msg_controllen < cmlen)
+		cmlen = msg->msg_controllen;
 	msg->msg_control += cmlen;
 	msg->msg_controllen -= cmlen;
 	err = 0;
--- a/net/compat.c	2007-12-11 12:10:32.000000000 -0500
+++ b/net/compat.c	2007-12-11 12:11:08.000000000 -0500
@@ -254,6 +254,8 @@ int put_cmsg_compat(struct msghdr *kmsg,
 	if (copy_to_user(CMSG_COMPAT_DATA(cm), data, cmlen - sizeof(struct compat_cmsghdr)))
 		return -EFAULT;
 	cmlen = CMSG_COMPAT_SPACE(len);
+	if (kmsg->msg_controllen < cmlen)
+		cmlen = kmsg->msg_controllen;
 	kmsg->msg_control += cmlen;
 	kmsg->msg_controllen -= cmlen;
 	return 0;





