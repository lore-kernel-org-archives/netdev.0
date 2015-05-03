From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 3/5] ipv6: Stop /128 route from disappearing
 after pmtu update
Date: Sat, 2 May 2015 20:38:01 -0700
Message-ID: <20150503033801.GE2731450@devbig242.prn2.facebook.com>
References: <1430251387-2942539-1-git-send-email-kafai@fb.com>
 <1430251387-2942539-4-git-send-email-kafai@fb.com>
 <m2d22itxe2.wl@sfc.wide.ad.jp>
 <20150502232040.GB2731450@devbig242.prn2.facebook.com>
 <m2bni2tsv0.wl@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <hannes@stressinduktion.org>,
	<steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<yangyingliang@huawei.com>, <shengyong1@huawei.com>,
	<Kernel-team@fb.com>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55505 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751255AbbECDiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2015 23:38:19 -0400
Content-Disposition: inline
In-Reply-To: <m2bni2tsv0.wl@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 03, 2015 at 09:19:47AM +0900, Hajime Tazaki wrote:
> - 'ip -6 r show' at the ping6 sender
> 2001:1::/64 dev sim0  proto kernel  metric 256 
> fe80::/64 dev sim0  proto kernel  metric 256 
> 
> # the results of ip command on receiver side are almost
>   similar.
> 
> I found that the test uses non-ARP interface between nodes:
> if I changed the interface to 'non-NOARP' NIC, the issue has
> gone away without the revert.
I have given a little more thoughts.  With the below partial patch
ruled out and together with a /64 route in your test,
I failed to see how another line change could have broken.

Can you share some more details on your test and
can you reproduce it with some basic iproute2 commands?

--Martin


> 
> I'm using the following scenario: just FYI.
> 
> https://gist.github.com/thehajime/26be8606ddbb924f357c
> 
> > Also, can you try the following change which is a partial revert.  If ping goes
> > through again, can you capture the 'ip -6 show' on both sides quickly after the
> > test.
> > 
> > Thanks,
> > --Martin
> > 
> > diff --git i/net/ipv6/route.c w/net/ipv6/route.c
> > index 3522711..60212d4 100644
> > --- i/net/ipv6/route.c
> > +++ w/net/ipv6/route.c
> > @@ -1124,7 +1124,7 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
> >  	struct rt6_info *rt6 = (struct rt6_info *)dst;
> > 
> >  	dst_confirm(dst);
> > -	if (mtu < dst_mtu(dst) && (rt6->rt6i_flags & RTF_CACHE)) {
> > +	if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen == 128) {
> >  		struct net *net = dev_net(dst->dev);
> > 
> >  		rt6->rt6i_flags |= RTF_MODIFIED;
> 
> this partial revert didn't change my situation.
> 
> 
> -- Hajime
