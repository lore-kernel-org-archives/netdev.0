From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: PATCH: [SKBUFF] introduce x25_type_trans
Date: Sun, 03 Oct 2004 23:07:40 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4160B06C.6020105@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040908060501010702090001"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040908060501010702090001
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/sk_buff-2.6

	Now there are six outstanding changesets in this tree.

Regards,

- Arnaldo

--------------040908060501010702090001
Content-Type: text/plain;
 name="x25_type_trans.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x25_type_trans.patch"

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.2035, 2004-10-03 23:01:56-03:00, acme@conectiva.com.br
  [SKBUFF] introduce x25_type_trans
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signet-off-by: David S. Miller <davem@redhat.com>


 drivers/isdn/i4l/isdn_x25iface.c |   16 ++++------------
 drivers/net/wan/cycx_x25.c       |    8 +++-----
 drivers/net/wan/hdlc_x25.c       |   14 ++++----------
 drivers/net/wan/lapbether.c      |   20 +++++---------------
 drivers/net/wan/x25_asy.c        |   18 +++++-------------
 include/net/x25device.h          |   17 +++++++++++++++++
 6 files changed, 38 insertions(+), 55 deletions(-)


diff -Nru a/drivers/isdn/i4l/isdn_x25iface.c b/drivers/isdn/i4l/isdn_x25iface.c
--- a/drivers/isdn/i4l/isdn_x25iface.c	2004-10-03 23:02:38 -03:00
+++ b/drivers/isdn/i4l/isdn_x25iface.c	2004-10-03 23:02:38 -03:00
@@ -21,6 +21,7 @@
 #include <linux/netdevice.h>
 #include <linux/concap.h>
 #include <linux/wanrouter.h>
+#include <net/x25device.h>
 #include "isdn_x25iface.h"
 
 /* for debugging messages not to cause an oops when device pointer is NULL*/
