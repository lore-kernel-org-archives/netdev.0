From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: PATCH: [SKBUFF] introduce ax25_type_trans
Date: Mon, 04 Oct 2004 11:43:21 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41616189.60309@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060805090508090008030709"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060805090508090008030709
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/sk_buff-2.6

	Now there are nine outstanding changesets in this tree.

Regards,

- Arnaldo

--------------060805090508090008030709
Content-Type: text/plain;
 name="ax25_type_trans.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ax25_type_trans.patch"

===================================================================


ChangeSet@1.2038, 2004-10-04 11:36:34-03:00, acme@conectiva.com.br
  [SKBUFF] introduce ax25_type_trans
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>


 drivers/net/hamradio/6pack.c      |    6 +-----
 drivers/net/hamradio/baycom_epp.c |    4 +---
 drivers/net/hamradio/bpqether.c   |    6 +-----
 drivers/net/hamradio/dmascc.c     |    4 +---
 drivers/net/hamradio/hdlcdrv.c    |    4 +---
 drivers/net/hamradio/mkiss.c      |    4 +---
 drivers/net/hamradio/scc.c        |    6 +-----
 drivers/net/hamradio/yam.c        |    4 +---
 include/net/ax25.h                |    9 +++++++++
 9 files changed, 17 insertions(+), 30 deletions(-)


diff -Nru a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
--- a/drivers/net/hamradio/6pack.c	2004-10-04 11:40:05 -03:00
+++ b/drivers/net/hamradio/6pack.c	2004-10-04 11:40:05 -03:00
@@ -424,17 +424,13 @@
 	if ((skb = dev_alloc_skb(count)) == NULL)
 		goto out_mem;
 
-	skb->dev = sp->dev;
 	ptr = skb_put(skb, count);
 	*ptr++ = cmd;	/* KISS command */
-
 	memcpy(ptr, sp->cooked_buf + 1, count);
-	skb_set_link_header(skb);
-	skb->protocol = htons(ETH_P_AX25);
+	skb->protocol = ax25_type_trans(skb, sp->dev);
 	netif_rx(skb);
 	sp->dev->last_rx = jiffies;
 	sp->stats.rx_packets++;
-
 	return;
 
 out_mem:
diff -Nru a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
--- a/drivers/net/hamradio/baycom_epp.c	2004-10-04 11:40:05 -03:00
+++ b/drivers/net/hamradio/baycom_epp.c	2004-10-04 11:40:05 -03:00
@@ -619,12 +619,10 @@
 		bc->stats.rx_dropped++;
 		return;
 	}
-	skb->dev = dev;
 	cp = skb_put(skb, pktlen);
 	*cp++ = 0; /* KISS kludge */
 	memcpy(cp, bc->hdlcrx.buf, pktlen - 1);
-	skb->protocol = htons(ETH_P_AX25);
-	skb_set_link_header(skb);
+	skb->protocol = ax25_type_trans(skb, dev);
 	netif_rx(skb);
 	dev->last_rx = jiffies;
 	bc->stats.rx_packets++;
diff -Nru a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
--- a/drivers/net/hamradio/bpqether.c	2004-10-04 11:40:05 -03:00
+++ b/drivers/net/hamradio/bpqether.c	2004-10-04 11:40:05 -03:00
@@ -213,11 +213,7 @@
 	ptr = skb_push(skb, 1);
 	*ptr = 0;
 
-	skb->dev = dev;
-	skb->protocol = htons(ETH_P_AX25);
-	skb_set_link_header(skb);
-	skb->pkt_type = PACKET_HOST;
-
+	skb->protocol = ax25_type_trans(skb, dev);
 	netif_rx(skb);
 	dev->last_rx = jiffies;
 unlock:
diff -Nru a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
--- a/drivers/net/hamradio/dmascc.c	2004-10-04 11:40:05 -03:00
+++ b/drivers/net/hamradio/dmascc.c	2004-10-04 11:40:05 -03:00
@@ -1222,9 +1222,7 @@
       data = skb_put(skb, cb+1);
       data[0] = 0;
       memcpy(&data[1], priv->rx_buf[i], cb);
