From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET] Check skb_header_cloned for TSO packets in ixgb
Date: Thu, 24 Feb 2005 21:29:51 +1100
Message-ID: <20050224102951.GA23562@gondor.apana.org.au>
References: <20050126110043.GA29950@yakov.inr.ac.ru> <20050126222522.GA21670@gondor.apana.org.au> <20050127110946.GA20494@gondor.apana.org.au> <20050127111201.GB20494@gondor.apana.org.au> <20050128202542.GA23670@yakov.inr.ac.ru> <20050129031740.GA6130@gondor.apana.org.au> <20050129032210.GA7424@gondor.apana.org.au> <20050215103312.6178385f.davem@davemloft.net> <20050215202453.GA4355@gondor.apana.org.au> <20050223195137.1e769c77.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="3V7upXqbjpZ4EhLz"
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050223195137.1e769c77.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Feb 23, 2005 at 07:51:37PM -0800, David S. Miller wrote:
> 
> Also queued to 2.6.12, thanks.  Someone should cook up the versions
> for other drivers supporting TSO.

I only found one other TSO driver that touches the headers, ixgb.
Here is the patch which adds an skb_header_cloned check to it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Do you know of any others?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== drivers/net/ixgb/ixgb_main.c 1.33 vs edited =====
--- 1.33/drivers/net/ixgb/ixgb_main.c	2005-01-11 16:03:21 +11:00
+++ edited/drivers/net/ixgb/ixgb_main.c	2005-02-24 21:26:48 +11:00
@@ -1155,7 +1155,7 @@
 #define IXGB_TX_FLAGS_VLAN		0x00000002
 #define IXGB_TX_FLAGS_TSO		0x00000004
 
-static inline boolean_t
+static inline int
 ixgb_tso(struct ixgb_adapter *adapter, struct sk_buff *skb)
 {
 #ifdef NETIF_F_TSO
@@ -1163,8 +1163,15 @@
 	unsigned int i;
 	uint8_t ipcss, ipcso, tucss, tucso, hdr_len;
 	uint16_t ipcse, tucse, mss;
+	int err;
 
 	if(likely(skb_shinfo(skb)->tso_size)) {
+		if (skb_header_cloned(skb)) {
+			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+			if (err)
+				return err;
+		}
+
 		hdr_len = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
 		mss = skb_shinfo(skb)->tso_size;
 		skb->nh.iph->tot_len = 0;
@@ -1203,11 +1210,11 @@
 		if(++i == adapter->tx_ring.count) i = 0;
 		adapter->tx_ring.next_to_use = i;
 
-		return TRUE;
+		return 1;
 	}
 #endif
 
-	return FALSE;
+	return 0;
 }
 
 static inline boolean_t
@@ -1378,6 +1385,7 @@
 	unsigned int tx_flags = 0;
 	unsigned long flags;
 	int vlan_id = 0;
+	int tso;
 
 	if(skb->len <= 0) {
 		dev_kfree_skb_any(skb);
@@ -1399,7 +1407,13 @@
 
 	first = adapter->tx_ring.next_to_use;
 	
-	if(ixgb_tso(adapter, skb))
+	tso = ixgb_tso(adapter, skb);
+	if (tso < 0) {
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
+	if (tso)
 		tx_flags |= IXGB_TX_FLAGS_TSO;
 	else if(ixgb_tx_csum(adapter, skb))
 		tx_flags |= IXGB_TX_FLAGS_CSUM;

--3V7upXqbjpZ4EhLz--
