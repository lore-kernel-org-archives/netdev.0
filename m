From: acme@ghostprotocols.net (Arnaldo Carvalho de Melo)
Subject: [PATCH 1/2][AX25] make ax25_queue_xmit a net_device parameter
Date: Mon, 4 Apr 2005 16:48:35 -0300
Message-ID: <20050404194835.GI640@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="mYCpIKhGyMATD0i+"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        Ralf Baechle <ralf@linux-mips.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--mYCpIKhGyMATD0i+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi David, Ralf,

	This one is just in preparation for the second, that introduces
ax25_type_trans.

	Available at:

bk://kernel.bkbits.net/acme/sk_buff-2.6

Regards,

- Arnaldo

--mYCpIKhGyMATD0i+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ax25.1.patch"

===================================================================


ChangeSet@1.2245, 2005-04-04 16:23:29-03:00, acme@toy.ghostprotocols.net
  [AX25] make ax25_queue_xmit a net_device parameter
  
  I.e. not using skb->dev as a way to pass the parameter used to fill...
  skb->dev :-)
  
  Also to get the _type_trans open coded sequence grouped, next changesets
  will introduce ax25_type_trans.
  
  Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
  Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 include/net/ax25.h   |    2 +-
 net/ax25/af_ax25.c   |    4 +---
 net/ax25/ax25_ip.c   |    4 +---
 net/ax25/ax25_out.c  |    8 +++-----
 net/ax25/ax25_subr.c |    4 +---
 5 files changed, 7 insertions(+), 15 deletions(-)


diff -Nru a/include/net/ax25.h b/include/net/ax25.h
--- a/include/net/ax25.h	2005-04-04 16:43:28 -03:00
+++ b/include/net/ax25.h	2005-04-04 16:43:28 -03:00
@@ -305,7 +305,7 @@
 extern void ax25_output(ax25_cb *, int, struct sk_buff *);
 extern void ax25_kick(ax25_cb *);
 extern void ax25_transmit_buffer(ax25_cb *, struct sk_buff *, int);
-extern void ax25_queue_xmit(struct sk_buff *);
+extern void ax25_queue_xmit(struct sk_buff *skb, struct net_device *dev);
 extern int  ax25_check_iframes_acked(ax25_cb *, unsigned short);
 
 /* ax25_route.c */
diff -Nru a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
--- a/net/ax25/af_ax25.c	2005-04-04 16:43:28 -03:00
+++ b/net/ax25/af_ax25.c	2005-04-04 16:43:28 -03:00
@@ -1587,9 +1587,7 @@
 	*asmptr = AX25_UI;
 
 	/* Datagram frames go straight out of the door as UI */
-	skb->dev = ax25->ax25_dev->dev;
-
-	ax25_queue_xmit(skb);
+	ax25_queue_xmit(skb, ax25->ax25_dev->dev);
 
 	err = len;
 
diff -Nru a/net/ax25/ax25_ip.c b/net/ax25/ax25_ip.c
--- a/net/ax25/ax25_ip.c	2005-04-04 16:43:28 -03:00
+++ b/net/ax25/ax25_ip.c	2005-04-04 16:43:28 -03:00
@@ -199,9 +199,7 @@
 		skb = ourskb;
 	}
 
-	skb->dev      = dev;
-
-	ax25_queue_xmit(skb);
+	ax25_queue_xmit(skb, dev);
 
 put:
 	ax25_put_route(route);
diff -Nru a/net/ax25/ax25_out.c b/net/ax25/ax25_out.c
--- a/net/ax25/ax25_out.c	2005-04-04 16:43:28 -03:00
+++ b/net/ax25/ax25_out.c	2005-04-04 16:43:28 -03:00
@@ -340,21 +340,19 @@
 
 	ax25_addr_build(ptr, &ax25->source_addr, &ax25->dest_addr, ax25->digipeat, type, ax25->modulus);
 
-	skb->dev = ax25->ax25_dev->dev;
-
-	ax25_queue_xmit(skb);
+	ax25_queue_xmit(skb, ax25->ax25_dev->dev);
 }
 
 /*
  *	A small shim to dev_queue_xmit to add the KISS control byte, and do
  *	any packet forwarding in operation.
  */
-void ax25_queue_xmit(struct sk_buff *skb)
+void ax25_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned char *ptr;
 
 	skb->protocol = htons(ETH_P_AX25);
-	skb->dev      = ax25_fwd_dev(skb->dev);
+	skb->dev      = ax25_fwd_dev(dev);
 
 	ptr  = skb_push(skb, 1);
 	*ptr = 0x00;			/* KISS */
diff -Nru a/net/ax25/ax25_subr.c b/net/ax25/ax25_subr.c
--- a/net/ax25/ax25_subr.c	2005-04-04 16:43:28 -03:00
+++ b/net/ax25/ax25_subr.c	2005-04-04 16:43:28 -03:00
@@ -220,9 +220,7 @@
 	dptr  = skb_push(skb, ax25_addr_size(digi));
 	dptr += ax25_addr_build(dptr, dest, src, &retdigi, AX25_RESPONSE, AX25_MODULUS);
 
-	skb->dev      = dev;
-
-	ax25_queue_xmit(skb);
+	ax25_queue_xmit(skb, dev);
 }
 
 /*


--mYCpIKhGyMATD0i+--
