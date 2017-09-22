From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [net-next 1/2] dummy: add device MTU validation check
Date: Fri, 22 Sep 2017 10:56:10 +0200
Message-ID: <20170922085610.GA4544@bistromath.localdomain>
References: <1506000722-40095-1-git-send-email-zhangshengju@cmss.chinamobile.com>
 <1506000722-40095-2-git-send-email-zhangshengju@cmss.chinamobile.com>
 <1506006138.29839.132.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
        davem@davemloft.net, willemb@google.com,
        stephen@networkplumber.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49844 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751832AbdIVI4R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 04:56:17 -0400
Content-Disposition: inline
In-Reply-To: <1506006138.29839.132.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-09-21, 08:02:18 -0700, Eric Dumazet wrote:
> On Thu, 2017-09-21 at 21:32 +0800, Zhang Shengju wrote:
> > Currently, any mtu value can be assigned when adding a new dummy device:
> > [~]# ip link add name dummy1 mtu 100000 type dummy
> > [~]# ip link show dummy1
> > 15: dummy1: <BROADCAST,NOARP> mtu 100000 qdisc noop state DOWN mode DEFAULT group default qlen 1000
> >     link/ether 0a:61:6b:16:14:ce brd ff:ff:ff:ff:ff:ff
> > 
> > This patch adds device MTU validation check.
> 
> What is wrong with big MTU on dummy ?

It looks like the "centralize MTU checking" series broke that, but
only for changing the MTU on an existing dummy device. Commit
a52ad514fdf3 defined min_mtu/max_mtu in ether_setup, which dummy uses,
but there was no MTU check in dummy prior to that commit.


> If this is a generic rule, this check should belong in core network
> stack.
> 
> > 
> > Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> > ---
> >  drivers/net/dummy.c | 8 ++++++++
> >  1 file changed, 8 insertions(+)
> > 
> > diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
> > index e31ab3b..0276b2b 100644
> > --- a/drivers/net/dummy.c
> > +++ b/drivers/net/dummy.c
> > @@ -365,6 +365,14 @@ static int dummy_validate(struct nlattr *tb[], struct nlattr *data[],
> >  		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
> >  			return -EADDRNOTAVAIL;
> >  	}
> > +
> > +	if (tb[IFLA_MTU]) {
> > +		u32 mtu = nla_get_u32(tb[IFLA_MTU]);
> 
> You do not verify/validate nla_len(tb[IFLA_MTU]).

I think ifla_policy already performs that check:


static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
[...]
	[IFLA_MTU]		= { .type = NLA_U32 },


static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh,
			struct netlink_ext_ack *extack)
{
[...]
	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy, extack);


-- 
Sabrina