@@ -191,12 +192,9 @@
   	IX25DEBUG( "isdn_x25iface_receive %s \n", MY_DEVNAME(cprot->net_dev) );
 	if ( ( (ix25_pdata_t*) (cprot->proto_data) ) 
 	     -> state == WAN_CONNECTED ){
-		skb -> dev = cprot -> net_dev;
-		skb -> protocol = htons(ETH_P_X25);
-		skb -> pkt_type = PACKET_HOST;
 		if( skb_push(skb, 1)){
 			skb -> data[0]=0x00;
-			skb -> mac.raw = skb -> data;
+			skb->protocol = x25_type_trans(skb, cprot->net_dev);
 			netif_rx(skb);
 			return 0;
 		}
@@ -224,10 +222,7 @@
 	*state_p = WAN_CONNECTED;
 	if( skb ){
 		*( skb_put(skb, 1) ) = 0x01;
-		skb -> mac.raw = skb -> data;
-		skb -> dev  = cprot -> net_dev;
-		skb -> protocol = htons(ETH_P_X25);
-		skb -> pkt_type = PACKET_HOST;
+		skb->protocol = x25_type_trans(skb, cprot->net_dev);
 		netif_rx(skb);
 		return 0;
 	} else {
@@ -256,10 +251,7 @@
 	skb = dev_alloc_skb(1);
 	if( skb ){
 		*( skb_put(skb, 1) ) = 0x02;
-		skb -> mac.raw = skb -> data;
-		skb -> dev  = cprot -> net_dev;
-		skb -> protocol = htons(ETH_P_X25);
-		skb -> pkt_type = PACKET_HOST;
+		skb->protocol = x25_type_trans(skb, cprot->net_dev);
 		netif_rx(skb);
 		return 0;
 	} else {
diff -Nru a/drivers/net/wan/cycx_x25.c b/drivers/net/wan/cycx_x25.c
--- a/drivers/net/wan/cycx_x25.c	2004-10-03 23:02:38 -03:00
+++ b/drivers/net/wan/cycx_x25.c	2004-10-03 23:02:38 -03:00
@@ -92,6 +92,8 @@
 #include <linux/cyclomx.h>	/* Cyclom 2X common user API definitions */
 #include <linux/cycx_x25.h>	/* X.25 firmware API definitions */
 
+#include <net/x25device.h>
+
 /* Defines & Macros */
 #define CYCX_X25_MAX_CMD_RETRY 5
 #define CYCX_X25_CHAN_MTU 2048	/* unfragmented logical channel MTU */
@@ -1486,11 +1488,7 @@
 	ptr  = skb_put(skb, 1);
 	*ptr = event;
 
-	skb->dev = dev;
-	skb->protocol = htons(ETH_P_X25);
-	skb->mac.raw = skb->data;
-	skb->pkt_type = PACKET_HOST;
-
+	skb->protocol = x25_type_trans(skb, dev);
 	netif_rx(skb);
 	dev->last_rx = jiffies;		/* timestamp */
 }
diff -Nru a/drivers/net/wan/hdlc_x25.c b/drivers/net/wan/hdlc_x25.c
--- a/drivers/net/wan/hdlc_x25.c	2004-10-03 23:02:38 -03:00
+++ b/drivers/net/wan/hdlc_x25.c	2004-10-03 23:02:38 -03:00
@@ -23,6 +23,8 @@
 #include <linux/rtnetlink.h>
 #include <linux/hdlc.h>
 
+#include <net/x25device.h>
+
 /* These functions are callbacks called by LAPB layer */
 
 static void x25_connect_disconnect(struct net_device *dev, int reason, int code)
@@ -38,11 +40,7 @@
 	ptr = skb_put(skb, 1);
 	*ptr = code;
 
-	skb->dev = dev;
-	skb->protocol = htons(ETH_P_X25);
-	skb->mac.raw = skb->data;
-	skb->pkt_type = PACKET_HOST;
-
+	skb->protocol = x25_type_trans(skb, dev);
 	netif_rx(skb);
 }
 
@@ -74,11 +72,7 @@
 	ptr  = skb->data;
 	*ptr = 0;
 
-	skb->dev = dev;
-	skb->protocol = htons(ETH_P_X25);
-	skb->mac.raw = skb->data;
-	skb->pkt_type = PACKET_HOST;
-
+	skb->protocol = x25_type_trans(skb, dev);
 	return netif_rx(skb);
 }
 
diff -Nru a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
--- a/drivers/net/wan/lapbether.c	2004-10-03 23:02:38 -03:00
+++ b/drivers/net/wan/lapbether.c	2004-10-03 23:02:38 -03:00
@@ -43,6 +43,8 @@
 #include <linux/lapb.h>
 #include <linux/init.h>
 
+#include <net/x25device.h>
+
 static char bcast_addr[6] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
 
 /* If this number is made larger, check that the temporary string buffer
@@ -137,11 +139,7 @@
 	ptr  = skb->data;
 	*ptr = 0x00;
 
-	skb->dev      = dev;
-	skb->protocol = htons(ETH_P_X25);
-	skb->mac.raw  = skb->data;
-	skb->pkt_type = PACKET_HOST;
-
+	skb->protocol = x25_type_trans(skb, dev);
 	skb->dev->last_rx = jiffies;
 	return netif_rx(skb);
 }
@@ -233,11 +231,7 @@
 	ptr  = skb_put(skb, 1);
 	*ptr = 0x01;
 
-	skb->dev      = dev;
-	skb->protocol = htons(ETH_P_X25);
-	skb->mac.raw  = skb->data;
-	skb->pkt_type = PACKET_HOST;
-
+	skb->protocol = x25_type_trans(skb, dev);
 	skb->dev->last_rx = jiffies;
 	netif_rx(skb);
 }
@@ -255,11 +249,7 @@
 	ptr  = skb_put(skb, 1);
 	*ptr = 0x02;
 
-	skb->dev      = dev;
-	skb->protocol = htons(ETH_P_X25);
-	skb->mac.raw  = skb->data;
-	skb->pkt_type = PACKET_HOST;
-
+	skb->protocol = x25_type_trans(skb, dev);
 	skb->dev->last_rx = jiffies;
 	netif_rx(skb);
 }
diff -Nru a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
--- a/drivers/net/wan/x25_asy.c	2004-10-03 23:02:38 -03:00
+++ b/drivers/net/wan/x25_asy.c	2004-10-03 23:02:38 -03:00
@@ -34,6 +34,8 @@
 #include <linux/init.h>
 #include "x25_asy.h"
 
+#include <net/x25device.h>
+
 static struct net_device **x25_asy_devs;
 static int x25_asy_maxdev = SL_NRUNIT;
 
@@ -209,10 +211,8 @@
 		return;
 	}
 	skb_push(skb,1);	/* LAPB internal control */
