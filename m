From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 06/12 -Rev2] rtnetlink changes.
Date: Sun, 22 Jul 2007 14:35:53 +0530
Message-ID: <20070722090553.7787.28728.sendpatchset@K50wks273871wss.in.ibm.com>
References: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org, tgraf@suug.ch, jeff@garzik.org,
	sri@us.ibm.com, hadi@cyberus.ca, kaber@trash.net, mchan@broadcom.com
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

diff -ruNp org/include/linux/if_link.h rev2/include/linux/if_link.h
--- org/include/linux/if_link.h	2007-07-20 16:33:35.000000000 +0530
+++ rev2/include/linux/if_link.h	2007-07-20 16:35:08.000000000 +0530
@@ -78,6 +78,8 @@ enum
 	IFLA_LINKMODE,
 	IFLA_LINKINFO,
 #define IFLA_LINKINFO IFLA_LINKINFO
+	IFLA_TXBTHSKB,		/* Driver support for Batch'd skbs */
+#define IFLA_TXBTHSKB IFLA_TXBTHSKB
 	__IFLA_MAX
 };
 
diff -ruNp org/net/core/rtnetlink.c rev2/net/core/rtnetlink.c
--- org/net/core/rtnetlink.c	2007-07-20 16:31:59.000000000 +0530
+++ rev2/net/core/rtnetlink.c	2007-07-21 22:27:10.000000000 +0530
@@ -634,6 +634,7 @@ static int rtnl_fill_ifinfo(struct sk_bu
 
 	NLA_PUT_STRING(skb, IFLA_IFNAME, dev->name);
 	NLA_PUT_U32(skb, IFLA_TXQLEN, dev->tx_queue_len);
+	NLA_PUT_U32(skb, IFLA_TXBTHSKB, BATCHING_ON(dev));
 	NLA_PUT_U32(skb, IFLA_WEIGHT, dev->weight);
 	NLA_PUT_U8(skb, IFLA_OPERSTATE,
 		   netif_running(dev) ? dev->operstate : IF_OPER_DOWN);
@@ -833,7 +834,8 @@ static int do_setlink(struct net_device 
 
 	if (tb[IFLA_TXQLEN])
 		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
-
+	if (tb[IFLA_TXBTHSKB])
+		dev_change_tx_batching(dev, nla_get_u32(tb[IFLA_TXBTHSKB]));
 	if (tb[IFLA_WEIGHT])
 		dev->weight = nla_get_u32(tb[IFLA_WEIGHT]);
 
@@ -1072,6 +1074,9 @@ replay:
 			       nla_len(tb[IFLA_BROADCAST]));
 		if (tb[IFLA_TXQLEN])
 			dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
+		if (tb[IFLA_TXBTHSKB])
+			dev_change_tx_batching(dev,
+					       nla_get_u32(tb[IFLA_TXBTHSKB]));
 		if (tb[IFLA_WEIGHT])
 			dev->weight = nla_get_u32(tb[IFLA_WEIGHT]);
 		if (tb[IFLA_OPERSTATE])
