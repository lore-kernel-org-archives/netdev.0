From: John Hughes <john@Calva.COM>
Subject: Patch to fix kernel bug 15678 - x25 code accesses fields beyond the
 end of packet.
Date: Sun, 04 Apr 2010 18:40:17 +0200
Message-ID: <4BB8C0F1.2090100@Calva.COM>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050603040900000809040201"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:44753 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762Ab0DDQpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 12:45:35 -0400
Received: from [192.168.14.6] (colmar.atlantech.com [82.224.234.55])
	(authenticated (0 bits))
	by oceanic.CalvaEDI.COM (8.11.1-20030923/8.11.1/6.32) with ESMTP id o34GeHg04839
	(using TLSv1/SSLv3 with cipher RC4-MD5 (128 bits) verified NO)
	for <netdev@vger.kernel.org>; Sun, 4 Apr 2010 18:40:20 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050603040900000809040201
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The current X.25 code attempts to decode fields in X.25 packets that are 
not present.  Here is a little patch that checks the received packet 
length before attempting to decode the missing fields.  It also improves 
error checking for malformed packets.


--------------050603040900000809040201
Content-Type: text/x-patch;
 name="x25-overrun.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x25-overrun.patch"

From: John Hughes <john@calva.com>
Subject: Patch to fix bug 15678 - x25 accesses fields beyond end of packet.

Here is a patch to stop X.25 examining fields beyond the end of the packet.

For example, when a simple CALL ACCEPTED was received:

	10 10 0f

x25_parse_facilities was attempting to decode the FACILITIES field, but this
packet contains no facilities field.

Signed-off-by: John Hughes <john@calva.com>

diff --git a/include/net/x25.h b/include/net/x25.h
index 9baa07d..33f67fb 100644
--- a/include/net/x25.h
+++ b/include/net/x25.h
@@ -182,6 +182,10 @@ extern int  sysctl_x25_clear_request_timeout;
 extern int  sysctl_x25_ack_holdback_timeout;
 extern int  sysctl_x25_forward;
 
+extern int x25_parse_address_block(struct sk_buff *skb,
+		struct x25_address *called_addr,
+		struct x25_address *calling_addr);
+
 extern int  x25_addr_ntoa(unsigned char *, struct x25_address *,
 			  struct x25_address *);
 extern int  x25_addr_aton(unsigned char *, struct x25_address *,
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 9796f3e..fe26c01 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -82,6 +82,41 @@ struct compat_x25_subscrip_struct {
 };
 #endif
 
+
+int x25_parse_address_block(struct sk_buff *skb,
+		struct x25_address *called_addr,
+		struct x25_address *calling_addr)
+{
+	unsigned char len;
+	int needed;
+	int rc;
+
+	if (skb->len < 1) {
+		/* packet has no address block */
+		rc = 0;
+		goto empty;
+	}
+
+	len = *skb->data;
+	needed = 1 + (len >> 4) + (len & 0x0f);
+
+	if (skb->len < needed) {
+		/* packet is too short to hold the addresses it claims
+		   to hold */
+		rc = -1;
+		goto empty;
+	}
+
+	return x25_addr_ntoa(skb->data, called_addr, calling_addr);
+
+empty:
+	*called_addr->x25_addr = 0;
+	*calling_addr->x25_addr = 0;
+
+	return rc;
+}
+
+
 int x25_addr_ntoa(unsigned char *p, struct x25_address *called_addr,
 		  struct x25_address *calling_addr)
 {
@@ -921,16 +956,26 @@ int x25_rx_call_request(struct sk_buff *skb, struct x25_neigh *nb,
 	/*
 	 *	Extract the X.25 addresses and convert them to ASCII strings,
 	 *	and remove them.
+	 *
+	 *	Address block is mandatory in call request packets
 	 */
-	addr_len = x25_addr_ntoa(skb->data, &source_addr, &dest_addr);
+	addr_len = x25_parse_address_block(skb, &source_addr, &dest_addr);
+	if (addr_len <= 0)
+		goto out_clear_request;
 	skb_pull(skb, addr_len);
 
 	/*
 	 *	Get the length of the facilities, skip past them for the moment
 	 *	get the call user data because this is needed to determine
 	 *	the correct listener
+	 *
+	 *	Facilities length is mandatory in call request packets
 	 */
+	if (skb->len < 1)
+		goto out_clear_request;
 	len = skb->data[0] + 1;
+	if (skb->len < len)
+		goto out_clear_request;
 	skb_pull(skb,len);
 
 	/*
diff --git a/net/x25/x25_facilities.c b/net/x25/x25_facilities.c
index a21f664..a2765c6 100644
--- a/net/x25/x25_facilities.c
+++ b/net/x25/x25_facilities.c
@@ -35,7 +35,7 @@ int x25_parse_facilities(struct sk_buff *skb, struct x25_facilities *facilities,
 		struct x25_dte_facilities *dte_facs, unsigned long *vc_fac_mask)
 {
 	unsigned char *p = skb->data;
-	unsigned int len = *p++;
+	unsigned int len;
 
 	*vc_fac_mask = 0;
 
@@ -50,6 +50,14 @@ int x25_parse_facilities(struct sk_buff *skb, struct x25_facilities *facilities,
 	memset(dte_facs->called_ae, '\0', sizeof(dte_facs->called_ae));
 	memset(dte_facs->calling_ae, '\0', sizeof(dte_facs->calling_ae));
 
+	if (skb->len < 1)
+		return 0;
+
+	len = *p++;
+
+	if (len >= skb->len)
+		return -1;
+
 	while (len > 0) {
 		switch (*p & X25_FAC_CLASS_MASK) {
 		case X25_FAC_CLASS_A:
@@ -247,6 +255,8 @@ int x25_negotiate_facilities(struct sk_buff *skb, struct sock *sk,
 	memcpy(new, ours, sizeof(*new));
 
 	len = x25_parse_facilities(skb, &theirs, dte, &x25->vc_facil_mask);
+	if (len < 0)
+		return len;
 
 	/*
 	 *	They want reverse charging, we won't accept it.
diff --git a/net/x25/x25_in.c b/net/x25/x25_in.c
index 96d9227..b39072f 100644
--- a/net/x25/x25_in.c
+++ b/net/x25/x25_in.c
@@ -89,6 +89,7 @@ static int x25_queue_rx_frame(struct sock *sk, struct sk_buff *skb, int more)
 static int x25_state1_machine(struct sock *sk, struct sk_buff *skb, int frametype)
 {
 	struct x25_address source_addr, dest_addr;
+	int len;
 
 	switch (frametype) {
 		case X25_CALL_ACCEPTED: {
@@ -106,11 +107,17 @@ static int x25_state1_machine(struct sock *sk, struct sk_buff *skb, int frametyp
 			 *	Parse the data in the frame.
 			 */
 			skb_pull(skb, X25_STD_MIN_LEN);
-			skb_pull(skb, x25_addr_ntoa(skb->data, &source_addr, &dest_addr));
-			skb_pull(skb,
-				 x25_parse_facilities(skb, &x25->facilities,
+
+			len = x25_parse_address_block(skb, &source_addr,
+						&dest_addr);
+			if (len > 0)
+				skb_pull(skb, len);
+
+			len = x25_parse_facilities(skb, &x25->facilities,
 						&x25->dte_facilities,
-						&x25->vc_facil_mask));
+						&x25->vc_facil_mask);
+			if (len > 0)
+				skb_pull(skb, len);
 			/*
 			 *	Copy any Call User Data.
 			 */

--------------050603040900000809040201--