-	skb->dev = sl->dev;
 	memcpy(skb_put(skb,count), sl->rbuff, count);
-	skb->mac.raw=skb->data;
-	skb->protocol=htons(ETH_P_X25);
+	skb->protocol = x25_type_trans(skb, sl->dev);
 	if((err=lapb_data_received(skb->dev, skb))!=LAPB_OK)
 	{
 		kfree_skb(skb);
@@ -419,11 +419,7 @@
 	ptr  = skb_put(skb, 1);
 	*ptr = 0x01;
 
-	skb->dev      = sl->dev;
-	skb->protocol = htons(ETH_P_X25);
-	skb->mac.raw  = skb->data;
-	skb->pkt_type = PACKET_HOST;
-
+	skb->protocol = x25_type_trans(skb, sl->dev);
 	netif_rx(skb);
 	sl->dev->last_rx = jiffies;
 }
@@ -442,11 +438,7 @@
 	ptr  = skb_put(skb, 1);
 	*ptr = 0x02;
 
-	skb->dev      = sl->dev;
-	skb->protocol = htons(ETH_P_X25);
-	skb->mac.raw  = skb->data;
-	skb->pkt_type = PACKET_HOST;
-
+	skb->protocol = x25_type_trans(skb, sl->dev);
 	netif_rx(skb);
 	sl->dev->last_rx = jiffies;
 }
diff -Nru a/include/net/x25device.h b/include/net/x25device.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/include/net/x25device.h	2004-10-03 23:02:38 -03:00
@@ -0,0 +1,17 @@
+#ifndef _X25DEVICE_H
+#define _X25DEVICE_H
+
+#include <linux/if_ether.h>
+#include <linux/if_packet.h>
+#include <linux/skbuff.h>
+
+static inline unsigned short x25_type_trans(struct sk_buff *skb,
+					    struct net_device *dev)
+{
+	skb->mac.raw = skb->data;
+	skb->input_dev = skb->dev = dev;
+	skb->pkt_type = PACKET_HOST;
+	
+	return htons(ETH_P_X25);
+}
+#endif

===================================================================


This BitKeeper patch contains the following changesets:
1.2035
## Wrapped with gzip_uu ##


