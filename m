From: acme@ghostprotocols.net (Arnaldo Carvalho de Melo)
Subject: [PATCH 2/2][AX25] make ax25_queue_xmit a net_device parameter
Date: Mon, 4 Apr 2005 16:50:30 -0300
Message-ID: <20050404195030.GJ640@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="7ZAtKRhVyVSsbBD2"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        Ralf Baechle <ralf@linux-mips.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--7ZAtKRhVyVSsbBD2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi David, Ralf,

	I'm trying to get back to the work of reducing the number of direct
references to skb->{h,nh,raw}, that eventually will become just a void
pointer.

	Available at:

bk://kernel.bkbits.net/acme/sk_buff-2.6

Regards,

- Arnaldo

--7ZAtKRhVyVSsbBD2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ax25.2.patch"

===================================================================


ChangeSet@1.2246, 2005-04-04 16:28:37-03:00, acme@toy.ghostprotocols.net
  [AX25] Introduce ax25_type_trans
  
  Replacing the open coded equivalents and making ax25 look more like
  a linux network protocol, i.e. more similar to inet.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
  Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 drivers/net/hamradio/6pack.c      |    4 +---
 drivers/net/hamradio/baycom_epp.c |    4 +---
 drivers/net/hamradio/bpqether.c   |   10 ++--------
 drivers/net/hamradio/dmascc.c     |    4 +---
 drivers/net/hamradio/hdlcdrv.c    |    4 +---
 drivers/net/hamradio/mkiss.c      |    4 +---
 drivers/net/hamradio/scc.c        |    5 +----
 drivers/net/hamradio/yam.c        |    4 +---
 include/net/ax25.h                |    8 ++++++++
 net/ax25/ax25_ds_subr.c           |    3 +--
 net/ax25/ax25_out.c               |    3 +--
 11 files changed, 19 insertions(+), 34 deletions(-)


diff -Nru a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
--- a/drivers/net/hamradio/6pack.c	2005-04-04 16:44:28 -03:00
+++ b/drivers/net/hamradio/6pack.c	2005-04-04 16:44:28 -03:00
@@ -394,13 +394,11 @@
 	if ((skb = dev_alloc_skb(count)) == NULL)
 		goto out_mem;
 
-	skb->dev = sp->dev;
 	ptr = skb_put(skb, count);
 	*ptr++ = cmd;	/* KISS command */
 
 	memcpy(ptr, sp->cooked_buf + 1, count);
-	skb->mac.raw = skb->data;
-	skb->protocol = htons(ETH_P_AX25);
+	skb->protocol = ax25_type_trans(skb, sp->dev);
 	netif_rx(skb);
 	sp->dev->last_rx = jiffies;
 	sp->stats.rx_packets++;
diff -Nru a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
--- a/drivers/net/hamradio/baycom_epp.c	2005-04-04 16:44:28 -03:00
+++ b/drivers/net/hamradio/baycom_epp.c	2005-04-04 16:44:28 -03:00
@@ -601,12 +601,10 @@
 		bc->stats.rx_dropped++;
 		return;
 	}
-	skb->dev = dev;
 	cp = skb_put(skb, pktlen);
 	*cp++ = 0; /* KISS kludge */
 	memcpy(cp, bc->hdlcrx.buf, pktlen - 1);
-	skb->protocol = htons(ETH_P_AX25);
-	skb->mac.raw = skb->data;
+	skb->protocol = ax25_type_trans(skb, dev);
 	netif_rx(skb);
 	dev->last_rx = jiffies;
 	bc->stats.rx_packets++;
diff -Nru a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
--- a/drivers/net/hamradio/bpqether.c	2005-04-04 16:44:28 -03:00
+++ b/drivers/net/hamradio/bpqether.c	2005-04-04 16:44:28 -03:00
@@ -211,11 +211,7 @@
 	ptr = skb_push(skb, 1);
 	*ptr = 0;
 
-	skb->dev = dev;
-	skb->protocol = htons(ETH_P_AX25);
-	skb->mac.raw = skb->data;
-	skb->pkt_type = PACKET_HOST;
-
+	skb->protocol = ax25_type_trans(skb, dev);
 	netif_rx(skb);
 	dev->last_rx = jiffies;
 unlock:
@@ -272,8 +268,6 @@
 		skb = newskb;
 	}
 
-	skb->protocol = htons(ETH_P_AX25);
-
 	ptr = skb_push(skb, 2);
 
 	*ptr++ = (size + 5) % 256;
@@ -287,7 +281,7 @@
 		return -ENODEV;
 	}
 
-	skb->dev = dev;
+	skb->protocol = ax25_type_trans(skb, dev);
 	skb->nh.raw = skb->data;
 	dev->hard_header(skb, dev, ETH_P_BPQ, bpq->dest_addr, NULL, 0);
 	bpq->stats.tx_packets++;
diff -Nru a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
--- a/drivers/net/hamradio/dmascc.c	2005-04-04 16:44:28 -03:00
+++ b/drivers/net/hamradio/dmascc.c	2005-04-04 16:44:28 -03:00
@@ -1306,9 +1306,7 @@
 			data = skb_put(skb, cb + 1);
 			data[0] = 0;
 			memcpy(&data[1], priv->rx_buf[i], cb);
-			skb->dev = priv->dev;
-			skb->protocol = ntohs(ETH_P_AX25);
-			skb->mac.raw = skb->data;
+			skb->protocol = ax25_type_trans(skb, priv->dev);
 			netif_rx(skb);
 			priv->dev->last_rx = jiffies;
 			priv->stats.rx_packets++;
