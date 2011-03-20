From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2] ROSE: prevent heap corruption with bad facilities
Date: Sun, 20 Mar 2011 16:48:05 +0000
Message-ID: <1300639685.26693.286.camel@localhost>
References: <1300603423.1869.18.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: ralf@linux-mips.org, davem@davemloft.net, netdev@vger.kernel.org,
	security@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39615 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751585Ab1CTQs1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Mar 2011 12:48:27 -0400
In-Reply-To: <1300603423.1869.18.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-03-20 at 02:43 -0400, Dan Rosenberg wrote:
> When parsing the FAC_NATIONAL_DIGIS facilities field, it's possible for
> a remote host to provide more digipeaters than expected, resulting in
> heap corruption.  Check against ROSE_MAX_DIGIS to prevent overflows, and
> abort facilities parsing on failure.
> 
> Additionally, when parsing the FAC_CCITT_DEST_NSAP and
> FAC_CCITT_SRC_NSAP facilities fields, a remote host can provide a length
> of less than 10, resulting in an underflow in a memcpy size, causing a
> kernel panic due to massive heap corruption.  A length of greater than
> 20 results in a stack overflow of the callsign array.  Abort facilities
> parsing on these invalid length values.
[...]

Look further and you'll see that the *entire* parsing code makes not the
slightest attempt to validate lengths.

This applies on top of your patch, and hopefully fixes the remaining
bugs.  It's compile-tested only.

Ben.

---
Subject: [PATCH] rose: Add length checks to CALL_REQUEST parsing

Define some constant offsets for CALL_REQUEST based on the description
at <http://www.techfest.com/networking/wan/x25plp.htm> and the
definition of ROSE as using 10-digit (5-byte) addresses.  Use them
consistently.  Validate all implicit and explicit facilities lengths.
Validate the address length byte rather than either trusting or
assuming its value.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/net/rose.h       |    8 ++++-
 net/rose/af_rose.c       |    8 ++--
 net/rose/rose_loopback.c |   13 ++++++-
 net/rose/rose_route.c    |   20 +++++++----
 net/rose/rose_subr.c     |   91 +++++++++++++++++++++++++++++-----------------
 5 files changed, 93 insertions(+), 47 deletions(-)

diff --git a/include/net/rose.h b/include/net/rose.h
index 5ba9f02..555dd19 100644
--- a/include/net/rose.h
+++ b/include/net/rose.h
@@ -14,6 +14,12 @@
 
 #define	ROSE_MIN_LEN			3
 
+#define	ROSE_CALL_REQ_ADDR_LEN_OFF	3
+#define	ROSE_CALL_REQ_ADDR_LEN_VAL	0xAA	/* each address is 10 digits */
+#define	ROSE_CALL_REQ_DEST_ADDR_OFF	4
+#define	ROSE_CALL_REQ_SRC_ADDR_OFF	9
+#define	ROSE_CALL_REQ_FACILITIES_OFF	14
+
 #define	ROSE_GFI			0x10
 #define	ROSE_Q_BIT			0x80
 #define	ROSE_D_BIT			0x40
@@ -214,7 +220,7 @@ extern void rose_requeue_frames(struct sock *);
 extern int  rose_validate_nr(struct sock *, unsigned short);
 extern void rose_write_internal(struct sock *, int);
 extern int  rose_decode(struct sk_buff *, int *, int *, int *, int *, int *);
