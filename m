From: Dan Aloni <da-x@gmx.net>
Subject: [BK PATCH 2.6] repost, fix sysctl breakage during network device renaming, for ipv4
Date: Mon, 1 Sep 2003 19:46:24 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901164624.GA26886@callisto.yi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Can you please take a look and comment?

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1292, 2003-08-26 18:30:17+03:00, da-x@gmx.net
  Sysctl assumes its ctl_table.procname field is const, but the 
  networking points ctl_table.procname to dev->name. When renaming 
  a network device using SIOCSIFNAME, dev->name is modified and 
  sysctl's assumption breaks, causing this behaviour, at least:
  
    1. sysctl wouldn't be able to remove the proc entry when the 
       device requests to be unregistered, because it would be 
       using the new name instead of the old one.
    2. proc entries for devices remain with the old name after 
       rename.
    
  This change includes allocating the current device name to a
  new copy upon registering with sysctl, plus re-registering with 
  sysctl when the device is renamed.
  
  This only fixes IPv4.
  Fixes for ax25, core/neighbour.c, decnet, and ipv6 are also planned.
  


 devinet.c |   45 ++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 40 insertions(+), 5 deletions(-)


diff -Nru a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c	Tue Aug 26 18:31:08 2003
+++ b/net/ipv4/devinet.c	Tue Aug 26 18:31:08 2003
@@ -904,6 +904,11 @@
 		 * not interesting to applications using netlink.
 		 */
 		inetdev_changename(dev, in_dev);
+
+#ifdef CONFIG_SYSCTL
+		devinet_sysctl_unregister(&in_dev->cnf);
+		devinet_sysctl_register(in_dev, &in_dev->cnf);
+#endif
 		break;
 	}
 out:
@@ -1295,12 +1300,21 @@
 	},
 };
 
+static char *strdup(char *s)
+{
+	char *rv = kmalloc(strlen(s)+1, GFP_KERNEL);
+	if (rv)
+		strcpy(rv, s);
+	return rv;
+}
+
 static void devinet_sysctl_register(struct in_device *in_dev,
 				    struct ipv4_devconf *p)
 {
 	int i;
 	struct net_device *dev = in_dev ? in_dev->dev : NULL;
 	struct devinet_sysctl_table *t = kmalloc(sizeof(*t), GFP_KERNEL);
+	char *dev_name = NULL;
 
 	if (!t)
 		return;
@@ -1309,13 +1323,25 @@
 		t->devinet_vars[i].data += (char *)p - (char *)&ipv4_devconf;
 		t->devinet_vars[i].de = NULL;
 	}
+
 	if (dev) {
-		t->devinet_dev[0].procname = dev->name;
+		dev_name = dev->name; 
 		t->devinet_dev[0].ctl_name = dev->ifindex;
 	} else {
-		t->devinet_dev[0].procname = "default";
+		dev_name = "default";
 		t->devinet_dev[0].ctl_name = NET_PROTO_CONF_DEFAULT;
 	}
+
+	/* 
+	 * Make a copy of dev_name, because '.procname' is regarded as const 
+	 * by sysctl and we wouldn't want anyone to change it under our feet
+	 * (see SIOCSIFNAME).
+	 */	
+	dev_name = strdup(dev_name);
+	if (!dev_name)
+	    goto free;
+
+	t->devinet_dev[0].procname    = dev_name;
 	t->devinet_dev[0].child	      = t->devinet_vars;
 	t->devinet_dev[0].de	      = NULL;
 	t->devinet_conf_dir[0].child  = t->devinet_dev;
@@ -1327,9 +1353,17 @@
 
 	t->sysctl_header = register_sysctl_table(t->devinet_root_dir, 0);
 	if (!t->sysctl_header)
-		kfree(t);
-	else
-		p->sysctl = t;
+	    goto free_procname;
+
+	p->sysctl = t;
+	return;
+
+	/* error path */
+ free_procname:
+	kfree(dev_name);
+ free:
+	kfree(t);
+	return;
 }
 
 static void devinet_sysctl_unregister(struct ipv4_devconf *p)
@@ -1338,6 +1372,7 @@
 		struct devinet_sysctl_table *t = p->sysctl;
 		p->sysctl = NULL;
 		unregister_sysctl_table(t->sysctl_header);
+		kfree(t->devinet_dev[0].procname);
 		kfree(t);
 	}
 }

===================================================================


This BitKeeper patch contains the following changesets:
+
## Wrapped with gzip_uu ##


