From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 19 Apr 2016 19:50:09 -0400 (EDT)
Message-ID: <20160419.195009.1052027353987244150.davem@davemloft.net>
References: <20160419.143134.2014460805657420897.davem@davemloft.net>
	<1461091667.10638.229.camel@edumazet-glaptop3.roam.corp.google.com>
	<57168225.2040507@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, roopa@cumulusnetworks.com,
	netdev@vger.kernel.org, jhs@mojatatu.com, tgraf@suug.ch
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753807AbcDSXuN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 19:50:13 -0400
In-Reply-To: <57168225.2040507@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 19 Apr 2016 21:08:21 +0200

> Le 19/04/2016 20:47, Eric Dumazet a =E9crit :
>> Since we want to use this in other places, we could define a helper.
>>
>> nla_align_64bit(skb, attribute)  or something.
> Yes, with the corresponding nla_total_size_64bit()

Good, idea, committed the following:

Roopa, please use these helpers in your RTM_GETSTATS patch.

Thank you.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[PATCH] net: Add helpers for 64-bit aligning netlink attributes.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Suggested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/netlink.h | 37 +++++++++++++++++++++++++++++++++++++
 net/core/rtnetlink.c  | 24 +++++-------------------
 2 files changed, 42 insertions(+), 19 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 0e31727..e644b34 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -1231,6 +1231,43 @@ static inline int nla_validate_nested(const stru=
ct nlattr *start, int maxtype,
 }
=20
 /**
+ * nla_align_64bit - 64-bit align the nla_data() of next attribute
+ * @skb: socket buffer the message is stored in
+ * @padattr: attribute type for the padding
+ *
+ * Conditionally emit a padding netlink attribute in order to make
+ * the next attribute we emit have a 64-bit aligned nla_data() area.
+ * This will only be done in architectures which do not have
+ * HAVE_EFFICIENT_UNALIGNED_ACCESS defined.
+ *
+ * Returns zero on success or a negative error code.
+ */
+static inline int nla_align_64bit(struct sk_buff *skb, int padattr)
+{
+#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
+	if (IS_ALIGNED((unsigned long)skb->data, 8)) {
+		struct nlattr *attr =3D nla_reserve(skb, padattr, 0);
+		if (!attr)
+			return -EMSGSIZE;
+	}
+#endif
+	return 0;
+}
+
+/**
+ * nla_total_size_64bit - total length of attribute including padding
+ * @payload: length of payload
+ */
+static inline int nla_total_size_64bit(int payload)
+{
+	return NLA_ALIGN(nla_attr_size(payload))
+#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
+		+ NLA_ALIGN(nla_attr_size(0))
+#endif
+		;
+}
+
+/**
  * nla_for_each_attr - iterate over a stream of attributes
  * @pos: loop counter, set to current attribute
  * @head: head of attribute stream
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 198ca2c..d3694a1 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -878,10 +878,7 @@ static noinline size_t if_nlmsg_size(const struct =
net_device *dev,
 	       + nla_total_size(IFNAMSIZ) /* IFLA_QDISC */
 	       + nla_total_size(sizeof(struct rtnl_link_ifmap))
 	       + nla_total_size(sizeof(struct rtnl_link_stats))
-#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
-	       + nla_total_size(0) /* IFLA_PAD */
-#endif
-	       + nla_total_size(sizeof(struct rtnl_link_stats64))
+	       + nla_total_size_64bit(sizeof(struct rtnl_link_stats64))
 	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_ADDRESS */
 	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_BROADCAST */
 	       + nla_total_size(4) /* IFLA_TXQLEN */
@@ -1054,22 +1051,11 @@ static noinline_for_stack int rtnl_fill_stats(s=
truct sk_buff *skb,
 {
 	struct rtnl_link_stats64 *sp;
 	struct nlattr *attr;
+	int err;
=20
-#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
-	/* IF necessary, add a zero length NOP attribute so that the
-	 * nla_data() of the IFLA_STATS64 will be 64-bit aligned.
-	 *
-	 * The nlattr header is 4 bytes in size, that's why we test
-	 * if the skb->data _is_ aligned.  This NOP attribute, plus
-	 * nlattr header for IFLA_STATS64, will make nla_data() 8-byte
-	 * aligned.
-	 */
-	if (IS_ALIGNED((unsigned long)skb->data, 8)) {
-		attr =3D nla_reserve(skb, IFLA_PAD, 0);
-		if (!attr)
-			return -EMSGSIZE;
-	}
-#endif
+	err =3D nla_align_64bit(skb, IFLA_PAD);
+	if (err)
+		return err;
=20
 	attr =3D nla_reserve(skb, IFLA_STATS64,
 			   sizeof(struct rtnl_link_stats64));
--=20
2.1.0
