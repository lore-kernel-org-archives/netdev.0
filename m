From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 06/11] VXLAN: Add option to mangle IP IDs on inner
 headers when using TSO
Date: Thu, 07 Apr 2016 18:32:30 -0400
Message-ID: <20160407223230.11142.93193.stgit@ahduyck-xeon-server>
References: <20160407222211.11142.41024.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36815 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932107AbcDGWce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 18:32:34 -0400
Received: by mail-pa0-f43.google.com with SMTP id bx7so46402137pad.3
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 15:32:34 -0700 (PDT)
In-Reply-To: <20160407222211.11142.41024.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for a feature I am calling IP ID mangling.  It is
basically just another way of saying the IP IDs that are transmitted by the
tunnel may not match up with what would normally be expected.  Specifically
what will happen is in the case of TSO the IP IDs on the headers will be a
fixed value so a given TSO will repeat the same inner IP ID value gso_segs
number of times.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/vxlan.c          |   16 ++++++++++++++++
 include/net/vxlan.h          |    1 +
 include/uapi/linux/if_link.h |    1 +
 3 files changed, 18 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 51cccddfe403..cc903ab832c2 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1783,6 +1783,10 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 			type |= SKB_GSO_TUNNEL_REMCSUM;
 	}
 
+	if ((vxflags & VXLAN_F_TCP_FIXEDID) && skb_is_gso(skb) &&
+	    (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4))
+		type |= SKB_GSO_TCP_FIXEDID;
+
 	min_headroom = LL_RESERVED_SPACE(dst->dev) + dst->header_len
 			+ VXLAN_HLEN + iphdr_len
 			+ (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
@@ -2635,6 +2639,7 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_GBP]	= { .type = NLA_FLAG, },
 	[IFLA_VXLAN_GPE]	= { .type = NLA_FLAG, },
 	[IFLA_VXLAN_REMCSUM_NOPARTIAL]	= { .type = NLA_FLAG },
+	[IFLA_VXLAN_IPID_MANGLE]	= { .type = NLA_FLAG },
 };
 
 static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -3092,6 +3097,9 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	if (data[IFLA_VXLAN_REMCSUM_NOPARTIAL])
 		conf.flags |= VXLAN_F_REMCSUM_NOPARTIAL;
 
+	if (data[IFLA_VXLAN_IPID_MANGLE])
+		conf.flags |= VXLAN_F_TCP_FIXEDID;
+
 	err = vxlan_dev_configure(src_net, dev, &conf);
 	switch (err) {
 	case -ENODEV:
@@ -3154,6 +3162,10 @@ static size_t vxlan_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(__u8)) + /* IFLA_VXLAN_UDP_ZERO_CSUM6_RX */
 		nla_total_size(sizeof(__u8)) + /* IFLA_VXLAN_REMCSUM_TX */
 		nla_total_size(sizeof(__u8)) + /* IFLA_VXLAN_REMCSUM_RX */
+		nla_total_size(0) +	       /* IFLA_VXLAN_GBP */
+		nla_total_size(0) +	       /* IFLA_VXLAN_GPE */
+		nla_total_size(0) +	       /* IFLA_VXLAN_REMCSUM_NOPARTIAL */
+		nla_total_size(0) +	       /* IFLA_VXLAN_IPID_MANGLE */
 		0;
 }
 
@@ -3244,6 +3256,10 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_flag(skb, IFLA_VXLAN_REMCSUM_NOPARTIAL))
 		goto nla_put_failure;
 
+	if (vxlan->flags & VXLAN_F_TCP_FIXEDID &&
+	    nla_put_flag(skb, IFLA_VXLAN_IPID_MANGLE))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index dcc6f4057115..5c2dc9ecea59 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -265,6 +265,7 @@ struct vxlan_dev {
 #define VXLAN_F_REMCSUM_NOPARTIAL	0x1000
 #define VXLAN_F_COLLECT_METADATA	0x2000
 #define VXLAN_F_GPE			0x4000
+#define VXLAN_F_TCP_FIXEDID		0x8000
 
 /* Flags that are used in the receive path. These flags must match in
  * order for a socket to be shareable
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 9427f17d06d6..a3bc3f2a63d3 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -489,6 +489,7 @@ enum {
 	IFLA_VXLAN_COLLECT_METADATA,
 	IFLA_VXLAN_LABEL,
 	IFLA_VXLAN_GPE,
+	IFLA_VXLAN_IPID_MANGLE,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
