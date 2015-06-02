From: <gregkh@linuxfoundation.org>
Subject: Patch "net: socket: Fix the wrong returns for recvmsg and sendmsg" has been added to the 3.14-stable tree
Date: Tue, 02 Jun 2015 22:00:45 +0900
Message-ID: <143325004525237@kroah.com>
References: <1433150880-9976-1-git-send-email-zhengjunling@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: <stable@vger.kernel.org>, <stable-commits@vger.kernel.org>
To: zhengjunling@huawei.com, davem@davemloft.net,
	gregkh@linuxfoundation.org, lizefan@huawei.com,
	netdev@vger.kernel.org, stable@vger.kernel.org,
	viro@zeniv.linux.org.uk, xuhanbing@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:36223 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755082AbbFBNAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 09:00:47 -0400
In-Reply-To: <1433150880-9976-1-git-send-email-zhengjunling@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    net: socket: Fix the wrong returns for recvmsg and sendmsg

to the 3.14-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     net-socket-fix-the-wrong-returns-for-recvmsg-and-sendmsg.patch
and it can be found in the queue-3.14 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From zhengjunling@huawei.com  Tue Jun  2 15:26:33 2015
From: Junling Zheng <zhengjunling@huawei.com>
Date: Mon, 1 Jun 2015 09:28:00 +0000
Subject: net: socket: Fix the wrong returns for recvmsg and sendmsg
To: <gregkh@linuxfoundation.org>
Cc: <lizefan@huawei.com>, <viro@zeniv.linux.org.uk>, <davem@davemloft.net>, <xuhanbing@huawei.com>, <stable@vger.kernel.org>, <netdev@vger.kernel.org>
Message-ID: <1433150880-9976-1-git-send-email-zhengjunling@huawei.com>

From: Junling Zheng <zhengjunling@huawei.com>

Based on 08adb7dabd4874cc5666b4490653b26534702ce0 upstream.

We found that after v3.10.73, recvmsg might return -EFAULT while -EINVAL
was expected.

We tested it through the recvmsg01 testcase come from LTP testsuit. It set
msg->msg_namelen to -1 and the recvmsg syscall returned errno 14, which is
unexpected (errno 22 is expected):

recvmsg01    4  TFAIL  :  invalid socket length ; returned -1 (expected -1),
errno 14 (expected 22)

Linux mainline has no this bug for commit 08adb7dab fixes it accidentally.
However, it is too large and complex to be backported to LTS 3.10.

Commit 281c9c36 (net: compat: Update get_compat_msghdr() to match
copy_msghdr_from_user() behaviour) made get_compat_msghdr() return
error if msg_sys->msg_namelen was negative, which changed the behaviors
of recvmsg and sendmsg syscall in a lib32 system:

Before commit 281c9c36, get_compat_msghdr() wouldn't fail and it would
return -EINVAL in move_addr_to_user() or somewhere if msg_sys->msg_namelen
was invalid and then syscall returned -EINVAL, which is correct.

And now, when msg_sys->msg_namelen is negative, get_compat_msghdr() will
fail and wants to return -EINVAL, however, the outer syscall will return
-EFAULT directly, which is unexpected.

This patch gets the return value of get_compat_msghdr() as well as
copy_msghdr_from_user(), then returns this expected value if
get_compat_msghdr() fails.

Fixes: 281c9c36 (net: compat: Update get_compat_msghdr() to match copy_msghdr_from_user() behaviour)
Signed-off-by: Junling Zheng <zhengjunling@huawei.com>
Signed-off-by: Hanbing Xu <xuhanbing@huawei.com>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 net/socket.c |   24 ++++++++++--------------
 1 file changed, 10 insertions(+), 14 deletions(-)

--- a/net/socket.c
+++ b/net/socket.c
@@ -2007,14 +2007,12 @@ static int ___sys_sendmsg(struct socket
 	int err, ctl_len, total_len;
 
 	err = -EFAULT;
-	if (MSG_CMSG_COMPAT & flags) {
-		if (get_compat_msghdr(msg_sys, msg_compat))
-			return -EFAULT;
-	} else {
+	if (MSG_CMSG_COMPAT & flags)
+		err = get_compat_msghdr(msg_sys, msg_compat);
+	else
 		err = copy_msghdr_from_user(msg_sys, msg);
-		if (err)
-			return err;
-	}
+	if (err)
+		return err;
 
 	if (msg_sys->msg_iovlen > UIO_FASTIOV) {
 		err = -EMSGSIZE;
@@ -2219,14 +2217,12 @@ static int ___sys_recvmsg(struct socket
 	struct sockaddr __user *uaddr;
 	int __user *uaddr_len;
 
-	if (MSG_CMSG_COMPAT & flags) {
-		if (get_compat_msghdr(msg_sys, msg_compat))
-			return -EFAULT;
-	} else {
+	if (MSG_CMSG_COMPAT & flags)
+		err = get_compat_msghdr(msg_sys, msg_compat);
+	else
 		err = copy_msghdr_from_user(msg_sys, msg);
-		if (err)
-			return err;
-	}
+	if (err)
+		return err;
 
 	if (msg_sys->msg_iovlen > UIO_FASTIOV) {
 		err = -EMSGSIZE;


Patches currently in stable-queue which might be from zhengjunling@huawei.com are

queue-3.14/net-socket-fix-the-wrong-returns-for-recvmsg-and-sendmsg.patch
