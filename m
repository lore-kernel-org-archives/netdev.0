From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/8] netfilter: ctnetlink: Fix regression in CTA_STATUS processing
Date: Thu, 23 Feb 2017 12:14:03 +0100
Message-ID: <1487848449-2731-3-git-send-email-pablo@netfilter.org>
References: <1487848449-2731-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54916 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751049AbdBWLOX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 06:14:23 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 5B25CA4176
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 12:14:21 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 482BFDA85F
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 12:14:21 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 06FD5DA86E
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 12:14:17 +0100 (CET)
In-Reply-To: <1487848449-2731-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Cernekee <cernekee@chromium.org>

The libnetfilter_conntrack userland library always sets IPS_CONFIRMED
when building a CTA_STATUS attribute.  If this toggles the bit from
0->1, the parser will return an error.  On Linux 4.4+ this will cause any
NFQA_EXP attribute in the packet to be ignored.  This breaks conntrackd's
userland helpers because they operate on unconfirmed connections.

Instead of returning -EBUSY if the user program asks to modify an
unchangeable bit, simply ignore the change.

Also, fix the logic so that user programs are allowed to clear
the bits that they are allowed to change.

Signed-off-by: Kevin Cernekee <cernekee@chromium.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_conntrack_common.h |  4 ++++
 net/netfilter/nf_conntrack_netlink.c               | 26 +++++++++++++++++++++-
 2 files changed, 29 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/netfilter/nf_conntrack_common.h b/include/uapi/linux/netfilter/nf_conntrack_common.h
index 6d074d14ee27..6a8e33dd4ecb 100644
--- a/include/uapi/linux/netfilter/nf_conntrack_common.h
+++ b/include/uapi/linux/netfilter/nf_conntrack_common.h
@@ -82,6 +82,10 @@ enum ip_conntrack_status {
 	IPS_DYING_BIT = 9,
 	IPS_DYING = (1 << IPS_DYING_BIT),
 
+	/* Bits that cannot be altered from userland. */
+	IPS_UNCHANGEABLE_MASK = (IPS_NAT_DONE_MASK | IPS_NAT_MASK |
+				 IPS_EXPECTED | IPS_CONFIRMED | IPS_DYING),
+
 	/* Connection has fixed timeout. */
 	IPS_FIXED_TIMEOUT_BIT = 10,
 	IPS_FIXED_TIMEOUT = (1 << IPS_FIXED_TIMEOUT_BIT),
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 27540455dc62..bf04b7e9d6f7 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2270,6 +2270,30 @@ ctnetlink_glue_build(struct sk_buff *skb, struct nf_conn *ct,
 }
 
 static int
+ctnetlink_update_status(struct nf_conn *ct, const struct nlattr * const cda[])
+{
+	unsigned int status = ntohl(nla_get_be32(cda[CTA_STATUS]));
+	unsigned long d = ct->status ^ status;
+
+	if (d & IPS_SEEN_REPLY && !(status & IPS_SEEN_REPLY))
+		/* SEEN_REPLY bit can only be set */
+		return -EBUSY;
+
+	if (d & IPS_ASSURED && !(status & IPS_ASSURED))
+		/* ASSURED bit can only be set */
+		return -EBUSY;
+
+	/* This check is less strict than ctnetlink_change_status()
+	 * because callers often flip IPS_EXPECTED bits when sending
+	 * an NFQA_CT attribute to the kernel.  So ignore the
+	 * unchangeable bits but do not error out.
+	 */
+	ct->status = (status & ~IPS_UNCHANGEABLE_MASK) |
+		     (ct->status & IPS_UNCHANGEABLE_MASK);
+	return 0;
+}
+
+static int
 ctnetlink_glue_parse_ct(const struct nlattr *cda[], struct nf_conn *ct)
 {
 	int err;
@@ -2280,7 +2304,7 @@ ctnetlink_glue_parse_ct(const struct nlattr *cda[], struct nf_conn *ct)
 			return err;
 	}
 	if (cda[CTA_STATUS]) {
-		err = ctnetlink_change_status(ct, cda);
+		err = ctnetlink_update_status(ct, cda);
 		if (err < 0)
 			return err;
 	}
-- 
2.1.4