M'XL( #Q]2S\  [56^V_;-A#^V?PK;@VP/&K+>EB*;,-!NC3IC*9)D+08AK8P
M:(FV5<ND1U)VC'G_^XYZV>ECQ8I--FR1O#M^W]WIHP[@G6*RUXAIZY$<P*]"
MZ5YCNGBT.-,XOA<"Q^V96+!V3!_;<R8Y2]MIPK/'EFL%K;60<X*&=U1',U@Q
MJ7H-Q_+J&;U9LE[C_O+5N^L7]X0,!G QHWS*'IB&P8!H(5<TC=4YU;-4<$M+
MRM6":6I%8K&M3;>N;;OX\9U3S_:#K1/8G=-MY,2.0SL.BVVW$P8=LDHXW;1D
M=,ZISB138J(-C_?5+A^?1O3LT/4<U_5<;^L'OA^0E^!8CMMUP?;:=MAV W#"
MGF?WG-/GMM>S;3!I.B_3 \\=:-GD%_AO25R0"!XV*M(I4*6R!5.0: 4X'FDZ
M3IFUE"+B=,%@DK TA@37!%>Z">-,@YXQP  (SU0FX5-8BH1_W5\+B-FJ=68&
M%OPV8QPDPX'QPABTBF*LDHA!ILS*P_#VXF%X=?/BS65SYV]@+$2<(*88*(]-
M )6S.%0%CZ5.!(>Q9'2NFA#1(IJ>H>.8S>@J$9EL M60,HI-B/[X!2Q(&0?6
M(DMC?JC1' P1@U^RA5BQG+6A!8QKN8&UH5)F(K]* I+]D3&%R4!/#))QR::)
MTDRR&+/'#"8DHHN=C$7E7V%EF)(U%'PQY8S&(";YO$ 'P9F5>[C6#DV"]9L(
M64)0!C%-.*P3/:L=\X!T@D#J'?-"E.'PYZU)4Y1W$NX<I5F,H6B:BHCJ"EJ4
M2?32%=FJQ#1OAS4VR7(#V5*8(A>LC6..HTAP$Y9I9@"VOC"HB[E+;;E+HDJH
ML554+$<J>+K!]GQ$D,.[5<<L7>4CDPGZZ/K8 $*R-F?)=#;&PEN1Z:4(&ZZ9
M=T^R7 5 )68E50)Q4<[+'5Z#[W>['7*W$Q+2^I<7(3:UR=EW'EP$TT8<G;:A
MB@,KVG^"NWZX]9S0<;=A3">.'5.G,PG=;CQ^(A+?B&*D)W!\S[:[6S?PPDXN
MC5_:?E\C?Q0E^42Y)21=L>@\P$"6FG\;JX._G< _W7;PQL]ETG4^%TF[^U61
M[-C0\O\7E;S?=>I^'_]3CYH.O4,Y0G'+GX?RZ<V?E74A@'7K6]AK16UNH277
M^1=[Y^XK9?J!#AQV[0!\\H$<)).83>#B]N9J^&KT\/O#Q=MKTFB4L4<%I]%.
MJXY^3O@HU]V(3X[[7YK6AH5=$SYS.& <=9H,\: [A9 HC1(2&7&1<**TC+/E
M43DX)G^21G$O5S" ^2*7G".T2AD_4L?/G2:\NKH;O;Z\O[F\-F"2"1S)U3&B
M0J-HN<%!$Y19D0S/9$SPJD_^0MI#Q[,]<*KXB&^45V$ -^^NK_MFW7%P_0-Y
MB7?&<EC^YX0KX_H ZD-N&)2&P>>&SS#)-$OULR)T"(Z)W6B? &G ";RA<[;7
M%)7C[E@XK,_-PZ*AIE3&YJPKC]\BS'A3-:%1L37;'5IKBM),^08/":/*E99K
M/(5B[%_40)@PU#(3Y4@QMG_.'EMFNMT@^X3*4E4S5?)_JB?0!Z^IP-TFDK&^
MH:M;9U6WX/][^^/N;0"O0<V[;Y+IV>"99'FN2=;3:*/*+P^[;)V5M >@ZUKW
MRP0S*5'VE_C<(PGRU+U'&G,SL<\CMZ@7]/%>0$2#>F)*6RY^DP]ZU2^AT8Q%
5<WP%&5 6GG;&;DC^!H[ZU[+W"@  
 


-- 
Dan Aloni
da-x@gmx.net