M'XL( #ZO8$$  ^596U/;.!1^1K]",[QL=S>.;KZEA:$%NC!LMPRTG<ZTG8PL
MR\2-8V=L)\"N][_OD0T!0M+$Z?*$"7:PI*.C[WSG(K&-/Q8Z[VU)-=)H&Q]E
M1=G;4EFJ51E/I:6RD17DT'"69=#0U5=E+KNF<S<8=HMA/YA$48=9#H(^I[)4
M SS5>=';HA:?O2FOQ[JW=7;XQ\<_7Y\AM+.#]P<RO=#GNL0[.ZC,\JE,PF)/
MEH,D2RV8(2U&NJQGKV9=*T8(@Q^;NIS83D4=(MQ*T9!2*:@."1.>(Y#1;4^.
M0D=80YVG.ODNTQBF**PLOW@H35!".!6$$EHYPK,%.L#48H3;F(@N)5W",>,]
M0GNVTR'PA>!:^CP\^#<'=PAZ@__?E>PCA;^<G[SY^/;M-QRG99Z%$Z7Q%;/[
M!M%^+1WZP.<\ODAUV,G %L%U#[_.4U CP_O2Z#/(<*CQ.YUD^-5"_7=O)90S
M"0=R&H?XW,+OXB31.7X5RJD>[>4Z',C2#-M%)]AQ*$6G=\9$G9870D02M+L"
MMS"/#:>Z<1&F]:T/$,215-I2]Z $.[**,8_Q2GE,DL"/M*.%$M)>;+8YP2)9
M)-QP1, $5(B*.XRX:ZL+<'8O9=HU]I+%]9RN0#E!'#"^$W+F.U*$82C=(%JE
MZT*I#Y2TA;<^IK?B$CD.=#G0^6,U.>4^ XXZ2MO*#[C-;!+*-=6<DWM?44I\
MAX.BBP7%J4HFH:X%P5I#/8W!)(/')N&N7P7:UX&KB!8>=Q1G/R/3KIAO$X/@
MV 2OO9%,PUP.=9%%Y4+H!F&B#&END>/$)2ZWB5=1E[FL<@7G'@^(#'A((D>O
MB=Q#L0_6['';:6UA=:VN[JMY9V#F,Y]6@& 8<1(PEVH/ M]Z6CZ4^M"\7+ Z
MV"^!W83^O_0ECN)$]Y9U0A'66*!/\(N>@"AUP"?ST5Z('T=[\A317N$W<7FB
M]1BBK8$$+\^UW65@G>!ZF1"3E_4XPX\@^(S)E<?H!L'[R2Q"VUJ$ND^3@-]B
M"J V >$][N27]0?6OASA]C >$TQ=M!U'::@CW/_,[(/#3\?[A_TCM UOXE0_
M?/D5^C:3XU=)G$ZNNG'4;X+L8'=1VUBJH2X7-19#PRG3\A45I2QC!>M*S(R3
MM*AK"EP,LKR<*SI^*<I\HDI\PTG\*\CY'6V9"\-UTPK(]!M8\*_P?('^05O0
ML;,[DLK*Y27>P?6?H2SERYNF.!U/ZE&SQOHKW&][C(=EK0F\/7V]?W+XH7_T
M_OP#M**M7)>3/,6#,@,5#S\<]4\-;B]>HG_1MD[#.*K#T?) :R+2$P5]-(WS
M;&\L<Z63R-RMV@ 66&V<2) *LUB3X:HL0"@E##(\]2MA>]QKO,5IZRX"=^@S
MK%>;Q#GGQ\L1W\25F8W9/2^;"P[&S0X$Q38Z%C:$EAM&YUF9J2P!1L^[&;B5
MX3Y0^,!US3"/MAMVG_#+RMS5>["?K\!1,$F'>U%AE9.1%>HOM_-]6Z\()QYA
MU(6LX57"]QRWX7WKQ&UXSYXA[^M]RQ+>+\-](_9S8.</V'] ?8&Y>?C0\;AY
M0-)8A\_*M'=V;Y**\0C&7"@+85)22]E0B.W70ARVN9!%6>6N,%[?O38LU9$<
MCD=[61$FYHCCR_<+F?\=#[^MJM6)!QLY#A=L[D N;PX_6I=>''?LY^=2S>YF
M12JY WP39P)7695*J/!\DQ6H\/GF>6'!7KT]9UL?(*!BH$>C&&B1S[B[\O@ 
M-A .H[9/O8J!T&:W %&G)6=MR //DK3FQ&4%:>]!O@EKQ>H"B K2D%:T+($8
M=\Q )DC;@;97#VR"_,]YR>S@K;V/M#P)7'//L*"66GQ(2%S**>0+YL+FP15.
M4T0].NM>QWGX\W.>YEQUA?/, -_$=8#=JUR'4<-@>)C<< R1<%T^%TF]E3;.
J(!BK-R#,V60P^+<9+/SV@V?_#U(#K8;%9+3C!$01+R#H/VGJ1_J&&@  
 

--------------040908060501010702090001--
