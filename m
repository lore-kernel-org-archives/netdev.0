From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH next v2] bonding: Display LACP info only to CAP_NET_ADMIN
 capable user
Date: Thu, 18 Jun 2015 10:41:34 -0400
Message-ID: <20150618144133.GL588@gospo.home.greyhouse.net>
References: <1434589182-7953-1-git-send-email-maheshb@google.com>
 <1434626256.27504.208.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:35740 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029AbbFROlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 10:41:37 -0400
Received: by ykar6 with SMTP id r6so67652635yka.2
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 07:41:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434626256.27504.208.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 18, 2015 at 04:17:36AM -0700, Eric Dumazet wrote:
> On Wed, 2015-06-17 at 17:59 -0700, Mahesh Bandewar wrote:
> > Actor and Partner details can be accessed via proc-fs, sys-fs
> > entries or netlink interface. These interfaces are world readable
> > at this moment. The earlier patch-series made the LACP communication
> > secure to avoid nuisance attack from within the same L2 domain but
> > it did not prevent "someone unprivileged" looking at that information
> > on host and perform the same act.
> > 
> > This patch essentially avoids spitting those entries if the user
> > in question does not have enough privileges.
> > 
> > Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> > ---
> >  drivers/net/bonding/bond_netlink.c |  11 ++--
> >  drivers/net/bonding/bond_procfs.c  | 101 +++++++++++++++++++------------------
> >  drivers/net/bonding/bond_sysfs.c   |  12 ++---
> >  3 files changed, 67 insertions(+), 57 deletions(-)
> > 
> > diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
> > index 5580fcde738f..3fd3aa4b145e 100644
> > --- a/drivers/net/bonding/bond_netlink.c
> > +++ b/drivers/net/bonding/bond_netlink.c
> > @@ -600,18 +600,23 @@ static int bond_fill_info(struct sk_buff *skb,
> >  
> >  	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
> >  		struct ad_info info;
> > +		u8 zero_mac[ETH_ALEN];
> >  
> > +		eth_zero_addr(zero_mac);
> >  		if (nla_put_u16(skb, IFLA_BOND_AD_ACTOR_SYS_PRIO,
> > -				bond->params.ad_actor_sys_prio))
> > +				capable(CAP_NET_ADMIN) ?
> > +				bond->params.ad_actor_sys_prio : 0))
> >  			goto nla_put_failure;
> >  
> >  		if (nla_put_u16(skb, IFLA_BOND_AD_USER_PORT_KEY,
> > -				bond->params.ad_user_port_key))
> > +				capable(CAP_NET_ADMIN) ?
> > +				bond->params.ad_user_port_key : 0))
> >  			goto nla_put_failure;
> >  
> >  		if (nla_put(skb, IFLA_BOND_AD_ACTOR_SYSTEM,
> >  			    sizeof(bond->params.ad_actor_system),
> > -			    &bond->params.ad_actor_system))
> > +			    capable(CAP_NET_ADMIN) ?
> > +			    &bond->params.ad_actor_system : &zero_mac))
> >  			goto nla_put_failure;
> >  
> 
> Hmm... I would rather not send these fake attributes at all ?

That would be my preference as well.  Sorry if my lack of elaboration on
on my earlier email made this confusing.

If there are values that should not be visible to non-root users, then
don't send them at all.  Do not just send NULL values.
