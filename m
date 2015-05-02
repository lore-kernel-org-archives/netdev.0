From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 3/5] ipv6: Stop /128 route from disappearing
 after pmtu update
Date: Sat, 2 May 2015 16:20:40 -0700
Message-ID: <20150502232040.GB2731450@devbig242.prn2.facebook.com>
References: <1430251387-2942539-1-git-send-email-kafai@fb.com>
 <1430251387-2942539-4-git-send-email-kafai@fb.com>
 <m2d22itxe2.wl@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <hannes@stressinduktion.org>,
	<steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<yangyingliang@huawei.com>, <shengyong1@huawei.com>,
	<Kernel-team@fb.com>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54083 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750966AbbEBXU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2015 19:20:58 -0400
Content-Disposition: inline
In-Reply-To: <m2d22itxe2.wl@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hajime,

On Sun, May 03, 2015 at 07:41:57AM +0900, Hajime Tazaki wrote:
> a regression is detected by my nightly test (below) and
> quick bisecting with LibOS (ns-3/DCE) gave me this commit.
> 
> https://urldefense.proofpoint.com/v1/url?u=http://ns-3-dce.cloud.wide.ad.jp/jenkins/job/daily-net-next-sim/878/&k=ZVNjlDMF0FElm4dQtryO4A%3D%3D%0A&r=%2Faj1ZOQObwbmtLwlDw3XzQ%3D%3D%0A&m=%2B4tL0PwkB3R%2BcCJxbDDg3rbrKM%2Fq3CKnwlsp5XsSwqg%3D%0A&s=07d84598efaff9b3d5df8d42779e0753f0cc007daaf1aaf9c0ca6bd8999192b9
> 
> At Tue, 28 Apr 2015 13:03:05 -0700,
> Martin KaFai Lau wrote:
> > ---
> >  net/ipv6/route.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> > index 07562a2..aa4cfdd 100644
> > --- a/net/ipv6/route.c
> > +++ b/net/ipv6/route.c
> > @@ -977,7 +977,7 @@ redo_rt6_select:
> >  
> >  	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
> >  		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
> > -	else if (!(rt->dst.flags & DST_HOST))
> > +	else if (!(rt->dst.flags & DST_HOST) || !(rt->dst.flags & RTF_LOCAL))
> >  		nrt = rt6_alloc_clone(rt, &fl6->daddr);
> >  	else
> >  		goto out2;
> > @@ -1172,7 +1172,7 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
> >  	struct rt6_info *rt6 = (struct rt6_info *)dst;
> >  
> >  	dst_confirm(dst);
> > -	if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen == 128) {
> > +	if (mtu < dst_mtu(dst) && (rt6->rt6i_flags & RTF_CACHE)) {
> >  		struct net *net = dev_net(dst->dev);
> >  
> >  		rt6->rt6i_flags |= RTF_MODIFIED;
> 
> - how to reproduce it
> 
> the test is simply sending an IPv6 packet to a node on the
> same subnet to verify the connectivity (e.g., ping6
> 2001:1::2 from 2001:1::1) and echo packets didn't get back.
> 
> reverting this commit fixes the issue.
> 
> please take a look at it: I'm glad to know if this only
> happens in my local environment.
Thanks for reporting.

I cannot reproduce in my environment.

15:58:30.658360 6a:aa:e6:a1:ce:f9 > 52:54:00:12:34:56, ethertype IPv6 (0x86dd), length 118: 2001:1::2 > 2001:1::1: ICMP6, echo request, seq 1, length 64
15:58:30.658479 52:54:00:12:34:56 > 6a:aa:e6:a1:ce:f9, ethertype IPv6 (0x86dd), length 118: 2001:1::1 > 2001:1::2: ICMP6, echo reply, seq 1, length 64
15:58:31.658093 6a:aa:e6:a1:ce:f9 > 52:54:00:12:34:56, ethertype IPv6 (0x86dd), length 118: 2001:1::2 > 2001:1::1: ICMP6, echo request, seq 2, length 64
15:58:31.658214 52:54:00:12:34:56 > 6a:aa:e6:a1:ce:f9, ethertype IPv6 (0x86dd), length 118: 2001:1::1 > 2001:1::2: ICMP6, echo reply, seq 2, length 64
15:58:32.657977 6a:aa:e6:a1:ce:f9 > 52:54:00:12:34:56, ethertype IPv6 (0x86dd), length 118: 2001:1::2 > 2001:1::1: ICMP6, echo request, seq 3, length 64
15:58:32.658079 52:54:00:12:34:56 > 6a:aa:e6:a1:ce:f9, ethertype IPv6 (0x86dd), length 118: 2001:1::1 > 2001:1::2: ICMP6, echo reply, seq 3, length 64
15:58:33.658104 6a:aa:e6:a1:ce:f9 > 52:54:00:12:34:56, ethertype IPv6 (0x86dd), length 118: 2001:1::2 > 2001:1::1: ICMP6, echo request, seq 4, length 64
15:58:33.658243 52:54:00:12:34:56 > 6a:aa:e6:a1:ce:f9, ethertype IPv6 (0x86dd), length 118: 2001:1::1 > 2001:1::2: ICMP6, echo reply, seq 4, length 64
15:58:34.658150 6a:aa:e6:a1:ce:f9 > 52:54:00:12:34:56, ethertype IPv6 (0x86dd), length 118: 2001:1::2 > 2001:1::1: ICMP6, echo request, seq 5, length 64
15:58:34.658275 52:54:00:12:34:56 > 6a:aa:e6:a1:ce:f9, ethertype IPv6 (0x86dd), length 118: 2001:1::1 > 2001:1::2: ICMP6, echo reply, seq 5, length 64

I suspect there is a RTF_LOCAL route getting a ICMPv6 too-big packet.

Can you provide a tcpdump at both ends?  Also, the output of
the 'ip -6 a' and 'ip -6 r show'.

Also, can you try the following change which is a partial revert.  If ping goes
through again, can you capture the 'ip -6 show' on both sides quickly after the
test.

Thanks,
--Martin

diff --git i/net/ipv6/route.c w/net/ipv6/route.c
index 3522711..60212d4 100644
--- i/net/ipv6/route.c
+++ w/net/ipv6/route.c
@@ -1124,7 +1124,7 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 	struct rt6_info *rt6 = (struct rt6_info *)dst;

 	dst_confirm(dst);
-	if (mtu < dst_mtu(dst) && (rt6->rt6i_flags & RTF_CACHE)) {
+	if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen == 128) {
 		struct net *net = dev_net(dst->dev);

 		rt6->rt6i_flags |= RTF_MODIFIED;
