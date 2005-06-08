From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: IPV6 RFC3542 compliance [PATCH]
Date: Wed, 8 Jun 2005 12:49:36 -0600
Message-ID: <OFFD1670C9.EB37D343-ON8825701A.0066F1CB-8825701A.00676801@us.ibm.com>
References: <20050607.171423.106079530.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 006767FF8825701A_="
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050607.171423.106079530.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=_mixed 006767FF8825701A_=
Content-Type: text/plain; charset="US-ASCII"

Below is a patch that adds a warning message for rfc2292-style
use of socket options, and uses a different numeric value for
options that have a different meaning in the rfc3542 API.
It also, of course, adds support for sending and receiving
traffic class, and the new IPV6_RECVx socket options from
rfc3542.

                                        +-DLS

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
diff -ruNp linux-2.6.11.10/include/linux/in6.h 
linux-2.6.11.10T3/include/linux/in6.h
--- linux-2.6.11.10/include/linux/in6.h 2005-05-16 10:51:43.000000000 
-0700
+++ linux-2.6.11.10T3/include/linux/in6.h       2005-06-08 
10:45:25.000000000 -0700
@@ -148,10 +148,10 @@ struct in6_flowlabel_req
  */
 
 #define IPV6_ADDRFORM          1
-#define IPV6_PKTINFO           2
-#define IPV6_HOPOPTS           3
-#define IPV6_DSTOPTS           4
-#define IPV6_RTHDR             5
+#define IPV6_2292PKTINFO       2
+#define IPV6_2292HOPOPTS       3
+#define IPV6_2292DSTOPTS       4
+#define IPV6_2292RTHDR         5
 #define IPV6_PKTOPTIONS                6
 #define IPV6_CHECKSUM          7
 #define IPV6_HOPLIMIT          8
@@ -184,6 +184,12 @@ struct in6_flowlabel_req
 
 #define IPV6_IPSEC_POLICY      34
 #define IPV6_XFRM_POLICY       35
+#define IPV6_RECVPKTINFO       36
+#define IPV6_RECVHOPLIMIT      37
+#define IPV6_RECVRTHDR         38
+#define IPV6_RECVHOPOPTS       39
+#define IPV6_RECVDSTOPTS       40
+#define IPV6_RECVTCLASS                41
 
 /*
  * Multicast:
@@ -198,4 +204,11 @@ struct in6_flowlabel_req
  * MCAST_MSFILTER              48
  */
 
+#define IPV6_PKTINFO           49
+#define IPV6_RTHDR             50
+#define IPV6_HOPOPTS           51
+#define IPV6_DSTOPTS           52
+#define IPV6_TCLASS            53
+#define IPV6_RTHDRDSTOPTS      54
+
 #endif
diff -ruNp linux-2.6.11.10/include/linux/ipv6.h 
linux-2.6.11.10T3/include/linux/ipv6.h
--- linux-2.6.11.10/include/linux/ipv6.h        2005-05-16 
10:51:43.000000000 -0700
+++ linux-2.6.11.10T3/include/linux/ipv6.h      2005-06-07 
15:10:28.000000000 -0700
@@ -221,7 +221,8 @@ struct ipv6_pinfo {
                                rxhlim:1,
                                hopopts:1,
                                dstopts:1,
-                                rxflow:1;
+                                rxflow:1,
+                               rxtclass:1;
                } bits;
                __u8            all;
        } rxopt;
@@ -231,7 +232,8 @@ struct ipv6_pinfo {
                                recverr:1,
                                sndflow:1,
                                pmtudisc:2,
-                               ipv6only:1;
+                               ipv6only:1,
+                               rfc2292:1;
 
        struct ipv6_mc_socklist *ipv6_mc_list;
        struct ipv6_ac_socklist *ipv6_ac_list;
@@ -244,6 +246,7 @@ struct ipv6_pinfo {
                struct ipv6_txoptions *opt;
                struct rt6_info *rt;
                int hop_limit;
+               int tclass;
        } cork;
 };
 
