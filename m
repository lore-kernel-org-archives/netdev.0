From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] fix ACK processing after netlink_dump_start
Date: Tue, 23 Oct 2007 18:40:23 +0400
Message-ID: <20071023144023.GA15035@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: dcbw@redhat.com, tgraf@suug.ch, jfannin@gmail.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:50164 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751844AbXJWOhw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 10:37:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Revert to original netlink behavior. Do not reply with ACK if the
netlink dump has bees successfully started.

libnl has been broken by the cd40b7d3983c708aabe3d3008ec64ffce56d33b0
The following command reproduce the problem:
   /nl-route-get 192.168.1.1

Signed-off-by: Denis V. Lunev <den@openvz.org>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 98e313e..44a8b41 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1565,7 +1565,10 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 
 	netlink_dump(sk);
 	sock_put(sk);
-	return 0;
+
+	/* We successfully started a dump, by returning -EINTR we
+	 * signal not to send ACK even if it was requested */
+	return -EINTR;
 }
 
 void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
@@ -1619,17 +1622,21 @@ int netlink_rcv_skb(struct sk_buff *skb, int (*cb)(struct sk_buff *,
 
 		/* Only requests are handled by the kernel */
 		if (!(nlh->nlmsg_flags & NLM_F_REQUEST))
-			goto skip;
+			goto ack;
 
 		/* Skip control messages */
 		if (nlh->nlmsg_type < NLMSG_MIN_TYPE)
-			goto skip;
+			goto ack;
 
 		err = cb(skb, nlh);
-skip:
+		if (err == -EINTR)
+			goto skip;
+
+ack:
 		if (nlh->nlmsg_flags & NLM_F_ACK || err)
 			netlink_ack(skb, nlh, err);
 
+skip:
 	        msglen = NLMSG_ALIGN(nlh->nlmsg_len);
 		if (msglen > skb->len)
 			msglen = skb->len;
