From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Tue, 18 Jan 2011 18:23:40 +0100
Message-ID: <20110118172340.GB1843@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, pablo@netfilter.org,
	arthur.marsh@internode.on.net, jengelh@medozas.de,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Alessandro Suardi <alessandro.suardi@gmail.com>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:49555 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154Ab1ARRXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 12:23:47 -0500
Received: by ewy5 with SMTP id 5so3426544ewy.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 09:23:46 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH] netlink: Fix possible NLM_F_DUMP misuse in genetlink

NLM_F_DUMP flags should be applied to GET requests only, eg. rtnetlink
tests message type to verify this. Since genetlink can't do the same
use "practical" test for ops->dumpit (assuming NEW request won't be
mixed with GET).

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Cc: Jan Engelhardt <jengelh@medozas.de>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Jamal Hadi Salim <hadi@cyberus.ca>
---
Not for stable before testing!

diff -Nurp a/net/netlink/genetlink.c b/net/netlink/genetlink.c
--- a/net/netlink/genetlink.c	2011-01-18 16:58:16.000000000 +0100
+++ b/net/netlink/genetlink.c	2011-01-18 17:08:43.000000000 +0100
@@ -519,15 +519,16 @@ static int genl_rcv_msg(struct sk_buff *
 	    security_netlink_recv(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (nlh->nlmsg_flags & NLM_F_DUMP) {
-		if (ops->dumpit == NULL)
+	if (ops->dumpit) {
+		if (nlh->nlmsg_flags & NLM_F_DUMP) {
+			genl_unlock();
+			err = netlink_dump_start(net->genl_sock, skb, nlh,
+						 ops->dumpit, ops->done);
+			genl_lock();
+			return err;
+		} else {
 			return -EOPNOTSUPP;
-
-		genl_unlock();
-		err = netlink_dump_start(net->genl_sock, skb, nlh,
-					 ops->dumpit, ops->done);
-		genl_lock();
-		return err;
+		}
 	}
 
 	if (ops->doit == NULL)
