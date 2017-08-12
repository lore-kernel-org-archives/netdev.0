From: Ido Schimmel <idosch@idosch.org>
Subject: Re: unregister_netdevice: waiting for eth0 to become free. Usage
 count = 1
Date: Sat, 12 Aug 2017 21:01:29 +0300
Message-ID: <20170812180129.GA31700@splinter>
References: <CAM_iQpW2=aKKUmWanbuhqXdZGxr_TqB5pQ+U+A0+=optuGX5-Q@mail.gmail.com>
 <CALAqxLXv60ReJu26omM6p=ZboEm-Z-3w+q0JcxLXDqqK5ohNoQ@mail.gmail.com>
 <CAEA6p_AL8uUghtZgp4OmqygcFs-Jiy286P5r6tRd+yeSWxR3KA@mail.gmail.com>
 <CALAqxLXY-kE2N__eDq514cLycR0-QRpyOCMWpdttO6fgovE2rg@mail.gmail.com>
 <CAEA6p_C_rEYkJhcniyy6HUHgNxWFoxWzZ-WHsaSmNDwx4D+RXQ@mail.gmail.com>
 <CAEA6p_AOcNkAWPc7NFBnr8QWi3eHdJiQ2=8D_DB_XthwSDL2+Q@mail.gmail.com>
 <CALAqxLUoV6EQvofTEv9whW1_QMPBPU7eJBhRFUjaSs7CGeRFww@mail.gmail.com>
 <CAM_iQpWMWg5ytDq2Y9p9uet1zowGuCX+eksyiyxu9vQ18WoPxQ@mail.gmail.com>
 <CAEA6p_CooRGNOQN3fosF0JLqmd9aOTuNHKNPE8cbrzDH6c176w@mail.gmail.com>
 <CAEA6p_COwXWP97wSHvzokmm8ckQ2QEd7=dfNH04ttDPm_z3bcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        John Stultz <john.stultz@linaro.org>,
        Martin KaFai Lau <kafai@fb.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux USB List <linux-usb@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Felipe Balbi <felipe.balbi@linux.intel.com>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:54829 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752105AbdHLSBe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2017 14:01:34 -0400
Content-Disposition: inline
In-Reply-To: <CAEA6p_COwXWP97wSHvzokmm8ckQ2QEd7=dfNH04ttDPm_z3bcg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wei,

On Fri, Aug 11, 2017 at 05:10:02PM -0700, Wei Wang wrote:
> I think we have a potential fix for this issue.
> Martin and I found that when addrconf_dst_alloc() creates a rt6, it is
> possible that rt6->dst.dev points to loopback device while
> rt6->rt6i_idev->dev points to a real device.
> When the real device goes down, the current fib6 clean up code only
> checks for rt6->dst.dev and assumes rt6->rt6i_idev->dev is the same.
> That leaves unreleased refcnt on the real device if rt6->dst.dev
> points to loopback dev.

[...]

> From 2d8861808c2029013f6b6e86120ba6902329145b Mon Sep 17 00:00:00 2001
> From: Wei Wang <weiwan@google.com>
> Date: Fri, 11 Aug 2017 16:36:04 -0700
> Subject: [PATCH 1/2] potential fix for unregister_netdevice()
> 
> Change-Id: I5d5f6f7a7ad0f5dd769f33487db17ff2570d52ea
> ---
>  net/ipv6/route.c | 17 ++++++++---------
>  1 file changed, 8 insertions(+), 9 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 4d30c96a819d..105922903932 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -417,14 +417,12 @@ static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
>  	struct net_device *loopback_dev =
>  		dev_net(dev)->loopback_dev;
>  
> -	if (dev != loopback_dev) {
> -		if (idev && idev->dev == dev) {
> -			struct inet6_dev *loopback_idev =
> -				in6_dev_get(loopback_dev);
> -			if (loopback_idev) {
> -				rt->rt6i_idev = loopback_idev;
> -				in6_dev_put(idev);
> -			}
> +	if (idev && idev->dev != loopback_dev) {
> +		struct inet6_dev *loopback_idev =
> +			in6_dev_get(loopback_dev);
> +		if (loopback_idev) {
> +			rt->rt6i_idev = loopback_idev;
> +			in6_dev_put(idev);
>  		}
>  	}
>  }
> @@ -2789,7 +2787,8 @@ static int fib6_ifdown(struct rt6_info *rt, void *arg)
>  	const struct arg_dev_net *adn = arg;
>  	const struct net_device *dev = adn->dev;
>  
> -	if ((rt->dst.dev == dev || !dev) &&
> +	if ((rt->dst.dev == dev || !dev ||
> +	     rt->rt6i_idev->dev == dev) &&

Can you please explain why this line is needed? While host routes aren't
removed from the FIB by rt6_ifdown() (when dst.dev goes down), they are
removed later on in addrconf_ifdown().

With your patch, if I check the return value of ip6_del_rt() in
__ipv6_ifa_notify() I see that -ENONET is returned. Because the host
route was already removed by rt6_ifdown(). When the line in question is
removed from the patch I don't get the error anymore.

Is it possible that in John's case the host route was correctly removed
from the FIB and that the unreleased reference was due to a wrong check
in ip6_dst_ifdown() (which you patched correctly AFAICT)?

Thanks

>  	    rt != adn->net->ipv6.ip6_null_entry &&
>  	    (rt->rt6i_nsiblings == 0 ||
>  	     (dev && netdev_unregistering(dev)) ||
> -- 
> 2.14.0.434.g98096fd7a8-goog
> 
