From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 4/8] net: ife: Introduce packet info packing method
Date: Mon, 14 Nov 2016 16:00:34 +0100
Message-ID: <1479135638-3580-5-git-send-email-jiri@resnulli.us>
References: <1479135638-3580-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com,
        john.fastabend@gmail.com, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36042 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932303AbcKNPAq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 10:00:46 -0500
Received: by mail-wm0-f67.google.com with SMTP id m203so16035213wma.3
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 07:00:45 -0800 (PST)
In-Reply-To: <1479135638-3580-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Add the ife_packet_info_pack function which encodes some informative
metadata into a packet using the ife encapsulation. The informative
metadata consists of:
 - The packet input/output ifindices
 - The packet original size, in case it was truncated

This method is useful for anyone that wants to pass informative metadata
on a packet alongside with the packet itself. A good usage can be packet
sampling.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/ife.h | 10 ++++++++++
 net/ife/ife.c     | 45 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+)

diff --git a/include/net/ife.h b/include/net/ife.h
index a75d4e0..5fbcfb3 100644
--- a/include/net/ife.h
+++ b/include/net/ife.h
@@ -18,6 +18,9 @@ int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen,
 
 void *ife_tlv_meta_next(void *skbdata);
 
+struct ethhdr *ife_packet_info_pack(struct sk_buff *skb, int orig_size,
+				    int in_ifindex, int out_ifindex);
+
 #else
 
 static inline void *ife_encode(struct sk_buff *skb, u16 metalen)
@@ -47,6 +50,13 @@ static inline void *ife_tlv_meta_next(void *skbdata)
 	return NULL;
 }
 
+static inline struct ethhdr *
+ife_packet_info_pack(struct sk_buff *skb, int orig_size, int in_ifindex,
+		     int out_ifindex)
+{
+	return NULL;
+}
+
 #endif
 
 #endif /* __NET_IFE_H */
diff --git a/net/ife/ife.c b/net/ife/ife.c
index 3642f43..f0b683e 100644
--- a/net/ife/ife.c
+++ b/net/ife/ife.c
@@ -138,6 +138,51 @@ int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen, const void *dval)
 }
 EXPORT_SYMBOL_GPL(ife_tlv_meta_encode);
 
+struct ethhdr *ife_packet_info_pack(struct sk_buff *skb, int orig_size,
+				    int in_ifindex, int out_ifindex)
+{
+	int curr_size;
+	void *ifetlv;
+	u16 metalen;
+
+	curr_size = skb->len;
+
+	metalen = nla_total_size(sizeof(orig_size)) +
+		  nla_total_size(sizeof(curr_size));
+
+	if (in_ifindex)
+		metalen += nla_total_size(sizeof(in_ifindex));
+	if (out_ifindex)
+		metalen += nla_total_size(sizeof(out_ifindex));
+
+	in_ifindex = htonl(in_ifindex);
+	out_ifindex = htonl(out_ifindex);
+	orig_size = htonl(orig_size);
+	curr_size = htonl(curr_size);
+
+	ifetlv = ife_encode(skb, metalen);
+	if (!ifetlv)
+		return NULL;
+
+	if (in_ifindex)
+		ifetlv += ife_tlv_meta_encode(ifetlv, IFE_META_IN_IFINDEX,
+					      sizeof(in_ifindex), &in_ifindex);
+
+	if (out_ifindex)
+		ifetlv += ife_tlv_meta_encode(ifetlv, IFE_META_OUT_IFINDEX,
+					      sizeof(out_ifindex),
+					      &out_ifindex);
+
+	ifetlv += ife_tlv_meta_encode(ifetlv, IFE_META_ORIGSIZE,
+				      sizeof(orig_size), &orig_size);
+
+	ifetlv += ife_tlv_meta_encode(ifetlv, IFE_META_SIZE,
+				      sizeof(curr_size), &curr_size);
+
+	return (struct ethhdr *) skb->data;
+}
+EXPORT_SYMBOL(ife_packet_info_pack);
+
 MODULE_AUTHOR("Jamal Hadi Salim <jhs@mojatatu.com>");
 MODULE_AUTHOR("Yotam Gigi <yotamg@mellanox.com>");
 MODULE_DESCRIPTION("Inter-FE LFB action");
-- 
2.7.4
