From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] netlink: advertise incomplete dumps
Date: Mon, 20 Jun 2011 13:40:46 +0200
Message-ID: <1308570046.4322.5.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <samuel@sortiz.org>,
	"aloisio.almeida" <aloisio.almeida@openbossa.org>,
	John Linville <linville@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>
To: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:46617 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875Ab1FTLku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 07:40:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Consider the following situation:
 * a dump that would show 8 entries, four in the first
   round, and four in the second
 * between the first and second rounds, 6 entries are
   removed
 * now the second round will not show any entry, and
   even if there is a sequence/generation counter the
   application will not know

To solve this problem, add a new flag NLM_F_DUMP_INTR
to the netlink header that indicates the dump wasn't
consistent, this flag can also be set on the MSG_DONE
message that terminates the dump, and as such above
situation can be detected.

To achieve this, add a sequence counter to the netlink
callback struct. Of course, netlink code still needs
to use this new functionality. The correct way to do
that is to always set cb->seq when a dumpit callback
is invoked and call nl_dump_check_consistent() for
each new message. The core code will also call this
function for the final MSG_DONE message.

To make it usable with generic netlink, a new function
genlmsg_nlhdr() is needed to obtain the netlink header
from the genetlink user header.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
Should we merge this through wireless? From wireless-next it'll go into
net-next quickly, but the converse isn't true, so using it in wireless
would be harder if it was merged through net-next I think? Or John can
cherry-pick into wireless-testing?


 include/linux/netlink.h  |    2 ++
 include/net/genetlink.h  |   32 ++++++++++++++++++++++++++++++++
 include/net/netlink.h    |   24 ++++++++++++++++++++++++
 net/netlink/af_netlink.c |    2 ++
 4 files changed, 60 insertions(+)

--- a/include/linux/netlink.h	2011-06-20 08:42:41.000000000 +0200
+++ b/include/linux/netlink.h	2011-06-20 09:39:19.000000000 +0200
@@ -49,6 +49,7 @@ struct nlmsghdr {
 #define NLM_F_MULTI		2	/* Multipart message, terminated by NLMSG_DONE */
 #define NLM_F_ACK		4	/* Reply with ack, with zero or error code */
 #define NLM_F_ECHO		8	/* Echo this request 		*/
+#define NLM_F_DUMP_INTR		16	/* Dump was inconsistent due to sequence change */
 
 /* Modifiers to GET request */
 #define NLM_F_ROOT	0x100	/* specify tree	root	*/
@@ -222,6 +223,7 @@ struct netlink_callback {
 					struct netlink_callback *cb);
 	int			(*done)(struct netlink_callback *cb);
 	int			family;
+	unsigned int		prev_seq, seq;
 	long			args[6];
 };
 
--- a/net/netlink/af_netlink.c	2011-06-20 08:42:41.000000000 +0200
+++ b/net/netlink/af_netlink.c	2011-06-20 09:39:19.000000000 +0200
@@ -1693,6 +1693,8 @@ static int netlink_dump(struct sock *sk)
 	if (!nlh)
 		goto errout_skb;
 
+	nl_dump_check_consistent(cb, nlh);
+
 	memcpy(nlmsg_data(nlh), &len, sizeof(len));
 
 	if (sk_filter(sk, skb))
--- a/include/net/genetlink.h	2011-06-20 08:42:41.000000000 +0200
+++ b/include/net/genetlink.h	2011-06-20 13:36:54.000000000 +0200
@@ -160,6 +160,38 @@ static inline void *genlmsg_put(struct s
 }
 
 /**
+ * genlmsg_nlhdr - Obtain netlink header from user specified header
+ * @user_hdr: user header as returned from genlmsg_put()
+ * @family: generic netlink family
+ *
+ * Returns pointer to netlink header.
+ */
+static inline struct nlmsghdr *genlmsg_nlhdr(void *user_hdr,
+					     struct genl_family *family)
+{
+	return (struct nlmsghdr *)((char *)user_hdr -
+				   family->hdrsize -
+				   GENL_HDRLEN -
+				   NLMSG_HDRLEN);
+}
+
+/**
+ * genl_dump_check_consistent - check if sequence is consistent and advertise if not
+ * @cb: netlink callback structure that stores the sequence number
+ * @user_hdr: user header as returned from genlmsg_put()
+ * @family: generic netlink family
+ *
+ * Cf. nl_dump_check_consistent(), this just provides a wrapper to make it
+ * simpler to use with generic netlink.
+ */
+static inline void genl_dump_check_consistent(struct netlink_callback *cb,
+					      void *user_hdr,
+					      struct genl_family *family)
+{
+	nl_dump_check_consistent(cb, genlmsg_nlhdr(user_hdr, family));
+}
+
+/**
  * genlmsg_put_reply - Add generic netlink header to a reply message
  * @skb: socket buffer holding the message
  * @info: receiver info
--- a/include/net/netlink.h	2011-06-20 08:42:41.000000000 +0200
+++ b/include/net/netlink.h	2011-06-20 09:39:19.000000000 +0200
@@ -638,6 +638,30 @@ static inline int nlmsg_unicast(struct s
 	     nlmsg_ok(pos, rem); \
 	     pos = nlmsg_next(pos, &(rem)))
 
+/**
+ * nl_dump_check_consistent - check if sequence is consistent and advertise if not
+ * @cb: netlink callback structure that stores the sequence number
+ * @nlh: netlink message header to write the flag to
+ *
+ * This function checks if the sequence (generation) number changed during dump
+ * and if it did, advertises it in the netlink message header.
+ *
+ * The correct way to use it is to set cb->seq to the generation counter when
+ * all locks for dumping have been acquired, and then call this function for
+ * each message that is generated.
+ *
+ * Note that due to initialisation concerns, 0 is an invalid sequence number
+ * and must not be used by code that uses this functionality.
+ */
+static inline void
+nl_dump_check_consistent(struct netlink_callback *cb,
+			 struct nlmsghdr *nlh)
+{
+	if (cb->prev_seq && cb->seq != cb->prev_seq)
+		nlh->nlmsg_flags |= NLM_F_DUMP_INTR;
+	cb->prev_seq = cb->seq;
+}
+
 /**************************************************************************
  * Netlink Attributes
  **************************************************************************/


