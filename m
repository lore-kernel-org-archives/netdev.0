From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] 2.5.68 - RCU for SNAP
Date: Wed, 30 Apr 2003 04:22:36 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030430072236.GE31429@conectiva.com.br>
References: <20030429154856.39c75139.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, Jay Schulist <jschlst@samba.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030429154856.39c75139.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

	Looks fine, applied, David, could you please pull from:

bk://kernel.bkbits.net/acme/net-2.5

	Thanks Stephen.

- Arnaldo


You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1170, 2003-04-30 04:17:25-03:00, shemminger@osdl.org
  Replace br_lock() in snap with Read Copy Update.
  
  Straightforward since SNAP uses list macros already.
  
  Tested by bringing up/down Appletalk on SMP system and making sure packets
  get through.
  
  This is the last subsystem that depends on br_lock before IPV4,IPV6
  can be converted.


 psnap.c |   32 +++++++++++++++++---------------
 1 files changed, 17 insertions(+), 15 deletions(-)


diff -Nru a/net/802/psnap.c b/net/802/psnap.c
--- a/net/802/psnap.c	Wed Apr 30 04:20:09 2003
+++ b/net/802/psnap.c	Wed Apr 30 04:20:09 2003
@@ -21,9 +21,9 @@
 #include <linux/mm.h>
 #include <linux/in.h>
 #include <linux/init.h>
-#include <linux/brlock.h>
 
-LIST_HEAD(snap_list);
+static LIST_HEAD(snap_list);
+static spinlock_t snap_lock = SPIN_LOCK_UNLOCKED;
 static struct llc_sap *snap_sap;
 
 /*
@@ -34,17 +34,13 @@
 	struct list_head *entry;
 	struct datalink_proto *proto = NULL, *p;
 
-	if (list_empty(&snap_list))
-		goto out;
-
-	list_for_each(entry, &snap_list) {
+	list_for_each_rcu(entry, &snap_list) {
 		p = list_entry(entry, struct datalink_proto, node);
 		if (!memcmp(p->type, desc, 5)) {
 			proto = p;
 			break;
 		}
 	}
-out:
 	return proto;
 }
 
@@ -55,11 +51,13 @@
 		    struct packet_type *pt)
 {
 	int rc = 1;
-	struct datalink_proto *proto = find_snap_client(skb->h.raw);
+	struct datalink_proto *proto;
 	static struct packet_type snap_packet_type = {
 		.type = __constant_htons(ETH_P_SNAP),
 	};
 
+	rcu_read_lock();
+	proto = find_snap_client(skb->h.raw);
 	if (proto) {
 		/* Pass the frame on. */
 		skb->h.raw  += 5;
@@ -71,6 +69,7 @@
 		rc = 1;
 	}
 
+	rcu_read_unlock();
 	return rc;
 }
 
@@ -124,7 +123,7 @@
 {
 	struct datalink_proto *proto = NULL;
 
-	br_write_lock_bh(BR_NETPROTO_LOCK);
+	spin_lock_bh(&snap_lock);
 
 	if (find_snap_client(desc))
 		goto out;
@@ -135,10 +134,12 @@
 		proto->rcvfunc		= rcvfunc;
 		proto->header_length	= 5 + 3; /* snap + 802.2 */
 		proto->request		= snap_request;
-		list_add(&proto->node, &snap_list);
+		list_add_rcu(&proto->node, &snap_list);
 	}
 out:
-	br_write_unlock_bh(BR_NETPROTO_LOCK);
+	spin_unlock_bh(&snap_lock);
+
+	synchronize_net();
 	return proto;
 }
 
@@ -147,12 +148,13 @@
  */
 void unregister_snap_client(struct datalink_proto *proto)
 {
-	br_write_lock_bh(BR_NETPROTO_LOCK);
+	spin_lock_bh(&snap_lock);
+	list_del_rcu(&proto->node);
+	spin_unlock_bh(&snap_lock);
 
-	list_del(&proto->node);
-	kfree(proto);
+	synchronize_net();
 
-	br_write_unlock_bh(BR_NETPROTO_LOCK);
+	kfree(proto);
 }
 
 MODULE_LICENSE("GPL");

===================================================================


This BitKeeper patch contains the following changesets:
1.1170
## Wrapped with gzip_uu ##


M'XL( "EYKSX  ^U6;6_;-A#^+/Z* PH$[E;+I%XLVX&#I''0&LE2(V[V:8! 
M4W0D6*8$DH[AS3]^1\EQUS1+L6+ OBPF[HS<\7F>X]T!?@/W1NJ1Q\5:DC?P
ML3)VY(E*26&+1^Z+:NTO- ;NJ@H#O;Q:R][[ZYZ2MAOX,<'(C%N1PZ/49N0Q
M/SS^Q^YJ.?+NKC[<WUS<$3(>PV7.U8.<2POC,;&5?N1E9LZYS<M*^59S9=;2
M-IS[8^H^H#3 3\R2D,;]/>O3*-D+EC'&(R8S&D2#?D2<_//GLK]&"6D44AI'
M0S;<AP,ZZ),),)^QA (->S3JA?@E&K%D%,1=&HXH!9/+];I "'U>F:ST*_T 
M/S/H4O(>_EW]ET3 G:Q++B0L=%I68M5Y"X4"HW@-V\+F&.897%;U#N[KC%OI
MXQ4\<R0N'G*[K/26ZPQ,H1!C?GLQ@XV1!LK"6%ASH2L#O-0(LCO<_"R-E1DL
M=LB(1>*!3=W+JJV"B[HNL91R!96"^2\S,#O,70-7&6*M7*K9: DU%RMI#8(]
M8%=MKJO-0_X$GQ<&\-A<0LE1A-DL#C VYQ8R64N5&<=PJ!@6$JN0,)W]&KU#
MTT<4P3$L 5N+$X9R?7(-83(<!F3V99Y(]Q_^$4(Y)6??:2(.>6] @U[MFN"+
MO[9R&"=[.G VZL?+@12)7/:7"SID+PW-2TCM."8L88-]P(8L:E;D6>+W%^6'
M-/[-NKR$Q5 H#<.0#O<HE;9+,WB^,6SPZL8DT&7Q_SOS7^Y,.V*?H*NWS<$=
MF#V?MA]8HTD0 4/;1SM%&Q!CN2T$W$SGG]./5Q>3CL-.W8N^/7T*FKI03GQJ
MH8VZ0L8PGTUOTYM/E]?I_:US5Y-3,@D3B,@THDC@.904RTTE%WFJQ:8CE=6[
M=W#RA03^(),H<:+B@1/56,]8O1'X?AP;5*A56NO*5O!3XT[)M!^@<@\!4]?L
MPRB=$J]-&\.R4%G:<(BR0,Z.62VZ9[FO^1;3IDGH.([7-^H)8,(")V7:.L_5
MW8"GB[QS<BR]20P;M:WSVDIYEC5%GC0RNF>JRN17M;I[$6ONH0L/!"W]-Q2_
M87BG!,Z;*GZ7*?:^51C3!@!=^)K"5E(FRV\DN>!KQ$CAGA<IFF=Z643<BG#.
B6RVUE)V& 8/''Q0BEV)E-NMQ+))@&,=+\B?0XUJMO0@     
 