-extern int  rose_parse_facilities(unsigned char *, struct rose_facilities_struct *);
+extern int  rose_parse_facilities(unsigned char *, unsigned int, struct rose_facilities_struct *);
 extern void rose_disconnect(struct sock *, int, int, int);
 
 /* rose_timer.c */
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 5ee0c62..a80aef6 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -978,7 +978,7 @@ int rose_rx_call_request(struct sk_buff *skb, struct net_device *dev, struct ros
 	struct sock *make;
 	struct rose_sock *make_rose;
 	struct rose_facilities_struct facilities;
-	int n, len;
+	int n;
 
 	skb->sk = NULL;		/* Initially we don't know who it's for */
 
@@ -987,9 +987,9 @@ int rose_rx_call_request(struct sk_buff *skb, struct net_device *dev, struct ros
 	 */
 	memset(&facilities, 0x00, sizeof(struct rose_facilities_struct));
 
-	len  = (((skb->data[3] >> 4) & 0x0F) + 1) >> 1;
-	len += (((skb->data[3] >> 0) & 0x0F) + 1) >> 1;
-	if (!rose_parse_facilities(skb->data + len + 4, &facilities)) {
+	if (!rose_parse_facilities(skb->data + ROSE_CALL_REQ_FACILITIES_OFF,
+				   skb->len - ROSE_CALL_REQ_FACILITIES_OFF,
+				   &facilities)) {
 		rose_transmit_clear_request(neigh, lci, ROSE_INVALID_FACILITY, 76);
 		return 0;
 	}
diff --git a/net/rose/rose_loopback.c b/net/rose/rose_loopback.c
index ae4a9d9..3444562 100644
--- a/net/rose/rose_loopback.c
+++ b/net/rose/rose_loopback.c
@@ -73,9 +73,20 @@ static void rose_loopback_timer(unsigned long param)
 	unsigned int lci_i, lci_o;
 
 	while ((skb = skb_dequeue(&loopback_queue)) != NULL) {
+		if (skb->len < ROSE_MIN_LEN) {
+			kfree_skb(skb);
+			continue;
+		}
 		lci_i     = ((skb->data[0] << 8) & 0xF00) + ((skb->data[1] << 0) & 0x0FF);
 		frametype = skb->data[2];
-		dest      = (rose_address *)(skb->data + 4);
+		if (frametype == ROSE_CALL_REQUEST &&
+		    (skb->len <= ROSE_CALL_REQ_FACILITIES_OFF ||
+		     skb->data[ROSE_CALL_REQ_ADDR_LEN_OFF] !=
+		     ROSE_CALL_REQ_ADDR_LEN_VAL)) {
+			kfree_skb(skb);
+			continue;
+		}
+		dest      = (rose_address *)(skb->data + ROSE_CALL_REQ_DEST_ADDR_OFF);
 		lci_o     = ROSE_DEFAULT_MAXVC + 1 - lci_i;
 
 		skb_reset_transport_header(skb);
diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index 88a77e9..08dcd2f 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -861,7 +861,7 @@ int rose_route_frame(struct sk_buff *skb, ax25_cb *ax25)
 	unsigned int lci, new_lci;
 	unsigned char cause, diagnostic;
 	struct net_device *dev;
-	int len, res = 0;
+	int res = 0;
 	char buf[11];
 
 #if 0
@@ -869,10 +869,17 @@ int rose_route_frame(struct sk_buff *skb, ax25_cb *ax25)
 		return res;
 #endif
 
+	if (skb->len < ROSE_MIN_LEN)
+		return res;
 	frametype = skb->data[2];
 	lci = ((skb->data[0] << 8) & 0xF00) + ((skb->data[1] << 0) & 0x0FF);
-	src_addr  = (rose_address *)(skb->data + 9);
-	dest_addr = (rose_address *)(skb->data + 4);
+	if (frametype == ROSE_CALL_REQUEST &&
+	    (skb->len <= ROSE_CALL_REQ_FACILITIES_OFF ||
+	     skb->data[ROSE_CALL_REQ_ADDR_LEN_OFF] !=
+	     ROSE_CALL_REQ_ADDR_LEN_VAL))
+		return res;
+	src_addr  = (rose_address *)(skb->data + ROSE_CALL_REQ_SRC_ADDR_OFF);
+	dest_addr = (rose_address *)(skb->data + ROSE_CALL_REQ_DEST_ADDR_OFF);
 
 	spin_lock_bh(&rose_neigh_list_lock);
 	spin_lock_bh(&rose_route_list_lock);
@@ -1010,12 +1017,11 @@ int rose_route_frame(struct sk_buff *skb, ax25_cb *ax25)
 		goto out;
 	}
 
-	len  = (((skb->data[3] >> 4) & 0x0F) + 1) >> 1;
-	len += (((skb->data[3] >> 0) & 0x0F) + 1) >> 1;
-
 	memset(&facilities, 0x00, sizeof(struct rose_facilities_struct));
 
-	if (!rose_parse_facilities(skb->data + len + 4, &facilities)) {
+	if (!rose_parse_facilities(skb->data + ROSE_CALL_REQ_FACILITIES_OFF,
+				   skb->len - ROSE_CALL_REQ_FACILITIES_OFF,
+				   &facilities)) {
 		rose_transmit_clear_request(rose_neigh, lci, ROSE_INVALID_FACILITY, 76);
 		goto out;
 	}
diff --git a/net/rose/rose_subr.c b/net/rose/rose_subr.c
index 174d51c..f6c71ca 100644
--- a/net/rose/rose_subr.c
+++ b/net/rose/rose_subr.c
@@ -142,7 +142,7 @@ void rose_write_internal(struct sock *sk, int frametype)
 		*dptr++ = ROSE_GFI | lci1;
 		*dptr++ = lci2;
 		*dptr++ = frametype;
-		*dptr++ = 0xAA;
+		*dptr++ = ROSE_CALL_REQ_ADDR_LEN_VAL;
 		memcpy(dptr, &rose->dest_addr,  ROSE_ADDR_LEN);
 		dptr   += ROSE_ADDR_LEN;
 		memcpy(dptr, &rose->source_addr, ROSE_ADDR_LEN);
@@ -246,12 +246,16 @@ static int rose_parse_national(unsigned char *p, struct rose_facilities_struct *
 	do {
 		switch (*p & 0xC0) {
 		case 0x00:
+			if (len < 2)
+				return -1;
 			p   += 2;
 			n   += 2;
 			len -= 2;
 			break;
 
 		case 0x40:
+			if (len < 3)
+				return -1;
 			if (*p == FAC_NATIONAL_RAND)
 				facilities->rand = ((p[1] << 8) & 0xFF00) + ((p[2] << 0) & 0x00FF);
 			p   += 3;
@@ -260,32 +264,48 @@ static int rose_parse_national(unsigned char *p, struct rose_facilities_struct *
 			break;
 
 		case 0x80:
+			if (len < 4)
+				return -1;
 			p   += 4;
 			n   += 4;
 			len -= 4;
 			break;
 
 		case 0xC0:
+			if (len < 2)
+				return -1;
 			l = p[1];
+			if (len < 2 + l)
+				return -1;
 			if (*p == FAC_NATIONAL_DEST_DIGI) {
 				if (!fac_national_digis_received) {
+					if (l < AX25_ADDR_LEN)
+						return -1;
 					memcpy(&facilities->source_digis[0], p + 2, AX25_ADDR_LEN);
 					facilities->source_ndigis = 1;
 				}
 			}
 			else if (*p == FAC_NATIONAL_SRC_DIGI) {
 				if (!fac_national_digis_received) {
+					if (l < AX25_ADDR_LEN)
+						return -1;
 					memcpy(&facilities->dest_digis[0], p + 2, AX25_ADDR_LEN);
 					facilities->dest_ndigis = 1;
 				}
 			}
 			else if (*p == FAC_NATIONAL_FAIL_CALL) {
+				if (l < AX25_ADDR_LEN)
+					return -1;
 				memcpy(&facilities->fail_call, p + 2, AX25_ADDR_LEN);
 			}
 			else if (*p == FAC_NATIONAL_FAIL_ADD) {
+				if (l < 1 + ROSE_ADDR_LEN)
+					return -1;
 				memcpy(&facilities->fail_addr, p + 3, ROSE_ADDR_LEN);
 			}
 			else if (*p == FAC_NATIONAL_DIGIS) {
+				if (l % AX25_ADDR_LEN)
+					return -1;
 				fac_national_digis_received = 1;
 				facilities->source_ndigis = 0;
 				facilities->dest_ndigis   = 0;
@@ -319,24 +339,32 @@ static int rose_parse_ccitt(unsigned char *p, struct rose_facilities_struct *fac
 	do {
 		switch (*p & 0xC0) {
 		case 0x00:
+			if (len < 2)
+				return -1;
 			p   += 2;
 			n   += 2;
 			len -= 2;
 			break;
 
 		case 0x40:
+			if (len < 3)
+				return -1;
 			p   += 3;
 			n   += 3;
 			len -= 3;
 			break;
 
 		case 0x80:
+			if (len < 4)
+				return -1;
 			p   += 4;
 			n   += 4;
 			len -= 4;
 			break;
 
 		case 0xC0:
+			if (len < 2)
+				return -1;
 			l = p[1];
 
 			/* Prevent overflows*/
@@ -365,49 +393,44 @@ static int rose_parse_ccitt(unsigned char *p, struct rose_facilities_struct *fac
 	return n;
 }
 
-int rose_parse_facilities(unsigned char *p,
+int rose_parse_facilities(unsigned char *p, unsigned packet_len,
 	struct rose_facilities_struct *facilities)
 {
 	int facilities_len, len;
 
 	facilities_len = *p++;
 
-	if (facilities_len == 0)
+	if (facilities_len == 0 || (unsigned)facilities_len > packet_len)
 		return 0;
 
-	while (facilities_len > 0) {
-		if (*p == 0x00) {
-			facilities_len--;
-			p++;
-
-			switch (*p) {
-			case FAC_NATIONAL:		/* National */
-				len = rose_parse_national(p + 1, facilities, facilities_len - 1);
-				if (len < 0)
-					return 0;
-				facilities_len -= len + 1;
-				p += len + 1;
-				break;
-
-			case FAC_CCITT:		/* CCITT */
-				len = rose_parse_ccitt(p + 1, facilities, facilities_len - 1);
-				if (len < 0)
-					return 0;
-				facilities_len -= len + 1;
-				p += len + 1;
-				break;
-
-			default:
-				printk(KERN_DEBUG "ROSE: rose_parse_facilities - unknown facilities family %02X\n", *p);
-				facilities_len--;
-				p++;
-				break;
-			}
-		} else
-			break;	/* Error in facilities format */
+	while (facilities_len >= 3 && *p == 0x00) {
+		facilities_len--;
+		p++;
+
+		switch (*p) {
+		case FAC_NATIONAL:		/* National */
+			len = rose_parse_national(p + 1, facilities, facilities_len - 1);
+			break;
+
+		case FAC_CCITT:		/* CCITT */
+			len = rose_parse_ccitt(p + 1, facilities, facilities_len - 1);
+			break;
+
+		default:
+			printk(KERN_DEBUG "ROSE: rose_parse_facilities - unknown facilities family %02X\n", *p);
+			len = 1;
+			break;
+		}
+
+		if (len < 0)
+			return 0;
+		if (WARN_ON(len >= facilities_len))
+			return 0;
+		facilities_len -= len + 1;
+		p += len + 1;
 	}
 
-	return 1;
+	return facilities_len == 0;
 }
 
 static int rose_create_facilities(unsigned char *buffer, struct rose_sock *rose)
-- 
1.7.4.1

-- 
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.
