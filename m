From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] ipx: remove MOD_{INC,DEC}_USE_COUNT
Date: Sun, 27 Apr 2003 12:03:02 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030427150302.GC15637@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

	Please pull from:

bk://kernel.bkbits.net/acme/net-2.5

	Now there are two outstanding changesets in this tree.

- Arnaldo

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1124, 2003-04-27 11:03:43-03:00, acme@conectiva.com.br
  o ipx: remove MOD_{INC,DEC}_USE_COUNT
  
  Now the core networking infrastructure will (finally) do that for the net protocol
  families, its just a matter of setting the ->owner field in the registered struct
  net_proto_family to THIS_MODULE.


 af_ipx.c |   28 ++++------------------------
 1 files changed, 4 insertions(+), 24 deletions(-)


diff -Nru a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
--- a/net/ipx/af_ipx.c	Sun Apr 27 11:56:18 2003
+++ b/net/ipx/af_ipx.c	Sun Apr 27 11:56:18 2003
@@ -95,18 +95,6 @@
 atomic_t ipx_sock_nr;
 #endif
 
-static void ipxcfg_set_auto_create(char val)
-{
-	if (ipxcfg_auto_create_interfaces != val) {
-		if (val)
-			MOD_INC_USE_COUNT;
-		else
-			MOD_DEC_USE_COUNT;
-
-		ipxcfg_auto_create_interfaces = val;
-	}
-}
-
 static void ipxcfg_set_auto_select(char val)
 {
 	ipxcfg_auto_select_primary = val;
@@ -373,7 +361,6 @@
 	if (intrfc->if_dev)
 		dev_put(intrfc->if_dev);
 	kfree(intrfc);
-	MOD_DEC_USE_COUNT;
 }
 
 static void ipxitf_down(struct ipx_interface *intrfc)
@@ -949,7 +936,6 @@
 		intrfc->if_sklist 	= NULL;
 		atomic_set(&intrfc->refcnt, 1);
 		spin_lock_init(&intrfc->if_sklist_lock);
-		MOD_INC_USE_COUNT;
 	}
 
 	return intrfc;
@@ -1272,7 +1258,7 @@
 		case SIOCAIPXITFCRT: 
 			if (get_user(val, (unsigned char *) arg))
 				return -EFAULT;
-			ipxcfg_set_auto_create(val);
+			ipxcfg_auto_create_interfaces = val;
 			break;
 
 		case SIOCAIPXPRISLT: 
@@ -1690,13 +1676,12 @@
 	struct ipx_opt *ipx = NULL;
 	struct sock *sk;
 
-	MOD_INC_USE_COUNT;
 	switch (sock->type) {
 		case SOCK_DGRAM:
 			sk = sk_alloc(PF_IPX, GFP_KERNEL, 1, NULL);
                 	ret = -ENOMEM;
 			if (!sk)
-				goto decmod;
+				goto out;
 			ipx = ipx_sk(sk) = kmalloc(sizeof(*ipx), GFP_KERNEL);
 			if (!ipx)
 				goto outsk;
@@ -1713,7 +1698,7 @@
 			 */
 		case SOCK_STREAM:       /* Allow higher levels to piggyback */
 		default:
-			goto decmod;
+			goto out;
 	}
 #ifdef IPX_REFCNT_DEBUG
         atomic_inc(&ipx_sock_nr);
@@ -1727,8 +1712,6 @@
 	return ret;
 outsk:
 	sk_free(sk);
-decmod:
-	MOD_DEC_USE_COUNT;
 	goto out;
 }
 
@@ -1745,10 +1728,6 @@
 	__set_bit(SOCK_DEAD, &sk->flags);
 	sock->sk = NULL;
 	ipx_destroy_socket(sk);
-
-	if (sock->type == SOCK_DGRAM)
-		MOD_DEC_USE_COUNT;
-
 out:
 	return 0;
 }
@@ -2252,6 +2231,7 @@
 static struct net_proto_family ipx_family_ops = {
 	.family		= PF_IPX,
 	.create		= ipx_create,
+	.owner		= THIS_MODULE,
 };
 
 static struct proto_ops SOCKOPS_WRAPPED(ipx_dgram_ops) = {

===================================================================


This BitKeeper patch contains the following changesets:
1.1124
## Wrapped with gzip_uu ##


M'XL( )+OJSX  ^U5VT[;0!!]]G[%2+RT*G'VYENJ(-HD*A$4$)!G:W'6B8OM
M1?8F*:K[[QT[%5":%A7Q6'OED7?N.^?8>S"K=35P5%)HL@='IK8#)S&E3FRV
M5FYB"O>Z0L6%,:CH+TVA^Q^/^Z6V/>YZ!#7GRB9+6.NJ'CC,%?<[]NY6#YR+
MR:?9R8<+0H9#&"U5N="7VL)P2*RIUBJ?UX?*+G-3NK9295UHV^5L[DT;3BG'
MVV.!H)[?,)_*H$G8G#$EF9Y3+D-?DK;\PZ=E_QI%4,D#)H1D02-$Z'$R!N8R
MQB50T:>RSP-@;$#%0(H>/BF%G5'A'8,>)1_A=3L8D00,9+=?!U#IPJPU?#X;
MQ]^FIZ/]\63T/9Y=3N+1V>ST"NUPG9H-V*6&Q%0:<!H;4]UDY0*R,JU4;:M5
M8E>HV61Y#F_2K%1Y?O<6Y@:=E(745)TW.L)M9:Q)3(Y!4U5D>:;K?<AL#5]6
MM04%A;)65V!2J+6U;8[6LW=@-B5NIYG.YYBUVZST(JO16,]A6P+&Q!1QER+N
MHM_AL<'5T?0RQO9F)Q.7'$,[C9"</^"#]/[Q(H0J2@Z>&0F6TL<#[JLT1N$F
MCR<3>2%.)A)^$X@@O:9*:3\(H]#W=J-@9[ MQ"05G#<4(T8=[)]:/H_^EQ7Z
M!Q+L+E0(Q@+*>-@(R?VHXP(2X D3./\[$R3TN/Q/A=>C0@>:,^A5FVXALL]_
MP\\+V#&.0F#XP1.!#PS?/-X*Q@,/Y?2G=!P'XR?I(E8KK#&IM+(ZSDKL(E6)
MKF$(..3WZ(?PZ_S]*.K\MQ+]G05V!V9E6ZN ^9UV*Y\J!07>2AF")%/./=D:
CN=U1.L[P\<'L/_QFDJ5.;NI5,?2BB&J=2O(#7'#HQ,$&    
 
