From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH RFC] netlink: a flag requesting header w/o data in error ACK
Date: Wed, 13 Nov 2013 16:46:09 +0100
Message-ID: <231e025015eee115182368b34333b38579e3112d.1384357520.git.jbenc@redhat.com>
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26610 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759500Ab3KMPrV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 10:47:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, ACK in case of error contains a full copy of the originating
message, although many applications do not need it. This can cause lost ACKs
with large netlink messages, especially after commit c05cdb1b864f ("netlink:
allow large data transfers from user-space").

Introduce a new message flag, NLM_F_SHORT_NACK, which requests only message
header to be included in ACK regardless of the error code. This flag has no
effect if NLM_F_ACK is not set.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
I'm not entirely happy with taking a bit in netlink message header for this.
Alternative approach would be to make this a socket option (as suggested by
David) but that would mean a socket lookup in netlink_ack for each and every
ACK, which doesn't sound nice, either. If this is preferred, I'll rework the
patch.
---
 include/uapi/linux/netlink.h |    3 ++-
 net/netlink/af_netlink.c     |   10 +++++++---
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index 1a85940..d21dc2b 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -53,7 +53,8 @@ struct nlmsghdr {
 #define NLM_F_MULTI		2	/* Multipart message, terminated by NLMSG_DONE */
 #define NLM_F_ACK		4	/* Reply with ack, with zero or error code */
 #define NLM_F_ECHO		8	/* Echo this request 		*/
-#define NLM_F_DUMP_INTR		16	/* Dump was inconsistent due to sequence change */
+#define NLM_F_DUMP_INTR		0x10	/* Dump was inconsistent due to sequence change */
+#define NLM_F_SHORT_NACK	0x20	/* Quote only the header in ack on error */
 
 /* Modifiers to GET request */
 #define NLM_F_ROOT	0x100	/* specify tree	root	*/
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 8df7f64..7ea2a1e 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2716,13 +2716,17 @@ EXPORT_SYMBOL(__netlink_dump_start);
 
 void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 {
+	int full_quote;
 	struct sk_buff *skb;
 	struct nlmsghdr *rep;
 	struct nlmsgerr *errmsg;
 	size_t payload = sizeof(*errmsg);
 
-	/* error messages get the original request appened */
-	if (err)
+	/* Error messages get the original request appened, unless
+	 * NLM_F_SHORT_NACK is set.
+	 */
+	full_quote = err && !(nlh->nlmsg_flags & NLM_F_SHORT_NACK);
+	if (full_quote)
 		payload += nlmsg_len(nlh);
 
 	skb = netlink_alloc_skb(in_skb->sk, nlmsg_total_size(payload),
@@ -2745,7 +2749,7 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 			  NLMSG_ERROR, payload, 0);
 	errmsg = nlmsg_data(rep);
 	errmsg->error = err;
-	memcpy(&errmsg->msg, nlh, err ? nlh->nlmsg_len : sizeof(*nlh));
+	memcpy(&errmsg->msg, nlh, full_quote ? nlh->nlmsg_len : sizeof(*nlh));
 	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).portid, MSG_DONTWAIT);
 }
 EXPORT_SYMBOL(netlink_ack);
-- 
1.7.6.5
