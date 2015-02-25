From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 5/8] mpls: Functions for reading and wrinting mpls labels over netlink
Date: Wed, 25 Feb 2015 11:16:36 -0600
Message-ID: <87wq35vrm3.fsf@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:58118 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583AbbBYRUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 12:20:07 -0500
In-Reply-To: <87pp8xx6ik.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 25 Feb 2015 11:09:23 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Reading and writing addresses in network byte order in netlink is
traditional and I see no reason to change that.  MPLS is interesting
as effectively it has variabely length addresses (the MPLS label
stack).  To represent these variable length addresses in netlink
I use a valid MPLS label stack (complete with stop bit).

This achieves two things: a well defined existing format is used,
and the data can be interpreted without looking at it's length.

Not needed to look at the length to decode the variable length
network representation allows existing userspace functions
such as inet_ntop to be used without needed to change their
prototype.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/mpls/af_mpls.c  | 57 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/mpls/internal.h |  3 +++
 2 files changed, 60 insertions(+)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 6a9ef31e0129..75f24609f297 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -398,6 +398,63 @@ static struct notifier_block mpls_dev_notifier = {
 	.notifier_call = mpls_dev_notify,
 };
 
+int nla_put_labels(struct sk_buff *skb, int attrtype,
+		   u8 labels, const u32 label[])
+{
+	struct nlattr *nla;
+	struct mpls_shim_hdr *nla_label;
+	bool bos;
+	int i;
+	nla = nla_reserve(skb, attrtype, labels*4);
+	if (!nla)
+		return -EMSGSIZE;
+
+	nla_label = nla_data(nla);
+	bos = true;
+	for (i = labels - 1; i >= 0; i--) {
+		nla_label[i] = mpls_entry_encode(label[i], 0, 0, bos);
+		bos = false;
+	}
+
+	return 0;
+}
+
+int nla_get_labels(const struct nlattr *nla,
+		   u32 max_labels, u32 *labels, u32 label[])
+{
+	unsigned len = nla_len(nla);
+	unsigned nla_labels;
+	struct mpls_shim_hdr *nla_label;
+	bool bos;
+	int i;
+
+	/* len needs to be an even multiple of 4 (the label size) */
+	if (len & 3)
+		return -EINVAL;
+
+	/* Limit the number of new labels allowed */
+	nla_labels = len/4;
+	if (nla_labels > max_labels)
+		return -EINVAL;
+
+	nla_label = nla_data(nla);
+	bos = true;
+	for (i = nla_labels - 1; i >= 0; i--, bos = false) {
+		struct mpls_entry_decoded dec;
+		dec = mpls_entry_decode(nla_label + i);
+
+		/* Ensure the bottom of stack flag is properly set
+		 * and ttl and tc are both clear.
+		 */
+		if ((dec.bos != bos) || dec.ttl || dec.tc)
+			return -EINVAL;
+
+		label[i] = dec.label;
+	}
+	*labels = nla_labels;
+	return 0;
+}
+
 static int resize_platform_label_table(struct net *net, size_t limit)
 {
 	size_t size = sizeof(struct mpls_route *) * limit;
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index c2944cb84d48..fb6de92052c4 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -53,4 +53,7 @@ static inline struct mpls_entry_decoded mpls_entry_decode(struct mpls_shim_hdr *
 	return result;
 }
 
+int nla_put_labels(struct sk_buff *skb, int attrtype,  u8 labels, const u32 label[]);
+int nla_get_labels(const struct nlattr *nla, u32 max_labels, u32 *labels, u32 label[]);
+
 #endif /* MPLS_INTERNAL_H */
-- 
2.2.1
