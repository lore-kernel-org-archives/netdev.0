From: "Kyle C Quest" <kquest@unital.com>
Subject: Re: [PATCH] IPV6_V6ONLY Support, v2 (is Re: [PATCH] IPv6: Allow Both IPv6 and IPv4 Sockets on the Same Port)
Date: Wed, 23 Oct 2002 11:53:07 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <01b901c27aac$4bab0d20$0506330a@leachlap5328>
References: <20021004.001929.03389091.yoshfuji@linux-ipv6.org><200210031552.TAA29921@sex.inr.ac.ru> <20021023.162439.114324450.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I'm just curious... what happened to the generic option, SO_ONEFAMILY, that
would replace
the need for IPV6_V6ONLY?



> In article <200210031552.TAA29921@sex.inr.ac.ru> (at Thu, 3 Oct 2002
19:52:40 +0400 (MSD)), kuznet@ms2.inr.ac.ru says:
>
> > Actually, it would be great if you said what is wrong in that my patch?
> > It looks so simple that I am not ready to agree that real one should be
> > so complicated. :-)
>
> Well, I've refered alexey's patch and simplified many if-clauses.
> Here's the new patch and test results.  seems ok.
>
> --------------------
> Linux IPv6 stack provides the ability for IPv6 applications to
> interoperate with IPv4 applications.  Port space for TCP (or UDP) is
> shared by IPv6 and IPv4.  This conforms to RFC2553.
> However, some kind of applications may want to restrict their use of
> an IPv6 socket to IPv6 communication only.  IPV6_V6ONLY socket option is
> defined for such applications in RFC2553bis, which is successor of
RFC2553.
> This patch allows to bind both IPv6 and IPv4 sockets with the single
> port number at the same time if IPV6_V6ONLY socket options is set to
> the IPv6 socket.
>
> Packet delivery strategy is similar to one before, but we prefer
> IPv4 a bit.
>
> Test results and patch against 2.4.20-pre11 follows.
>
> *** Test for bind(2) ***
>
> [SOCK_DGRAM w/o IPV6_V6ONLY]
> 0 :: 127.1 ::1
> 0 x x x x
> :: x x x x
> 127.1 x x x o
> ::1 x x o x
>
> ==> OK
>
> [SOCK_DGRAM w/ IPV6_V6ONLY]
> 0 :: 127.1 ::1
> 0 x o x o
> :: o x o x
> 127.1 x o x o
> ::1 o x o x
>
> ==> OK
>
> [SOCK_DGRAM w/ SO_REUSEADDR w/o IPV6_V6ONLY]
> 0 :: 127.1 ::1
> 0 o o o o
> :: o o o o
> 127.1 o o o o
> ::1 o o o o
>
> ==> OK
>
> [SOCK_DGRAM w/ SO_REUSEADDR w IPV6_V6ONLY]
> 0 :: 127.1 ::1
> 0 o o o o
> :: o o o o
> 127.1 o o o o
> ::1 o o o o
>
> ==> OK
>
> [SOCK_STREAM w/o IPV6_V6ONLY]
> 0 :: 127.1 ::1
> 0 x x x x
> :: x x x x
> 127.1 x x x o
> ::1 x x o x
>
> ==> OK
>
> [SOCK_STREAM w/ IPV6_V6ONLY]
> 0 :: 127.1 ::1
> 0 x o x o
> :: o x o x
> 127.1 x o x o
> ::1 o x o x
>
> ==> OK
>
> [SOCK_STREAM w/ SO_REUSEADDR w/o IPV6_V6ONLY]
> 0 :: 127.1 ::1
> 0 o o o o
> :: o o o o
> 127.1 o o o o
> ::1 o o o o
>
> ==> OK
>
> [SOCK_STREAM w/ SO_REUSEADDR w IPV6_V6ONLY]
> 0 :: 127.1 ::1
> 0 o o o o
> :: o o o o
> 127.1 o o o o
> ::1 o o o o
>
> ==> OK
>
> *** Test for Receiver ***
>
> [IPv6]
> 1a. :: <- ::1
> received from ::1
>
> 1b. :: w/IPV6_V6ONLY <- ::1
> received from ::1
>
> 2a. :: <- 127.0.0.1
> received from ::1
>
> 2b. :: w/IPV6_V6ONLY <- 127.0.0.1
> none received
>
> 3a. :: <- ff02::1
> received from fe80::EUI64
>
> 3b. :: w/IPV6_V6ONLY <- ff02::1
> received from fe80::EUI64
>
> 4a. :: <- 224.0.0.1
> received from ::ffff:ipv4addr
>
> 4b. :: w/IPV6_V6ONLY <- 224.0.0.1
> none received
>
> ==> OK
>
> [IPv4]
> 1. 0.0.0.0 <- ::1
> none received
>
> 2. 0.0.0.0 <- 127.0.0.1
> received from 127.0.0.1
>
> 3. 0.0.0.0 <- ff02::1
> none received
>
> 4. 0.0.0.0 <- 224.0.0.1
> received from ipv4addr
>
> ==> OK
>
> [IPv6 vs IPv4]
> 5. :: w/IPV6_V6ONLY vs 0.0.0.0 <- ::1
> ipv6 received from ::1
>
> 6. :: w/IPV6_V6ONLY vs 0.0.0.0 <- 127.0.0.1
> ipv4 received from 127.0.0.1
>
> 7. :: w/IPV6_V6ONLY vs 0.0.0.0 <- ff02::1
> ipv6 received from fe80::EUI64
>
> 8. :: w/IPV6_V6ONLY vs 0.0.0.0 <- 224.0.0.1
> ipv4 received from ipv4addra
>
> ==> OK
>
> -------------------------------------------------------------------
> Patch-Name: Allow Both IPv6 and IPv4 Sockets on the Same Port Number
(IPV6_V6ONLY Support) - Rev.2
> Patch-Id: FIX_2_4_20_pre11_DOUBLEBIND-20021023
> Patch-Author: YOSHIFUJI Hideaki / USAGI Project <yoshfuji@linux-ipv6.org>
> Credit: YOSHIFUJI Hideaki / USAGI Project <yoshfuji@linux-ipv6.org>
> Reference: RFC2553bis
> -------------------------------------------------------------------
> Index: Documentation/networking/ip-sysctl.txt
> ===================================================================
> RCS file:
/cvsroot/usagi/usagi-backport/linux24/Documentation/networking/ip-sysctl.txt
,v
> retrieving revision 1.1.1.1
> retrieving revision 1.1.1.1.42.1
> diff -u -r1.1.1.1 -r1.1.1.1.42.1
> --- Documentation/networking/ip-sysctl.txt 20 Aug 2002 09:48:10 -0000
1.1.1.1
> +++ Documentation/networking/ip-sysctl.txt 22 Oct 2002 19:19:48 -0000
1.1.1.1.42.1
> @@ -462,6 +462,15 @@
>  IPv6 has no global variables such as tcp_*.  tcp_* settings under ipv4/
also
>  apply to IPv6 [XXX?].
>
> +bindv6only - BOOLEAN
> + Default value for IPV6_V6ONLY socket option,
> + which restricts use of the IPv6 socket to IPv6 communication
> + only.
> + TRUE: disable IPv4-mapped address feature
> + FALSE: enable IPv4-mapped address feature
> +
> + Default: FALSE (as specified in RFC2553bis)
> +
>  conf/default/*:
>   Change the interface-specific default settings.
>
> Index: include/linux/in6.h
> ===================================================================
> RCS file: /cvsroot/usagi/usagi-backport/linux24/include/linux/in6.h,v
> retrieving revision 1.1.1.1
> retrieving revision 1.1.1.1.40.1
> diff -u -r1.1.1.1 -r1.1.1.1.40.1
> --- include/linux/in6.h 20 Aug 2002 09:46:34 -0000 1.1.1.1
> +++ include/linux/in6.h 22 Oct 2002 19:19:48 -0000 1.1.1.1.40.1
> @@ -156,6 +156,7 @@
>  #define IPV6_MTU_DISCOVER 23
>  #define IPV6_MTU 24
>  #define IPV6_RECVERR 25
> +#define IPV6_V6ONLY 26
>
>  /* IPV6_MTU_DISCOVER values */
>  #define IPV6_PMTUDISC_DONT 0
> Index: include/linux/sysctl.h
> ===================================================================
> RCS file: /cvsroot/usagi/usagi-backport/linux24/include/linux/sysctl.h,v
> retrieving revision 1.1.1.2
> retrieving revision 1.1.1.2.16.1
> diff -u -r1.1.1.2 -r1.1.1.2.16.1
> --- include/linux/sysctl.h 9 Oct 2002 01:35:37 -0000 1.1.1.2
> +++ include/linux/sysctl.h 22 Oct 2002 19:19:48 -0000 1.1.1.2.16.1
> @@ -345,7 +345,8 @@
>  enum {
>   NET_IPV6_CONF=16,
>   NET_IPV6_NEIGH=17,
> - NET_IPV6_ROUTE=18
> + NET_IPV6_ROUTE=18,
> + NET_IPV6_BINDV6ONLY=20,
>  };
>
>  enum {
> Index: include/net/ipv6.h
> ===================================================================
> RCS file: /cvsroot/usagi/usagi-backport/linux24/include/net/ipv6.h,v
> retrieving revision 1.1.1.1
> retrieving revision 1.1.1.1.38.1
> diff -u -r1.1.1.1 -r1.1.1.1.38.1
> --- include/net/ipv6.h 20 Aug 2002 09:46:45 -0000 1.1.1.1
> +++ include/net/ipv6.h 22 Oct 2002 19:19:48 -0000 1.1.1.1.38.1
> @@ -88,6 +88,9 @@
>
>  #include <net/sock.h>
>
> +/* sysctls */
> +extern int sysctl_ipv6_bindv6only;
> +
>  extern struct ipv6_mib ipv6_statistics[NR_CPUS*2];
>  #define IP6_INC_STATS(field) SNMP_INC_STATS(ipv6_statistics, field)
>  #define IP6_INC_STATS_BH(field) SNMP_INC_STATS_BH(ipv6_statistics, field)
> Index: include/net/sock.h
> ===================================================================
> RCS file: /cvsroot/usagi/usagi-backport/linux24/include/net/sock.h,v
> retrieving revision 1.1.1.1
> retrieving revision 1.1.1.1.40.1
> diff -u -r1.1.1.1 -r1.1.1.1.40.1
> --- include/net/sock.h 20 Aug 2002 09:46:45 -0000 1.1.1.1
> +++ include/net/sock.h 22 Oct 2002 19:19:48 -0000 1.1.1.1.40.1
> @@ -171,7 +171,8 @@
>   __u8 mc_loop:1,
>                           recverr:1,
>                           sndflow:1,
> -                         pmtudisc:2;
> +                         pmtudisc:2,
> + ipv6only:1;
>
>   struct ipv6_mc_socklist *ipv6_mc_list;
>   struct ipv6_fl_socklist *ipv6_fl_list;
> @@ -188,6 +189,12 @@
>   struct icmp6_filter filter;
>  };
>
> +#define __ipv6_only_sock(sk) ((sk)->net_pinfo.af_inet6.ipv6only)
> +#define ipv6_only_sock(sk) ((sk)->family == PF_INET6 && \
> + (sk)->net_pinfo.af_inet6.ipv6only)
> +#else
> +#define __ipv6_only_sock(sk) 0
> +#define ipv6_only_sock(sk) 0
>  #endif /* IPV6 */
>
>  #if defined(CONFIG_INET) || defined(CONFIG_INET_MODULE)
> Index: net/ipv4/tcp_ipv4.c
> ===================================================================
> RCS file: /cvsroot/usagi/usagi-backport/linux24/net/ipv4/tcp_ipv4.c,v
> retrieving revision 1.1.1.2
> retrieving revision 1.1.1.2.16.2
> diff -u -r1.1.1.2 -r1.1.1.2.16.2
> --- net/ipv4/tcp_ipv4.c 9 Oct 2002 01:35:52 -0000 1.1.1.2
> +++ net/ipv4/tcp_ipv4.c 22 Oct 2002 19:40:48 -0000 1.1.1.2.16.2
> @@ -45,9 +45,13 @@
>   * Vitaly E. Lavrov : Transparent proxy revived after year coma.
>   * Andi Kleen : Fix new listen.
>   * Andi Kleen : Fix accept error reporting.
> + * YOSHIFUJI Hideaki @USAGI: Support IPV6_V6ONLY socket option, which
> + * allow both IPv4 and IPv6 sockets to bind
> + * a single port at the same time.
>   */
>
>  #include <linux/config.h>
> +
>  #include <linux/types.h>
>  #include <linux/fcntl.h>
>  #include <linux/random.h>
> @@ -182,6 +186,7 @@
>   for( ; sk2 != NULL; sk2 = sk2->bind_next) {
>   if (sk != sk2 &&
>       sk2->reuse <= 1 &&
> +     !ipv6_only_sock(sk2) &&
>       sk->bound_dev_if == sk2->bound_dev_if) {
>   if (!sk_reuse ||
>       !sk2->reuse ||
> @@ -418,23 +423,27 @@
>   struct sock *result = NULL;
>   int score, hiscore;
>
> - hiscore=0;
> + hiscore=-1;
>   for(; sk; sk = sk->next) {
> - if(sk->num == hnum) {
> + if(sk->num == hnum && !ipv6_only_sock(sk)) {
>   __u32 rcv_saddr = sk->rcv_saddr;
>
> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> + score = sk->family == PF_INET ? 1 : 0;
> +#else
>   score = 1;
> +#endif
>   if(rcv_saddr) {
>   if (rcv_saddr != daddr)
>   continue;
> - score++;
> + score+=2;
>   }
>   if (sk->bound_dev_if) {
>   if (sk->bound_dev_if != dif)
>   continue;
> - score++;
> + score+=2;
>   }
> - if (score == 3)
> + if (score == 5)
>   return sk;
>   if (score > hiscore) {
>   hiscore = score;
> @@ -456,6 +465,7 @@
>   if (sk->num == hnum &&
>       sk->next == NULL &&
>       (!sk->rcv_saddr || sk->rcv_saddr == daddr) &&
> +     (sk->family == PF_INET || !ipv6_only_sock(sk)) &&
>       !sk->bound_dev_if)
>   goto sherry_cache;
>   sk = __tcp_v4_lookup_listener(sk, daddr, hnum, dif);
> Index: net/ipv4/udp.c
> ===================================================================
> RCS file: /cvsroot/usagi/usagi-backport/linux24/net/ipv4/udp.c,v
> retrieving revision 1.1.1.1
> retrieving revision 1.1.1.1.40.1
> diff -u -r1.1.1.1 -r1.1.1.1.40.1
> --- net/ipv4/udp.c 20 Aug 2002 09:47:02 -0000 1.1.1.1
> +++ net/ipv4/udp.c 22 Oct 2002 19:19:48 -0000 1.1.1.1.40.1
> @@ -61,6 +61,9 @@
>   * return ENOTCONN for unconnected sockets (POSIX)
>   * Janos Farkas : don't deliver multi/broadcasts to a different
>   * bound-to-device socket
> + * YOSHIFUJI Hideaki @USAGI: Support IPV6_V6ONLY socket option, which
> + * allow both IPv4 and IPv6 sockets to bind
> + * a single port at the same time.
>   *
>   *
>   * This program is free software; you can redistribute it and/or
> @@ -85,6 +88,7 @@
>  #include <linux/netdevice.h>
>  #include <net/snmp.h>
>  #include <net/ip.h>
> +#include <net/ipv6.h>
>  #include <net/protocol.h>
>  #include <linux/skbuff.h>
>  #include <net/sock.h>
> @@ -159,6 +163,7 @@
>        sk2 = sk2->next) {
>   if (sk2->num == snum &&
>       sk2 != sk &&
> +     !ipv6_only_sock(sk2) &&
>       sk2->bound_dev_if == sk->bound_dev_if &&
>       (!sk2->rcv_saddr ||
>        !sk->rcv_saddr ||
> @@ -215,29 +220,34 @@
>   int badness = -1;
>
>   for(sk = udp_hash[hnum & (UDP_HTABLE_SIZE - 1)]; sk != NULL; sk =
sk->next) {
> - if(sk->num == hnum) {
> - int score = 0;
> + if(sk->num == hnum && !ipv6_only_sock(sk)) {
> + int score;
> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> + score = sk->family == PF_INET ? 1 : 0;
> +#else
> + score = 1;
> +#endif
>   if(sk->rcv_saddr) {
>   if(sk->rcv_saddr != daddr)
>   continue;
> - score++;
> + score+=2;
>   }
>   if(sk->daddr) {
>   if(sk->daddr != saddr)
>   continue;
> - score++;
> + score+=2;
>   }
>   if(sk->dport) {
>   if(sk->dport != sport)
>   continue;
> - score++;
> + score+=2;
>   }
>   if(sk->bound_dev_if) {
>   if(sk->bound_dev_if != dif)
>   continue;
> - score++;
> + score+=2;
>   }
> - if(score == 4) {
> + if(score == 9) {
>   result = sk;
>   break;
>   } else if(score > badness) {
> @@ -273,6 +283,7 @@
>       (s->daddr && s->daddr!=rmt_addr) ||
>       (s->dport != rmt_port && s->dport != 0) ||
>       (s->rcv_saddr  && s->rcv_saddr != loc_addr) ||
> +     ipv6_only_sock(s) ||
>       (s->bound_dev_if && s->bound_dev_if != dif))
>   continue;
>   break;
> Index: net/ipv6/af_inet6.c
> ===================================================================
> RCS file: /cvsroot/usagi/usagi-backport/linux24/net/ipv6/af_inet6.c,v
> retrieving revision 1.1.1.1
> retrieving revision 1.1.1.1.36.1
> diff -u -r1.1.1.1 -r1.1.1.1.36.1
> --- net/ipv6/af_inet6.c 20 Aug 2002 09:47:02 -0000 1.1.1.1
> +++ net/ipv6/af_inet6.c 22 Oct 2002 19:19:48 -0000 1.1.1.1.36.1
> @@ -88,6 +88,8 @@
>  extern void ipv6_sysctl_unregister(void);
>  #endif
>
> +int sysctl_ipv6_bindv6only;
> +
>  #ifdef INET_REFCNT_DEBUG
>  atomic_t inet6_sock_nr;
>  #endif
> @@ -173,6 +175,8 @@
>   sk->net_pinfo.af_inet6.mc_loop   = 1;
>   sk->net_pinfo.af_inet6.pmtudisc   = IPV6_PMTUDISC_WANT;
>
> + sk->net_pinfo.af_inet6.ipv6only = sysctl_ipv6_bindv6only;
> +
>   /* Init the ipv4 part of the socket since we can have sockets
>   * using v6 API for ipv4.
>   */
> Index: net/ipv6/ipv6_sockglue.c
> ===================================================================
> RCS file: /cvsroot/usagi/usagi-backport/linux24/net/ipv6/ipv6_sockglue.c,v
> retrieving revision 1.1.1.1
> retrieving revision 1.1.1.1.36.1
> diff -u -r1.1.1.1 -r1.1.1.1.36.1
> --- net/ipv6/ipv6_sockglue.c 20 Aug 2002 09:47:02 -0000 1.1.1.1
> +++ net/ipv6/ipv6_sockglue.c 22 Oct 2002 19:19:48 -0000 1.1.1.1.36.1
> @@ -157,7 +157,8 @@
>   break;
>   }
>
> - if (!(ipv6_addr_type(&np->daddr) & IPV6_ADDR_MAPPED)) {
> + if (ipv6_only_sock(sk) ||
> +     !(ipv6_addr_type(&np->daddr) & IPV6_ADDR_MAPPED)) {
>   retv = -EADDRNOTAVAIL;
>   break;
>   }
> @@ -203,6 +204,13 @@
>   }
>   goto e_inval;
>
> + case IPV6_V6ONLY:
> + if (sk->num)
> + goto e_inval;
> + np->ipv6only = valbool;
> + retv = 0;
> + break;
> +
>   case IPV6_PKTINFO:
>   np->rxopt.bits.rxinfo = valbool;
>   retv = 0;
> @@ -465,6 +473,10 @@
>   return -ENOTCONN;
>   break;
>   }
> +
> + case IPV6_V6ONLY:
> + val = np->ipv6only;
> + break;
>
>   case IPV6_PKTINFO:
>   val = np->rxopt.bits.rxinfo;
> Index: net/ipv6/sysctl_net_ipv6.c
> ===================================================================
> RCS file:
/cvsroot/usagi/usagi-backport/linux24/net/ipv6/sysctl_net_ipv6.c,v
> retrieving revision 1.1.1.1
> retrieving revision 1.1.1.1.40.1
> diff -u -r1.1.1.1 -r1.1.1.1.40.1
> --- net/ipv6/sysctl_net_ipv6.c 20 Aug 2002 09:47:02 -0000 1.1.1.1
> +++ net/ipv6/sysctl_net_ipv6.c 22 Oct 2002 19:19:48 -0000 1.1.1.1.40.1
> @@ -17,6 +17,8 @@
>
>  ctl_table ipv6_table[] = {
>   {NET_IPV6_ROUTE, "route", NULL, 0, 0555, ipv6_route_table},
> + {NET_IPV6_BINDV6ONLY, "bindv6only",
> + &sysctl_ipv6_bindv6only, sizeof(int), 0644, NULL, &proc_dointvec},
>   {0}
>  };
>
> Index: net/ipv6/tcp_ipv6.c
> ===================================================================
> RCS file: /cvsroot/usagi/usagi-backport/linux24/net/ipv6/tcp_ipv6.c,v
> retrieving revision 1.1.1.2
> retrieving revision 1.1.1.2.16.1
> diff -u -r1.1.1.2 -r1.1.1.2.16.1
> --- net/ipv6/tcp_ipv6.c 9 Oct 2002 01:35:53 -0000 1.1.1.2
> +++ net/ipv6/tcp_ipv6.c 22 Oct 2002 19:19:48 -0000 1.1.1.2.16.1
> @@ -14,6 +14,9 @@
>   *
>   * Fixes:
>   * Hideaki YOSHIFUJI : sin6_scope_id support
> + * YOSHIFUJI Hideaki @USAGI: Support IPV6_V6ONLY socket option, which
> + * allow both IPv4 and IPv6 sockets to bind
> + * a single port at the same time.
>   *
>   * This program is free software; you can redistribute it and/or
>   *      modify it under the terms of the GNU General Public License
> @@ -148,14 +151,23 @@
>       !sk2->reuse ||
>       sk2->state == TCP_LISTEN) {
>   /* NOTE: IPv6 tw bucket have different format */
> - if (!sk2->rcv_saddr ||
> -     addr_type == IPV6_ADDR_ANY ||
> -     !ipv6_addr_cmp(&sk->net_pinfo.af_inet6.rcv_saddr,
> -    sk2->state != TCP_TIME_WAIT ?
> -    &sk2->net_pinfo.af_inet6.rcv_saddr :
> -    &((struct tcp_tw_bucket*)sk)->v6_rcv_saddr) ||
> -     (addr_type==IPV6_ADDR_MAPPED && sk2->family==AF_INET &&
> -      sk->rcv_saddr==sk2->rcv_saddr))
> + if ((!sk2->rcv_saddr && !ipv6_only_sock(sk)) ||
> +     (sk2->family == AF_INET6 &&
> +      ipv6_addr_any(&sk2->net_pinfo.af_inet6.rcv_saddr) &&
> +      !(ipv6_only_sock(sk2) && addr_type == IPV6_ADDR_MAPPED)) ||
> +     (addr_type == IPV6_ADDR_ANY &&
> +      (!ipv6_only_sock(sk) ||
> +       !(sk2->family == AF_INET6 ?
ipv6_addr_type(&sk2->net_pinfo.af_inet6.rcv_saddr) == IPV6_ADDR_MAPPED :
1))) ||
> +     (sk2->family == AF_INET6 &&
> +      !ipv6_addr_cmp(&sk->net_pinfo.af_inet6.rcv_saddr,
> +     sk2->state != TCP_TIME_WAIT ?
> +     &sk2->net_pinfo.af_inet6.rcv_saddr :
> +     &((struct tcp_tw_bucket*)sk)->v6_rcv_saddr)) ||
> +     (addr_type == IPV6_ADDR_MAPPED &&
> +      !ipv6_only_sock(sk2) &&
> +      (!sk2->rcv_saddr ||
> +       !sk->rcv_saddr ||
> +       sk->rcv_saddr == sk2->rcv_saddr)))
>   break;
>   }
>   }
> @@ -601,6 +613,9 @@
>   struct sockaddr_in sin;
>
>   SOCK_DEBUG(sk, "connect: ipv4 mapped\n");
> +
> + if (__ipv6_only_sock(sk))
> + return -ENETUNREACH;
>
>   sin.sin_family = AF_INET;
>   sin.sin_port = usin->sin6_port;
> Index: net/ipv6/udp.c
> ===================================================================
> RCS file: /cvsroot/usagi/usagi-backport/linux24/net/ipv6/udp.c,v
> retrieving revision 1.1.1.2
> retrieving revision 1.1.1.2.16.1
> diff -u -r1.1.1.2 -r1.1.1.2.16.1
> --- net/ipv6/udp.c 9 Oct 2002 01:35:53 -0000 1.1.1.2
> +++ net/ipv6/udp.c 22 Oct 2002 19:19:48 -0000 1.1.1.2.16.1
> @@ -11,6 +11,9 @@
>   *
>   * Fixes:
>   * Hideaki YOSHIFUJI : sin6_scope_id support
> + * YOSHIFUJI Hideaki @USAGI: Support IPV6_V6ONLY socket option, which
> + * allow both IPv4 and IPv6 sockets to bind
> + * a single port at the same time.
>   *
>   * This program is free software; you can redistribute it and/or
>   *      modify it under the terms of the GNU General Public License
> @@ -106,13 +109,21 @@
>   if (sk2->num == snum &&
>       sk2 != sk &&
>       sk2->bound_dev_if == sk->bound_dev_if &&
> -     (!sk2->rcv_saddr ||
> -      addr_type == IPV6_ADDR_ANY ||
> -      !ipv6_addr_cmp(&sk->net_pinfo.af_inet6.rcv_saddr,
> -     &sk2->net_pinfo.af_inet6.rcv_saddr) ||
> +     ((!sk2->rcv_saddr && !ipv6_only_sock(sk)) ||
> +      (sk2->family == AF_INET6 &&
> +       ipv6_addr_any(&sk2->net_pinfo.af_inet6.rcv_saddr) &&
> +       !(ipv6_only_sock(sk2) && addr_type == IPV6_ADDR_MAPPED)) ||
> +      (addr_type == IPV6_ADDR_ANY &&
> +       (!ipv6_only_sock(sk) ||
> +        !(sk2->family == AF_INET6 ?
(ipv6_addr_type(&sk2->net_pinfo.af_inet6.rcv_saddr) == IPV6_ADDR_MAPPED) :
1))) ||
> +      (sk2->family == AF_INET6 &&
> +       !ipv6_addr_cmp(&sk->net_pinfo.af_inet6.rcv_saddr,
> +      &sk2->net_pinfo.af_inet6.rcv_saddr)) ||
>        (addr_type == IPV6_ADDR_MAPPED &&
> -       sk2->family == AF_INET &&
> -       sk->rcv_saddr == sk2->rcv_saddr)) &&
> +       !ipv6_only_sock(sk2) &&
> +       (!sk2->rcv_saddr ||
> +        !sk->rcv_saddr ||
> +        sk->rcv_saddr == sk2->rcv_saddr))) &&
>       (!sk2->reuse || !sk->reuse))
>   goto fail;
>   }
> @@ -221,6 +232,8 @@
>   int err;
>
>   if (usin->sin6_family == AF_INET) {
> + if (__ipv6_only_sock(sk))
> + return -EAFNOSUPPORT;
>   err = udp_connect(sk, uaddr, addr_len);
>   goto ipv4_connected;
>   }
> @@ -256,6 +269,9 @@
>   if (addr_type == IPV6_ADDR_MAPPED) {
>   struct sockaddr_in sin;
>
> + if (__ipv6_only_sock(sk))
> + return -ENETUNREACH;
> +
>   sin.sin_family = AF_INET;
>   sin.sin_addr.s_addr = daddr->s6_addr32[3];
>   sin.sin_port = usin->sin6_port;
> @@ -783,8 +799,11 @@
>   fl.oif = 0;
>
>   if (sin6) {
> - if (sin6->sin6_family == AF_INET)
> + if (sin6->sin6_family == AF_INET) {
> + if (__ipv6_only_sock(sk))
> + return -ENETUNREACH;
>   return udp_sendmsg(sk, msg, ulen);
> + }
>
>   if (addr_len < SIN6_LEN_RFC2133)
>   return -EINVAL;
> @@ -830,6 +849,9 @@
>
>   if (addr_type == IPV6_ADDR_MAPPED) {
>   struct sockaddr_in sin;
> +
> + if (__ipv6_only_sock(sk))
> + return -ENETUNREACH;
>
>   sin.sin_family = AF_INET;
>   sin.sin_addr.s_addr = daddr->s6_addr32[3];
>
>
