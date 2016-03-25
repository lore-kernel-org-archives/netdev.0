From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Fri, 25 Mar 2016 16:55:27 -0700
Message-ID: <20160325235527.GA29327@kafai-mba.local>
References: <CAC15z3hhXxTQ+_Y6DaZcd-XVfCdDO9ZcQD6doNNKt-wHjTXAQw@mail.gmail.com>
 <CAM_iQpWvKUyTmvH=08FbeyGWKfV_WaM_L1MgOQ-9r9hjfvzPyA@mail.gmail.com>
 <CAC15z3ikqBc3CcgNaUJkaD1ZiBbwqZFkjEsgR7_F9Q1dvZ2Zvw@mail.gmail.com>
 <20160322060220.GA50824@kafai-mba.local>
 <CAM_iQpVfofoThoUS8UYkh-2KR_Co42tfxz00mCXx+JMWpwgg8A@mail.gmail.com>
 <20160322173939.GA53936@kafai-mba.local>
 <CAC15z3jDRvJR4uZ97mC+beaMaPQvAvTHB9OLKCdQ4hcwRu07vw@mail.gmail.com>
 <CAM_iQpU7JeLuAVPqtzjvJ7qvMYTDZSR8xc7Vfw--uQDxW-WaHQ@mail.gmail.com>
 <1458689814.10868.29.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAC15z3g-LDOdpcsZEs6XFFOOb92bXAbdOORdnd+MTvF62TgSiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Wei Wang <tracywwnj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45298 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752772AbcCYXzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 19:55:39 -0400
