From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2/2] [NET] Add skb_header_cloned and use it in e1000/tg3
Date: Wed, 16 Feb 2005 07:24:53 +1100
Message-ID: <20050215202453.GA4355@gondor.apana.org.au>
References: <20050122170533.GB11499@yakov.inr.ac.ru> <20050123071027.GA20296@gondor.apana.org.au> <20050126110043.GA29950@yakov.inr.ac.ru> <20050126222522.GA21670@gondor.apana.org.au> <20050127110946.GA20494@gondor.apana.org.au> <20050127111201.GB20494@gondor.apana.org.au> <20050128202542.GA23670@yakov.inr.ac.ru> <20050129031740.GA6130@gondor.apana.org.au> <20050129032210.GA7424@gondor.apana.org.au> <20050215103312.6178385f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050215103312.6178385f.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Feb 15, 2005 at 10:33:12AM -0800, David S. Miller wrote:
> 
> The tg3 version creates an SKB leak.  If pskb_expand_head() fails, we just
> unlock and return NETDEV_TX_OK.  The upper layer assumes the driver took
> ownership of the SKB in such a case.  I would recommend just kfree_skb()'ing
> the thing when this happens.

Indeed.  Here is the corrected version.

This patch adds skb_header_cloned which tells us whether we need to
copy the data before we can modify the header part of the skb.  Again,
what constitutes the header is left up to the users of the skb to define.

This patch then uses this function in e1000/tg3 to copy the data before
the TCP/IP header is modified.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=tso-mangle-2

===== drivers/net/tg3.c 1.241 vs edited =====
--- 1.241/drivers/net/tg3.c	2005-02-12 07:44:48 +11:00
+++ edited/drivers/net/tg3.c	2005-02-16 07:21:33 +11:00
@@ -3096,6 +3096,12 @@
 	    (mss = skb_shinfo(skb)->tso_size) != 0) {
 		int tcp_opt_len, ip_tcp_len;
 
+		if (skb_header_cloned(skb) &&
+		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
+			dev_kfree_skb(skb);
+			goto out_unlock;
+		}
+
 		tcp_opt_len = ((skb->h.th->doff - 5) * 4);
 		ip_tcp_len = (skb->nh.iph->ihl * 4) + sizeof(struct tcphdr);
 
===== drivers/net/e1000/e1000_main.c 1.147 vs edited =====
--- 1.147/drivers/net/e1000/e1000_main.c	2005-01-21 08:24:31 +11:00
+++ edited/drivers/net/e1000/e1000_main.c	2005-01-29 14:11:09 +11:00
@@ -1522,7 +1522,7 @@
 #define E1000_TX_FLAGS_VLAN_MASK	0xffff0000
 #define E1000_TX_FLAGS_VLAN_SHIFT	16
 
-static inline boolean_t
+static inline int
 e1000_tso(struct e1000_adapter *adapter, struct sk_buff *skb)
 {
 #ifdef NETIF_F_TSO
@@ -1531,8 +1531,15 @@
 	uint32_t cmd_length = 0;
 	uint16_t ipcse, tucse, mss;
 	uint8_t ipcss, ipcso, tucss, tucso, hdr_len;
+	int err;
 
 	if(skb_shinfo(skb)->tso_size) {
+		if (skb_header_cloned(skb)) {
+			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+			if (err)
+				return err;
+		}
+
 		hdr_len = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
 		mss = skb_shinfo(skb)->tso_size;
 		skb->nh.iph->tot_len = 0;
@@ -1569,11 +1576,11 @@
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
@@ -1798,6 +1805,7 @@
 	unsigned int nr_frags = 0;
 	unsigned int mss = 0;
 	int count = 0;
+	int tso;
 	unsigned int f;
 	len -= skb->data_len;
 
@@ -1869,7 +1877,13 @@
 
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
===== include/linux/skbuff.h 1.60 vs edited =====
--- 1.60/include/linux/skbuff.h	2005-01-29 14:01:43 +11:00
+++ edited/include/linux/skbuff.h	2005-01-29 14:06:35 +11:00
@@ -395,6 +395,25 @@
 }
 
 /**
+ *	skb_header_cloned - is the header a clone
+ *	@skb: buffer to check
+ *
+ *	Returns true if modifying the header part of the buffer requires
+ *	the data to be copied.
+ */
+static inline int skb_header_cloned(const struct sk_buff *skb)
+{
+	int dataref;
+
+	if (!skb->cloned)
+		return 0;
+
+	dataref = atomic_read(&skb_shinfo(skb)->dataref);
+	dataref = (dataref & SKB_DATAREF_MASK) - (dataref >> SKB_DATAREF_SHIFT);
+	return dataref != 1;
+}
+
+/**
  *	skb_header_release - release reference to header
  *	@skb: buffer to operate on
  *

--oyUTqETQ0mS9luUI--
