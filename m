From: David Stevens <dlstevens@us.ibm.com>
Subject: IPV6 RFC3542 compliance [PATCH]
Date: Mon, 6 Jun 2005 13:48:26 -0600
Message-ID: <OF68DFE8BB.D1DDCA2A-ON88257018.0068C3C7-88257018.006CCE31@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 006CCE2C88257018_="
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, yoshfuji@linux-ipv6.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=_mixed 006CCE2C88257018_=
Content-Type: text/plain; charset="US-ASCII"

I've been looking at RFC 3542 (Advanced Sockets API) compliance,
and found the following:

("x" is one of {PKTINFO, HOPLIMIT, RTHDR, DSTOPTS, TCLASS })
What RFC 3542 says:
1) IPV6_x as socket options specify "sticky" option values;
        getsockopt() returns the current values of the sticky options
        setsockopt() sets the values for future sends
2) IPV6_RECVx are boolean socket options indicated whether the
     particular field will be returned in ancillary data on a recvmsg()
        getsockopt() gets the current value (1 or 0)
        setsockopt() sets or clears the boolean value
3) Ancillary data (send and receive) use IPV6_x for the corresponding
    data item

What current kernel does:
1) IPV6_x are boolean options
2) the sticky versions are not implemented
3) TCLASS is not implemented

The patch below adds sending and receiving of traffic class, the
definitions for IPV6_RECVx and changes the boolean socket options
to their RFC 3542 names. The original names are still there for use
with sticky options in the future (not included here), and as the
ancillary data message types.

The bad news:
This patch changes the argument lists of ip6_append_data() and
datagram_send_ctl(). This, because traffic class is not an extension
header, but part of the IPv6 header. This is analogous to the hop limit,
which is an explicit argument to these functions.

I've tested these pieces, but I have a couple open questions which
may be relevant (will continue looking myself...):

1) In ipv6_pinfo, there is a "hop_limit" field at the top level and 
another
        "cork.hop_limit". Why aren't these the same?
2) The (old name) IPV6_RTHDR socket option allows a value of "2",
        used by TCP. Still need to see what that's about for relevance
        to other options (but this code leaves that unchanged, except
        the name).

                                        +-DLS

in-line for view, attached for applying

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
diff -ruNp linux-2.6.11.10/include/linux/in6.h 
linux-2.6.11.10T2/include/linux/in6.h
--- linux-2.6.11.10/include/linux/in6.h 2005-05-16 10:51:43.000000000 
-0700
+++ linux-2.6.11.10T2/include/linux/in6.h       2005-05-23 
14:12:59.000000000 -0700
@@ -172,6 +172,7 @@ struct in6_flowlabel_req
 #define IPV6_V6ONLY            26
 #define IPV6_JOIN_ANYCAST      27
 #define IPV6_LEAVE_ANYCAST     28
+#define IPV6_TCLASS            30
 
 /* IPV6_MTU_DISCOVER values */
 #define IPV6_PMTUDISC_DONT             0
@@ -184,6 +185,12 @@ struct in6_flowlabel_req
 
 #define IPV6_IPSEC_POLICY      34
 #define IPV6_XFRM_POLICY       35
+#define IPV6_RTHDRDSTOPTS      36
+#define IPV6_RECVPKTINFO       37
+#define IPV6_RECVHOPLIMIT      38
+#define IPV6_RECVRTHDR         39
+#define IPV6_RECVHOPOPTS       40
+#define IPV6_RECVDSTOPTS       41
 
 /*
  * Multicast:
@@ -198,4 +205,6 @@ struct in6_flowlabel_req
  * MCAST_MSFILTER              48
  */
 
+#define IPV6_RECVTCLASS                49
+
 #endif
diff -ruNp linux-2.6.11.10/include/linux/ipv6.h 
linux-2.6.11.10T2/include/linux/ipv6.h
--- linux-2.6.11.10/include/linux/ipv6.h        2005-05-16 
10:51:43.000000000 -0700
+++ linux-2.6.11.10T2/include/linux/ipv6.h      2005-05-24 
13:18:27.000000000 -0700
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
@@ -244,6 +245,7 @@ struct ipv6_pinfo {
                struct ipv6_txoptions *opt;
                struct rt6_info *rt;
                int hop_limit;
+               int tclass;
        } cork;
 };
 