Content-Disposition: inline
In-Reply-To: <CAC15z3g-LDOdpcsZEs6XFFOOb92bXAbdOORdnd+MTvF62TgSiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 04:57:22PM -0700, Wei Wang wrote:
> What about something like this:
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index ed44663..21b4102 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1394,6 +1394,19 @@ static void ip6_rt_update_pmtu(struct dst_entry
> *dst, struct sock *sk,
>     __ip6_rt_update_pmtu(dst, sk, skb ? ipv6_hdr(skb) : NULL, mtu);
>  }
>
> +static void ip6_fill_in_flow(struct flowi6 *fl6,  struct net *net,
> +                  struct sk_buff *skb, int oif, u32 mark)
> +{
> +   const struct ipv6hdr *iph = (struct ipv6hdr *) skb->data;
> +
> +   memset(fl6, 0, sizeof(fl6));
> +   fl6->flowi6_oif = oif;
> +   fl6->flowi6_mark = mark ? mark : IP6_REPLY_MARK(net, skb->mark);
> +   fl6->daddr = iph->daddr;
> +   fl6->saddr = iph->saddr;
> +   fl6->flowlabel = ip6_flowinfo(iph);
> +}
> +
>  void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
>              int oif, u32 mark)
>  {
> @@ -1401,13 +1414,7 @@ void ip6_update_pmtu(struct sk_buff *skb,
> struct net *net, __be32 mtu,
>     struct dst_entry *dst;
>     struct flowi6 fl6;
>
> -   memset(&fl6, 0, sizeof(fl6));
> -   fl6.flowi6_oif = oif;
> -   fl6.flowi6_mark = mark ? mark : IP6_REPLY_MARK(net, skb->mark);
> -   fl6.daddr = iph->daddr;
> -   fl6.saddr = iph->saddr;
> -   fl6.flowlabel = ip6_flowinfo(iph);
> -
> +   ip6_fill_in_flow(&fl6, net, skb, oif, mark);
>     dst = ip6_route_output(net, NULL, &fl6);
>     if (!dst->error)
>         __ip6_rt_update_pmtu(dst, NULL, iph, ntohl(mtu));
> @@ -1417,8 +1424,22 @@ EXPORT_SYMBOL_GPL(ip6_update_pmtu);
>
>  void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu)
>  {
> -   ip6_update_pmtu(skb, sock_net(sk), mtu,
> +   struct ipv6_pinfo *np = inet6_sk(sk);
> +   struct dst_entry *dst_new;
> +   struct flowi6 fl6;
> +   struct net *net = sock_net(sk);
> +
> +   ip6_update_pmtu(skb, net, mtu,
> +           sk->sk_bound_dev_if, sk->sk_mark);
> +
> +   if (sk->sk_state == TCP_ESTABLISHED &&
> +       !sk_dst_check(sk, np->dst_cookie)) {
> +       ip6_fill_in_flow(&fl6, net, skb,
>             sk->sk_bound_dev_if, sk->sk_mark);
> +       dst_new = ip6_route_output(net, NULL, &fl6);
> +       if (!IS_ERR(dst_new))
> +           ip6_dst_store(sk, dst_new, NULL, NULL);
> +   }
>  }
>  EXPORT_SYMBOL_GPL(ip6_sk_update_pmtu);

Here is the change I come up with (based on your flow key buildup function
with one fix), take a little different approach in ip6_sk_update_pmtu()
and some explanation on ip6_dst_store() after looking at ip6_rt_check()

I have not included the sk lock yet.  There is still a few things I don't fully
understand in another discussion thread.

[PATCH] ipv6: Update sk->sk_dst_cache in ip6_sk_update_pmtu()

There is a case in connected UDP socket such that
getsockopt(IPV6_MTU) will return a stale MTU value. The reproducible
sequence could be the following:
1. Create a connected UDP socket
2. Send some datagrams out
3. Receive a ICMPV6_PKT_TOOBIG
4. No new outgoing datagrams to trigger the sk_dst_check()
   logic to update the sk->sk_dst_cache.
5. getsockopt(IPV6_MTU) returns the mtu from the invalid
   sk->sk_dst_cache instead of the newly created RTF_CACHE clone which
   contains the MTU value instructed by the ICMPV6_PKT_TOOBIG message.

One observation is that, the __udp6_lib_err() code path does not do a
sk_dst_check() and route relookup (if needed) after doing the pmtu
update (while TCP does).

This patch does a ip6_dst_check() in ip6_sk_update_pmtu() which is used
by UDP to do the pmtu update and update sk->sk_dst_cache if it is needed.

ip6_dst_store(sk, ndst, NULL, NULL) is used.  NULL(s) are passed to
the daddr and saddr parameters for simplicity reason.  The current
use case is only for the UDP lookup.  The details is in ip6_rt_check().

At the point where ip6_dst_store(sk, ndst, NULL, NULL) is called in
this patch, ndst should be a RTF_CACHE clone (which implies
((struct rt6i_info *)ndst)->rt6i_dst.plen == 128) and ip6_rt_check()
will pass without even considering np->d/saddr_cache.

Even it has to use np->d/saddr_cache, the worst case is ip6_rt_check()
fails and causes one more route lookup.

Test:

Server (Connected UDP Socket):
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Route Details:
[root@arch-fb-vm1 ~]# ip -6 r show | egrep '2fac'
2fac::/64 dev eth0  proto kernel  metric 256  pref medium
2fac:face::/64 via 2fac::face dev eth0  metric 1024  pref medium

A crappy python code to create a connected UDP socket:

import socket
import errno

HOST = '2fac::1'
PORT = 8080

s = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
s.bind((HOST, PORT))
s.connect(('2fac:face::face', 53))
print("connected")
while True:
    try:
	data = s.recv(1024)
    except socket.error as se:
	if se.errno == errno.EMSGSIZE:
		pmtu = s.getsockopt(41, 24)
		print("PMTU:%d" % pmtu)
		break
s.close()

Python program output after getting a ICMPV6_PKT_TOOBIG:
[root@arch-fb-vm1 ~]# python2 ~/devshare/kernel/tasks/fib6/udp-connect-53-8080.py
connected
PMTU:1300

Cache routes after recieving TOOBIG:
[root@arch-fb-vm1 ~]# ip -6 r show table cache
2fac:face::face via 2fac::face dev eth0  metric 0
    cache  expires 463sec mtu 1300 pref medium

Client (Send the ICMPV6_PKT_TOOBIG):
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
scapy is used to generate the TOOBIG message.  Here is the scrapy script I have
used:

>>> p=Ether(src='da:75:4d:36:ac:32', dst='52:54:00:12:34:66', type=0x86dd)/IPv6(src='2fac::face', dst='2fac::1')/ICMPv6PacketTooBig(mtu=1300)/IPv6(src='2fac::
1',dst='2fac:face::face', nh='UDP')/UDP(sport=8080,dport=53)
>>> sendp(p, iface='qemubr0')

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reported-by: Wei Wang <weiwan@google.com>
---
 net/ipv6/route.c | 40 +++++++++++++++++++++++++++++++++-------
 1 file changed, 33 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ed44663..06934ff 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1394,6 +1394,20 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 	__ip6_rt_update_pmtu(dst, sk, skb ? ipv6_hdr(skb) : NULL, mtu);
 }

+static void build_skb_flow_key(struct flowi6 *fl6,
+			       const struct sk_buff *skb,
+			       struct net *net, int oif, u32 mark)
+{
+	const struct ipv6hdr *iph = (struct ipv6hdr *)skb->data;
+
+	memset(fl6, 0, sizeof(*fl6));
+	fl6->flowi6_oif = oif;
+	fl6->flowi6_mark = mark ? mark : IP6_REPLY_MARK(net, skb->mark);
+	fl6->daddr = iph->daddr;
+	fl6->saddr = iph->saddr;
+	fl6->flowlabel = ip6_flowinfo(iph);
+}
+
 void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 		     int oif, u32 mark)
 {
@@ -1401,13 +1415,7 @@ void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 	struct dst_entry *dst;
 	struct flowi6 fl6;

-	memset(&fl6, 0, sizeof(fl6));
-	fl6.flowi6_oif = oif;
-	fl6.flowi6_mark = mark ? mark : IP6_REPLY_MARK(net, skb->mark);
-	fl6.daddr = iph->daddr;
-	fl6.saddr = iph->saddr;
-	fl6.flowlabel = ip6_flowinfo(iph);
-
+	build_skb_flow_key(&fl6, skb, net, oif, mark);
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (!dst->error)
 		__ip6_rt_update_pmtu(dst, NULL, iph, ntohl(mtu));
@@ -1417,8 +1425,26 @@ EXPORT_SYMBOL_GPL(ip6_update_pmtu);

 void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu)
 {
+	struct dst_entry *odst;
+
+	odst = sk_dst_get(sk);
+
 	ip6_update_pmtu(skb, sock_net(sk), mtu,
 			sk->sk_bound_dev_if, sk->sk_mark);
+
+	if (odst && !odst->error &&
+	    !ip6_dst_check(odst, inet6_sk(sk)->dst_cookie)) {
+		struct dst_entry *ndst;
+		struct flowi6 fl6;
+
+		build_skb_flow_key(&fl6, skb, sock_net(sk),
+				   sk->sk_bound_dev_if, sk->sk_mark);
+		ndst = ip6_route_output(sock_net(sk), NULL, &fl6);
+		if (!ndst->error)
+			ip6_dst_store(sk, ndst, NULL, NULL);
+	}
+
+	dst_release(odst);
 }
 EXPORT_SYMBOL_GPL(ip6_sk_update_pmtu);
