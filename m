From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] genetlink: fix possible memory leak in genl_family_rcv_msg()
Date: Sat, 27 Apr 2013 09:34:16 +0800
Message-ID: <CAPgLHd_tU4suwLY9M1Xoq9osTMcFWMARAaQV=9eodCJ+hZLz-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net, pablo@netfilter.org, shemminger@vyatta.com,
	ebiederm@xmission.com, bhutchings@solarflare.com,
	pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f50.google.com ([209.85.214.50]:39304 "EHLO
	mail-bk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089Ab3D0BeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 21:34:18 -0400
Received: by mail-bk0-f50.google.com with SMTP id ik5so2017264bkc.37
        for <netdev@vger.kernel.org>; Fri, 26 Apr 2013 18:34:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

'attrbuf' is malloced in genl_family_rcv_msg() when family->maxattr &&
family->parallel_ops, thus should be freed before leaving from the error
handling cases, otherwise it will cause memory leak.

Introduced by commit def3117493eafd9dfa1f809d861e0031b2cc8a07
(genl: Allow concurrent genl callbacks.)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/netlink/genetlink.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 2f72598..2fd6dbe 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -598,7 +598,7 @@ static int genl_family_rcv_msg(struct genl_family *family,
 		err = nlmsg_parse(nlh, hdrlen, attrbuf, family->maxattr,
 				  ops->policy);
 		if (err < 0)
-			return err;
+			goto out;
 	}
 
 	info.snd_seq = nlh->nlmsg_seq;
@@ -613,7 +613,7 @@ static int genl_family_rcv_msg(struct genl_family *family,
 	if (family->pre_doit) {
 		err = family->pre_doit(ops, skb, &info);
 		if (err)
-			return err;
+			goto out;
 	}
 
 	err = ops->doit(skb, &info);
@@ -621,6 +621,7 @@ static int genl_family_rcv_msg(struct genl_family *family,
 	if (family->post_doit)
 		family->post_doit(ops, skb, &info);
 
+out:
 	if (family->parallel_ops)
 		kfree(attrbuf);
 