diff -Nru a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
--- a/drivers/net/hamradio/hdlcdrv.c	2005-04-04 16:44:28 -03:00
+++ b/drivers/net/hamradio/hdlcdrv.c	2005-04-04 16:44:28 -03:00
@@ -174,12 +174,10 @@
 		s->stats.rx_dropped++;
 		return;
 	}
-	skb->dev = dev;
 	cp = skb_put(skb, pkt_len);
 	*cp++ = 0; /* KISS kludge */
 	memcpy(cp, s->hdlcrx.buffer, pkt_len - 1);
-	skb->protocol = htons(ETH_P_AX25);
-	skb->mac.raw = skb->data;
+	skb->protocol = ax25_type_trans(skb, dev);
 	netif_rx(skb);
 	dev->last_rx = jiffies;
 	s->stats.rx_packets++;
diff -Nru a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
--- a/drivers/net/hamradio/mkiss.c	2005-04-04 16:44:28 -03:00
+++ b/drivers/net/hamradio/mkiss.c	2005-04-04 16:44:28 -03:00
@@ -332,12 +332,10 @@
 		return;
 	}
 
-	skb->dev      = ax->dev;
 	spin_lock_bh(&ax->buflock);
 	memcpy(skb_put(skb,count), ax->rbuff, count);
 	spin_unlock_bh(&ax->buflock);
-	skb->mac.raw  = skb->data;
-	skb->protocol = htons(ETH_P_AX25);
+	skb->protocol = ax25_type_trans(skb, ax->dev);
 	netif_rx(skb);
 	ax->dev->last_rx = jiffies;
 	ax->rx_packets++;
diff -Nru a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
--- a/drivers/net/hamradio/scc.c	2005-04-04 16:44:28 -03:00
+++ b/drivers/net/hamradio/scc.c	2005-04-04 16:44:28 -03:00
@@ -1630,10 +1630,7 @@
 	scc->dev_stat.rx_packets++;
 	scc->dev_stat.rx_bytes += skb->len;
 
-	skb->dev      = scc->dev;
-	skb->protocol = htons(ETH_P_AX25);
-	skb->mac.raw  = skb->data;
-	skb->pkt_type = PACKET_HOST;
+	skb->protocol = ax25_type_trans(skb, scc->dev);
 	
 	netif_rx(skb);
 	scc->dev->last_rx = jiffies;
diff -Nru a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
--- a/drivers/net/hamradio/yam.c	2005-04-04 16:44:28 -03:00
+++ b/drivers/net/hamradio/yam.c	2005-04-04 16:44:28 -03:00
@@ -522,12 +522,10 @@
 				++yp->stats.rx_dropped;
 			} else {
 				unsigned char *cp;
-				skb->dev = dev;
 				cp = skb_put(skb, pkt_len);
 				*cp++ = 0;		/* KISS kludge */
 				memcpy(cp, yp->rx_buf, pkt_len - 1);
-				skb->protocol = htons(ETH_P_AX25);
-				skb->mac.raw = skb->data;
+				skb->protocol = ax25_type_trans(skb, dev);
 				netif_rx(skb);
 				dev->last_rx = jiffies;
 				++yp->stats.rx_packets;
diff -Nru a/include/net/ax25.h b/include/net/ax25.h
--- a/include/net/ax25.h	2005-04-04 16:44:28 -03:00
+++ b/include/net/ax25.h	2005-04-04 16:44:28 -03:00
@@ -220,6 +220,14 @@
 	}
 }
 
+static inline unsigned short ax25_type_trans(struct sk_buff *skb, struct net_device *dev)
+{
+	skb->dev      = dev;
+	skb->pkt_type = PACKET_HOST;
+	skb->mac.raw  = skb->data;
+	return htons(ETH_P_AX25);
+}
+
 /* af_ax25.c */
 extern struct hlist_head ax25_list;
 extern spinlock_t ax25_list_lock;
diff -Nru a/net/ax25/ax25_ds_subr.c b/net/ax25/ax25_ds_subr.c
--- a/net/ax25/ax25_ds_subr.c	2005-04-04 16:44:28 -03:00
+++ b/net/ax25/ax25_ds_subr.c	2005-04-04 16:44:28 -03:00
@@ -143,8 +143,7 @@
 	*p++ = cmd;
 	*p++ = param;
 
-	skb->dev      = ax25_dev->dev;
-	skb->protocol = htons(ETH_P_AX25);
+	skb->protocol = ax25_type_trans(skb, ax25_dev->dev);
 
 	dev_queue_xmit(skb);
 }
diff -Nru a/net/ax25/ax25_out.c b/net/ax25/ax25_out.c
--- a/net/ax25/ax25_out.c	2005-04-04 16:44:28 -03:00
+++ b/net/ax25/ax25_out.c	2005-04-04 16:44:28 -03:00
@@ -351,8 +351,7 @@
 {
 	unsigned char *ptr;
 
-	skb->protocol = htons(ETH_P_AX25);
-	skb->dev      = ax25_fwd_dev(dev);
+	skb->protocol = ax25_type_trans(skb, ax25_fwd_dev(dev));
 
 	ptr  = skb_push(skb, 1);
 	*ptr = 0x00;			/* KISS */


--7ZAtKRhVyVSsbBD2--
