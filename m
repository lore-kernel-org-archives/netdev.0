From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] new module infrastructure for net_proto_family
Date: Sat, 19 Apr 2003 13:14:57 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030419161457.GA6164@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/net-2.5

	Waiting for OK so that I can submit the conversion for the protocols.

- Arnaldo

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1119, 2003-04-19 13:07:08-03:00, acme@conectiva.com.br
  o net: new module infrastructure for net_proto_family
  
  Next batch of changesets will fix the legacy protocols (IPX, LLC, etc). Tested with LLC and IPX already.


 include/linux/net.h |   13 ++++++++-----
 net/socket.c        |   16 +++++++++++-----
 2 files changed, 19 insertions(+), 10 deletions(-)


diff -Nru a/include/linux/net.h b/include/linux/net.h
--- a/include/linux/net.h	Sat Apr 19 13:10:22 2003
+++ b/include/linux/net.h	Sat Apr 19 13:10:22 2003
@@ -127,14 +127,17 @@
 				      int offset, size_t size, int flags);
 };
 
+struct module;
+
 struct net_proto_family {
-	int	family;
-	int	(*create)(struct socket *sock, int protocol);
+	int		family;
+	int		(*create)(struct socket *sock, int protocol);
 	/* These are counters for the number of different methods of
 	   each we support */
-	short	authentication;
-	short	encryption;
-	short	encrypt_net;
+	short		authentication;
+	short		encryption;
+	short		encrypt_net;
+	struct module	*owner;
 };
 
 struct iovec;
diff -Nru a/net/socket.c b/net/socket.c
--- a/net/socket.c	Sat Apr 19 13:10:22 2003
+++ b/net/socket.c	Sat Apr 19 13:10:22 2003
@@ -506,8 +506,10 @@
  
 void sock_release(struct socket *sock)
 {
-	if (sock->ops) 
+	if (sock->ops) {
 		sock->ops->release(sock);
+		module_put(net_families[sock->ops->family]->owner);
+	}
 
 	if (sock->fasync_list)
 		printk(KERN_ERR "sock_release: fasync list not empty!\n");
@@ -1058,11 +1060,12 @@
 
 	sock->type  = type;
 
+	i = -EBUSY;
+	if (!try_module_get(net_families[family]->owner))
+		goto out_release;
+
 	if ((i = net_families[family]->create(sock, protocol)) < 0) 
-	{
-		sock_release(sock);
-		goto out;
-	}
+		goto out_release;
 
 	*res = sock;
 	security_socket_post_create(sock, family, type, protocol);
@@ -1070,6 +1073,9 @@
 out:
 	net_family_read_unlock();
 	return i;
+out_release:
+	sock_release(sock);
+	goto out;
 }
 
 asmlinkage long sys_socket(int family, int type, int protocol)

===================================================================


This BitKeeper patch contains the following changesets:
1.1119
## Wrapped with gzip_uu ##


M'XL( .YTH3X  ^56;6_;-A#^+/Z*&_K%SF*9I%YMPT&:I-B"!EV0+L"&;3 8
MBK:$RJ)!47&,:?^])\EUG<Q=D&#?:@FB>"2/SSUW#ZTW<%LJ,W:$7"KR!G[6
MI1T[4A=*VNQ>N%(OW3N# S=:X\ PU4LU/'L_+)0=<#<@.'(MK$SA7IER[##7
MVUGL9J7&SLV[GVZOWMX0,IW">2J*A?JH+$RGQ&IS+_*D/!4VS77A6B.*<JEL
MNV>]FUIS2CE> 8L\&H0U"ZD?U9(EC F?J81R/PY]\K9(3*9*]\SH:JW,J5QG
M;I$_=N-1GXTH9;$_JGD4<Y]< ',98R.@WI#Z0WQAWIA&8QH/*+Y0:%@Y?<H&
M_,AA0,D9_+\AG!,)&I#8,3[6L-1)E2O(BKD1I365M)51,->FF3);&6WU;"Z6
M6;[!=7A_4 \6[EKF]1QDNWFI; GK+,]AGCV 317D:B'D!MKE4N<E]"ZO?SN&
MJZOS8U!6]EWX5956);C*IHT91)$ S@&1&R62C4O> X]&'B?77_-)!B_\$4(%
M)2?/,(B!#DLM/RGKRGT21T%4AWX4!;6D\XB'8AX$T?R.C^3AA/W+45L)F ;.
MPCH( _8\E*R0>96H89X5U4-3_6[Z")%/:S[""W&-* L]G\6"BE"I;R#ZAK]'
MP(+8"UO=')C\O()>C9B\%#$-F4>]P*\#[K&X$Y7W6%)\S,+_EE0,@^ [EE27
M[%]@8-;MC1*Y/I3W5RCMDO$1<-(%O.5@0OXD%\QC:+]D'L?&R0KK.%WTDVVO
M=R01H%7]WG9QIR$X:MICA&=W4?<GC;\ O,9?!#YQRE0;]"$JY*BPF10VT\5D
M9U>%-)O50=L,(VV,^X"=([TNE)FT>MB7\_-">/DI0LI4+9<99MN<ZC+)76T6
M!\^0N'%#@]K'F+M_DX"]M/ 9^\XKOSU_GU3^/MFO*/F+@"+]Y+)KG&P.O<;;
MX$2ORC[\C0.,-C7O=+S,5I7M-42T%.!GQ!^[V8.3CI:_L-<4(-:Y\P_6. UI
M4^093&'P[NSVX^^3;IL?K-G,MEX7ZHG7)Z[Z"&"!U(&N[,RH7(ER*TP:<O3>
M[!(T^ _,PK&(H]KVC&.4#,+^TFTC;N!^63SY^K$F4R4_E=5RFC OGL=^0CX#
(H=]Z"@<*    
 
