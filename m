From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 4/8] mpls: Basic support for adding and removing routes
Date: Wed, 25 Feb 2015 11:16:08 -0600
Message-ID: <87385tx67b.fsf@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:49960 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbbBYRTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 12:19:37 -0500
In-Reply-To: <87pp8xx6ik.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 25 Feb 2015 11:09:23 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


mpls_route_add and mpls_route_del implement the basic logic for adding
and removing Next Hop Label Forwarding Entries from the MPLS input
label map.  The addition and subtraction is done in a way that is
consistent with how the existing routing table in Linux are
maintained.  Thus all of the work to deal with NLM_F_APPEND,
NLM_F_EXCL, NLM_F_REPLACE, and NLM_F_CREATE.

Cases that are not clearly defined such as changing the interpretation
of the mpls reserved labels is not allowed.

Because it seems like the right thing to do adding an MPLS route without
specifying an input label and allowing the kernel to pick a free label
table entry is supported.   The implementation is currently less than optimal
but that can be changed.

As I don't have anything else to test with only ethernet and the loopback
device are the only two device types currently supported for forwarding
MPLS over.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/mpls/af_mpls.c | 134 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 134 insertions(+)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index d49a54ea288e..6a9ef31e0129 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -16,6 +16,7 @@
 #include <net/netns/generic.h>
 #include "internal.h"
 
+#define LABEL_NOT_SPECIFIED (1<<20)
 #define MAX_NEW_LABELS 2
 
 /* This maximum ha length copied from the definition of struct neighbour */
@@ -205,6 +206,18 @@ static struct packet_type mpls_packet_type __read_mostly = {
 	.func = mpls_forward,
 };
 
+struct mpls_route_config {
+	u32		rc_protocol;
+	u32		rc_ifindex;
+	u32		rc_ha_len;
+	u8		rc_ha[MAX_HA_LEN];
+	u32		rc_label;
+	u32		rc_output_labels;
+	u32		rc_output_label[MAX_NEW_LABELS];
+	u32		rc_nlflags;
+	struct nl_info	rc_nlinfo;
+};
+
 static struct mpls_route *mpls_rt_alloc(void)
 {
 	struct mpls_route *rt;
@@ -237,6 +250,127 @@ static void mpls_route_update(struct net *net, unsigned index,
 	mpls_rt_free(old);
 }
 
+static unsigned find_free_label(struct net *net)
+{
+	unsigned index;
+	for (index = 16; index < net->mpls.platform_labels; index++) {
+		if (!net->mpls.platform_label[index])
+			return index;
+	}
+	return LABEL_NOT_SPECIFIED;
+}
+
+static int mpls_route_add(struct mpls_route_config *cfg)
+{
+	struct net *net = cfg->rc_nlinfo.nl_net;
+	struct net_device *dev = NULL;
+	struct mpls_route *rt, *old;
+	unsigned index;
+	int i;
+	int err = -EINVAL;
+
+	index = cfg->rc_label;
+
+	/* If a label was not specified during insert pick one */
+	if ((index == LABEL_NOT_SPECIFIED) &&
+	    (cfg->rc_nlflags & NLM_F_CREATE)) {
+		index = find_free_label(net);
+	}
+
+	/* The first 16 labels are reserved, and may not be set */
+	if (index < 16)
+		goto errout;
+
+	/* The full 20 bit range may not be supported. */
+	if (index >= net->mpls.platform_labels)
+		goto errout;
+
+	/* Ensure only a supported number of labels are present */
+	if (cfg->rc_output_labels > MAX_NEW_LABELS)
+		goto errout;
+
+	err = -ENODEV;
+	dev = dev_get_by_index(net, cfg->rc_ifindex);
+	if (!dev)
+		goto errout;
+
+	err = -ENETDOWN;
+	if (!(dev->flags & IFF_UP))
+		goto errout;
+
+	/* For now just support ethernet devices */
+	err = -EINVAL;
+	if ((dev->type != ARPHRD_ETHER) && (dev->type != ARPHRD_LOOPBACK))
+		goto errout;
+
+	err = -EINVAL;
+	if (dev->addr_len != cfg->rc_ha_len)
+		goto errout;
+
+	/* Append makes no sense with mpls */
+	err = -EINVAL;
+	if (cfg->rc_nlflags & NLM_F_APPEND)
+		goto errout;
+
+	err = -EEXIST;
+	old = net->mpls.platform_label[index];
+	if ((cfg->rc_nlflags & NLM_F_EXCL) && old)
+		goto errout;
+
+	err = -EEXIST;
+	if (!(cfg->rc_nlflags & NLM_F_REPLACE) && old)
+		goto errout;
+
+	err = -ENOENT;
+	if (!(cfg->rc_nlflags & NLM_F_CREATE) && !old)
+		goto errout;
+
+	err = -ENOMEM;
+	rt = mpls_rt_alloc();
+	if (!rt)
+		goto errout;
+
+	rt->rt_labels = cfg->rc_output_labels;
+	for (i = 0; i < rt->rt_labels; i++)
+		rt->rt_label[i] = cfg->rc_output_label[i];
+	rt->rt_protocol = cfg->rc_protocol;
+	rt->rt_dev = dev;
+	memcpy(rt->rt_ha, cfg->rc_ha, dev->addr_len);
+
+	mpls_route_update(net, index, NULL, rt, &cfg->rc_nlinfo);
+
+	dev_put(dev);
+	return 0;
+
+errout:
+	if (dev)
+		dev_put(dev);
+	return err;
+}
+
+static int mpls_route_del(struct mpls_route_config *cfg)
+{
+	struct net *net = cfg->rc_nlinfo.nl_net;
+	unsigned index;
+	int err = -EINVAL;
+
+	index = cfg->rc_label;
+
+	/* The first 16 labels are reserved, and may not be removed */
+	if (index < 16)
+		goto errout;
+
+	/* The full 20 bit range may not be supported */
+	if (index >= net->mpls.platform_labels)
+		goto errout;
+
+	mpls_route_update(net, index, NULL, NULL, &cfg->rc_nlinfo);
+
+	err = 0;
+errout:
+	return err;
+}
+
 static void mpls_ifdown(struct net_device *dev)
 {
 	struct net *net = dev_net(dev);
-- 
2.2.1
