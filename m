From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] take2: new module infrastructure for net_proto_family
Date: Sat, 19 Apr 2003 20:34:08 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030419233408.GG6251@conectiva.com.br>
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

	It has your suggestions implemented.

	Waiting for OK so that I can submit the conversion for the protocols.

- Arnaldo

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1119, 2003-04-19 20:26:12-03:00, acme@conectiva.com.br
  o net: new module infrastructure for net_proto_family
    
  Next batch of changesets will fix the legacy protocols (IPX, LLC, etc).
  Tested with LLC and IPX already.


 include/linux/net.h |   13 ++++++++-----
 net/socket.c        |   19 ++++++++++++++-----
 2 files changed, 22 insertions(+), 10 deletions(-)


diff -Nru a/include/linux/net.h b/include/linux/net.h
--- a/include/linux/net.h	Sat Apr 19 20:30:08 2003
+++ b/include/linux/net.h	Sat Apr 19 20:30:08 2003
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
--- a/net/socket.c	Sat Apr 19 20:30:08 2003
+++ b/net/socket.c	Sat Apr 19 20:30:08 2003
@@ -506,8 +506,13 @@
  
 void sock_release(struct socket *sock)
 {
-	if (sock->ops) 
+	if (sock->ops) {
+		const int family = sock->ops->family;
+
 		sock->ops->release(sock);
+		sock->ops = NULL;
+		module_put(net_families[family]->owner);
+	}
 
 	if (sock->fasync_list)
 		printk(KERN_ERR "sock_release: fasync list not empty!\n");
@@ -1058,11 +1063,12 @@
 
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
@@ -1070,6 +1076,9 @@
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


M'XL(  #<H3X  ^U6;6_;-A#^+/Z*&_K%R6*9I-XL&0[2)$47U.B"= $VK(-!
M4[0E5!8-BHYCS/WO/4F.ZW1N@P3[MEF&:)%W#^^>NX?6*[BME$D<(>>*O()?
M=&431^I229O?"5?JN3LQN'"C-2[T,CU7O?-WO5+9+G<#@BO7PLH,[I2I$H>Y
MWF[&KA<J<6[>O+T=O;XA9#B$BTR4,_5!61@.B=7F3A1I=29L5NC2M4:4U5S9
M9L_-SG3#*>5X!2SR:!!N6$C]:"-9RICPF4HI]_NA3UZ7J<E5Y9X;O5PI<R97
MN5L6CV$\ZK.84M;WXPV/^MPGE\!<QE@,U.M1OX<_.$UXF##>I5Y"*=2LG'W+
M!OS,H4O).?R[*5P0"1J0V 1O*YCK=%DHR,NI$94U2VF71L%4F]IDO##:ZO%4
MS/-BC7X >'NO[BU,&N[U%&2S?:5L!:N\*&":WX/-%!1J)N0:&@"IBPHZ5]>_
MG\!H='$"RLHC%Y%^4Y55*?K9K%X 4:: 5B *HT2Z=LD[X%'LA>3Z:TU)]YD?
M0JB@Y/0)%C'97J7E)V5=N4]D'$2;T(^B8"/I-.*AF 9!-)WP6!XNVC^ FF[@
M'F<,@:@7AD^&DI>R6*:J5^3E\KY6@)L]BLBG&Q[CA7'%E(6>S_J"BE"I[T3T
M';S]P(*@CRS7VCE@_+2*7APQ>6[$-&0>]0)_$W"/]5MA>8]EQ1(6_5A6?>@&
M_W%9M07_%;IFU7Q1)M>':O\"M5TQCH4@;=);'@;D([ED'L/Y*^9Q')R\M([3
M,C#8/G6.)09HU5%GZ]SJ"([K\03#L[N\CP8U7@!>C1>!3YPJTP8QQ!)9*FTN
MA<UU.=C-JU*:]>+@W!@SK2?W W:.]:I49M!H8E_23XOA^2<)J3(UG^=8;W.F
MJ[1PM9D=/$?Z-0P--C[FW/ZK!.RYS<_\_[N_/8>_Z?Y]PE_0]I<!C8&1JWKP
ML*&GT*G1NJ=Z41W!W\2IWW8JVW1QFSH,86?1/7V0PD>$8+2&<':K:/G^=C3"
M)G5:9L>+I>W45#9>^$+R9^O^%YK7?8OR<#ZC-&A(:VWD"-!]<W[[X8]!&]E/
MUJS'6ZB9^C'4$>XZ0[Y!+^W8J$*):JMG&G)$KW<),/-#5K@6<<QE;S(A35X/
BCPU)=;@/SH.O[WHR4_)3M9P/93Q!6M,)^0)3*('(1@H     
 
