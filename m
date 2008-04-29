From: Satoru SATOH <satoru.satoh@gmail.com>
Subject: Re: [PATCH] Use inline function dst_metric() instead of direct access
 to dst->metric[]
Date: Wed, 30 Apr 2008 00:21:48 +0900
Message-ID: <48173D0C.8020109@gmail.com>
References: <d72b7ace0804250717g40f81ea0o899f43fdc1d08384@mail.gmail.com>	<20080426.232332.30254129.davem@davemloft.net>	<4815D81F.5090404@gmail.com> <20080428.231017.23295115.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51878 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751673AbYD2PY7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 11:24:59 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m3TFOwbB023030
	for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 11:24:58 -0400
Received: from pobox.nrt.redhat.com (pobox.nrt.redhat.com [10.64.255.12])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m3TFOuxI029999
	for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 11:24:57 -0400
Received: from gescom.nrt.redhat.com (vpn-198-10.nrt.redhat.com [10.64.198.10])
	by pobox.nrt.redhat.com (8.13.1/8.13.1) with ESMTP id m3TFOtUF018992
	for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 00:24:55 +0900
In-Reply-To: <20080428.231017.23295115.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / 吉藤英明 wrote:
> Sato-san, I think we have more places, e.g., in net/ipv4/route.c:
>     if (rt->u.dst.metrics[RTAX_HOPLIMIT-1] == 0)
> should be converted as
>     if (dst_metric(&rt->u.dst, RTAX_HOPLIMIT) == 0)
>
> Could you annotate those as well, please?
>
> Maybe we could introduce dst_metric_set(), but it is a
> different issue.
>
> --yoshfuji
Right. Here is a updated version.

There are functions to refer to the value of dst->metric[THE_METRIC-1] directly
without use of a inline function "dst_metric" defined in net/dst.h.

The following patch changes them to use the inline function consistently.

Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>