-      skb->dev = priv->dev;
-      skb->protocol = ntohs(ETH_P_AX25);
-      skb_set_link_header(skb);
+      skb->protocol = ax25_type_trans(skb, priv->dev);
       netif_rx(skb);
       priv->dev->last_rx = jiffies;
       priv->stats.rx_packets++;
diff -Nru a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
--- a/drivers/net/hamradio/hdlcdrv.c	2004-10-04 11:40:05 -03:00
+++ b/drivers/net/hamradio/hdlcdrv.c	2004-10-04 11:40:05 -03:00
@@ -174,12 +174,10 @@
 		s->stats.rx_dropped++;
 		return;
 	}
-	skb->dev = dev;
 	cp = skb_put(skb, pkt_len);
 	*cp++ = 0; /* KISS kludge */
 	memcpy(cp, s->hdlcrx.buffer, pkt_len - 1);
-	skb->protocol = htons(ETH_P_AX25);
-	skb_set_link_header(skb);
+	skb->protocol = ax25_type_trans(skb, dev);
 	netif_rx(skb);
 	dev->last_rx = jiffies;
 	s->stats.rx_packets++;
diff -Nru a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
--- a/drivers/net/hamradio/mkiss.c	2004-10-04 11:40:05 -03:00
+++ b/drivers/net/hamradio/mkiss.c	2004-10-04 11:40:05 -03:00
@@ -332,12 +332,10 @@
 		return;
 	}
 
-	skb->dev      = ax->dev;
 	spin_lock_bh(&ax->buflock);
 	memcpy(skb_put(skb,count), ax->rbuff, count);
 	spin_unlock_bh(&ax->buflock);
-	skb_set_link_header(skb);
-	skb->protocol = htons(ETH_P_AX25);
+	skb->protocol = ax25_type_trans(skb, ax->dev);
 	netif_rx(skb);
 	ax->dev->last_rx = jiffies;
 	ax->rx_packets++;
diff -Nru a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
--- a/drivers/net/hamradio/scc.c	2004-10-04 11:40:05 -03:00
+++ b/drivers/net/hamradio/scc.c	2004-10-04 11:40:05 -03:00
@@ -1630,11 +1630,7 @@
 	scc->dev_stat.rx_packets++;
 	scc->dev_stat.rx_bytes += skb->len;
 
-	skb->dev      = scc->dev;
-	skb->protocol = htons(ETH_P_AX25);
-	skb_set_link_header(skb);
-	skb->pkt_type = PACKET_HOST;
-	
+	skb->protocol = ax25_type_trans(skb, scc->dev);
 	netif_rx(skb);
 	scc->dev->last_rx = jiffies;
 	return;
diff -Nru a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
--- a/drivers/net/hamradio/yam.c	2004-10-04 11:40:05 -03:00
+++ b/drivers/net/hamradio/yam.c	2004-10-04 11:40:05 -03:00
@@ -522,12 +522,10 @@
 				++yp->stats.rx_dropped;
 			} else {
 				unsigned char *cp;
-				skb->dev = dev;
 				cp = skb_put(skb, pkt_len);
 				*cp++ = 0;		/* KISS kludge */
 				memcpy(cp, yp->rx_buf, pkt_len - 1);
-				skb->protocol = htons(ETH_P_AX25);
-				skb_set_link_header(skb);
+				skb->protocol = ax25_type_trans(skb, dev);
 				netif_rx(skb);
 				dev->last_rx = jiffies;
 				++yp->stats.rx_packets;
diff -Nru a/include/net/ax25.h b/include/net/ax25.h
--- a/include/net/ax25.h	2004-10-04 11:40:05 -03:00
+++ b/include/net/ax25.h	2004-10-04 11:40:05 -03:00
@@ -220,6 +220,15 @@
 	}
 }
 
+static inline unsigned short ax25_type_trans(struct sk_buff *skb,
+					     struct net_device *dev)
+{
+	skb->dev = dev;
+	skb->pkt_type = PACKET_HOST;
+	skb_set_link_header(skb);
+	return htons(ETH_P_AX25);
+}
+
 /* af_ax25.c */
 extern struct hlist_head ax25_list;
 extern spinlock_t ax25_list_lock;


--------------060805090508090008030709--
