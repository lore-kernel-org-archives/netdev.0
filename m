From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 5/5] net/ipv4 : Correct the size argument to kzalloc
Date: Tue, 29 Dec 2009 20:16:49 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0912292016230.4001__33163.1023822867$1262114244$gmane$org@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:45176 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752444AbZL2TQw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2009 14:16:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

obj has type struct snmp_object **, not struct snmp_object *.  But indeed
it is not even clear why kmalloc is needed.  The memory is freed by the end
of the function, so the local variable of pointer type should be sufficient.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@disable sizeof_type_expr@
type T;
T **x;
@@

  x =
  <+...sizeof(
- T
+ *x
  )...+>
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 net/ipv4/netfilter/nf_nat_snmp_basic.c         |   31 +++++++-------------
 1 files changed, 11 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index d9521f6..0b9c7ce 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -1038,7 +1038,7 @@ static int snmp_parse_mangle(unsigned char *msg,
 	unsigned int cls, con, tag, vers, pdutype;
 	struct asn1_ctx ctx;
 	struct asn1_octstr comm;
-	struct snmp_object **obj;
+	struct snmp_object *obj;
 
 	if (debug > 1)
 		hex_dump(msg, len);
@@ -1148,43 +1148,34 @@ static int snmp_parse_mangle(unsigned char *msg,
 	if (cls != ASN1_UNI || con != ASN1_CON || tag != ASN1_SEQ)
 		return 0;
 
-	obj = kmalloc(sizeof(struct snmp_object), GFP_ATOMIC);
-	if (obj == NULL) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "OOM in bsalg(%d)\n", __LINE__);
-		return 0;
-	}
-
 	while (!asn1_eoc_decode(&ctx, eoc)) {
 		unsigned int i;
 
-		if (!snmp_object_decode(&ctx, obj)) {
-			if (*obj) {
-				kfree((*obj)->id);
-				kfree(*obj);
+		if (!snmp_object_decode(&ctx, &obj)) {
+			if (obj) {
+				kfree(obj->id);
+				kfree(obj);
 			}
-			kfree(obj);
 			return 0;
 		}
 
 		if (debug > 1) {
 			printk(KERN_DEBUG "bsalg: object: ");
-			for (i = 0; i < (*obj)->id_len; i++) {
+			for (i = 0; i < obj->id_len; i++) {
 				if (i > 0)
 					printk(".");
-				printk("%lu", (*obj)->id[i]);
+				printk("%lu", obj->id[i]);
 			}
-			printk(": type=%u\n", (*obj)->type);
+			printk(": type=%u\n", obj->type);
 
 		}
 
-		if ((*obj)->type == SNMP_IPADDR)
+		if (obj->type == SNMP_IPADDR)
 			mangle_address(ctx.begin, ctx.pointer - 4 , map, check);
 
-		kfree((*obj)->id);
-		kfree(*obj);
+		kfree(obj->id);
+		kfree(obj);
 	}
-	kfree(obj);
 
 	if (!asn1_eoc_decode(&ctx, eoc))
 		return 0;