net/decnet/dn_route.c | 12 ++++++------
net/ipv4/route.c | 16 ++++++++--------
net/ipv4/tcp_input.c | 15 ++++++++-------
net/ipv6/route.c | 6 +++---
4 files changed, 25 insertions(+), 24 deletions(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 2f665a5..f50e88b 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -235,14 +235,14 @@ static void dn_dst_update_pmtu(struct dst_entry
*dst, u32 mtu)
else
min_mtu -= 21;

- if (dst->metrics[RTAX_MTU-1] > mtu && mtu >= min_mtu) {
+ if (dst_metric(dst, RTAX_MTU) > mtu && mtu >= min_mtu) {
if (!(dst_metric_locked(dst, RTAX_MTU))) {
dst->metrics[RTAX_MTU-1] = mtu;
dst_set_expires(dst, dn_rt_mtu_expires);
}
if (!(dst_metric_locked(dst, RTAX_ADVMSS))) {
u32 mss = mtu - DN_MAX_NSP_DATA_HEADER;
- if (dst->metrics[RTAX_ADVMSS-1] > mss)
+ if (dst_metric(dst, RTAX_ADVMSS) > mss)
dst->metrics[RTAX_ADVMSS-1] = mss;
}
}
@@ -805,12 +805,12 @@ static int dn_rt_set_next_hop(struct dn_route *rt,
struct dn_fib_res *res)
rt->u.dst.neighbour = n;
}

- if (rt->u.dst.metrics[RTAX_MTU-1] == 0 ||
- rt->u.dst.metrics[RTAX_MTU-1] > rt->u.dst.dev->mtu)
+ if (dst_metric(&rt->u.dst, RTAX_MTU) == 0 ||
+ dst_metric(&rt->u.dst, RTAX_MTU) > rt->u.dst.dev->mtu)
rt->u.dst.metrics[RTAX_MTU-1] = rt->u.dst.dev->mtu;
mss = dn_mss_from_pmtu(dev, dst_mtu(&rt->u.dst));
- if (rt->u.dst.metrics[RTAX_ADVMSS-1] == 0 ||
- rt->u.dst.metrics[RTAX_ADVMSS-1] > mss)
+ if (dst_metric(&rt->u.dst, RTAX_ADVMSS) == 0 ||
+ dst_metric(&rt->u.dst, RTAX_ADVMSS) > mss)
rt->u.dst.metrics[RTAX_ADVMSS-1] = mss;
return 0;
}
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ce25a13..24dc66b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1462,14 +1462,14 @@ unsigned short ip_rt_frag_needed(struct net
*net, struct iphdr *iph,

/* BSD 4.2 compatibility hack :-( */
if (mtu == 0 &&
- old_mtu >= rth->u.dst.metrics[RTAX_MTU-1] &&
+ old_mtu >= dst_metric(&rth->u.dst, RTAX_MTU) &&
old_mtu >= 68 + (iph->ihl << 2))
old_mtu -= iph->ihl << 2;

mtu = guess_mtu(old_mtu);
}
- if (mtu <= rth->u.dst.metrics[RTAX_MTU-1]) {
- if (mtu < rth->u.dst.metrics[RTAX_MTU-1]) {
+ if (mtu <= dst_metric(&rth->u.dst, RTAX_MTU)) {
+ if (mtu < dst_metric(&rth->u.dst, RTAX_MTU)) {
dst_confirm(&rth->u.dst);
if (mtu < ip_rt_min_pmtu) {
mtu = ip_rt_min_pmtu;
@@ -1491,7 +1491,7 @@ unsigned short ip_rt_frag_needed(struct net *net,
struct iphdr *iph,

static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
{
- if (dst->metrics[RTAX_MTU-1] > mtu && mtu >= 68 &&
+ if (dst_metric(dst, RTAX_MTU) > mtu && mtu >= 68 &&
!(dst_metric_locked(dst, RTAX_MTU))) {
if (mtu < ip_rt_min_pmtu) {
mtu = ip_rt_min_pmtu;
@@ -1618,14 +1618,14 @@ static void rt_set_nexthop(struct rtable *rt,
struct fib_result *res, u32 itag)
} else
rt->u.dst.metrics[RTAX_MTU-1]= rt->u.dst.dev->mtu;

- if (rt->u.dst.metrics[RTAX_HOPLIMIT-1] == 0)
+ if (dst_metric(&rt->u.dst, RTAX_HOPLIMIT) == 0)
rt->u.dst.metrics[RTAX_HOPLIMIT-1] = sysctl_ip_default_ttl;
- if (rt->u.dst.metrics[RTAX_MTU-1] > IP_MAX_MTU)
+ if (dst_metric(&rt->u.dst, RTAX_MTU) > IP_MAX_MTU)
rt->u.dst.metrics[RTAX_MTU-1] = IP_MAX_MTU;
- if (rt->u.dst.metrics[RTAX_ADVMSS-1] == 0)
+ if (dst_metric(&rt->u.dst, RTAX_ADVMSS) == 0)
rt->u.dst.metrics[RTAX_ADVMSS-1] = max_t(unsigned int,
rt->u.dst.dev->mtu - 40,
ip_rt_min_advmss);
- if (rt->u.dst.metrics[RTAX_ADVMSS-1] > 65535 - 40)
+ if (dst_metric(&rt->u.dst, RTAX_ADVMSS) > 65535 - 40)
rt->u.dst.metrics[RTAX_ADVMSS-1] = 65535 - 40;

#ifdef CONFIG_NET_CLS_ROUTE
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0298f80..3754055 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -66,6 +66,7 @@
#include <linux/mm.h>
#include <linux/module.h>
#include <linux/sysctl.h>
+#include <net/dst.h>
#include <net/tcp.h>
#include <net/inet_common.h>
#include <linux/ipsec.h>
@@ -605,7 +606,7 @@ static u32 tcp_rto_min(struct sock *sk)
u32 rto_min = TCP_RTO_MIN;

if (dst && dst_metric_locked(dst, RTAX_RTO_MIN))
- rto_min = dst->metrics[RTAX_RTO_MIN - 1];
+ rto_min = dst_metric(dst, RTAX_RTO_MIN);
return rto_min;
}

@@ -769,7 +770,7 @@ void tcp_update_metrics(struct sock *sk)
dst->metrics[RTAX_RTTVAR - 1] = m;
else
dst->metrics[RTAX_RTTVAR-1] -=
- (dst->metrics[RTAX_RTTVAR-1] - m)>>2;
+ (dst_metric(dst, RTAX_RTTVAR) - m)>>2;
}

if (tp->snd_ssthresh >= 0xFFFF) {
@@ -788,21 +789,21 @@ void tcp_update_metrics(struct sock *sk)
dst->metrics[RTAX_SSTHRESH-1] =
max(tp->snd_cwnd >> 1, tp->snd_ssthresh);
if (!dst_metric_locked(dst, RTAX_CWND))
- dst->metrics[RTAX_CWND-1] = (dst->metrics[RTAX_CWND-1] + tp->snd_cwnd)
>> 1;
+ dst->metrics[RTAX_CWND-1] = (dst_metric(dst, RTAX_CWND) +
tp->snd_cwnd) >> 1;
} else {
/* Else slow start did not finish, cwnd is non-sense,
ssthresh may be also invalid.
*/
if (!dst_metric_locked(dst, RTAX_CWND))
- dst->metrics[RTAX_CWND-1] = (dst->metrics[RTAX_CWND-1] +
tp->snd_ssthresh) >> 1;
- if (dst->metrics[RTAX_SSTHRESH-1] &&
+ dst->metrics[RTAX_CWND-1] = (dst_metric(dst, RTAX_CWND) +
tp->snd_ssthresh) >> 1;
+ if (dst_metric(dst, RTAX_SSTHRESH) &&
!dst_metric_locked(dst, RTAX_SSTHRESH) &&
- tp->snd_ssthresh > dst->metrics[RTAX_SSTHRESH-1])
+ tp->snd_ssthresh > dst_metric(dst, RTAX_SSTHRESH))
dst->metrics[RTAX_SSTHRESH-1] = tp->snd_ssthresh;
}

if (!dst_metric_locked(dst, RTAX_REORDERING)) {
- if (dst->metrics[RTAX_REORDERING-1] < tp->reordering &&
+ if (dst_metric(dst, RTAX_REORDERING) < tp->reordering &&
tp->reordering != sysctl_tcp_reordering)
dst->metrics[RTAX_REORDERING-1] = tp->reordering;
}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a493ad9..12bba08 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1243,11 +1243,11 @@ install_route:
}
}

- if (rt->u.dst.metrics[RTAX_HOPLIMIT-1] == 0)
+ if (dst_metric(&rt->u.dst, RTAX_HOPLIMIT) == 0)
rt->u.dst.metrics[RTAX_HOPLIMIT-1] = -1;
- if (!rt->u.dst.metrics[RTAX_MTU-1])
+ if (!dst_metric(&rt->u.dst, RTAX_MTU))
rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(dev);
- if (!rt->u.dst.metrics[RTAX_ADVMSS-1])
+ if (!dst_metric(&rt->u.dst, RTAX_ADVMSS))
rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, dst_mtu(&rt->u.dst));
rt->u.dst.dev = dev;
rt->rt6i_idev = idev;

