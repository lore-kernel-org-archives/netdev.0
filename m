From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] ipv4/ipv6: call tcp_timewait_kill in tcp_tw_deschedule
Date: Wed, 14 May 2003 01:35:13 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030514043513.GA30200@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

	As discussed in the past, please pull from:

bk://kernel.bkbits.net/acme/net-2.5

	There is just this outstanding changeset in this tree.

Best Regards,

- Arnaldo

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1114, 2003-05-14 01:26:18-03:00, acme@conectiva.com.br
  o ipv4/ipv6: call tcp_timewait_kill in tcp_tw_deschedule
  
  After all calls to tcp_tw_deschedule we had a call to tcp_timewait_kill,
  move it to the end of tcp_tw_deschedule and unexport tcp_timewait_kill,
  making it static.


 include/net/tcp.h        |    1 -
 net/ipv4/tcp_ipv4.c      |    3 ---
 net/ipv4/tcp_minisocks.c |    5 ++---
 net/ipv6/tcp_ipv6.c      |    2 --
 net/netsyms.c            |    1 -
 5 files changed, 2 insertions(+), 10 deletions(-)


diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	Wed May 14 01:30:34 2003
+++ b/include/net/tcp.h	Wed May 14 01:30:34 2003
@@ -222,7 +222,6 @@
 extern atomic_t tcp_orphan_count;
 extern int tcp_tw_count;
 extern void tcp_time_wait(struct sock *sk, int state, int timeo);
-extern void tcp_timewait_kill(struct tcp_tw_bucket *tw);
 extern void tcp_tw_schedule(struct tcp_tw_bucket *tw, int timeo);
 extern void tcp_tw_deschedule(struct tcp_tw_bucket *tw);
 
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	Wed May 14 01:30:34 2003
+++ b/net/ipv4/tcp_ipv4.c	Wed May 14 01:30:34 2003
@@ -633,7 +633,6 @@
 	} else if (tw) {
 		/* Silly. Should hash-dance instead... */
 		tcp_tw_deschedule(tw);
-		tcp_timewait_kill(tw);
 		NET_INC_STATS_BH(TimeWaitRecycled);
 
 		tcp_tw_put(tw);
@@ -737,7 +736,6 @@
 
  		if (tw) {
  			tcp_tw_deschedule(tw);
- 			tcp_timewait_kill(tw);
  			tcp_tw_put(tw);
  		}
 
@@ -1853,7 +1851,6 @@
 							  tcp_v4_iif(skb));
 		if (sk2) {
 			tcp_tw_deschedule((struct tcp_tw_bucket *)sk);
-			tcp_timewait_kill((struct tcp_tw_bucket *)sk);
 			tcp_tw_put((struct tcp_tw_bucket *)sk);
 			sk = sk2;
 			goto process;
diff -Nru a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
--- a/net/ipv4/tcp_minisocks.c	Wed May 14 01:30:35 2003
+++ b/net/ipv4/tcp_minisocks.c	Wed May 14 01:30:35 2003
@@ -54,7 +54,7 @@
 
 
 /* Must be called with locally disabled BHs. */
-void tcp_timewait_kill(struct tcp_tw_bucket *tw)
+static void tcp_timewait_kill(struct tcp_tw_bucket *tw)
 {
 	struct tcp_ehash_bucket *ehead;
 	struct tcp_bind_hashbucket *bhead;
@@ -166,7 +166,6 @@
 		if (!th->fin || TCP_SKB_CB(skb)->end_seq != tw->rcv_nxt+1) {
 kill_with_rst:
 			tcp_tw_deschedule(tw);
-			tcp_timewait_kill(tw);
 			tcp_tw_put(tw);
 			return TCP_TW_RST;
 		}
@@ -223,7 +222,6 @@
 			if (sysctl_tcp_rfc1337 == 0) {
 kill:
 				tcp_tw_deschedule(tw);
-				tcp_timewait_kill(tw);
 				tcp_tw_put(tw);
 				return TCP_TW_SUCCESS;
 			}
@@ -484,6 +482,7 @@
 			del_timer(&tcp_tw_timer);
 	}
 	spin_unlock(&tw_death_lock);
+	tcp_timewait_kill(tw);
 }
 
 /* Short-time timewait calendar */
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	Wed May 14 01:30:34 2003
+++ b/net/ipv6/tcp_ipv6.c	Wed May 14 01:30:34 2003
@@ -505,7 +505,6 @@
 		/* Silly. Should hash-dance instead... */
 		local_bh_disable();
 		tcp_tw_deschedule(tw);
-		tcp_timewait_kill(tw);
 		NET_INC_STATS_BH(TimeWaitRecycled);
 		local_bh_enable();
 