diff -ruNp linux-2.6.11.10/include/net/ipv6.h 
linux-2.6.11.10T2/include/net/ipv6.h
--- linux-2.6.11.10/include/net/ipv6.h  2005-05-16 10:51:49.000000000 
-0700
+++ linux-2.6.11.10T2/include/net/ipv6.h        2005-05-24 
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
linux-2.6.11.10T2/include/net/transp_v6.h
--- linux-2.6.11.10/include/net/transp_v6.h     2005-05-16 
10:51:51.000000000 -0700
+++ linux-2.6.11.10T2/include/net/transp_v6.h   2005-05-24 
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
linux-2.6.11.10T2/net/ipv6/datagram.c
--- linux-2.6.11.10/net/ipv6/datagram.c 2005-05-16 10:52:00.000000000 
-0700
+++ linux-2.6.11.10T2/net/ipv6/datagram.c       2005-05-24 
14:03:56.000000000 -0700
@@ -388,6 +388,11 @@ int datagram_recv_ctl(struct sock *sk, s
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
@@ -414,7 +419,7 @@ int datagram_recv_ctl(struct sock *sk, s
 
 int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
                      struct ipv6_txoptions *opt,
-                     int *hlimit)
+                     int *hlimit, int *tclass)
 {
        struct in6_pktinfo *src_info;
        struct cmsghdr *cmsg;
@@ -587,6 +592,15 @@ int datagram_send_ctl(struct msghdr *msg
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
linux-2.6.11.10T2/net/ipv6/icmp.c
--- linux-2.6.11.10/net/ipv6/icmp.c     2005-05-16 10:52:00.000000000 
-0700
+++ linux-2.6.11.10T2/net/ipv6/icmp.c   2005-05-24 15:05:14.000000000 
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
linux-2.6.11.10T2/net/ipv6/ip6_flowlabel.c
--- linux-2.6.11.10/net/ipv6/ip6_flowlabel.c    2005-05-16 
10:52:00.000000000 -0700
+++ linux-2.6.11.10T2/net/ipv6/ip6_flowlabel.c  2005-05-24 
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
linux-2.6.11.10T2/net/ipv6/ip6_output.c
--- linux-2.6.11.10/net/ipv6/ip6_output.c       2005-05-16 
10:52:00.000000000 -0700
+++ linux-2.6.11.10T2/net/ipv6/ip6_output.c     2005-05-24 
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
linux-2.6.11.10T2/net/ipv6/ipv6_sockglue.c
--- linux-2.6.11.10/net/ipv6/ipv6_sockglue.c    2005-05-16 
10:52:00.000000000 -0700
+++ linux-2.6.11.10T2/net/ipv6/ipv6_sockglue.c  2005-06-06 
11:52:15.000000000 -0700
@@ -208,33 +208,38 @@ int ipv6_setsockopt(struct sock *sk, int
                retv = 0;
                break;
 
-       case IPV6_PKTINFO:
+       case IPV6_RECVPKTINFO:
                np->rxopt.bits.rxinfo = valbool;
                retv = 0;
                break;
 
-       case IPV6_HOPLIMIT:
+       case IPV6_RECVHOPLIMIT:
                np->rxopt.bits.rxhlim = valbool;
                retv = 0;
                break;
 
-       case IPV6_RTHDR:
+       case IPV6_RECVRTHDR:
                if (val < 0 || val > 2)
                        goto e_inval;
                np->rxopt.bits.srcrt = val;
                retv = 0;
                break;
 
-       case IPV6_HOPOPTS:
+       case IPV6_RECVHOPOPTS:
                np->rxopt.bits.hopopts = valbool;
                retv = 0;
                break;
 
-       case IPV6_DSTOPTS:
+       case IPV6_RECVDSTOPTS:
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
@@ -274,7 +279,7 @@ int ipv6_setsockopt(struct sock *sk, int
                msg.msg_controllen = optlen;
                msg.msg_control = (void*)(opt+1);
 
-               retv = datagram_send_ctl(&msg, &fl, opt, &junk);
+               retv = datagram_send_ctl(&msg, &fl, opt, &junk, &junk);
                if (retv)
                        goto done;
 update:
@@ -620,26 +625,30 @@ int ipv6_getsockopt(struct sock *sk, int
                val = np->ipv6only;
                break;
 
-       case IPV6_PKTINFO:
+       case IPV6_RECVPKTINFO:
                val = np->rxopt.bits.rxinfo;
                break;
 
-       case IPV6_HOPLIMIT:
+       case IPV6_RECVHOPLIMIT:
                val = np->rxopt.bits.rxhlim;
                break;
 
-       case IPV6_RTHDR:
+       case IPV6_RECVRTHDR:
                val = np->rxopt.bits.srcrt;
                break;
 
-       case IPV6_HOPOPTS:
+       case IPV6_RECVHOPOPTS:
                val = np->rxopt.bits.hopopts;
                break;
 
-       case IPV6_DSTOPTS:
+       case IPV6_RECVDSTOPTS:
                val = np->rxopt.bits.dstopts;
                break;
 
+       case IPV6_RECVTCLASS:
+               val = np->rxopt.bits.rxtclass;
+               break;
+
        case IPV6_FLOWINFO:
                val = np->rxopt.bits.rxflow;
                break;
diff -ruNp linux-2.6.11.10/net/ipv6/raw.c linux-2.6.11.10T2/net/ipv6/raw.c
--- linux-2.6.11.10/net/ipv6/raw.c      2005-05-16 10:52:00.000000000 
-0700
+++ linux-2.6.11.10T2/net/ipv6/raw.c    2005-05-24 15:09:42.000000000 
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
diff -ruNp linux-2.6.11.10/net/ipv6/udp.c linux-2.6.11.10T2/net/ipv6/udp.c
--- linux-2.6.11.10/net/ipv6/udp.c      2005-05-16 10:52:00.000000000 
-0700
+++ linux-2.6.11.10T2/net/ipv6/udp.c    2005-05-24 15:11:58.000000000 
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


--=_mixed 006CCE2C88257018_=
Content-Type: application/octet-stream; name="rfc3542.patch"
Content-Disposition: attachment; filename="rfc3542.patch"
Content-Transfer-Encoding: base64

ZGlmZiAtcnVOcCBsaW51eC0yLjYuMTEuMTAvaW5jbHVkZS9saW51eC9pbjYuaCBsaW51eC0yLjYu
MTEuMTBUMi9pbmNsdWRlL2xpbnV4L2luNi5oCi0tLSBsaW51eC0yLjYuMTEuMTAvaW5jbHVkZS9s
aW51eC9pbjYuaAkyMDA1LTA1LTE2IDEwOjUxOjQzLjAwMDAwMDAwMCAtMDcwMAorKysgbGludXgt
Mi42LjExLjEwVDIvaW5jbHVkZS9saW51eC9pbjYuaAkyMDA1LTA1LTIzIDE0OjEyOjU5LjAwMDAw
MDAwMCAtMDcwMApAQCAtMTcyLDYgKzE3Miw3IEBAIHN0cnVjdCBpbjZfZmxvd2xhYmVsX3JlcQog
I2RlZmluZSBJUFY2X1Y2T05MWQkJMjYKICNkZWZpbmUgSVBWNl9KT0lOX0FOWUNBU1QJMjcKICNk
ZWZpbmUgSVBWNl9MRUFWRV9BTllDQVNUCTI4CisjZGVmaW5lIElQVjZfVENMQVNTCQkzMAogCiAv
KiBJUFY2X01UVV9ESVNDT1ZFUiB2YWx1ZXMgKi8KICNkZWZpbmUgSVBWNl9QTVRVRElTQ19ET05U
CQkwCkBAIC0xODQsNiArMTg1LDEyIEBAIHN0cnVjdCBpbjZfZmxvd2xhYmVsX3JlcQogCiAjZGVm
aW5lIElQVjZfSVBTRUNfUE9MSUNZCTM0CiAjZGVmaW5lIElQVjZfWEZSTV9QT0xJQ1kJMzUKKyNk
ZWZpbmUgSVBWNl9SVEhEUkRTVE9QVFMJMzYKKyNkZWZpbmUgSVBWNl9SRUNWUEtUSU5GTwkzNwor
I2RlZmluZSBJUFY2X1JFQ1ZIT1BMSU1JVAkzOAorI2RlZmluZSBJUFY2X1JFQ1ZSVEhEUgkJMzkK
KyNkZWZpbmUgSVBWNl9SRUNWSE9QT1BUUwk0MAorI2RlZmluZSBJUFY2X1JFQ1ZEU1RPUFRTCTQx
CiAKIC8qCiAgKiBNdWx0aWNhc3Q6CkBAIC0xOTgsNCArMjA1LDYgQEAgc3RydWN0IGluNl9mbG93
bGFiZWxfcmVxCiAgKiBNQ0FTVF9NU0ZJTFRFUgkJNDgKICAqLwogCisjZGVmaW5lIElQVjZfUkVD
VlRDTEFTUwkJNDkKKwogI2VuZGlmCmRpZmYgLXJ1TnAgbGludXgtMi42LjExLjEwL2luY2x1ZGUv
bGludXgvaXB2Ni5oIGxpbnV4LTIuNi4xMS4xMFQyL2luY2x1ZGUvbGludXgvaXB2Ni5oCi0tLSBs
aW51eC0yLjYuMTEuMTAvaW5jbHVkZS9saW51eC9pcHY2LmgJMjAwNS0wNS0xNiAxMDo1MTo0My4w
MDAwMDAwMDAgLTA3MDAKKysrIGxpbnV4LTIuNi4xMS4xMFQyL2luY2x1ZGUvbGludXgvaXB2Ni5o
CTIwMDUtMDUtMjQgMTM6MTg6MjcuMDAwMDAwMDAwIC0wNzAwCkBAIC0yMjEsNyArMjIxLDggQEAg
c3RydWN0IGlwdjZfcGluZm8gewogCQkJCXJ4aGxpbToxLAogCQkJCWhvcG9wdHM6MSwKIAkJCQlk
c3RvcHRzOjEsCi0gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHJ4ZmxvdzoxOworICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICByeGZsb3c6MSwKKwkJCQlyeHRjbGFzczoxOwog
CQl9IGJpdHM7CiAJCV9fdTgJCWFsbDsKIAl9IHJ4b3B0OwpAQCAtMjQ0LDYgKzI0NSw3IEBAIHN0
cnVjdCBpcHY2X3BpbmZvIHsKIAkJc3RydWN0IGlwdjZfdHhvcHRpb25zICpvcHQ7CiAJCXN0cnVj
dCBydDZfaW5mbwkqcnQ7CiAJCWludCBob3BfbGltaXQ7CisJCWludCB0Y2xhc3M7CiAJfSBjb3Jr
OwogfTsKIApkaWZmIC1ydU5wIGxpbnV4LTIuNi4xMS4xMC9pbmNsdWRlL25ldC9pcHY2LmggbGlu
dXgtMi42LjExLjEwVDIvaW5jbHVkZS9uZXQvaXB2Ni5oCi0tLSBsaW51eC0yLjYuMTEuMTAvaW5j
bHVkZS9uZXQvaXB2Ni5oCTIwMDUtMDUtMTYgMTA6NTE6NDkuMDAwMDAwMDAwIC0wNzAwCisrKyBs
aW51eC0yLjYuMTEuMTBUMi9pbmNsdWRlL25ldC9pcHY2LmgJMjAwNS0wNS0yNCAxNDo1NzoyMy4w
MDAwMDAwMDAgLTA3MDAKQEAgLTM0Nyw2ICszNDcsNyBAQCBleHRlcm4gaW50CQkJaXA2X2FwcGVu
ZF9kYXRhKHN0cnVjdCBzb2NrCiAJCQkJCQlpbnQgbGVuZ3RoLAogCQkJCQkJaW50IHRyYW5zaGRy
bGVuLAogCQkgICAgICAJCQkJaW50IGhsaW1pdCwKKwkJICAgICAgCQkJCWludCB0Y2xhc3MsCiAJ
CQkJCQlzdHJ1Y3QgaXB2Nl90eG9wdGlvbnMgKm9wdCwKIAkJCQkJCXN0cnVjdCBmbG93aSAqZmws
CiAJCQkJCQlzdHJ1Y3QgcnQ2X2luZm8gKnJ0LApkaWZmIC1ydU5wIGxpbnV4LTIuNi4xMS4xMC9p
bmNsdWRlL25ldC90cmFuc3BfdjYuaCBsaW51eC0yLjYuMTEuMTBUMi9pbmNsdWRlL25ldC90cmFu
c3BfdjYuaAotLS0gbGludXgtMi42LjExLjEwL2luY2x1ZGUvbmV0L3RyYW5zcF92Ni5oCTIwMDUt
MDUtMTYgMTA6NTE6NTEuMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0yLjYuMTEuMTBUMi9pbmNs
dWRlL25ldC90cmFuc3BfdjYuaAkyMDA1LTA1LTI0IDE0OjA0OjExLjAwMDAwMDAwMCAtMDcwMApA
QCAtMzcsNyArMzcsNyBAQCBleHRlcm4gaW50CQkJZGF0YWdyYW1fcmVjdl9jdGwoc3RydWN0IHNv
CiBleHRlcm4gaW50CQkJZGF0YWdyYW1fc2VuZF9jdGwoc3RydWN0IG1zZ2hkciAqbXNnLAogCQkJ
CQkJICBzdHJ1Y3QgZmxvd2kgKmZsLAogCQkJCQkJICBzdHJ1Y3QgaXB2Nl90eG9wdGlvbnMgKm9w
dCwKLQkJCQkJCSAgaW50ICpobGltaXQpOworCQkJCQkJICBpbnQgKmhsaW1pdCwgaW50ICp0Y2xh
c3MpOwogCiAjZGVmaW5lCQlMT09QQkFDSzRfSVBWNgkJX19jb25zdGFudF9odG9ubCgweDdmMDAw
MDA2KQogCmRpZmYgLXJ1TnAgbGludXgtMi42LjExLjEwL25ldC9pcHY2L2RhdGFncmFtLmMgbGlu
dXgtMi42LjExLjEwVDIvbmV0L2lwdjYvZGF0YWdyYW0uYwotLS0gbGludXgtMi42LjExLjEwL25l
dC9pcHY2L2RhdGFncmFtLmMJMjAwNS0wNS0xNiAxMDo1MjowMC4wMDAwMDAwMDAgLTA3MDAKKysr
IGxpbnV4LTIuNi4xMS4xMFQyL25ldC9pcHY2L2RhdGFncmFtLmMJMjAwNS0wNS0yNCAxNDowMzo1
Ni4wMDAwMDAwMDAgLTA3MDAKQEAgLTM4OCw2ICszODgsMTEgQEAgaW50IGRhdGFncmFtX3JlY3Zf
Y3RsKHN0cnVjdCBzb2NrICpzaywgcwogCQlpbnQgaGxpbSA9IHNrYi0+bmguaXB2NmgtPmhvcF9s
aW1pdDsKIAkJcHV0X2Ntc2cobXNnLCBTT0xfSVBWNiwgSVBWNl9IT1BMSU1JVCwgc2l6ZW9mKGhs
aW0pLCAmaGxpbSk7CiAJfQorCWlmIChucC0+cnhvcHQuYml0cy5yeHRjbGFzcykgeworCQl1OCB0
Y2xhc3MgPSAoc2tiLT5uaC5pcHY2aC0+cHJpb3JpdHkgPDwgNCkgfAorCQkJKChza2ItPm5oLmlw
djZoLT5mbG93X2xibFswXT4+NCkgJiAweGYpOworCQlwdXRfY21zZyhtc2csIFNPTF9JUFY2LCBJ
UFY2X1RDTEFTUywgc2l6ZW9mKHRjbGFzcyksICZ0Y2xhc3MpOworCX0KIAogCWlmIChucC0+cnhv
cHQuYml0cy5yeGZsb3cgJiYgKCoodTMyKilza2ItPm5oLnJhdyAmIElQVjZfRkxPV0lORk9fTUFT
SykpIHsKIAkJdTMyIGZsb3dpbmZvID0gKih1MzIqKXNrYi0+bmgucmF3ICYgSVBWNl9GTE9XSU5G
T19NQVNLOwpAQCAtNDE0LDcgKzQxOSw3IEBAIGludCBkYXRhZ3JhbV9yZWN2X2N0bChzdHJ1Y3Qg
c29jayAqc2ssIHMKIAogaW50IGRhdGFncmFtX3NlbmRfY3RsKHN0cnVjdCBtc2doZHIgKm1zZywg
c3RydWN0IGZsb3dpICpmbCwKIAkJICAgICAgc3RydWN0IGlwdjZfdHhvcHRpb25zICpvcHQsCi0J
CSAgICAgIGludCAqaGxpbWl0KQorCQkgICAgICBpbnQgKmhsaW1pdCwgaW50ICp0Y2xhc3MpCiB7
CiAJc3RydWN0IGluNl9wa3RpbmZvICpzcmNfaW5mbzsKIAlzdHJ1Y3QgY21zZ2hkciAqY21zZzsK
QEAgLTU4Nyw2ICs1OTIsMTUgQEAgaW50IGRhdGFncmFtX3NlbmRfY3RsKHN0cnVjdCBtc2doZHIg
Km1zZwogCQkJKmhsaW1pdCA9ICooaW50ICopQ01TR19EQVRBKGNtc2cpOwogCQkJYnJlYWs7CiAK
KwkJY2FzZSBJUFY2X1RDTEFTUzoKKwkJCWlmIChjbXNnLT5jbXNnX2xlbiAhPSBDTVNHX0xFTihz
aXplb2YoaW50KSkpIHsKKwkJCQllcnIgPSAtRUlOVkFMOworCQkJCWdvdG8gZXhpdF9mOworCQkJ
fQorCisJCQkqdGNsYXNzID0gKihpbnQgKilDTVNHX0RBVEEoY21zZyk7CisJCQlicmVhazsKKwog
CQlkZWZhdWx0OgogCQkJTElNSVRfTkVUREVCVUcoCiAJCQkJcHJpbnRrKEtFUk5fREVCVUcgImlu
dmFsaWQgY21zZyB0eXBlOiAlZFxuIiwgY21zZy0+Y21zZ190eXBlKSk7CmRpZmYgLXJ1TnAgbGlu
dXgtMi42LjExLjEwL25ldC9pcHY2L2ljbXAuYyBsaW51eC0yLjYuMTEuMTBUMi9uZXQvaXB2Ni9p
Y21wLmMKLS0tIGxpbnV4LTIuNi4xMS4xMC9uZXQvaXB2Ni9pY21wLmMJMjAwNS0wNS0xNiAxMDo1
MjowMC4wMDAwMDAwMDAgLTA3MDAKKysrIGxpbnV4LTIuNi4xMS4xMFQyL25ldC9pcHY2L2ljbXAu
YwkyMDA1LTA1LTI0IDE1OjA1OjE0LjAwMDAwMDAwMCAtMDcwMApAQCAtMjg3LDcgKzI4Nyw3IEBA
IHZvaWQgaWNtcHY2X3NlbmQoc3RydWN0IHNrX2J1ZmYgKnNrYiwgaW4KIAlpbnQgaWlmID0gMDsK
IAlpbnQgYWRkcl90eXBlID0gMDsKIAlpbnQgbGVuOwotCWludCBobGltaXQ7CisJaW50IGhsaW1p
dCwgdGNsYXNzOwogCWludCBlcnIgPSAwOwogCiAJaWYgKCh1OCopaGRyIDwgc2tiLT5oZWFkIHx8
ICh1OCopKGhkcisxKSA+IHNrYi0+dGFpbCkKQEAgLTM4MSw2ICszODEsOSBAQCB2b2lkIGljbXB2
Nl9zZW5kKHN0cnVjdCBza19idWZmICpza2IsIGluCiAJCWhsaW1pdCA9IG5wLT5ob3BfbGltaXQ7
CiAJaWYgKGhsaW1pdCA8IDApCiAJCWhsaW1pdCA9IGRzdF9tZXRyaWMoZHN0LCBSVEFYX0hPUExJ
TUlUKTsKKwl0Y2xhc3MgPSBucC0+Y29yay50Y2xhc3M7CisJaWYgKHRjbGFzcyA8IDApCisJCXRj
bGFzcyA9IDA7CiAKIAltc2cuc2tiID0gc2tiOwogCW1zZy5vZmZzZXQgPSBza2ItPm5oLnJhdyAt
IHNrYi0+ZGF0YTsKQEAgLTM5OCw3ICs0MDEsNyBAQCB2b2lkIGljbXB2Nl9zZW5kKHN0cnVjdCBz
a19idWZmICpza2IsIGluCiAJZXJyID0gaXA2X2FwcGVuZF9kYXRhKHNrLCBpY21wdjZfZ2V0ZnJh
ZywgJm1zZywKIAkJCSAgICAgIGxlbiArIHNpemVvZihzdHJ1Y3QgaWNtcDZoZHIpLAogCQkJICAg
ICAgc2l6ZW9mKHN0cnVjdCBpY21wNmhkciksCi0JCQkgICAgICBobGltaXQsIE5VTEwsICZmbCwg
KHN0cnVjdCBydDZfaW5mbyopZHN0LAorCQkJICAgICAgaGxpbWl0LCB0Y2xhc3MsIE5VTEwsICZm
bCwgKHN0cnVjdCBydDZfaW5mbyopZHN0LAogCQkJICAgICAgTVNHX0RPTlRXQUlUKTsKIAlpZiAo
ZXJyKSB7CiAJCWlwNl9mbHVzaF9wZW5kaW5nX2ZyYW1lcyhzayk7CkBAIC00MzIsNiArNDM1LDcg
QEAgc3RhdGljIHZvaWQgaWNtcHY2X2VjaG9fcmVwbHkoc3RydWN0IHNrXwogCXN0cnVjdCBkc3Rf
ZW50cnkgKmRzdDsKIAlpbnQgZXJyID0gMDsKIAlpbnQgaGxpbWl0OworCWludCB0Y2xhc3M7CiAK
IAlzYWRkciA9ICZza2ItPm5oLmlwdjZoLT5kYWRkcjsKIApAQCAtNDY3LDE1ICs0NzEsMTggQEAg
c3RhdGljIHZvaWQgaWNtcHY2X2VjaG9fcmVwbHkoc3RydWN0IHNrXwogCQlobGltaXQgPSBucC0+
aG9wX2xpbWl0OwogCWlmIChobGltaXQgPCAwKQogCQlobGltaXQgPSBkc3RfbWV0cmljKGRzdCwg
UlRBWF9IT1BMSU1JVCk7CisJdGNsYXNzID0gbnAtPmNvcmsudGNsYXNzOworCWlmICh0Y2xhc3Mg
PCAwKQorCQl0Y2xhc3MgPSAwOwogCiAJaWRldiA9IGluNl9kZXZfZ2V0KHNrYi0+ZGV2KTsKIAog
CW1zZy5za2IgPSBza2I7CiAJbXNnLm9mZnNldCA9IDA7CiAKLQllcnIgPSBpcDZfYXBwZW5kX2Rh
dGEoc2ssIGljbXB2Nl9nZXRmcmFnLCAmbXNnLCBza2ItPmxlbiArIHNpemVvZihzdHJ1Y3QgaWNt
cDZoZHIpLAotCQkJCXNpemVvZihzdHJ1Y3QgaWNtcDZoZHIpLCBobGltaXQsIE5VTEwsICZmbCwK
LQkJCQkoc3RydWN0IHJ0Nl9pbmZvKilkc3QsIE1TR19ET05UV0FJVCk7CisJZXJyID0gaXA2X2Fw
cGVuZF9kYXRhKHNrLCBpY21wdjZfZ2V0ZnJhZywgJm1zZywgc2tiLT5sZW4gKworCQlzaXplb2Yo
c3RydWN0IGljbXA2aGRyKSwgc2l6ZW9mKHN0cnVjdCBpY21wNmhkciksIGhsaW1pdCwKKwkJdGNs
YXNzLCBOVUxMLCAmZmwsIChzdHJ1Y3QgcnQ2X2luZm8qKWRzdCwgTVNHX0RPTlRXQUlUKTsKIAog
CWlmIChlcnIpIHsKIAkJaXA2X2ZsdXNoX3BlbmRpbmdfZnJhbWVzKHNrKTsKZGlmZiAtcnVOcCBs
aW51eC0yLjYuMTEuMTAvbmV0L2lwdjYvaXA2X2Zsb3dsYWJlbC5jIGxpbnV4LTIuNi4xMS4xMFQy
L25ldC9pcHY2L2lwNl9mbG93bGFiZWwuYwotLS0gbGludXgtMi42LjExLjEwL25ldC9pcHY2L2lw
Nl9mbG93bGFiZWwuYwkyMDA1LTA1LTE2IDEwOjUyOjAwLjAwMDAwMDAwMCAtMDcwMAorKysgbGlu
dXgtMi42LjExLjEwVDIvbmV0L2lwdjYvaXA2X2Zsb3dsYWJlbC5jCTIwMDUtMDUtMjQgMTQ6MDQ6
MjguMDAwMDAwMDAwIC0wNzAwCkBAIC0zMTEsNyArMzExLDcgQEAgZmxfY3JlYXRlKHN0cnVjdCBp
bjZfZmxvd2xhYmVsX3JlcSAqZnJlcQogCQltc2cubXNnX2NvbnRyb2wgPSAodm9pZCopKGZsLT5v
cHQrMSk7CiAJCWZsb3dpLm9pZiA9IDA7CiAKLQkJZXJyID0gZGF0YWdyYW1fc2VuZF9jdGwoJm1z
ZywgJmZsb3dpLCBmbC0+b3B0LCAmanVuayk7CisJCWVyciA9IGRhdGFncmFtX3NlbmRfY3RsKCZt
c2csICZmbG93aSwgZmwtPm9wdCwgJmp1bmssICZqdW5rKTsKIAkJaWYgKGVycikKIAkJCWdvdG8g
ZG9uZTsKIAkJZXJyID0gLUVJTlZBTDsKZGlmZiAtcnVOcCBsaW51eC0yLjYuMTEuMTAvbmV0L2lw
djYvaXA2X291dHB1dC5jIGxpbnV4LTIuNi4xMS4xMFQyL25ldC9pcHY2L2lwNl9vdXRwdXQuYwot
LS0gbGludXgtMi42LjExLjEwL25ldC9pcHY2L2lwNl9vdXRwdXQuYwkyMDA1LTA1LTE2IDEwOjUy
OjAwLjAwMDAwMDAwMCAtMDcwMAorKysgbGludXgtMi42LjExLjEwVDIvbmV0L2lwdjYvaXA2X291
dHB1dC5jCTIwMDUtMDUtMjQgMTQ6NTg6NTEuMDAwMDAwMDAwIC0wNzAwCkBAIC0yMTEsNyArMjEx
LDcgQEAgaW50IGlwNl94bWl0KHN0cnVjdCBzb2NrICpzaywgc3RydWN0IHNrXwogCXN0cnVjdCBp
cHY2aGRyICpoZHI7CiAJdTggIHByb3RvID0gZmwtPnByb3RvOwogCWludCBzZWdfbGVuID0gc2ti
LT5sZW47Ci0JaW50IGhsaW1pdDsKKwlpbnQgaGxpbWl0LCB0Y2xhc3M7CiAJdTMyIG10dTsKIAog
CWlmIChvcHQpIHsKQEAgLTI1Myw2ICsyNTMsMTMgQEAgaW50IGlwNl94bWl0KHN0cnVjdCBzb2Nr
ICpzaywgc3RydWN0IHNrXwogCQlobGltaXQgPSBucC0+aG9wX2xpbWl0OwogCWlmIChobGltaXQg
PCAwKQogCQlobGltaXQgPSBkc3RfbWV0cmljKGRzdCwgUlRBWF9IT1BMSU1JVCk7CisJdGNsYXNz
ID0gLTE7CisJaWYgKG5wKQorCQl0Y2xhc3MgPSBucC0+Y29yay50Y2xhc3M7CisJaWYgKHRjbGFz
cyA8IDApCisJCXRjbGFzcyA9IDA7CisJaGRyLT5wcmlvcml0eSA9IChucC0+Y29yay50Y2xhc3M+
PjQpICYweGY7CisJaGRyLT5mbG93X2xibFswXSB8PSAobnAtPmNvcmsudGNsYXNzICYgMHhmKTw8
NDsKIAogCWhkci0+cGF5bG9hZF9sZW4gPSBodG9ucyhzZWdfbGVuKTsKIAloZHItPm5leHRoZHIg
PSBwcm90bzsKQEAgLTgwNiwxMCArODEzLDExIEBAIG91dF9lcnJfcmVsZWFzZToKIAlyZXR1cm4g
ZXJyOwogfQogCi1pbnQgaXA2X2FwcGVuZF9kYXRhKHN0cnVjdCBzb2NrICpzaywgaW50IGdldGZy
YWcodm9pZCAqZnJvbSwgY2hhciAqdG8sIGludCBvZmZzZXQsIGludCBsZW4sIGludCBvZGQsIHN0
cnVjdCBza19idWZmICpza2IpLAotCQkgICAgdm9pZCAqZnJvbSwgaW50IGxlbmd0aCwgaW50IHRy
YW5zaGRybGVuLAotCQkgICAgaW50IGhsaW1pdCwgc3RydWN0IGlwdjZfdHhvcHRpb25zICpvcHQs
IHN0cnVjdCBmbG93aSAqZmwsIHN0cnVjdCBydDZfaW5mbyAqcnQsCi0JCSAgICB1bnNpZ25lZCBp
bnQgZmxhZ3MpCitpbnQgaXA2X2FwcGVuZF9kYXRhKHN0cnVjdCBzb2NrICpzaywgaW50IGdldGZy
YWcodm9pZCAqZnJvbSwgY2hhciAqdG8sCisJaW50IG9mZnNldCwgaW50IGxlbiwgaW50IG9kZCwg
c3RydWN0IHNrX2J1ZmYgKnNrYiksCisJdm9pZCAqZnJvbSwgaW50IGxlbmd0aCwgaW50IHRyYW5z
aGRybGVuLAorCWludCBobGltaXQsIGludCB0Y2xhc3MsIHN0cnVjdCBpcHY2X3R4b3B0aW9ucyAq
b3B0LCBzdHJ1Y3QgZmxvd2kgKmZsLAorCXN0cnVjdCBydDZfaW5mbyAqcnQsIHVuc2lnbmVkIGlu
dCBmbGFncykKIHsKIAlzdHJ1Y3QgaW5ldF9zb2NrICppbmV0ID0gaW5ldF9zayhzayk7CiAJc3Ry
dWN0IGlwdjZfcGluZm8gKm5wID0gaW5ldDZfc2soc2spOwpAQCAtODQ3LDYgKzg1NSw3IEBAIGlu
dCBpcDZfYXBwZW5kX2RhdGEoc3RydWN0IHNvY2sgKnNrLCBpbnQKIAkJbnAtPmNvcmsucnQgPSBy
dDsKIAkJaW5ldC0+Y29yay5mbCA9ICpmbDsKIAkJbnAtPmNvcmsuaG9wX2xpbWl0ID0gaGxpbWl0
OworCQlucC0+Y29yay50Y2xhc3MgPSB0Y2xhc3M7CiAJCWluZXQtPmNvcmsuZnJhZ3NpemUgPSBt
dHUgPSBkc3RfcG10dSgmcnQtPnUuZHN0KTsKIAkJaW5ldC0+Y29yay5sZW5ndGggPSAwOwogCQlz
ay0+c2tfc25kbXNnX3BhZ2UgPSBOVUxMOwpAQCAtMTEzMCw2ICsxMTM5LDEwIEBAIGludCBpcDZf
cHVzaF9wZW5kaW5nX2ZyYW1lcyhzdHJ1Y3Qgc29jayAKIAkKIAkqKHUzMiopaGRyID0gZmwtPmZs
Nl9mbG93bGFiZWwgfCBodG9ubCgweDYwMDAwMDAwKTsKIAorCS8qIHRyYWZmaWMgY2xhc3MgKi8K
KwloZHItPnByaW9yaXR5ID0gKG5wLT5jb3JrLnRjbGFzcz4+NCkgJiAweGY7CisJaGRyLT5mbG93
X2xibFswXSB8PSAobnAtPmNvcmsudGNsYXNzICYgMHhmKTw8NDsKKwogCWlmIChza2ItPmxlbiA8
PSBzaXplb2Yoc3RydWN0IGlwdjZoZHIpICsgSVBWNl9NQVhQTEVOKQogCQloZHItPnBheWxvYWRf
bGVuID0gaHRvbnMoc2tiLT5sZW4gLSBzaXplb2Yoc3RydWN0IGlwdjZoZHIpKTsKIAllbHNlCmRp
ZmYgLXJ1TnAgbGludXgtMi42LjExLjEwL25ldC9pcHY2L2lwdjZfc29ja2dsdWUuYyBsaW51eC0y
LjYuMTEuMTBUMi9uZXQvaXB2Ni9pcHY2X3NvY2tnbHVlLmMKLS0tIGxpbnV4LTIuNi4xMS4xMC9u
ZXQvaXB2Ni9pcHY2X3NvY2tnbHVlLmMJMjAwNS0wNS0xNiAxMDo1MjowMC4wMDAwMDAwMDAgLTA3
MDAKKysrIGxpbnV4LTIuNi4xMS4xMFQyL25ldC9pcHY2L2lwdjZfc29ja2dsdWUuYwkyMDA1LTA2
LTA2IDExOjUyOjE1LjAwMDAwMDAwMCAtMDcwMApAQCAtMjA4LDMzICsyMDgsMzggQEAgaW50IGlw
djZfc2V0c29ja29wdChzdHJ1Y3Qgc29jayAqc2ssIGludAogCQlyZXR2ID0gMDsKIAkJYnJlYWs7
CiAKLQljYXNlIElQVjZfUEtUSU5GTzoKKwljYXNlIElQVjZfUkVDVlBLVElORk86CiAJCW5wLT5y
eG9wdC5iaXRzLnJ4aW5mbyA9IHZhbGJvb2w7CiAJCXJldHYgPSAwOwogCQlicmVhazsKIAotCWNh
c2UgSVBWNl9IT1BMSU1JVDoKKwljYXNlIElQVjZfUkVDVkhPUExJTUlUOgogCQlucC0+cnhvcHQu
Yml0cy5yeGhsaW0gPSB2YWxib29sOwogCQlyZXR2ID0gMDsKIAkJYnJlYWs7CiAKLQljYXNlIElQ
VjZfUlRIRFI6CisJY2FzZSBJUFY2X1JFQ1ZSVEhEUjoKIAkJaWYgKHZhbCA8IDAgfHwgdmFsID4g
MikKIAkJCWdvdG8gZV9pbnZhbDsKIAkJbnAtPnJ4b3B0LmJpdHMuc3JjcnQgPSB2YWw7CiAJCXJl
dHYgPSAwOwogCQlicmVhazsKIAotCWNhc2UgSVBWNl9IT1BPUFRTOgorCWNhc2UgSVBWNl9SRUNW
SE9QT1BUUzoKIAkJbnAtPnJ4b3B0LmJpdHMuaG9wb3B0cyA9IHZhbGJvb2w7CiAJCXJldHYgPSAw
OwogCQlicmVhazsKIAotCWNhc2UgSVBWNl9EU1RPUFRTOgorCWNhc2UgSVBWNl9SRUNWRFNUT1BU
UzoKIAkJbnAtPnJ4b3B0LmJpdHMuZHN0b3B0cyA9IHZhbGJvb2w7CiAJCXJldHYgPSAwOwogCQli
cmVhazsKIAorCWNhc2UgSVBWNl9SRUNWVENMQVNTOgorCQlucC0+cnhvcHQuYml0cy5yeHRjbGFz
cyA9IHZhbGJvb2w7CisJCXJldHYgPSAwOworCQlicmVhazsKKwogCWNhc2UgSVBWNl9GTE9XSU5G
TzoKIAkJbnAtPnJ4b3B0LmJpdHMucnhmbG93ID0gdmFsYm9vbDsKIAkJcmV0diA9IDA7CkBAIC0y
NzQsNyArMjc5LDcgQEAgaW50IGlwdjZfc2V0c29ja29wdChzdHJ1Y3Qgc29jayAqc2ssIGludAog
CQltc2cubXNnX2NvbnRyb2xsZW4gPSBvcHRsZW47CiAJCW1zZy5tc2dfY29udHJvbCA9ICh2b2lk
Kikob3B0KzEpOwogCi0JCXJldHYgPSBkYXRhZ3JhbV9zZW5kX2N0bCgmbXNnLCAmZmwsIG9wdCwg
Jmp1bmspOworCQlyZXR2ID0gZGF0YWdyYW1fc2VuZF9jdGwoJm1zZywgJmZsLCBvcHQsICZqdW5r
LCAmanVuayk7CiAJCWlmIChyZXR2KQogCQkJZ290byBkb25lOwogdXBkYXRlOgpAQCAtNjIwLDI2
ICs2MjUsMzAgQEAgaW50IGlwdjZfZ2V0c29ja29wdChzdHJ1Y3Qgc29jayAqc2ssIGludAogCQl2
YWwgPSBucC0+aXB2Nm9ubHk7CiAJCWJyZWFrOwogCi0JY2FzZSBJUFY2X1BLVElORk86CisJY2Fz
ZSBJUFY2X1JFQ1ZQS1RJTkZPOgogCQl2YWwgPSBucC0+cnhvcHQuYml0cy5yeGluZm87CiAJCWJy
ZWFrOwogCi0JY2FzZSBJUFY2X0hPUExJTUlUOgorCWNhc2UgSVBWNl9SRUNWSE9QTElNSVQ6CiAJ
CXZhbCA9IG5wLT5yeG9wdC5iaXRzLnJ4aGxpbTsKIAkJYnJlYWs7CiAKLQljYXNlIElQVjZfUlRI
RFI6CisJY2FzZSBJUFY2X1JFQ1ZSVEhEUjoKIAkJdmFsID0gbnAtPnJ4b3B0LmJpdHMuc3JjcnQ7
CiAJCWJyZWFrOwogCi0JY2FzZSBJUFY2X0hPUE9QVFM6CisJY2FzZSBJUFY2X1JFQ1ZIT1BPUFRT
OgogCQl2YWwgPSBucC0+cnhvcHQuYml0cy5ob3BvcHRzOwogCQlicmVhazsKIAotCWNhc2UgSVBW
Nl9EU1RPUFRTOgorCWNhc2UgSVBWNl9SRUNWRFNUT1BUUzoKIAkJdmFsID0gbnAtPnJ4b3B0LmJp
dHMuZHN0b3B0czsKIAkJYnJlYWs7CiAKKwljYXNlIElQVjZfUkVDVlRDTEFTUzoKKwkJdmFsID0g
bnAtPnJ4b3B0LmJpdHMucnh0Y2xhc3M7CisJCWJyZWFrOworCiAJY2FzZSBJUFY2X0ZMT1dJTkZP
OgogCQl2YWwgPSBucC0+cnhvcHQuYml0cy5yeGZsb3c7CiAJCWJyZWFrOwpkaWZmIC1ydU5wIGxp
bnV4LTIuNi4xMS4xMC9uZXQvaXB2Ni9yYXcuYyBsaW51eC0yLjYuMTEuMTBUMi9uZXQvaXB2Ni9y
YXcuYwotLS0gbGludXgtMi42LjExLjEwL25ldC9pcHY2L3Jhdy5jCTIwMDUtMDUtMTYgMTA6NTI6
MDAuMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0yLjYuMTEuMTBUMi9uZXQvaXB2Ni9yYXcuYwky
MDA1LTA1LTI0IDE1OjA5OjQyLjAwMDAwMDAwMCAtMDcwMApAQCAtNjE3LDYgKzYxNyw3IEBAIHN0
YXRpYyBpbnQgcmF3djZfc2VuZG1zZyhzdHJ1Y3Qga2lvY2IgKmkKIAlzdHJ1Y3QgZmxvd2kgZmw7
CiAJaW50IGFkZHJfbGVuID0gbXNnLT5tc2dfbmFtZWxlbjsKIAlpbnQgaGxpbWl0ID0gLTE7CisJ
aW50IHRjbGFzcyA9IC0xOwogCXUxNiBwcm90bzsKIAlpbnQgZXJyOwogCkBAIC03MDIsNyArNzAz
LDcgQEAgc3RhdGljIGludCByYXd2Nl9zZW5kbXNnKHN0cnVjdCBraW9jYiAqaQogCQltZW1zZXQo
b3B0LCAwLCBzaXplb2Yoc3RydWN0IGlwdjZfdHhvcHRpb25zKSk7CiAJCW9wdC0+dG90X2xlbiA9
IHNpemVvZihzdHJ1Y3QgaXB2Nl90eG9wdGlvbnMpOwogCi0JCWVyciA9IGRhdGFncmFtX3NlbmRf
Y3RsKG1zZywgJmZsLCBvcHQsICZobGltaXQpOworCQllcnIgPSBkYXRhZ3JhbV9zZW5kX2N0bCht
c2csICZmbCwgb3B0LCAmaGxpbWl0LCAmdGNsYXNzKTsKIAkJaWYgKGVyciA8IDApIHsKIAkJCWZs
Nl9zb2NrX3JlbGVhc2UoZmxvd2xhYmVsKTsKIAkJCXJldHVybiBlcnI7CkBAIC03NTgsNiArNzU5
LDEyIEBAIHN0YXRpYyBpbnQgcmF3djZfc2VuZG1zZyhzdHJ1Y3Qga2lvY2IgKmkKIAkJCWhsaW1p
dCA9IGRzdF9tZXRyaWMoZHN0LCBSVEFYX0hPUExJTUlUKTsKIAl9CiAKKwlpZiAodGNsYXNzIDwg
MCkgeworCQl0Y2xhc3MgPSBucC0+Y29yay50Y2xhc3M7CisJCWlmICh0Y2xhc3MgPCAwKQorCQkJ
dGNsYXNzID0gMDsKKwl9CisKIAlpZiAobXNnLT5tc2dfZmxhZ3MmTVNHX0NPTkZJUk0pCiAJCWdv
dG8gZG9fY29uZmlybTsKIApAQCAtNzY2LDggKzc3Myw5IEBAIGJhY2tfZnJvbV9jb25maXJtOgog
CQllcnIgPSByYXd2Nl9zZW5kX2hkcmluYyhzaywgbXNnLT5tc2dfaW92LCBsZW4sICZmbCwgKHN0
cnVjdCBydDZfaW5mbyopZHN0LCBtc2ctPm1zZ19mbGFncyk7CiAJfSBlbHNlIHsKIAkJbG9ja19z
b2NrKHNrKTsKLQkJZXJyID0gaXA2X2FwcGVuZF9kYXRhKHNrLCBpcF9nZW5lcmljX2dldGZyYWcs
IG1zZy0+bXNnX2lvdiwgbGVuLCAwLAotCQkJCQlobGltaXQsIG9wdCwgJmZsLCAoc3RydWN0IHJ0
Nl9pbmZvKilkc3QsIG1zZy0+bXNnX2ZsYWdzKTsKKwkJZXJyID0gaXA2X2FwcGVuZF9kYXRhKHNr
LCBpcF9nZW5lcmljX2dldGZyYWcsIG1zZy0+bXNnX2lvdiwKKwkJCWxlbiwgMCwgaGxpbWl0LCB0
Y2xhc3MsIG9wdCwgJmZsLCAoc3RydWN0IHJ0Nl9pbmZvKilkc3QsCisJCQltc2ctPm1zZ19mbGFn
cyk7CiAKIAkJaWYgKGVycikKIAkJCWlwNl9mbHVzaF9wZW5kaW5nX2ZyYW1lcyhzayk7CmRpZmYg
LXJ1TnAgbGludXgtMi42LjExLjEwL25ldC9pcHY2L3VkcC5jIGxpbnV4LTIuNi4xMS4xMFQyL25l
dC9pcHY2L3VkcC5jCi0tLSBsaW51eC0yLjYuMTEuMTAvbmV0L2lwdjYvdWRwLmMJMjAwNS0wNS0x
NiAxMDo1MjowMC4wMDAwMDAwMDAgLTA3MDAKKysrIGxpbnV4LTIuNi4xMS4xMFQyL25ldC9pcHY2
L3VkcC5jCTIwMDUtMDUtMjQgMTU6MTE6NTguMDAwMDAwMDAwIC0wNzAwCkBAIC02MzcsNiArNjM3
LDcgQEAgc3RhdGljIGludCB1ZHB2Nl9zZW5kbXNnKHN0cnVjdCBraW9jYiAqaQogCWludCBhZGRy
X2xlbiA9IG1zZy0+bXNnX25hbWVsZW47CiAJaW50IHVsZW4gPSBsZW47CiAJaW50IGhsaW1pdCA9
IC0xOworCWludCB0Y2xhc3MgPSAtMTsKIAlpbnQgY29ya3JlcSA9IHVwLT5jb3JrZmxhZyB8fCBt
c2ctPm1zZ19mbGFncyZNU0dfTU9SRTsKIAlpbnQgZXJyOwogCkBAIC03NTgsNyArNzU5LDcgQEAg
ZG9fdWRwX3NlbmRtc2c6CiAJCW1lbXNldChvcHQsIDAsIHNpemVvZihzdHJ1Y3QgaXB2Nl90eG9w
dGlvbnMpKTsKIAkJb3B0LT50b3RfbGVuID0gc2l6ZW9mKCpvcHQpOwogCi0JCWVyciA9IGRhdGFn
cmFtX3NlbmRfY3RsKG1zZywgZmwsIG9wdCwgJmhsaW1pdCk7CisJCWVyciA9IGRhdGFncmFtX3Nl
bmRfY3RsKG1zZywgZmwsIG9wdCwgJmhsaW1pdCwgJnRjbGFzcyk7CiAJCWlmIChlcnIgPCAwKSB7
CiAJCQlmbDZfc29ja19yZWxlYXNlKGZsb3dsYWJlbCk7CiAJCQlyZXR1cm4gZXJyOwpAQCAtODEy
LDYgKzgxMywxMSBAQCBkb191ZHBfc2VuZG1zZzoKIAkJaWYgKGhsaW1pdCA8IDApCiAJCQlobGlt
aXQgPSBkc3RfbWV0cmljKGRzdCwgUlRBWF9IT1BMSU1JVCk7CiAJfQorCWlmICh0Y2xhc3MgPCAw
KSB7CisJCXRjbGFzcyA9IG5wLT5jb3JrLnRjbGFzczsKKwkJaWYgKHRjbGFzcyA8IDApCisJCQl0
Y2xhc3MgPSAwOworCX0KIAogCWlmIChtc2ctPm1zZ19mbGFncyZNU0dfQ09ORklSTSkKIAkJZ290
byBkb19jb25maXJtOwpAQCAtODMyLDkgKzgzOCwxMCBAQCBiYWNrX2Zyb21fY29uZmlybToKIAog
ZG9fYXBwZW5kX2RhdGE6CiAJdXAtPmxlbiArPSB1bGVuOwotCWVyciA9IGlwNl9hcHBlbmRfZGF0
YShzaywgaXBfZ2VuZXJpY19nZXRmcmFnLCBtc2ctPm1zZ19pb3YsIHVsZW4sIHNpemVvZihzdHJ1
Y3QgdWRwaGRyKSwKLQkJCSAgICAgIGhsaW1pdCwgb3B0LCBmbCwgKHN0cnVjdCBydDZfaW5mbyop
ZHN0LAotCQkJICAgICAgY29ya3JlcSA/IG1zZy0+bXNnX2ZsYWdzfE1TR19NT1JFIDogbXNnLT5t
c2dfZmxhZ3MpOworCWVyciA9IGlwNl9hcHBlbmRfZGF0YShzaywgaXBfZ2VuZXJpY19nZXRmcmFn
LCBtc2ctPm1zZ19pb3YsIHVsZW4sCisJCXNpemVvZihzdHJ1Y3QgdWRwaGRyKSwgaGxpbWl0LCB0
Y2xhc3MsIG9wdCwgZmwsCisJCShzdHJ1Y3QgcnQ2X2luZm8qKWRzdCwKKwkJY29ya3JlcSA/IG1z
Zy0+bXNnX2ZsYWdzfE1TR19NT1JFIDogbXNnLT5tc2dfZmxhZ3MpOwogCWlmIChlcnIpCiAJCXVk
cF92Nl9mbHVzaF9wZW5kaW5nX2ZyYW1lcyhzayk7CiAJZWxzZSBpZiAoIWNvcmtyZXEpCg==

--=_mixed 006CCE2C88257018_=--
