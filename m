From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: the TSO packet mangling issue
Date: Thu, 27 Jan 2005 22:12:01 +1100
Message-ID: <20050127111201.GB20494@gondor.apana.org.au>
References: <20050121204024.6f94fc26.davem@davemloft.net> <20050122054346.GA1635@gondor.apana.org.au> <20050122170533.GB11499@yakov.inr.ac.ru> <20050123071027.GA20296@gondor.apana.org.au> <20050126110043.GA29950@yakov.inr.ac.ru> <20050126222522.GA21670@gondor.apana.org.au> <20050127110946.GA20494@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="8P1HSweYDcXXzwPJ"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20050127110946.GA20494@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--8P1HSweYDcXXzwPJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This patch adds tcp_skb_cow() and uses it in e1000/tg3.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--8P1HSweYDcXXzwPJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=tso-mangle-2

===== drivers/net/tg3.c 1.231 vs edited =====
--- 1.231/drivers/net/tg3.c	2005-01-23 14:41:32 +11:00
+++ edited/drivers/net/tg3.c	2005-01-27 21:57:09 +11:00
@@ -32,6 +32,7 @@
 #include <linux/workqueue.h>
 
 #include <net/checksum.h>
+#include <net/tcp.h>
 
 #include <asm/system.h>
 #include <asm/io.h>
@@ -3102,6 +3103,9 @@
 	if (skb->len > (tp->dev->mtu + ETH_HLEN) &&
 	    (mss = skb_shinfo(skb)->tso_size) != 0) {
 		int tcp_opt_len, ip_tcp_len;
+
+		if (tcp_skb_cow(skb))
+			goto out_unlock;
 
 		tcp_opt_len = ((skb->h.th->doff - 5) * 4);
 		ip_tcp_len = (skb->nh.iph->ihl * 4) + sizeof(struct tcphdr);
===== drivers/net/e1000/e1000.h 1.60 vs edited =====
--- 1.60/drivers/net/e1000/e1000.h	2005-01-21 08:24:31 +11:00
+++ edited/drivers/net/e1000/e1000.h	2005-01-27 21:57:09 +11:00
@@ -67,6 +67,7 @@
 #include <linux/reboot.h>
 #ifdef NETIF_F_TSO
 #include <net/checksum.h>
+#include <net/tcp.h>
 #endif
 #include <linux/workqueue.h>
 #include <linux/mii.h>
===== drivers/net/e1000/e1000_main.c 1.147 vs edited =====
--- 1.147/drivers/net/e1000/e1000_main.c	2005-01-21 08:24:31 +11:00
+++ edited/drivers/net/e1000/e1000_main.c	2005-01-27 21:57:09 +11:00
@@ -1522,7 +1522,7 @@
 #define E1000_TX_FLAGS_VLAN_MASK	0xffff0000
 #define E1000_TX_FLAGS_VLAN_SHIFT	16
 
-static inline boolean_t
+static inline int
 e1000_tso(struct e1000_adapter *adapter, struct sk_buff *skb)
 {
 #ifdef NETIF_F_TSO
@@ -1531,8 +1531,13 @@
 	uint32_t cmd_length = 0;
 	uint16_t ipcse, tucse, mss;
 	uint8_t ipcss, ipcso, tucss, tucso, hdr_len;
+	int err;
 
 	if(skb_shinfo(skb)->tso_size) {
+		err = tcp_skb_cow(skb);
+		if (err)
+			return err;
+
 		hdr_len = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
 		mss = skb_shinfo(skb)->tso_size;
 		skb->nh.iph->tot_len = 0;
@@ -1569,11 +1574,11 @@
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
@@ -1798,6 +1803,7 @@
 	unsigned int nr_frags = 0;
 	unsigned int mss = 0;
 	int count = 0;
+	int tso;
 	unsigned int f;
 	len -= skb->data_len;
 
@@ -1869,7 +1875,13 @@
 
 	first = adapter->tx_ring.next_to_use;
 	
-	if(likely(e1000_tso(adapter, skb)))
+	tso = e1000_tso(adapter, skb);
+	if (tso < 0) {
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
+	if (likely(tso))
 		tx_flags |= E1000_TX_FLAGS_TSO;
 	else if(likely(e1000_tx_csum(adapter, skb)))
 		tx_flags |= E1000_TX_FLAGS_CSUM;
===== include/net/tcp.h 1.104 vs edited =====
--- 1.104/include/net/tcp.h	2005-01-27 21:43:07 +11:00
+++ edited/include/net/tcp.h	2005-01-27 21:57:19 +11:00
@@ -1243,6 +1243,25 @@
 	sk_stream_free_skb(sk, skb);
 }
 
+/* Return an skb which is writeable up to the point where the
+ * TCP payload starts.
+ */
+static inline int tcp_skb_cow(struct sk_buff *skb)
+{
+	int dataref;
+
+	if (!skb->cloned)
+		return 0;
+
+	dataref = atomic_read(&skb_shinfo(skb)->dataref);
+	dataref -= !!(dataref & SKB_DATAREF_TCP);
+	dataref &= SKB_DATAREF_MASK;
+	if (dataref == 1)
+		return 0;
+
+	return pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+}
+
 /*
  * Which congestion algorithim is in use on the connection.
  */

--8P1HSweYDcXXzwPJ--
