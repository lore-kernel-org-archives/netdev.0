From: =?utf-8?B?5byg6IOc5Li+?= <zhangshengju@cmss.chinamobile.com>
Subject: RE: [net-next 1/2] dummy: add device MTU validation check
Date: Fri, 22 Sep 2017 11:28:01 +0800
Message-ID: <00b401d33352$cb92d990$62b88cb0$@cmss.chinamobile.com>
References: <1506000722-40095-1-git-send-email-zhangshengju@cmss.chinamobile.com>    <1506000722-40095-2-git-send-email-zhangshengju@cmss.chinamobile.com> <1506006138.29839.132.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <willemb@google.com>,
        <stephen@networkplumber.org>, <netdev@vger.kernel.org>
To: "'Eric Dumazet'" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:57439 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751794AbdIVD2L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 23:28:11 -0400
In-Reply-To: <1506006138.29839.132.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> Sent: 2017年9月21日 23:02
> To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> Cc: davem@davemloft.net; willemb@google.com;
> stephen@networkplumber.org; netdev@vger.kernel.org
> Subject: Re: [net-next 1/2] dummy: add device MTU validation check
> 
> On Thu, 2017-09-21 at 21:32 +0800, Zhang Shengju wrote:
> > Currently, any mtu value can be assigned when adding a new dummy device:
> > [~]# ip link add name dummy1 mtu 100000 type dummy [~]# ip link show
> > dummy1
> > 15: dummy1: <BROADCAST,NOARP> mtu 100000 qdisc noop state DOWN
> mode DEFAULT group default qlen 1000
> >     link/ether 0a:61:6b:16:14:ce brd ff:ff:ff:ff:ff:ff
> >
> > This patch adds device MTU validation check.
> 
> What is wrong with big MTU on dummy ?
> 
> If this is a generic rule, this check should belong in core network stack.
> 

dummy_setup() function setup mtu range: [0, ETH_MAX_MTU]. 
This will be checked at dev_set_mtu() function in core network stack.

So if you add a new dummy device without specify mtu value, you can't set a value out of range [0, ETH_MAX_MTU] afterward.
BUT you can set any mtu when adding new device. This cause an inconsistence.

> >
> > Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> > ---
> >  drivers/net/dummy.c | 8 ++++++++
> >  1 file changed, 8 insertions(+)
> >
> > diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c index
> > e31ab3b..0276b2b 100644
> > --- a/drivers/net/dummy.c
> > +++ b/drivers/net/dummy.c
> > @@ -365,6 +365,14 @@ static int dummy_validate(struct nlattr *tb[], struct
> nlattr *data[],
> >  		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
> >  			return -EADDRNOTAVAIL;
> >  	}
> > +
> > +	if (tb[IFLA_MTU]) {
> > +		u32 mtu = nla_get_u32(tb[IFLA_MTU]);
> 
> You do not verify/validate nla_len(tb[IFLA_MTU]).
> 
> Do not ever trust user space.
MTU attribute is just u32, do you think it's necessary to check the length? 
Actually I don't see any place to check the length of mtu attribute in network stack code. 

> 
> > +
> > +		if (mtu > ETH_MAX_MTU)
> > +			return -EINVAL;
> > +	}
> > +
> >  	return 0;
> >  }
> >
> 
