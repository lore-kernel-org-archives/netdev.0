From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/62: SNMP NAT: correct the size argument to kzalloc
Date: Tue, 16 Feb 2010 15:55:20 +0100 (MET)
Message-ID: <20100216145518.2796.51152.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 71c3ebfdb27b50dcaef38b6f70da82b9142c5fb6
Author: Julia Lawall <julia@diku.dk>
Date:   Mon Jan 4 15:21:31 2010 +0100

    netfilter: SNMP NAT: correct the size argument to kzalloc
    
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
    Signed-off-by: Patrick McHardy <kaber@trash.net>

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
