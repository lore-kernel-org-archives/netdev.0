From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] DSA support for Micrel KSZ8895
Date: Sun, 27 Aug 2017 18:44:34 +0200
Message-ID: <20170827164434.GH13622@lunn.ch>
References: <20170816075524.GA18532@amd>
 <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170827123658.GA727@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Woojung.Huh@microchip.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tristram.Ha@micrel.com
To: Pavel Machek <pavel@denx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170827123658.GA727@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> No, tag_ksz part probably is not acceptable. Do you see solution
> better than just copying it into tag_ksz1 file?

How about something like this, which needs further work to actually
compile, but should give you the idea.

	 Andrew

index 99e38af85fc5..843e77b7c270 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -49,8 +49,11 @@ const struct dsa_device_ops *dsa_device_ops[DSA_TAG_LAST] = {
 #ifdef CONFIG_NET_DSA_TAG_EDSA
        [DSA_TAG_PROTO_EDSA] = &edsa_netdev_ops,
 #endif
-#ifdef CONFIG_NET_DSA_TAG_KSZ
-       [DSA_TAG_PROTO_KSZ] = &ksz_netdev_ops,
+#ifdef CONFIG_NET_DSA_TAG_KSZ_8K
+       [DSA_TAG_PROTO_KSZ8K] = &ksz8k_netdev_ops,
+#endif
+#ifdef CONFIG_NET_DSA_TAG_KSZ_9K
+       [DSA_TAG_PROTO_KSZ9K] = &ksz9k_netdev_ops,
 #endif
 #ifdef CONFIG_NET_DSA_TAG_LAN9303
        [DSA_TAG_PROTO_LAN9303] = &lan9303_netdev_ops,
diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
index de66ca8e6201..398b833889f1 100644
--- a/net/dsa/tag_ksz.c
+++ b/net/dsa/tag_ksz.c
@@ -35,6 +35,9 @@
 static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
 {
        struct dsa_slave_priv *p = netdev_priv(dev);
+       struct dsa_port *dp = p->dp;
+       struct dsa_switch *ds = dp->ds;
+       struct dsa_switch_tree *dst = ds->dst;
        struct sk_buff *nskb;
        int padlen;
        u8 *tag;
@@ -69,8 +72,14 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
        }
 
        tag = skb_put(nskb, KSZ_INGRESS_TAG_LEN);
-       tag[0] = 0;
-       tag[1] = 1 << p->dp->index; /* destination port */
+       if (dst->tag_ops == ksz8k_netdev_ops) {
+               tag[0] = 1 << p->dp->index; /* destination port */0;
+               tag[1] = 0;
+       }
+
+       if (dst->tag_ops == ksz9k_netdev_ops) {
+               tag[0] = 0;
+               tag[1] = 1 << p->dp->index; /* destination port */
 
        return nskb;
 }
@@ -98,7 +107,12 @@ static struct sk_buff *ksz_rcv(struct sk_buff *skb, struct net_device *dev,
        return skb;
 }
 
-const struct dsa_device_ops ksz_netdev_ops = {
+const struct dsa_device_ops ksz8k_netdev_ops = {
+       .xmit   = ksz_xmit,
+       .rcv    = ksz_rcv,
+};
+
+const struct dsa_device_ops ksz9k_netdev_ops = {
        .xmit   = ksz_xmit,
        .rcv    = ksz_rcv,
 };