diff -ruNp linux-2.6.11.10/include/net/ipv6.h 
linux-2.6.11.10T3/include/net/ipv6.h
--- linux-2.6.11.10/include/net/ipv6.h  2005-05-16 10:51:49.000000000 
-0700
+++ linux-2.6.11.10T3/include/net/ipv6.h        2005-05-24 
14:57:23.000000000 -0700
@@ -347,6 +347,7 @@ extern int                  ip6_append_data(struct 
sock
                                                int length,
                                                int transhdrlen,
                                                int hlimit,
+                                               int tclass,
                                                struct ipv6_txoptions 
*opt,
                                                struct flowi *fl,
                                                struct rt6_info *rt,
diff -ruNp linux-2.6.11.10/include/net/transp_v6.h 
linux-2.6.11.10T3/include/net/transp_v6.h
--- linux-2.6.11.10/include/net/transp_v6.h     2005-05-16 
10:51:51.000000000 -0700
+++ linux-2.6.11.10T3/include/net/transp_v6.h   2005-05-24 
14:04:11.000000000 -0700
@@ -37,7 +37,7 @@ extern int                    datagram_recv_ctl(struct 
so
 extern int                     datagram_send_ctl(struct msghdr *msg,
                                                  struct flowi *fl,
                                                  struct ipv6_txoptions 
*opt,
-                                                 int *hlimit);
+                                                 int *hlimit, int 
*tclass);
 
 #define                LOOPBACK4_IPV6 __constant_htonl(0x7f000006)
 
diff -ruNp linux-2.6.11.10/net/ipv6/datagram.c 
linux-2.6.11.10T3/net/ipv6/datagram.c
--- linux-2.6.11.10/net/ipv6/datagram.c 2005-05-16 10:52:00.000000000 
-0700
+++ linux-2.6.11.10T3/net/ipv6/datagram.c       2005-06-08 
11:29:31.000000000 -0700
@@ -381,13 +381,19 @@ int datagram_recv_ctl(struct sock *sk, s
 
                src_info.ipi6_ifindex = opt->iif;
                ipv6_addr_copy(&src_info.ipi6_addr, 
&skb->nh.ipv6h->daddr);
-               put_cmsg(msg, SOL_IPV6, IPV6_PKTINFO, sizeof(src_info), 
&src_info);
+               put_cmsg(msg, SOL_IPV6, np->rfc2292 ? IPV6_2292PKTINFO :
+                       IPV6_PKTINFO, sizeof(src_info), &src_info);
        }
 
        if (np->rxopt.bits.rxhlim) {
                int hlim = skb->nh.ipv6h->hop_limit;
                put_cmsg(msg, SOL_IPV6, IPV6_HOPLIMIT, sizeof(hlim), 
&hlim);
        }
+       if (np->rxopt.bits.rxtclass) {
+               u8 tclass = (skb->nh.ipv6h->priority << 4) |
+                       ((skb->nh.ipv6h->flow_lbl[0]>>4) & 0xf);
+               put_cmsg(msg, SOL_IPV6, IPV6_TCLASS, sizeof(tclass), 
&tclass);
+       }
 
        if (np->rxopt.bits.rxflow && (*(u32*)skb->nh.raw & 
IPV6_FLOWINFO_MASK)) {
                u32 flowinfo = *(u32*)skb->nh.raw & IPV6_FLOWINFO_MASK;
@@ -395,26 +401,30 @@ int datagram_recv_ctl(struct sock *sk, s
        }
        if (np->rxopt.bits.hopopts && opt->hop) {
                u8 *ptr = skb->nh.raw + opt->hop;
-               put_cmsg(msg, SOL_IPV6, IPV6_HOPOPTS, (ptr[1]+1)<<3, ptr);
+               put_cmsg(msg, SOL_IPV6, np->rfc2292 ? IPV6_2292HOPOPTS :
+                       IPV6_HOPOPTS, (ptr[1]+1)<<3, ptr);
        }
        if (np->rxopt.bits.dstopts && opt->dst0) {
                u8 *ptr = skb->nh.raw + opt->dst0;
-               put_cmsg(msg, SOL_IPV6, IPV6_DSTOPTS, (ptr[1]+1)<<3, ptr);
+               put_cmsg(msg, SOL_IPV6, np->rfc2292 ? IPV6_2292DSTOPTS :
+                       IPV6_DSTOPTS, (ptr[1]+1)<<3, ptr);
        }
        if (np->rxopt.bits.srcrt && opt->srcrt) {
                struct ipv6_rt_hdr *rthdr = (struct ipv6_rt_hdr 
*)(skb->nh.raw + opt->srcrt);
-               put_cmsg(msg, SOL_IPV6, IPV6_RTHDR, (rthdr->hdrlen+1) << 
3, rthdr);
+               put_cmsg(msg, SOL_IPV6, np->rfc2292 ? IPV6_2292RTHDR :
+                       IPV6_RTHDR, (rthdr->hdrlen+1) << 3, rthdr);
        }
        if (np->rxopt.bits.dstopts && opt->dst1) {
                u8 *ptr = skb->nh.raw + opt->dst1;
-               put_cmsg(msg, SOL_IPV6, IPV6_DSTOPTS, (ptr[1]+1)<<3, ptr);
+               put_cmsg(msg, SOL_IPV6, np->rfc2292 ? IPV6_2292DSTOPTS :
+                       IPV6_DSTOPTS, (ptr[1]+1)<<3, ptr);
        }
        return 0;
 }
 
 int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
                      struct ipv6_txoptions *opt,
-                     int *hlimit)
+                     int *hlimit, int *tclass)
 {
        struct in6_pktinfo *src_info;
        struct cmsghdr *cmsg;
@@ -436,6 +446,7 @@ int datagram_send_ctl(struct msghdr *msg
                        continue;
 
                switch (cmsg->cmsg_type) {
+               case IPV6_2292PKTINFO:
                case IPV6_PKTINFO:
                        if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct 
in6_pktinfo))) {
                                err = -EINVAL;
@@ -491,6 +502,7 @@ int datagram_send_ctl(struct msghdr *msg
                        fl->fl6_flowlabel = IPV6_FLOWINFO_MASK & *(u32 
*)CMSG_DATA(cmsg);
                        break;
 
+               case IPV6_2292HOPOPTS:
                case IPV6_HOPOPTS:
                         if (opt->hopopt || cmsg->cmsg_len < 
CMSG_LEN(sizeof(struct ipv6_opt_hdr))) {
                                err = -EINVAL;
@@ -511,6 +523,7 @@ int datagram_send_ctl(struct msghdr *msg
                        opt->hopopt = hdr;
                        break;
 
+               case IPV6_2292DSTOPTS:
                case IPV6_DSTOPTS:
                         if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct 
ipv6_opt_hdr))) {
                                err = -EINVAL;
@@ -535,6 +548,7 @@ int datagram_send_ctl(struct msghdr *msg
                        opt->dst1opt = hdr;
                        break;
 
+               case IPV6_2292RTHDR:
                case IPV6_RTHDR:
                         if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct 
ipv6_rt_hdr))) {
                                err = -EINVAL;
@@ -587,6 +601,15 @@ int datagram_send_ctl(struct msghdr *msg
                        *hlimit = *(int *)CMSG_DATA(cmsg);
                        break;
 
+               case IPV6_TCLASS:
+                       if (cmsg->cmsg_len != CMSG_LEN(sizeof(int))) {
+                               err = -EINVAL;
+                               goto exit_f;
+                       }
+
+                       *tclass = *(int *)CMSG_DATA(cmsg);
+                       break;
+
                default:
                        LIMIT_NETDEBUG(
                                printk(KERN_DEBUG "invalid cmsg type: 
%d\n", cmsg->cmsg_type));
diff -ruNp linux-2.6.11.10/net/ipv6/icmp.c 
linux-2.6.11.10T3/net/ipv6/icmp.c
--- linux-2.6.11.10/net/ipv6/icmp.c     2005-05-16 10:52:00.000000000 
-0700
+++ linux-2.6.11.10T3/net/ipv6/icmp.c   2005-05-24 15:05:14.000000000 
-0700
@@ -287,7 +287,7 @@ void icmpv6_send(struct sk_buff *skb, in
        int iif = 0;
        int addr_type = 0;
        int len;
-       int hlimit;
+       int hlimit, tclass;
        int err = 0;
 
        if ((u8*)hdr < skb->head || (u8*)(hdr+1) > skb->tail)
@@ -381,6 +381,9 @@ void icmpv6_send(struct sk_buff *skb, in
                hlimit = np->hop_limit;
        if (hlimit < 0)
                hlimit = dst_metric(dst, RTAX_HOPLIMIT);
+       tclass = np->cork.tclass;
+       if (tclass < 0)
+               tclass = 0;
 
        msg.skb = skb;
        msg.offset = skb->nh.raw - skb->data;
@@ -398,7 +401,7 @@ void icmpv6_send(struct sk_buff *skb, in
        err = ip6_append_data(sk, icmpv6_getfrag, &msg,
                              len + sizeof(struct icmp6hdr),
                              sizeof(struct icmp6hdr),
-                             hlimit, NULL, &fl, (struct rt6_info*)dst,
+                             hlimit, tclass, NULL, &fl, (struct 
rt6_info*)dst,
                              MSG_DONTWAIT);
        if (err) {
                ip6_flush_pending_frames(sk);
@@ -432,6 +435,7 @@ static void icmpv6_echo_reply(struct sk_
        struct dst_entry *dst;
        int err = 0;
        int hlimit;
+       int tclass;
 
        saddr = &skb->nh.ipv6h->daddr;
 
@@ -467,15 +471,18 @@ static void icmpv6_echo_reply(struct sk_
                hlimit = np->hop_limit;
        if (hlimit < 0)
                hlimit = dst_metric(dst, RTAX_HOPLIMIT);
+       tclass = np->cork.tclass;
+       if (tclass < 0)
+               tclass = 0;
 
        idev = in6_dev_get(skb->dev);
 
        msg.skb = skb;
        msg.offset = 0;
 
-       err = ip6_append_data(sk, icmpv6_getfrag, &msg, skb->len + 
sizeof(struct icmp6hdr),
-                               sizeof(struct icmp6hdr), hlimit, NULL, 
&fl,
-                               (struct rt6_info*)dst, MSG_DONTWAIT);
+       err = ip6_append_data(sk, icmpv6_getfrag, &msg, skb->len +
+               sizeof(struct icmp6hdr), sizeof(struct icmp6hdr), hlimit,
+               tclass, NULL, &fl, (struct rt6_info*)dst, MSG_DONTWAIT);
 
        if (err) {
                ip6_flush_pending_frames(sk);
diff -ruNp linux-2.6.11.10/net/ipv6/ip6_flowlabel.c 
linux-2.6.11.10T3/net/ipv6/ip6_flowlabel.c
--- linux-2.6.11.10/net/ipv6/ip6_flowlabel.c    2005-05-16 
10:52:00.000000000 -0700
+++ linux-2.6.11.10T3/net/ipv6/ip6_flowlabel.c  2005-05-24 
14:04:28.000000000 -0700
@@ -311,7 +311,7 @@ fl_create(struct in6_flowlabel_req *freq
                msg.msg_control = (void*)(fl->opt+1);
                flowi.oif = 0;
 
-               err = datagram_send_ctl(&msg, &flowi, fl->opt, &junk);
+               err = datagram_send_ctl(&msg, &flowi, fl->opt, &junk, 
&junk);
                if (err)
                        goto done;
                err = -EINVAL;
diff -ruNp linux-2.6.11.10/net/ipv6/ip6_output.c 
linux-2.6.11.10T3/net/ipv6/ip6_output.c
--- linux-2.6.11.10/net/ipv6/ip6_output.c       2005-05-16 
10:52:00.000000000 -0700
+++ linux-2.6.11.10T3/net/ipv6/ip6_output.c     2005-05-24 
14:58:51.000000000 -0700
@@ -211,7 +211,7 @@ int ip6_xmit(struct sock *sk, struct sk_
        struct ipv6hdr *hdr;
        u8  proto = fl->proto;
        int seg_len = skb->len;
-       int hlimit;
+       int hlimit, tclass;
        u32 mtu;
 
        if (opt) {
@@ -253,6 +253,13 @@ int ip6_xmit(struct sock *sk, struct sk_
                hlimit = np->hop_limit;
        if (hlimit < 0)
                hlimit = dst_metric(dst, RTAX_HOPLIMIT);
+       tclass = -1;
+       if (np)
+               tclass = np->cork.tclass;
+       if (tclass < 0)
+               tclass = 0;
+       hdr->priority = (np->cork.tclass>>4) &0xf;
+       hdr->flow_lbl[0] |= (np->cork.tclass & 0xf)<<4;
 
        hdr->payload_len = htons(seg_len);
        hdr->nexthdr = proto;
@@ -806,10 +813,11 @@ out_err_release:
        return err;
 }
 
-int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to, 
int offset, int len, int odd, struct sk_buff *skb),
-                   void *from, int length, int transhdrlen,
-                   int hlimit, struct ipv6_txoptions *opt, struct flowi 
*fl, struct rt6_info *rt,
-                   unsigned int flags)
+int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
+       int offset, int len, int odd, struct sk_buff *skb),
+       void *from, int length, int transhdrlen,
+       int hlimit, int tclass, struct ipv6_txoptions *opt, struct flowi 
*fl,
+       struct rt6_info *rt, unsigned int flags)
 {
        struct inet_sock *inet = inet_sk(sk);
        struct ipv6_pinfo *np = inet6_sk(sk);
@@ -847,6 +855,7 @@ int ip6_append_data(struct sock *sk, int
                np->cork.rt = rt;
                inet->cork.fl = *fl;
                np->cork.hop_limit = hlimit;
+               np->cork.tclass = tclass;
                inet->cork.fragsize = mtu = dst_pmtu(&rt->u.dst);
                inet->cork.length = 0;
                sk->sk_sndmsg_page = NULL;
@@ -1130,6 +1139,10 @@ int ip6_push_pending_frames(struct sock 
 
        *(u32*)hdr = fl->fl6_flowlabel | htonl(0x60000000);
 
+       /* traffic class */
+       hdr->priority = (np->cork.tclass>>4) & 0xf;
+       hdr->flow_lbl[0] |= (np->cork.tclass & 0xf)<<4;
+
        if (skb->len <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN)
                hdr->payload_len = htons(skb->len - sizeof(struct 
ipv6hdr));
        else
diff -ruNp linux-2.6.11.10/net/ipv6/ipv6_sockglue.c 
linux-2.6.11.10T3/net/ipv6/ipv6_sockglue.c
--- linux-2.6.11.10/net/ipv6/ipv6_sockglue.c    2005-05-16 
10:52:00.000000000 -0700
+++ linux-2.6.11.10T3/net/ipv6/ipv6_sockglue.c  2005-06-08 
11:06:47.000000000 -0700
@@ -115,6 +115,15 @@ extern int ip6_mc_msfilter(struct sock *
 extern int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
        struct group_filter __user *optval, int __user *optlen);
 
+/*
+ * warn of obsolete RFC 2292 socket API use
+ */
+static void warn2292(char *optname)
+{
+       printk(KERN_WARNING "process '%s' is using obsolete %s socket 
option\n",
+               current->comm, optname);
+}
+
 
 int ipv6_setsockopt(struct sock *sk, int level, int optname,
                    char __user *optval, int optlen)
@@ -208,33 +217,53 @@ int ipv6_setsockopt(struct sock *sk, int
                retv = 0;
                break;
 
-       case IPV6_PKTINFO:
+       case IPV6_2292PKTINFO:
+               warn2292("IPV6_PKTINFO");
+       case IPV6_RECVPKTINFO:
+               np->rfc2292 = optname == IPV6_2292PKTINFO;
                np->rxopt.bits.rxinfo = valbool;
                retv = 0;
                break;
 
        case IPV6_HOPLIMIT:
+               warn2292("IPV6_HOPLIMIT");
+       case IPV6_RECVHOPLIMIT:
+               np->rfc2292 = optname == IPV6_HOPLIMIT;
                np->rxopt.bits.rxhlim = valbool;
                retv = 0;
                break;
 
-       case IPV6_RTHDR:
+       case IPV6_2292RTHDR:
+               warn2292("IPV6_RTHDR");
+       case IPV6_RECVRTHDR:
                if (val < 0 || val > 2)
                        goto e_inval;
+               np->rfc2292 = optname == IPV6_2292RTHDR;
                np->rxopt.bits.srcrt = val;
                retv = 0;
                break;
 
-       case IPV6_HOPOPTS:
+       case IPV6_2292HOPOPTS:
+               warn2292("IPV6_HOPOPTS");
+       case IPV6_RECVHOPOPTS:
+               np->rfc2292 = optname == IPV6_2292HOPOPTS;
                np->rxopt.bits.hopopts = valbool;
                retv = 0;
                break;
 
-       case IPV6_DSTOPTS:
+       case IPV6_2292DSTOPTS:
+               warn2292("IPV6_DSTOPTS");
+       case IPV6_RECVDSTOPTS:
+               np->rfc2292 = optname == IPV6_2292DSTOPTS;
                np->rxopt.bits.dstopts = valbool;
                retv = 0;
                break;
 
+       case IPV6_RECVTCLASS:
+               np->rxopt.bits.rxtclass = valbool;
+               retv = 0;
+               break;
+
        case IPV6_FLOWINFO:
                np->rxopt.bits.rxflow = valbool;
                retv = 0;
@@ -274,7 +303,7 @@ int ipv6_setsockopt(struct sock *sk, int
                msg.msg_controllen = optlen;
                msg.msg_control = (void*)(opt+1);
 
-               retv = datagram_send_ctl(&msg, &fl, opt, &junk);
+               retv = datagram_send_ctl(&msg, &fl, opt, &junk, &junk);
                if (retv)
                        goto done;
 update:
@@ -620,26 +649,45 @@ int ipv6_getsockopt(struct sock *sk, int
                val = np->ipv6only;
                break;
 
-       case IPV6_PKTINFO:
+       case IPV6_2292PKTINFO:
+               warn2292("IPV6_PKTINFO");
+       case IPV6_RECVPKTINFO:
+               np->rfc2292 = optname == IPV6_2292PKTINFO;
                val = np->rxopt.bits.rxinfo;
                break;
 
        case IPV6_HOPLIMIT:
+               warn2292("IPV6_HOPLIMIT");
+       case IPV6_RECVHOPLIMIT:
+               np->rfc2292 = optname == IPV6_HOPLIMIT;
                val = np->rxopt.bits.rxhlim;
                break;
 
-       case IPV6_RTHDR:
+       case IPV6_2292RTHDR:
+               warn2292("IPV6_RTHDR");
+       case IPV6_RECVRTHDR:
+               np->rfc2292 = optname == IPV6_2292RTHDR;
                val = np->rxopt.bits.srcrt;
                break;
 
-       case IPV6_HOPOPTS:
+       case IPV6_2292HOPOPTS:
+               warn2292("IPV6_HOPOPTS");
+       case IPV6_RECVHOPOPTS:
+               np->rfc2292 = optname == IPV6_2292HOPOPTS;
                val = np->rxopt.bits.hopopts;
                break;
 
-       case IPV6_DSTOPTS:
+       case IPV6_2292DSTOPTS:
+               warn2292("IPV6_DSTOPTS");
+       case IPV6_RECVDSTOPTS:
+               np->rfc2292 = optname == IPV6_2292DSTOPTS;
                val = np->rxopt.bits.dstopts;
                break;
 
+       case IPV6_RECVTCLASS:
+               val = np->rxopt.bits.rxtclass;
+               break;
+
        case IPV6_FLOWINFO:
                val = np->rxopt.bits.rxflow;
                break;
diff -ruNp linux-2.6.11.10/net/ipv6/raw.c linux-2.6.11.10T3/net/ipv6/raw.c
--- linux-2.6.11.10/net/ipv6/raw.c      2005-05-16 10:52:00.000000000 
-0700
+++ linux-2.6.11.10T3/net/ipv6/raw.c    2005-05-24 15:09:42.000000000 
-0700
@@ -617,6 +617,7 @@ static int rawv6_sendmsg(struct kiocb *i
        struct flowi fl;
        int addr_len = msg->msg_namelen;
        int hlimit = -1;
+       int tclass = -1;
        u16 proto;
        int err;
 
@@ -702,7 +703,7 @@ static int rawv6_sendmsg(struct kiocb *i
                memset(opt, 0, sizeof(struct ipv6_txoptions));
                opt->tot_len = sizeof(struct ipv6_txoptions);
 
-               err = datagram_send_ctl(msg, &fl, opt, &hlimit);
+               err = datagram_send_ctl(msg, &fl, opt, &hlimit, &tclass);
                if (err < 0) {
                        fl6_sock_release(flowlabel);
                        return err;
@@ -758,6 +759,12 @@ static int rawv6_sendmsg(struct kiocb *i
                        hlimit = dst_metric(dst, RTAX_HOPLIMIT);
        }
 
+       if (tclass < 0) {
+               tclass = np->cork.tclass;
+               if (tclass < 0)
+                       tclass = 0;
+       }
+
        if (msg->msg_flags&MSG_CONFIRM)
                goto do_confirm;
 
@@ -766,8 +773,9 @@ back_from_confirm:
                err = rawv6_send_hdrinc(sk, msg->msg_iov, len, &fl, 
(struct rt6_info*)dst, msg->msg_flags);
        } else {
                lock_sock(sk);
-               err = ip6_append_data(sk, ip_generic_getfrag, 
msg->msg_iov, len, 0,
-                                       hlimit, opt, &fl, (struct 
rt6_info*)dst, msg->msg_flags);
+               err = ip6_append_data(sk, ip_generic_getfrag, 
msg->msg_iov,
+                       len, 0, hlimit, tclass, opt, &fl, (struct 
rt6_info*)dst,
+                       msg->msg_flags);
 
                if (err)
                        ip6_flush_pending_frames(sk);
diff -ruNp linux-2.6.11.10/net/ipv6/udp.c linux-2.6.11.10T3/net/ipv6/udp.c
--- linux-2.6.11.10/net/ipv6/udp.c      2005-05-16 10:52:00.000000000 
-0700
+++ linux-2.6.11.10T3/net/ipv6/udp.c    2005-05-24 15:11:58.000000000 
-0700
@@ -637,6 +637,7 @@ static int udpv6_sendmsg(struct kiocb *i
        int addr_len = msg->msg_namelen;
        int ulen = len;
        int hlimit = -1;
+       int tclass = -1;
        int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
        int err;
 
@@ -758,7 +759,7 @@ do_udp_sendmsg:
                memset(opt, 0, sizeof(struct ipv6_txoptions));
                opt->tot_len = sizeof(*opt);
 
-               err = datagram_send_ctl(msg, fl, opt, &hlimit);
+               err = datagram_send_ctl(msg, fl, opt, &hlimit, &tclass);
                if (err < 0) {
                        fl6_sock_release(flowlabel);
                        return err;
@@ -812,6 +813,11 @@ do_udp_sendmsg:
                if (hlimit < 0)
                        hlimit = dst_metric(dst, RTAX_HOPLIMIT);
        }
+       if (tclass < 0) {
+               tclass = np->cork.tclass;
+               if (tclass < 0)
+                       tclass = 0;
+       }
 
        if (msg->msg_flags&MSG_CONFIRM)
                goto do_confirm;
@@ -832,9 +838,10 @@ back_from_confirm:
 
 do_append_data:
        up->len += ulen;
-       err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov, ulen, 
sizeof(struct udphdr),
-                             hlimit, opt, fl, (struct rt6_info*)dst,
-                             corkreq ? msg->msg_flags|MSG_MORE : 
msg->msg_flags);
+       err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov, ulen,
+               sizeof(struct udphdr), hlimit, tclass, opt, fl,
+               (struct rt6_info*)dst,
+               corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
        if (err)
                udp_v6_flush_pending_frames(sk);
        else if (!corkreq)


--=_mixed 006767FF8825701A_=
Content-Type: application/octet-stream; name="rfc3542-2.patch"
Content-Disposition: attachment; filename="rfc3542-2.patch"
Content-Transfer-Encoding: base64

ZGlmZiAtcnVOcCBsaW51eC0yLjYuMTEuMTAvaW5jbHVkZS9saW51eC9pbjYuaCBsaW51eC0yLjYu
MTEuMTBUMy9pbmNsdWRlL2xpbnV4L2luNi5oCi0tLSBsaW51eC0yLjYuMTEuMTAvaW5jbHVkZS9s
aW51eC9pbjYuaAkyMDA1LTA1LTE2IDEwOjUxOjQzLjAwMDAwMDAwMCAtMDcwMAorKysgbGludXgt
Mi42LjExLjEwVDMvaW5jbHVkZS9saW51eC9pbjYuaAkyMDA1LTA2LTA4IDEwOjQ1OjI1LjAwMDAw
MDAwMCAtMDcwMApAQCAtMTQ4LDEwICsxNDgsMTAgQEAgc3RydWN0IGluNl9mbG93bGFiZWxfcmVx
CiAgKi8KIAogI2RlZmluZSBJUFY2X0FERFJGT1JNCQkxCi0jZGVmaW5lIElQVjZfUEtUSU5GTwkJ
MgotI2RlZmluZSBJUFY2X0hPUE9QVFMJCTMKLSNkZWZpbmUgSVBWNl9EU1RPUFRTCQk0Ci0jZGVm
aW5lIElQVjZfUlRIRFIJCTUKKyNkZWZpbmUgSVBWNl8yMjkyUEtUSU5GTwkyCisjZGVmaW5lIElQ
VjZfMjI5MkhPUE9QVFMJMworI2RlZmluZSBJUFY2XzIyOTJEU1RPUFRTCTQKKyNkZWZpbmUgSVBW
Nl8yMjkyUlRIRFIJCTUKICNkZWZpbmUgSVBWNl9QS1RPUFRJT05TCQk2CiAjZGVmaW5lIElQVjZf
Q0hFQ0tTVU0JCTcKICNkZWZpbmUgSVBWNl9IT1BMSU1JVAkJOApAQCAtMTg0LDYgKzE4NCwxMiBA
QCBzdHJ1Y3QgaW42X2Zsb3dsYWJlbF9yZXEKIAogI2RlZmluZSBJUFY2X0lQU0VDX1BPTElDWQkz
NAogI2RlZmluZSBJUFY2X1hGUk1fUE9MSUNZCTM1CisjZGVmaW5lIElQVjZfUkVDVlBLVElORk8J
MzYKKyNkZWZpbmUgSVBWNl9SRUNWSE9QTElNSVQJMzcKKyNkZWZpbmUgSVBWNl9SRUNWUlRIRFIJ
CTM4CisjZGVmaW5lIElQVjZfUkVDVkhPUE9QVFMJMzkKKyNkZWZpbmUgSVBWNl9SRUNWRFNUT1BU
Uwk0MAorI2RlZmluZSBJUFY2X1JFQ1ZUQ0xBU1MJCTQxCiAKIC8qCiAgKiBNdWx0aWNhc3Q6CkBA
IC0xOTgsNCArMjA0LDExIEBAIHN0cnVjdCBpbjZfZmxvd2xhYmVsX3JlcQogICogTUNBU1RfTVNG
SUxURVIJCTQ4CiAgKi8KIAorI2RlZmluZSBJUFY2X1BLVElORk8JCTQ5CisjZGVmaW5lIElQVjZf
UlRIRFIJCTUwCisjZGVmaW5lIElQVjZfSE9QT1BUUwkJNTEKKyNkZWZpbmUgSVBWNl9EU1RPUFRT
CQk1MgorI2RlZmluZSBJUFY2X1RDTEFTUwkJNTMKKyNkZWZpbmUgSVBWNl9SVEhEUkRTVE9QVFMJ
NTQKKwogI2VuZGlmCmRpZmYgLXJ1TnAgbGludXgtMi42LjExLjEwL2luY2x1ZGUvbGludXgvaXB2
Ni5oIGxpbnV4LTIuNi4xMS4xMFQzL2luY2x1ZGUvbGludXgvaXB2Ni5oCi0tLSBsaW51eC0yLjYu
MTEuMTAvaW5jbHVkZS9saW51eC9pcHY2LmgJMjAwNS0wNS0xNiAxMDo1MTo0My4wMDAwMDAwMDAg
LTA3MDAKKysrIGxpbnV4LTIuNi4xMS4xMFQzL2luY2x1ZGUvbGludXgvaXB2Ni5oCTIwMDUtMDYt
MDcgMTU6MTA6MjguMDAwMDAwMDAwIC0wNzAwCkBAIC0yMjEsNyArMjIxLDggQEAgc3RydWN0IGlw
djZfcGluZm8gewogCQkJCXJ4aGxpbToxLAogCQkJCWhvcG9wdHM6MSwKIAkJCQlkc3RvcHRzOjEs
Ci0gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHJ4ZmxvdzoxOworICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICByeGZsb3c6MSwKKwkJCQlyeHRjbGFzczoxOwogCQl9IGJpdHM7
CiAJCV9fdTgJCWFsbDsKIAl9IHJ4b3B0OwpAQCAtMjMxLDcgKzIzMiw4IEBAIHN0cnVjdCBpcHY2
X3BpbmZvIHsKIAkgICAgICAgICAgICAgICAgICAgICAgICByZWN2ZXJyOjEsCiAJICAgICAgICAg
ICAgICAgICAgICAgICAgc25kZmxvdzoxLAogCQkJCXBtdHVkaXNjOjIsCi0JCQkJaXB2Nm9ubHk6
MTsKKwkJCQlpcHY2b25seToxLAorCQkJCXJmYzIyOTI6MTsKIAogCXN0cnVjdCBpcHY2X21jX3Nv
Y2tsaXN0CSppcHY2X21jX2xpc3Q7CiAJc3RydWN0IGlwdjZfYWNfc29ja2xpc3QJKmlwdjZfYWNf
bGlzdDsKQEAgLTI0NCw2ICsyNDYsNyBAQCBzdHJ1Y3QgaXB2Nl9waW5mbyB7CiAJCXN0cnVjdCBp
cHY2X3R4b3B0aW9ucyAqb3B0OwogCQlzdHJ1Y3QgcnQ2X2luZm8JKnJ0OwogCQlpbnQgaG9wX2xp
bWl0OworCQlpbnQgdGNsYXNzOwogCX0gY29yazsKIH07CiAKZGlmZiAtcnVOcCBsaW51eC0yLjYu
MTEuMTAvaW5jbHVkZS9uZXQvaXB2Ni5oIGxpbnV4LTIuNi4xMS4xMFQzL2luY2x1ZGUvbmV0L2lw
djYuaAotLS0gbGludXgtMi42LjExLjEwL2luY2x1ZGUvbmV0L2lwdjYuaAkyMDA1LTA1LTE2IDEw
OjUxOjQ5LjAwMDAwMDAwMCAtMDcwMAorKysgbGludXgtMi42LjExLjEwVDMvaW5jbHVkZS9uZXQv
aXB2Ni5oCTIwMDUtMDUtMjQgMTQ6NTc6MjMuMDAwMDAwMDAwIC0wNzAwCkBAIC0zNDcsNiArMzQ3
LDcgQEAgZXh0ZXJuIGludAkJCWlwNl9hcHBlbmRfZGF0YShzdHJ1Y3Qgc29jawogCQkJCQkJaW50
IGxlbmd0aCwKIAkJCQkJCWludCB0cmFuc2hkcmxlbiwKIAkJICAgICAgCQkJCWludCBobGltaXQs
CisJCSAgICAgIAkJCQlpbnQgdGNsYXNzLAogCQkJCQkJc3RydWN0IGlwdjZfdHhvcHRpb25zICpv
cHQsCiAJCQkJCQlzdHJ1Y3QgZmxvd2kgKmZsLAogCQkJCQkJc3RydWN0IHJ0Nl9pbmZvICpydCwK
ZGlmZiAtcnVOcCBsaW51eC0yLjYuMTEuMTAvaW5jbHVkZS9uZXQvdHJhbnNwX3Y2LmggbGludXgt
Mi42LjExLjEwVDMvaW5jbHVkZS9uZXQvdHJhbnNwX3Y2LmgKLS0tIGxpbnV4LTIuNi4xMS4xMC9p
bmNsdWRlL25ldC90cmFuc3BfdjYuaAkyMDA1LTA1LTE2IDEwOjUxOjUxLjAwMDAwMDAwMCAtMDcw
MAorKysgbGludXgtMi42LjExLjEwVDMvaW5jbHVkZS9uZXQvdHJhbnNwX3Y2LmgJMjAwNS0wNS0y
NCAxNDowNDoxMS4wMDAwMDAwMDAgLTA3MDAKQEAgLTM3LDcgKzM3LDcgQEAgZXh0ZXJuIGludAkJ
CWRhdGFncmFtX3JlY3ZfY3RsKHN0cnVjdCBzbwogZXh0ZXJuIGludAkJCWRhdGFncmFtX3NlbmRf
Y3RsKHN0cnVjdCBtc2doZHIgKm1zZywKIAkJCQkJCSAgc3RydWN0IGZsb3dpICpmbCwKIAkJCQkJ
CSAgc3RydWN0IGlwdjZfdHhvcHRpb25zICpvcHQsCi0JCQkJCQkgIGludCAqaGxpbWl0KTsKKwkJ
CQkJCSAgaW50ICpobGltaXQsIGludCAqdGNsYXNzKTsKIAogI2RlZmluZQkJTE9PUEJBQ0s0X0lQ
VjYJCV9fY29uc3RhbnRfaHRvbmwoMHg3ZjAwMDAwNikKIApkaWZmIC1ydU5wIGxpbnV4LTIuNi4x
MS4xMC9uZXQvaXB2Ni9kYXRhZ3JhbS5jIGxpbnV4LTIuNi4xMS4xMFQzL25ldC9pcHY2L2RhdGFn
cmFtLmMKLS0tIGxpbnV4LTIuNi4xMS4xMC9uZXQvaXB2Ni9kYXRhZ3JhbS5jCTIwMDUtMDUtMTYg
MTA6NTI6MDAuMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0yLjYuMTEuMTBUMy9uZXQvaXB2Ni9k
YXRhZ3JhbS5jCTIwMDUtMDYtMDggMTE6Mjk6MzEuMDAwMDAwMDAwIC0wNzAwCkBAIC0zODEsMTMg
KzM4MSwxOSBAQCBpbnQgZGF0YWdyYW1fcmVjdl9jdGwoc3RydWN0IHNvY2sgKnNrLCBzCiAKIAkJ
c3JjX2luZm8uaXBpNl9pZmluZGV4ID0gb3B0LT5paWY7CiAJCWlwdjZfYWRkcl9jb3B5KCZzcmNf
aW5mby5pcGk2X2FkZHIsICZza2ItPm5oLmlwdjZoLT5kYWRkcik7Ci0JCXB1dF9jbXNnKG1zZywg
U09MX0lQVjYsIElQVjZfUEtUSU5GTywgc2l6ZW9mKHNyY19pbmZvKSwgJnNyY19pbmZvKTsKKwkJ
cHV0X2Ntc2cobXNnLCBTT0xfSVBWNiwgbnAtPnJmYzIyOTIgPyBJUFY2XzIyOTJQS1RJTkZPIDoK
KwkJCUlQVjZfUEtUSU5GTywgc2l6ZW9mKHNyY19pbmZvKSwgJnNyY19pbmZvKTsKIAl9CiAKIAlp
ZiAobnAtPnJ4b3B0LmJpdHMucnhobGltKSB7CiAJCWludCBobGltID0gc2tiLT5uaC5pcHY2aC0+
aG9wX2xpbWl0OwogCQlwdXRfY21zZyhtc2csIFNPTF9JUFY2LCBJUFY2X0hPUExJTUlULCBzaXpl
b2YoaGxpbSksICZobGltKTsKIAl9CisJaWYgKG5wLT5yeG9wdC5iaXRzLnJ4dGNsYXNzKSB7CisJ
CXU4IHRjbGFzcyA9IChza2ItPm5oLmlwdjZoLT5wcmlvcml0eSA8PCA0KSB8CisJCQkoKHNrYi0+
bmguaXB2NmgtPmZsb3dfbGJsWzBdPj40KSAmIDB4Zik7CisJCXB1dF9jbXNnKG1zZywgU09MX0lQ
VjYsIElQVjZfVENMQVNTLCBzaXplb2YodGNsYXNzKSwgJnRjbGFzcyk7CisJfQogCiAJaWYgKG5w
LT5yeG9wdC5iaXRzLnJ4ZmxvdyAmJiAoKih1MzIqKXNrYi0+bmgucmF3ICYgSVBWNl9GTE9XSU5G
T19NQVNLKSkgewogCQl1MzIgZmxvd2luZm8gPSAqKHUzMiopc2tiLT5uaC5yYXcgJiBJUFY2X0ZM
T1dJTkZPX01BU0s7CkBAIC0zOTUsMjYgKzQwMSwzMCBAQCBpbnQgZGF0YWdyYW1fcmVjdl9jdGwo
c3RydWN0IHNvY2sgKnNrLCBzCiAJfQogCWlmIChucC0+cnhvcHQuYml0cy5ob3BvcHRzICYmIG9w
dC0+aG9wKSB7CiAJCXU4ICpwdHIgPSBza2ItPm5oLnJhdyArIG9wdC0+aG9wOwotCQlwdXRfY21z
Zyhtc2csIFNPTF9JUFY2LCBJUFY2X0hPUE9QVFMsIChwdHJbMV0rMSk8PDMsIHB0cik7CisJCXB1
dF9jbXNnKG1zZywgU09MX0lQVjYsIG5wLT5yZmMyMjkyID8gSVBWNl8yMjkySE9QT1BUUyA6CisJ
CQlJUFY2X0hPUE9QVFMsIChwdHJbMV0rMSk8PDMsIHB0cik7CiAJfQogCWlmIChucC0+cnhvcHQu
Yml0cy5kc3RvcHRzICYmIG9wdC0+ZHN0MCkgewogCQl1OCAqcHRyID0gc2tiLT5uaC5yYXcgKyBv
cHQtPmRzdDA7Ci0JCXB1dF9jbXNnKG1zZywgU09MX0lQVjYsIElQVjZfRFNUT1BUUywgKHB0clsx
XSsxKTw8MywgcHRyKTsKKwkJcHV0X2Ntc2cobXNnLCBTT0xfSVBWNiwgbnAtPnJmYzIyOTIgPyBJ
UFY2XzIyOTJEU1RPUFRTIDoKKwkJCUlQVjZfRFNUT1BUUywgKHB0clsxXSsxKTw8MywgcHRyKTsK
IAl9CiAJaWYgKG5wLT5yeG9wdC5iaXRzLnNyY3J0ICYmIG9wdC0+c3JjcnQpIHsKIAkJc3RydWN0
IGlwdjZfcnRfaGRyICpydGhkciA9IChzdHJ1Y3QgaXB2Nl9ydF9oZHIgKikoc2tiLT5uaC5yYXcg
KyBvcHQtPnNyY3J0KTsKLQkJcHV0X2Ntc2cobXNnLCBTT0xfSVBWNiwgSVBWNl9SVEhEUiwgKHJ0
aGRyLT5oZHJsZW4rMSkgPDwgMywgcnRoZHIpOworCQlwdXRfY21zZyhtc2csIFNPTF9JUFY2LCBu
cC0+cmZjMjI5MiA/IElQVjZfMjI5MlJUSERSIDoKKwkJCUlQVjZfUlRIRFIsIChydGhkci0+aGRy
bGVuKzEpIDw8IDMsIHJ0aGRyKTsKIAl9CiAJaWYgKG5wLT5yeG9wdC5iaXRzLmRzdG9wdHMgJiYg
b3B0LT5kc3QxKSB7CiAJCXU4ICpwdHIgPSBza2ItPm5oLnJhdyArIG9wdC0+ZHN0MTsKLQkJcHV0
X2Ntc2cobXNnLCBTT0xfSVBWNiwgSVBWNl9EU1RPUFRTLCAocHRyWzFdKzEpPDwzLCBwdHIpOwor
CQlwdXRfY21zZyhtc2csIFNPTF9JUFY2LCBucC0+cmZjMjI5MiA/IElQVjZfMjI5MkRTVE9QVFMg
OgorCQkJSVBWNl9EU1RPUFRTLCAocHRyWzFdKzEpPDwzLCBwdHIpOwogCX0KIAlyZXR1cm4gMDsK
IH0KIAogaW50IGRhdGFncmFtX3NlbmRfY3RsKHN0cnVjdCBtc2doZHIgKm1zZywgc3RydWN0IGZs
b3dpICpmbCwKIAkJICAgICAgc3RydWN0IGlwdjZfdHhvcHRpb25zICpvcHQsCi0JCSAgICAgIGlu
dCAqaGxpbWl0KQorCQkgICAgICBpbnQgKmhsaW1pdCwgaW50ICp0Y2xhc3MpCiB7CiAJc3RydWN0
IGluNl9wa3RpbmZvICpzcmNfaW5mbzsKIAlzdHJ1Y3QgY21zZ2hkciAqY21zZzsKQEAgLTQzNiw2
ICs0NDYsNyBAQCBpbnQgZGF0YWdyYW1fc2VuZF9jdGwoc3RydWN0IG1zZ2hkciAqbXNnCiAJCQlj
b250aW51ZTsKIAogCQlzd2l0Y2ggKGNtc2ctPmNtc2dfdHlwZSkgeworCQljYXNlIElQVjZfMjI5
MlBLVElORk86CiAgCQljYXNlIElQVjZfUEtUSU5GTzoKICAJCQlpZiAoY21zZy0+Y21zZ19sZW4g
PCBDTVNHX0xFTihzaXplb2Yoc3RydWN0IGluNl9wa3RpbmZvKSkpIHsKIAkJCQllcnIgPSAtRUlO
VkFMOwpAQCAtNDkxLDYgKzUwMiw3IEBAIGludCBkYXRhZ3JhbV9zZW5kX2N0bChzdHJ1Y3QgbXNn
aGRyICptc2cKIAkJCWZsLT5mbDZfZmxvd2xhYmVsID0gSVBWNl9GTE9XSU5GT19NQVNLICYgKih1
MzIgKilDTVNHX0RBVEEoY21zZyk7CiAJCQlicmVhazsKIAorCQljYXNlIElQVjZfMjI5MkhPUE9Q
VFM6CiAJCWNhc2UgSVBWNl9IT1BPUFRTOgogICAgICAgICAgICAgICAgICAgICAgICAgaWYgKG9w
dC0+aG9wb3B0IHx8IGNtc2ctPmNtc2dfbGVuIDwgQ01TR19MRU4oc2l6ZW9mKHN0cnVjdCBpcHY2
X29wdF9oZHIpKSkgewogCQkJCWVyciA9IC1FSU5WQUw7CkBAIC01MTEsNiArNTIzLDcgQEAgaW50
IGRhdGFncmFtX3NlbmRfY3RsKHN0cnVjdCBtc2doZHIgKm1zZwogCQkJb3B0LT5ob3BvcHQgPSBo
ZHI7CiAJCQlicmVhazsKIAorCQljYXNlIElQVjZfMjI5MkRTVE9QVFM6CiAJCWNhc2UgSVBWNl9E
U1RPUFRTOgogICAgICAgICAgICAgICAgICAgICAgICAgaWYgKGNtc2ctPmNtc2dfbGVuIDwgQ01T
R19MRU4oc2l6ZW9mKHN0cnVjdCBpcHY2X29wdF9oZHIpKSkgewogCQkJCWVyciA9IC1FSU5WQUw7
CkBAIC01MzUsNiArNTQ4LDcgQEAgaW50IGRhdGFncmFtX3NlbmRfY3RsKHN0cnVjdCBtc2doZHIg
Km1zZwogCQkJb3B0LT5kc3Qxb3B0ID0gaGRyOwogCQkJYnJlYWs7CiAKKwkJY2FzZSBJUFY2XzIy
OTJSVEhEUjoKIAkJY2FzZSBJUFY2X1JUSERSOgogICAgICAgICAgICAgICAgICAgICAgICAgaWYg
KGNtc2ctPmNtc2dfbGVuIDwgQ01TR19MRU4oc2l6ZW9mKHN0cnVjdCBpcHY2X3J0X2hkcikpKSB7
CiAJCQkJZXJyID0gLUVJTlZBTDsKQEAgLTU4Nyw2ICs2MDEsMTUgQEAgaW50IGRhdGFncmFtX3Nl
bmRfY3RsKHN0cnVjdCBtc2doZHIgKm1zZwogCQkJKmhsaW1pdCA9ICooaW50ICopQ01TR19EQVRB
KGNtc2cpOwogCQkJYnJlYWs7CiAKKwkJY2FzZSBJUFY2X1RDTEFTUzoKKwkJCWlmIChjbXNnLT5j
bXNnX2xlbiAhPSBDTVNHX0xFTihzaXplb2YoaW50KSkpIHsKKwkJCQllcnIgPSAtRUlOVkFMOwor
CQkJCWdvdG8gZXhpdF9mOworCQkJfQorCisJCQkqdGNsYXNzID0gKihpbnQgKilDTVNHX0RBVEEo
Y21zZyk7CisJCQlicmVhazsKKwogCQlkZWZhdWx0OgogCQkJTElNSVRfTkVUREVCVUcoCiAJCQkJ
cHJpbnRrKEtFUk5fREVCVUcgImludmFsaWQgY21zZyB0eXBlOiAlZFxuIiwgY21zZy0+Y21zZ190
eXBlKSk7CmRpZmYgLXJ1TnAgbGludXgtMi42LjExLjEwL25ldC9pcHY2L2ljbXAuYyBsaW51eC0y
LjYuMTEuMTBUMy9uZXQvaXB2Ni9pY21wLmMKLS0tIGxpbnV4LTIuNi4xMS4xMC9uZXQvaXB2Ni9p
Y21wLmMJMjAwNS0wNS0xNiAxMDo1MjowMC4wMDAwMDAwMDAgLTA3MDAKKysrIGxpbnV4LTIuNi4x
MS4xMFQzL25ldC9pcHY2L2ljbXAuYwkyMDA1LTA1LTI0IDE1OjA1OjE0LjAwMDAwMDAwMCAtMDcw
MApAQCAtMjg3LDcgKzI4Nyw3IEBAIHZvaWQgaWNtcHY2X3NlbmQoc3RydWN0IHNrX2J1ZmYgKnNr
YiwgaW4KIAlpbnQgaWlmID0gMDsKIAlpbnQgYWRkcl90eXBlID0gMDsKIAlpbnQgbGVuOwotCWlu
dCBobGltaXQ7CisJaW50IGhsaW1pdCwgdGNsYXNzOwogCWludCBlcnIgPSAwOwogCiAJaWYgKCh1
OCopaGRyIDwgc2tiLT5oZWFkIHx8ICh1OCopKGhkcisxKSA+IHNrYi0+dGFpbCkKQEAgLTM4MSw2
ICszODEsOSBAQCB2b2lkIGljbXB2Nl9zZW5kKHN0cnVjdCBza19idWZmICpza2IsIGluCiAJCWhs
aW1pdCA9IG5wLT5ob3BfbGltaXQ7CiAJaWYgKGhsaW1pdCA8IDApCiAJCWhsaW1pdCA9IGRzdF9t
ZXRyaWMoZHN0LCBSVEFYX0hPUExJTUlUKTsKKwl0Y2xhc3MgPSBucC0+Y29yay50Y2xhc3M7CisJ
aWYgKHRjbGFzcyA8IDApCisJCXRjbGFzcyA9IDA7CiAKIAltc2cuc2tiID0gc2tiOwogCW1zZy5v
ZmZzZXQgPSBza2ItPm5oLnJhdyAtIHNrYi0+ZGF0YTsKQEAgLTM5OCw3ICs0MDEsNyBAQCB2b2lk
IGljbXB2Nl9zZW5kKHN0cnVjdCBza19idWZmICpza2IsIGluCiAJZXJyID0gaXA2X2FwcGVuZF9k
YXRhKHNrLCBpY21wdjZfZ2V0ZnJhZywgJm1zZywKIAkJCSAgICAgIGxlbiArIHNpemVvZihzdHJ1
Y3QgaWNtcDZoZHIpLAogCQkJICAgICAgc2l6ZW9mKHN0cnVjdCBpY21wNmhkciksCi0JCQkgICAg
ICBobGltaXQsIE5VTEwsICZmbCwgKHN0cnVjdCBydDZfaW5mbyopZHN0LAorCQkJICAgICAgaGxp
bWl0LCB0Y2xhc3MsIE5VTEwsICZmbCwgKHN0cnVjdCBydDZfaW5mbyopZHN0LAogCQkJICAgICAg
TVNHX0RPTlRXQUlUKTsKIAlpZiAoZXJyKSB7CiAJCWlwNl9mbHVzaF9wZW5kaW5nX2ZyYW1lcyhz
ayk7CkBAIC00MzIsNiArNDM1LDcgQEAgc3RhdGljIHZvaWQgaWNtcHY2X2VjaG9fcmVwbHkoc3Ry
dWN0IHNrXwogCXN0cnVjdCBkc3RfZW50cnkgKmRzdDsKIAlpbnQgZXJyID0gMDsKIAlpbnQgaGxp
bWl0OworCWludCB0Y2xhc3M7CiAKIAlzYWRkciA9ICZza2ItPm5oLmlwdjZoLT5kYWRkcjsKIApA
QCAtNDY3LDE1ICs0NzEsMTggQEAgc3RhdGljIHZvaWQgaWNtcHY2X2VjaG9fcmVwbHkoc3RydWN0
IHNrXwogCQlobGltaXQgPSBucC0+aG9wX2xpbWl0OwogCWlmIChobGltaXQgPCAwKQogCQlobGlt
aXQgPSBkc3RfbWV0cmljKGRzdCwgUlRBWF9IT1BMSU1JVCk7CisJdGNsYXNzID0gbnAtPmNvcmsu
dGNsYXNzOworCWlmICh0Y2xhc3MgPCAwKQorCQl0Y2xhc3MgPSAwOwogCiAJaWRldiA9IGluNl9k
ZXZfZ2V0KHNrYi0+ZGV2KTsKIAogCW1zZy5za2IgPSBza2I7CiAJbXNnLm9mZnNldCA9IDA7CiAK
LQllcnIgPSBpcDZfYXBwZW5kX2RhdGEoc2ssIGljbXB2Nl9nZXRmcmFnLCAmbXNnLCBza2ItPmxl
biArIHNpemVvZihzdHJ1Y3QgaWNtcDZoZHIpLAotCQkJCXNpemVvZihzdHJ1Y3QgaWNtcDZoZHIp
LCBobGltaXQsIE5VTEwsICZmbCwKLQkJCQkoc3RydWN0IHJ0Nl9pbmZvKilkc3QsIE1TR19ET05U
V0FJVCk7CisJZXJyID0gaXA2X2FwcGVuZF9kYXRhKHNrLCBpY21wdjZfZ2V0ZnJhZywgJm1zZywg
c2tiLT5sZW4gKworCQlzaXplb2Yoc3RydWN0IGljbXA2aGRyKSwgc2l6ZW9mKHN0cnVjdCBpY21w
NmhkciksIGhsaW1pdCwKKwkJdGNsYXNzLCBOVUxMLCAmZmwsIChzdHJ1Y3QgcnQ2X2luZm8qKWRz
dCwgTVNHX0RPTlRXQUlUKTsKIAogCWlmIChlcnIpIHsKIAkJaXA2X2ZsdXNoX3BlbmRpbmdfZnJh
bWVzKHNrKTsKZGlmZiAtcnVOcCBsaW51eC0yLjYuMTEuMTAvbmV0L2lwdjYvaXA2X2Zsb3dsYWJl
bC5jIGxpbnV4LTIuNi4xMS4xMFQzL25ldC9pcHY2L2lwNl9mbG93bGFiZWwuYwotLS0gbGludXgt
Mi42LjExLjEwL25ldC9pcHY2L2lwNl9mbG93bGFiZWwuYwkyMDA1LTA1LTE2IDEwOjUyOjAwLjAw
MDAwMDAwMCAtMDcwMAorKysgbGludXgtMi42LjExLjEwVDMvbmV0L2lwdjYvaXA2X2Zsb3dsYWJl
bC5jCTIwMDUtMDUtMjQgMTQ6MDQ6MjguMDAwMDAwMDAwIC0wNzAwCkBAIC0zMTEsNyArMzExLDcg
QEAgZmxfY3JlYXRlKHN0cnVjdCBpbjZfZmxvd2xhYmVsX3JlcSAqZnJlcQogCQltc2cubXNnX2Nv
bnRyb2wgPSAodm9pZCopKGZsLT5vcHQrMSk7CiAJCWZsb3dpLm9pZiA9IDA7CiAKLQkJZXJyID0g
ZGF0YWdyYW1fc2VuZF9jdGwoJm1zZywgJmZsb3dpLCBmbC0+b3B0LCAmanVuayk7CisJCWVyciA9
IGRhdGFncmFtX3NlbmRfY3RsKCZtc2csICZmbG93aSwgZmwtPm9wdCwgJmp1bmssICZqdW5rKTsK
IAkJaWYgKGVycikKIAkJCWdvdG8gZG9uZTsKIAkJZXJyID0gLUVJTlZBTDsKZGlmZiAtcnVOcCBs
aW51eC0yLjYuMTEuMTAvbmV0L2lwdjYvaXA2X291dHB1dC5jIGxpbnV4LTIuNi4xMS4xMFQzL25l
dC9pcHY2L2lwNl9vdXRwdXQuYwotLS0gbGludXgtMi42LjExLjEwL25ldC9pcHY2L2lwNl9vdXRw
dXQuYwkyMDA1LTA1LTE2IDEwOjUyOjAwLjAwMDAwMDAwMCAtMDcwMAorKysgbGludXgtMi42LjEx
LjEwVDMvbmV0L2lwdjYvaXA2X291dHB1dC5jCTIwMDUtMDUtMjQgMTQ6NTg6NTEuMDAwMDAwMDAw
IC0wNzAwCkBAIC0yMTEsNyArMjExLDcgQEAgaW50IGlwNl94bWl0KHN0cnVjdCBzb2NrICpzaywg
c3RydWN0IHNrXwogCXN0cnVjdCBpcHY2aGRyICpoZHI7CiAJdTggIHByb3RvID0gZmwtPnByb3Rv
OwogCWludCBzZWdfbGVuID0gc2tiLT5sZW47Ci0JaW50IGhsaW1pdDsKKwlpbnQgaGxpbWl0LCB0
Y2xhc3M7CiAJdTMyIG10dTsKIAogCWlmIChvcHQpIHsKQEAgLTI1Myw2ICsyNTMsMTMgQEAgaW50
IGlwNl94bWl0KHN0cnVjdCBzb2NrICpzaywgc3RydWN0IHNrXwogCQlobGltaXQgPSBucC0+aG9w
X2xpbWl0OwogCWlmIChobGltaXQgPCAwKQogCQlobGltaXQgPSBkc3RfbWV0cmljKGRzdCwgUlRB
WF9IT1BMSU1JVCk7CisJdGNsYXNzID0gLTE7CisJaWYgKG5wKQorCQl0Y2xhc3MgPSBucC0+Y29y
ay50Y2xhc3M7CisJaWYgKHRjbGFzcyA8IDApCisJCXRjbGFzcyA9IDA7CisJaGRyLT5wcmlvcml0
eSA9IChucC0+Y29yay50Y2xhc3M+PjQpICYweGY7CisJaGRyLT5mbG93X2xibFswXSB8PSAobnAt
PmNvcmsudGNsYXNzICYgMHhmKTw8NDsKIAogCWhkci0+cGF5bG9hZF9sZW4gPSBodG9ucyhzZWdf
bGVuKTsKIAloZHItPm5leHRoZHIgPSBwcm90bzsKQEAgLTgwNiwxMCArODEzLDExIEBAIG91dF9l
cnJfcmVsZWFzZToKIAlyZXR1cm4gZXJyOwogfQogCi1pbnQgaXA2X2FwcGVuZF9kYXRhKHN0cnVj
dCBzb2NrICpzaywgaW50IGdldGZyYWcodm9pZCAqZnJvbSwgY2hhciAqdG8sIGludCBvZmZzZXQs
IGludCBsZW4sIGludCBvZGQsIHN0cnVjdCBza19idWZmICpza2IpLAotCQkgICAgdm9pZCAqZnJv
bSwgaW50IGxlbmd0aCwgaW50IHRyYW5zaGRybGVuLAotCQkgICAgaW50IGhsaW1pdCwgc3RydWN0
IGlwdjZfdHhvcHRpb25zICpvcHQsIHN0cnVjdCBmbG93aSAqZmwsIHN0cnVjdCBydDZfaW5mbyAq
cnQsCi0JCSAgICB1bnNpZ25lZCBpbnQgZmxhZ3MpCitpbnQgaXA2X2FwcGVuZF9kYXRhKHN0cnVj
dCBzb2NrICpzaywgaW50IGdldGZyYWcodm9pZCAqZnJvbSwgY2hhciAqdG8sCisJaW50IG9mZnNl
dCwgaW50IGxlbiwgaW50IG9kZCwgc3RydWN0IHNrX2J1ZmYgKnNrYiksCisJdm9pZCAqZnJvbSwg
aW50IGxlbmd0aCwgaW50IHRyYW5zaGRybGVuLAorCWludCBobGltaXQsIGludCB0Y2xhc3MsIHN0
cnVjdCBpcHY2X3R4b3B0aW9ucyAqb3B0LCBzdHJ1Y3QgZmxvd2kgKmZsLAorCXN0cnVjdCBydDZf
aW5mbyAqcnQsIHVuc2lnbmVkIGludCBmbGFncykKIHsKIAlzdHJ1Y3QgaW5ldF9zb2NrICppbmV0
ID0gaW5ldF9zayhzayk7CiAJc3RydWN0IGlwdjZfcGluZm8gKm5wID0gaW5ldDZfc2soc2spOwpA
QCAtODQ3LDYgKzg1NSw3IEBAIGludCBpcDZfYXBwZW5kX2RhdGEoc3RydWN0IHNvY2sgKnNrLCBp
bnQKIAkJbnAtPmNvcmsucnQgPSBydDsKIAkJaW5ldC0+Y29yay5mbCA9ICpmbDsKIAkJbnAtPmNv
cmsuaG9wX2xpbWl0ID0gaGxpbWl0OworCQlucC0+Y29yay50Y2xhc3MgPSB0Y2xhc3M7CiAJCWlu
ZXQtPmNvcmsuZnJhZ3NpemUgPSBtdHUgPSBkc3RfcG10dSgmcnQtPnUuZHN0KTsKIAkJaW5ldC0+
Y29yay5sZW5ndGggPSAwOwogCQlzay0+c2tfc25kbXNnX3BhZ2UgPSBOVUxMOwpAQCAtMTEzMCw2
ICsxMTM5LDEwIEBAIGludCBpcDZfcHVzaF9wZW5kaW5nX2ZyYW1lcyhzdHJ1Y3Qgc29jayAKIAkK
IAkqKHUzMiopaGRyID0gZmwtPmZsNl9mbG93bGFiZWwgfCBodG9ubCgweDYwMDAwMDAwKTsKIAor
CS8qIHRyYWZmaWMgY2xhc3MgKi8KKwloZHItPnByaW9yaXR5ID0gKG5wLT5jb3JrLnRjbGFzcz4+
NCkgJiAweGY7CisJaGRyLT5mbG93X2xibFswXSB8PSAobnAtPmNvcmsudGNsYXNzICYgMHhmKTw8
NDsKKwogCWlmIChza2ItPmxlbiA8PSBzaXplb2Yoc3RydWN0IGlwdjZoZHIpICsgSVBWNl9NQVhQ
TEVOKQogCQloZHItPnBheWxvYWRfbGVuID0gaHRvbnMoc2tiLT5sZW4gLSBzaXplb2Yoc3RydWN0
IGlwdjZoZHIpKTsKIAllbHNlCmRpZmYgLXJ1TnAgbGludXgtMi42LjExLjEwL25ldC9pcHY2L2lw
djZfc29ja2dsdWUuYyBsaW51eC0yLjYuMTEuMTBUMy9uZXQvaXB2Ni9pcHY2X3NvY2tnbHVlLmMK
LS0tIGxpbnV4LTIuNi4xMS4xMC9uZXQvaXB2Ni9pcHY2X3NvY2tnbHVlLmMJMjAwNS0wNS0xNiAx
MDo1MjowMC4wMDAwMDAwMDAgLTA3MDAKKysrIGxpbnV4LTIuNi4xMS4xMFQzL25ldC9pcHY2L2lw
djZfc29ja2dsdWUuYwkyMDA1LTA2LTA4IDExOjA2OjQ3LjAwMDAwMDAwMCAtMDcwMApAQCAtMTE1
LDYgKzExNSwxNSBAQCBleHRlcm4gaW50IGlwNl9tY19tc2ZpbHRlcihzdHJ1Y3Qgc29jayAqCiBl
eHRlcm4gaW50IGlwNl9tY19tc2ZnZXQoc3RydWN0IHNvY2sgKnNrLCBzdHJ1Y3QgZ3JvdXBfZmls
dGVyICpnc2YsCiAJc3RydWN0IGdyb3VwX2ZpbHRlciBfX3VzZXIgKm9wdHZhbCwgaW50IF9fdXNl
ciAqb3B0bGVuKTsKIAorLyoKKyAqIHdhcm4gb2Ygb2Jzb2xldGUgUkZDIDIyOTIgc29ja2V0IEFQ
SSB1c2UKKyAqLworc3RhdGljIHZvaWQgd2FybjIyOTIoY2hhciAqb3B0bmFtZSkKK3sKKwlwcmlu
dGsoS0VSTl9XQVJOSU5HICJwcm9jZXNzICclcycgaXMgdXNpbmcgb2Jzb2xldGUgJXMgc29ja2V0
IG9wdGlvblxuIiwKKwkJY3VycmVudC0+Y29tbSwgb3B0bmFtZSk7Cit9CisKIAogaW50IGlwdjZf
c2V0c29ja29wdChzdHJ1Y3Qgc29jayAqc2ssIGludCBsZXZlbCwgaW50IG9wdG5hbWUsCiAJCSAg
ICBjaGFyIF9fdXNlciAqb3B0dmFsLCBpbnQgb3B0bGVuKQpAQCAtMjA4LDMzICsyMTcsNTMgQEAg
aW50IGlwdjZfc2V0c29ja29wdChzdHJ1Y3Qgc29jayAqc2ssIGludAogCQlyZXR2ID0gMDsKIAkJ
YnJlYWs7CiAKLQljYXNlIElQVjZfUEtUSU5GTzoKKwljYXNlIElQVjZfMjI5MlBLVElORk86CisJ
CXdhcm4yMjkyKCJJUFY2X1BLVElORk8iKTsKKwljYXNlIElQVjZfUkVDVlBLVElORk86CisJCW5w
LT5yZmMyMjkyID0gb3B0bmFtZSA9PSBJUFY2XzIyOTJQS1RJTkZPOwogCQlucC0+cnhvcHQuYml0
cy5yeGluZm8gPSB2YWxib29sOwogCQlyZXR2ID0gMDsKIAkJYnJlYWs7CiAKIAljYXNlIElQVjZf
SE9QTElNSVQ6CisJCXdhcm4yMjkyKCJJUFY2X0hPUExJTUlUIik7CisJY2FzZSBJUFY2X1JFQ1ZI
T1BMSU1JVDoKKwkJbnAtPnJmYzIyOTIgPSBvcHRuYW1lID09IElQVjZfSE9QTElNSVQ7CiAJCW5w
LT5yeG9wdC5iaXRzLnJ4aGxpbSA9IHZhbGJvb2w7CiAJCXJldHYgPSAwOwogCQlicmVhazsKIAot
CWNhc2UgSVBWNl9SVEhEUjoKKwljYXNlIElQVjZfMjI5MlJUSERSOgorCQl3YXJuMjI5MigiSVBW
Nl9SVEhEUiIpOworCWNhc2UgSVBWNl9SRUNWUlRIRFI6CiAJCWlmICh2YWwgPCAwIHx8IHZhbCA+
IDIpCiAJCQlnb3RvIGVfaW52YWw7CisJCW5wLT5yZmMyMjkyID0gb3B0bmFtZSA9PSBJUFY2XzIy
OTJSVEhEUjsKIAkJbnAtPnJ4b3B0LmJpdHMuc3JjcnQgPSB2YWw7CiAJCXJldHYgPSAwOwogCQli
cmVhazsKIAotCWNhc2UgSVBWNl9IT1BPUFRTOgorCWNhc2UgSVBWNl8yMjkySE9QT1BUUzoKKwkJ
d2FybjIyOTIoIklQVjZfSE9QT1BUUyIpOworCWNhc2UgSVBWNl9SRUNWSE9QT1BUUzoKKwkJbnAt
PnJmYzIyOTIgPSBvcHRuYW1lID09IElQVjZfMjI5MkhPUE9QVFM7CiAJCW5wLT5yeG9wdC5iaXRz
LmhvcG9wdHMgPSB2YWxib29sOwogCQlyZXR2ID0gMDsKIAkJYnJlYWs7CiAKLQljYXNlIElQVjZf
RFNUT1BUUzoKKwljYXNlIElQVjZfMjI5MkRTVE9QVFM6CisJCXdhcm4yMjkyKCJJUFY2X0RTVE9Q
VFMiKTsKKwljYXNlIElQVjZfUkVDVkRTVE9QVFM6CisJCW5wLT5yZmMyMjkyID0gb3B0bmFtZSA9
PSBJUFY2XzIyOTJEU1RPUFRTOwogCQlucC0+cnhvcHQuYml0cy5kc3RvcHRzID0gdmFsYm9vbDsK
IAkJcmV0diA9IDA7CiAJCWJyZWFrOwogCisJY2FzZSBJUFY2X1JFQ1ZUQ0xBU1M6CisJCW5wLT5y
eG9wdC5iaXRzLnJ4dGNsYXNzID0gdmFsYm9vbDsKKwkJcmV0diA9IDA7CisJCWJyZWFrOworCiAJ
Y2FzZSBJUFY2X0ZMT1dJTkZPOgogCQlucC0+cnhvcHQuYml0cy5yeGZsb3cgPSB2YWxib29sOwog
CQlyZXR2ID0gMDsKQEAgLTI3NCw3ICszMDMsNyBAQCBpbnQgaXB2Nl9zZXRzb2Nrb3B0KHN0cnVj
dCBzb2NrICpzaywgaW50CiAJCW1zZy5tc2dfY29udHJvbGxlbiA9IG9wdGxlbjsKIAkJbXNnLm1z
Z19jb250cm9sID0gKHZvaWQqKShvcHQrMSk7CiAKLQkJcmV0diA9IGRhdGFncmFtX3NlbmRfY3Rs
KCZtc2csICZmbCwgb3B0LCAmanVuayk7CisJCXJldHYgPSBkYXRhZ3JhbV9zZW5kX2N0bCgmbXNn
LCAmZmwsIG9wdCwgJmp1bmssICZqdW5rKTsKIAkJaWYgKHJldHYpCiAJCQlnb3RvIGRvbmU7CiB1
cGRhdGU6CkBAIC02MjAsMjYgKzY0OSw0NSBAQCBpbnQgaXB2Nl9nZXRzb2Nrb3B0KHN0cnVjdCBz
b2NrICpzaywgaW50CiAJCXZhbCA9IG5wLT5pcHY2b25seTsKIAkJYnJlYWs7CiAKLQljYXNlIElQ
VjZfUEtUSU5GTzoKKwljYXNlIElQVjZfMjI5MlBLVElORk86CisJCXdhcm4yMjkyKCJJUFY2X1BL
VElORk8iKTsKKwljYXNlIElQVjZfUkVDVlBLVElORk86CisJCW5wLT5yZmMyMjkyID0gb3B0bmFt
ZSA9PSBJUFY2XzIyOTJQS1RJTkZPOwogCQl2YWwgPSBucC0+cnhvcHQuYml0cy5yeGluZm87CiAJ
CWJyZWFrOwogCiAJY2FzZSBJUFY2X0hPUExJTUlUOgorCQl3YXJuMjI5MigiSVBWNl9IT1BMSU1J
VCIpOworCWNhc2UgSVBWNl9SRUNWSE9QTElNSVQ6CisJCW5wLT5yZmMyMjkyID0gb3B0bmFtZSA9
PSBJUFY2X0hPUExJTUlUOwogCQl2YWwgPSBucC0+cnhvcHQuYml0cy5yeGhsaW07CiAJCWJyZWFr
OwogCi0JY2FzZSBJUFY2X1JUSERSOgorCWNhc2UgSVBWNl8yMjkyUlRIRFI6CisJCXdhcm4yMjky
KCJJUFY2X1JUSERSIik7CisJY2FzZSBJUFY2X1JFQ1ZSVEhEUjoKKwkJbnAtPnJmYzIyOTIgPSBv
cHRuYW1lID09IElQVjZfMjI5MlJUSERSOwogCQl2YWwgPSBucC0+cnhvcHQuYml0cy5zcmNydDsK
IAkJYnJlYWs7CiAKLQljYXNlIElQVjZfSE9QT1BUUzoKKwljYXNlIElQVjZfMjI5MkhPUE9QVFM6
CisJCXdhcm4yMjkyKCJJUFY2X0hPUE9QVFMiKTsKKwljYXNlIElQVjZfUkVDVkhPUE9QVFM6CisJ
CW5wLT5yZmMyMjkyID0gb3B0bmFtZSA9PSBJUFY2XzIyOTJIT1BPUFRTOwogCQl2YWwgPSBucC0+
cnhvcHQuYml0cy5ob3BvcHRzOwogCQlicmVhazsKIAotCWNhc2UgSVBWNl9EU1RPUFRTOgorCWNh
c2UgSVBWNl8yMjkyRFNUT1BUUzoKKwkJd2FybjIyOTIoIklQVjZfRFNUT1BUUyIpOworCWNhc2Ug
SVBWNl9SRUNWRFNUT1BUUzoKKwkJbnAtPnJmYzIyOTIgPSBvcHRuYW1lID09IElQVjZfMjI5MkRT
VE9QVFM7CiAJCXZhbCA9IG5wLT5yeG9wdC5iaXRzLmRzdG9wdHM7CiAJCWJyZWFrOwogCisJY2Fz
ZSBJUFY2X1JFQ1ZUQ0xBU1M6CisJCXZhbCA9IG5wLT5yeG9wdC5iaXRzLnJ4dGNsYXNzOworCQli
cmVhazsKKwogCWNhc2UgSVBWNl9GTE9XSU5GTzoKIAkJdmFsID0gbnAtPnJ4b3B0LmJpdHMucnhm
bG93OwogCQlicmVhazsKZGlmZiAtcnVOcCBsaW51eC0yLjYuMTEuMTAvbmV0L2lwdjYvcmF3LmMg
bGludXgtMi42LjExLjEwVDMvbmV0L2lwdjYvcmF3LmMKLS0tIGxpbnV4LTIuNi4xMS4xMC9uZXQv
aXB2Ni9yYXcuYwkyMDA1LTA1LTE2IDEwOjUyOjAwLjAwMDAwMDAwMCAtMDcwMAorKysgbGludXgt
Mi42LjExLjEwVDMvbmV0L2lwdjYvcmF3LmMJMjAwNS0wNS0yNCAxNTowOTo0Mi4wMDAwMDAwMDAg
LTA3MDAKQEAgLTYxNyw2ICs2MTcsNyBAQCBzdGF0aWMgaW50IHJhd3Y2X3NlbmRtc2coc3RydWN0
IGtpb2NiICppCiAJc3RydWN0IGZsb3dpIGZsOwogCWludCBhZGRyX2xlbiA9IG1zZy0+bXNnX25h
bWVsZW47CiAJaW50IGhsaW1pdCA9IC0xOworCWludCB0Y2xhc3MgPSAtMTsKIAl1MTYgcHJvdG87
CiAJaW50IGVycjsKIApAQCAtNzAyLDcgKzcwMyw3IEBAIHN0YXRpYyBpbnQgcmF3djZfc2VuZG1z
ZyhzdHJ1Y3Qga2lvY2IgKmkKIAkJbWVtc2V0KG9wdCwgMCwgc2l6ZW9mKHN0cnVjdCBpcHY2X3R4
b3B0aW9ucykpOwogCQlvcHQtPnRvdF9sZW4gPSBzaXplb2Yoc3RydWN0IGlwdjZfdHhvcHRpb25z
KTsKIAotCQllcnIgPSBkYXRhZ3JhbV9zZW5kX2N0bChtc2csICZmbCwgb3B0LCAmaGxpbWl0KTsK
KwkJZXJyID0gZGF0YWdyYW1fc2VuZF9jdGwobXNnLCAmZmwsIG9wdCwgJmhsaW1pdCwgJnRjbGFz
cyk7CiAJCWlmIChlcnIgPCAwKSB7CiAJCQlmbDZfc29ja19yZWxlYXNlKGZsb3dsYWJlbCk7CiAJ
CQlyZXR1cm4gZXJyOwpAQCAtNzU4LDYgKzc1OSwxMiBAQCBzdGF0aWMgaW50IHJhd3Y2X3NlbmRt
c2coc3RydWN0IGtpb2NiICppCiAJCQlobGltaXQgPSBkc3RfbWV0cmljKGRzdCwgUlRBWF9IT1BM
SU1JVCk7CiAJfQogCisJaWYgKHRjbGFzcyA8IDApIHsKKwkJdGNsYXNzID0gbnAtPmNvcmsudGNs
YXNzOworCQlpZiAodGNsYXNzIDwgMCkKKwkJCXRjbGFzcyA9IDA7CisJfQorCiAJaWYgKG1zZy0+
bXNnX2ZsYWdzJk1TR19DT05GSVJNKQogCQlnb3RvIGRvX2NvbmZpcm07CiAKQEAgLTc2Niw4ICs3
NzMsOSBAQCBiYWNrX2Zyb21fY29uZmlybToKIAkJZXJyID0gcmF3djZfc2VuZF9oZHJpbmMoc2ss
IG1zZy0+bXNnX2lvdiwgbGVuLCAmZmwsIChzdHJ1Y3QgcnQ2X2luZm8qKWRzdCwgbXNnLT5tc2df
ZmxhZ3MpOwogCX0gZWxzZSB7CiAJCWxvY2tfc29jayhzayk7Ci0JCWVyciA9IGlwNl9hcHBlbmRf
ZGF0YShzaywgaXBfZ2VuZXJpY19nZXRmcmFnLCBtc2ctPm1zZ19pb3YsIGxlbiwgMCwKLQkJCQkJ
aGxpbWl0LCBvcHQsICZmbCwgKHN0cnVjdCBydDZfaW5mbyopZHN0LCBtc2ctPm1zZ19mbGFncyk7
CisJCWVyciA9IGlwNl9hcHBlbmRfZGF0YShzaywgaXBfZ2VuZXJpY19nZXRmcmFnLCBtc2ctPm1z
Z19pb3YsCisJCQlsZW4sIDAsIGhsaW1pdCwgdGNsYXNzLCBvcHQsICZmbCwgKHN0cnVjdCBydDZf
aW5mbyopZHN0LAorCQkJbXNnLT5tc2dfZmxhZ3MpOwogCiAJCWlmIChlcnIpCiAJCQlpcDZfZmx1
c2hfcGVuZGluZ19mcmFtZXMoc2spOwpkaWZmIC1ydU5wIGxpbnV4LTIuNi4xMS4xMC9uZXQvaXB2
Ni91ZHAuYyBsaW51eC0yLjYuMTEuMTBUMy9uZXQvaXB2Ni91ZHAuYwotLS0gbGludXgtMi42LjEx
LjEwL25ldC9pcHY2L3VkcC5jCTIwMDUtMDUtMTYgMTA6NTI6MDAuMDAwMDAwMDAwIC0wNzAwCisr
KyBsaW51eC0yLjYuMTEuMTBUMy9uZXQvaXB2Ni91ZHAuYwkyMDA1LTA1LTI0IDE1OjExOjU4LjAw
MDAwMDAwMCAtMDcwMApAQCAtNjM3LDYgKzYzNyw3IEBAIHN0YXRpYyBpbnQgdWRwdjZfc2VuZG1z
ZyhzdHJ1Y3Qga2lvY2IgKmkKIAlpbnQgYWRkcl9sZW4gPSBtc2ctPm1zZ19uYW1lbGVuOwogCWlu
dCB1bGVuID0gbGVuOwogCWludCBobGltaXQgPSAtMTsKKwlpbnQgdGNsYXNzID0gLTE7CiAJaW50
IGNvcmtyZXEgPSB1cC0+Y29ya2ZsYWcgfHwgbXNnLT5tc2dfZmxhZ3MmTVNHX01PUkU7CiAJaW50
IGVycjsKIApAQCAtNzU4LDcgKzc1OSw3IEBAIGRvX3VkcF9zZW5kbXNnOgogCQltZW1zZXQob3B0
LCAwLCBzaXplb2Yoc3RydWN0IGlwdjZfdHhvcHRpb25zKSk7CiAJCW9wdC0+dG90X2xlbiA9IHNp
emVvZigqb3B0KTsKIAotCQllcnIgPSBkYXRhZ3JhbV9zZW5kX2N0bChtc2csIGZsLCBvcHQsICZo
bGltaXQpOworCQllcnIgPSBkYXRhZ3JhbV9zZW5kX2N0bChtc2csIGZsLCBvcHQsICZobGltaXQs
ICZ0Y2xhc3MpOwogCQlpZiAoZXJyIDwgMCkgewogCQkJZmw2X3NvY2tfcmVsZWFzZShmbG93bGFi
ZWwpOwogCQkJcmV0dXJuIGVycjsKQEAgLTgxMiw2ICs4MTMsMTEgQEAgZG9fdWRwX3NlbmRtc2c6
CiAJCWlmIChobGltaXQgPCAwKQogCQkJaGxpbWl0ID0gZHN0X21ldHJpYyhkc3QsIFJUQVhfSE9Q
TElNSVQpOwogCX0KKwlpZiAodGNsYXNzIDwgMCkgeworCQl0Y2xhc3MgPSBucC0+Y29yay50Y2xh
c3M7CisJCWlmICh0Y2xhc3MgPCAwKQorCQkJdGNsYXNzID0gMDsKKwl9CiAKIAlpZiAobXNnLT5t
c2dfZmxhZ3MmTVNHX0NPTkZJUk0pCiAJCWdvdG8gZG9fY29uZmlybTsKQEAgLTgzMiw5ICs4Mzgs
MTAgQEAgYmFja19mcm9tX2NvbmZpcm06CiAKIGRvX2FwcGVuZF9kYXRhOgogCXVwLT5sZW4gKz0g
dWxlbjsKLQllcnIgPSBpcDZfYXBwZW5kX2RhdGEoc2ssIGlwX2dlbmVyaWNfZ2V0ZnJhZywgbXNn
LT5tc2dfaW92LCB1bGVuLCBzaXplb2Yoc3RydWN0IHVkcGhkciksCi0JCQkgICAgICBobGltaXQs
IG9wdCwgZmwsIChzdHJ1Y3QgcnQ2X2luZm8qKWRzdCwKLQkJCSAgICAgIGNvcmtyZXEgPyBtc2ct
Pm1zZ19mbGFnc3xNU0dfTU9SRSA6IG1zZy0+bXNnX2ZsYWdzKTsKKwllcnIgPSBpcDZfYXBwZW5k
X2RhdGEoc2ssIGlwX2dlbmVyaWNfZ2V0ZnJhZywgbXNnLT5tc2dfaW92LCB1bGVuLAorCQlzaXpl
b2Yoc3RydWN0IHVkcGhkciksIGhsaW1pdCwgdGNsYXNzLCBvcHQsIGZsLAorCQkoc3RydWN0IHJ0
Nl9pbmZvKilkc3QsCisJCWNvcmtyZXEgPyBtc2ctPm1zZ19mbGFnc3xNU0dfTU9SRSA6IG1zZy0+
bXNnX2ZsYWdzKTsKIAlpZiAoZXJyKQogCQl1ZHBfdjZfZmx1c2hfcGVuZGluZ19mcmFtZXMoc2sp
OwogCWVsc2UgaWYgKCFjb3JrcmVxKQo=

--=_mixed 006767FF8825701A_=--