@@ -1698,7 +1697,6 @@
 		sk2 = tcp_v6_lookup_listener(&skb->nh.ipv6h->daddr, ntohs(th->dest), tcp_v6_iif(skb));
 		if (sk2 != NULL) {
 			tcp_tw_deschedule((struct tcp_tw_bucket *)sk);
-			tcp_timewait_kill((struct tcp_tw_bucket *)sk);
 			tcp_tw_put((struct tcp_tw_bucket *)sk);
 			sk = sk2;
 			goto process;
diff -Nru a/net/netsyms.c b/net/netsyms.c
--- a/net/netsyms.c	Wed May 14 01:30:34 2003
+++ b/net/netsyms.c	Wed May 14 01:30:34 2003
@@ -420,7 +420,6 @@
 EXPORT_SYMBOL(tcp_rcv_state_process);
 EXPORT_SYMBOL(tcp_timewait_state_process);
 EXPORT_SYMBOL(tcp_timewait_cachep);
-EXPORT_SYMBOL(tcp_timewait_kill);
 EXPORT_SYMBOL(tcp_sendmsg);
 EXPORT_SYMBOL(tcp_v4_rebuild_header);
 EXPORT_SYMBOL(tcp_v4_send_check);

===================================================================


This BitKeeper patch contains the following changesets:
1.1114
## Wrapped with gzip_uu ##


M'XL( &O&P3X  ^V876^C.!2&K^-?86EN]BO$WT!6665F.MH=S4A;=377E6-,
M<1MP!2:92OSX-63:I4F:)G0ODQ! -AQ>SGEXL?,.?JMT.1U)E6OP#OYE*S<=
M*5MHY<Q*!LKFP:+T'5?6^HY)9G,]^?!E4F@W)@$'ON=2.I7!E2ZKZ0@']*G%
M/=SKZ>CJTY_?OKZ_ F V@Q\S6=SH?[2#LQEPMES)95+-I<N6M@A<*8LJUZZ[
M9O-T:$,0(O[+<4@1%PT6B(6-P@G&DF&=(,(BP<!M9?+<%M7<%&DI$RV3P)8W
MS\/X\S%#A N,&A2RB(,+B .,,8.(3A"?M#MX2L041V-$IPC!-BOS[6S 7SD<
M(_ !_K^W\!$H:*&Y7[&)7XDI5'*YA$[=7SN3Z[4T[OK.^!93;!K7UXFN5*:3
M>JG]J7YYGSI=PO:L]M3*Z]L]$JXUS&0"Y8_P=O<*O_E0N5UI:%S7GVFHBP3:
M=$\TZ3OJ0G^_MZ5[(9*\,\5-&ZMRTAD5@"]0Q#P"E__Q ,8G?@! $H$_7JF 
MA[0%M7K(JT#UJQ#SL$$4H["1!"V$D*E&"Y*FBNZO^&ZD#4N,4!8W%(<,'R6F
MK>NDS5*[LRTI;C"A(FZ8HMJWTX3AT.LZH&A/N+XN3 5GQ^IBCX'8MJZH88R)
ML"&4+'B:1(M8*X%H>EC8=KR^,([BZ'5AIE#+.M%MWMM80?9,%HM\&!&))J6:
M1$1$A&$6T9B\(&MOM+XHP1"*3LM6;@I3676W0U>K+?3/.%L(%.L%Q9$0_D+Q
M,2G;"MJ72&(L2.>D.W?SNJ,.3"=(Y$KG\Z)V55"8XDX&/L"+V?2_D!$2-\AG
MDW;^2L5S=Z53%A]V5P3'^.RN;W#7CN2_X;A<=XNWR\M=8@9X[@4A'.(.P#U/
M^>L(#K8:\&"K+*UOS7QIBOK[N/.[]OU^P&P0CIB@O.%Q3#8D<CJ 1'HF<3B)
M&Z/?(G%/S8:P*+RQ8' 1,M1N<,3%/C1[;GHBGR>;.QAF[A033CAJO'-2MG%,
M?"JGY,SIFSC=O%@/<=HKW!!8>>CA_-RM-U>%*VN278$_5:ZLE7N\L46M[OQL
MZ1>W_MDC+N*6=$):T#_[$OG-:#>"/_;W_G/0'R$>_0B</$H%M[DM2]/.OWS-
ME4UT!Z>L#PQ4_0@\1!C[<0VB5 RW:')&?SCZFTG"?O3[-1M$/8HZ;_95[GGS
MTSSJ.!I/G, !E<EJKO(T*,IE4,C50Y";Y4L3.(0XB1K*0HX[_L(A_)T'JV_@
H;S-YWL/?4[6&D.?G2RUQCW]%>8G>NNM\1FB:) N)P;\^ZGLZ]Q(     
 
