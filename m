From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] caif: fix a signedness bug in cfpkt_iterate()
Date: Thu, 19 Feb 2015 12:13:13 +0300
Message-ID: <20150219091313.GA29358@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cfpkt_iterate() function can return -EPROTO on error, but the
function is a u16 so the negative value gets truncated to a positive
unsigned short.  This causes a static checker warning.

The only caller which might care is cffrml_receive(), when it's checking
the frame checksum.  I modified cffrml_receive() so that it never says
-EPROTO is a valid checksum.

Also this isn't ever going to be inlined so I removed the "inline".

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/include/net/caif/cfpkt.h b/include/net/caif/cfpkt.h
index 1c1ad46..fe328c5 100644
--- a/include/net/caif/cfpkt.h
+++ b/include/net/caif/cfpkt.h
@@ -171,7 +171,7 @@ struct cfpkt *cfpkt_split(struct cfpkt *pkt, u16 pos);
  * @return    Checksum of buffer.
  */
 
-u16 cfpkt_iterate(struct cfpkt *pkt,
+int cfpkt_iterate(struct cfpkt *pkt,
 		u16 (*iter_func)(u16 chks, void *buf, u16 len),
 		u16 data);
 
diff --git a/net/caif/cfpkt_skbuff.c b/net/caif/cfpkt_skbuff.c
index 1be0b52..f6c3b21 100644
--- a/net/caif/cfpkt_skbuff.c
+++ b/net/caif/cfpkt_skbuff.c
@@ -255,9 +255,9 @@ inline u16 cfpkt_getlen(struct cfpkt *pkt)
 	return skb->len;
 }
 
-inline u16 cfpkt_iterate(struct cfpkt *pkt,
-			 u16 (*iter_func)(u16, void *, u16),
-			 u16 data)
+int cfpkt_iterate(struct cfpkt *pkt,
+		  u16 (*iter_func)(u16, void *, u16),
+		  u16 data)
 {
 	/*
 	 * Don't care about the performance hit of linearizing,
diff --git a/net/caif/cffrml.c b/net/caif/cffrml.c
index 8bc7caa..434ba85 100644
--- a/net/caif/cffrml.c
+++ b/net/caif/cffrml.c
@@ -84,7 +84,7 @@ static int cffrml_receive(struct cflayer *layr, struct cfpkt *pkt)
 	u16 tmp;
 	u16 len;
 	u16 hdrchks;
-	u16 pktchks;
+	int pktchks;
 	struct cffrml *this;
 	this = container_obj(layr);
 
