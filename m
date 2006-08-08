From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/4] [NETLINK]: Handle NLM_F_ECHO in netlink_rcv_skb()
Date: Wed, 09 Aug 2006 00:00:01 +0200
Message-ID: <20060809205439.434010049@postel.suug.ch>
References: <20060809204821.216122988@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:19362 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751369AbWHIUzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 16:55:09 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_echo
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current behaviour around NLM_F_ECHO is inconsistent
and spread all around in various subsystems and doesn't
represent what it was meant for.

This patch handles NLM_F_ECHO in netlink_rcv_skb() to
handle it in a central point. Most subsystems currently
interpret NLM_F_ECHO as to just unicast events to the
originator of the change while the real meaning of the
flag is to echo the request.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/netlink/af_netlink.c
===================================================================
--- net-2.6.19.git.orig/net/netlink/af_netlink.c
+++ net-2.6.19.git/net/netlink/af_netlink.c
@@ -1430,6 +1430,28 @@ int netlink_dump_start(struct sock *ssk,
 	return 0;
 }
 
+static void netlink_echo(struct sk_buff *in_skb, struct nlmsghdr *orig)
+{
+	struct sk_buff *skb;
+	struct nlmsghdr *nlh;
+	int payload = nlmsg_len(orig);
+
+	skb = nlmsg_new(nlmsg_total_size(payload), GFP_KERNEL);
+	if (skb == NULL)
+		return;
+
+	/*
+	 * Return original header with pid set to 0 (from kernel) and
+	 * NLM_F_REQUEST flag removed to indicate this is not a request
+	 * for an echo but the reply.
+	 */
+	nlh = __nlmsg_put(skb, 0, orig->nlmsg_seq, orig->nlmsg_type,
+			  payload, orig->nlmsg_flags & ~NLM_F_REQUEST);
+	memcpy(nlmsg_data(nlh), nlmsg_data(orig), payload);
+
+	nlmsg_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).pid);
+}
+
 void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 {
 	struct sk_buff *skb;
@@ -1476,6 +1498,9 @@ static int netlink_rcv_skb(struct sk_buf
 		if (nlh->nlmsg_len < NLMSG_HDRLEN || skb->len < nlh->nlmsg_len)
 			return 0;
 
+		if (nlh->nlmsg_flags & NLM_F_ECHO)
+			netlink_echo(skb, nlh);
+
 		if (cb(skb, nlh, &err) < 0) {
 			/* Not an error, but we have to interrupt processing
 			 * here. Note: that in this case we do not pull

