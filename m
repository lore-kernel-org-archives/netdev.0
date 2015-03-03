From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] bridge: fix bridge netlink RCU usage
Date: Tue, 03 Mar 2015 14:43:33 +0100
Message-ID: <1425390213.2450.45.camel@sipsolutions.net>
References: <1425389374-12568-1-git-send-email-johannes@sipsolutions.net>
	 <1425390038.5130.171.camel@edumazet-glaptop2.roam.corp.google.com>
	 (sfid-20150303_144041_415908_D62670A0)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55854 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754682AbbCCNng (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 08:43:36 -0500
In-Reply-To: <1425390038.5130.171.camel@edumazet-glaptop2.roam.corp.google.com> (sfid-20150303_144041_415908_D62670A0)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-03-03 at 05:40 -0800, Eric Dumazet wrote:
> On Tue, 2015-03-03 at 14:29 +0100, Johannes Berg wrote:
> > From: Johannes Berg <johannes.berg@intel.com>
> > 
> > When the STP timer fires, it can call br_ifinfo_notify(),
> > which in turn ends up in the new br_get_link_af_size().
> > This function is annotated to be using RTNL locking, which
> > clearly isn't the case here, and thus lockdep warns:
> > 
> >   ===============================
> >   [ INFO: suspicious RCU usage. ]
> >   3.19.0+ #569 Not tainted
> >   -------------------------------
> >   net/bridge/br_private.h:204 suspicious rcu_dereference_protected() usage!
> > 
> > Fix this by doing RCU locking here.
> > 
> > Fixes: b7853d73e39b ("bridge: add vlan info to bridge setlink and dellink notification messages")
> > Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> > ---
> >  net/bridge/br_netlink.c | 11 +++++++----
> >  1 file changed, 7 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> > index 17e0177467f5..c63ac0d13add 100644
> > --- a/net/bridge/br_netlink.c
> > +++ b/net/bridge/br_netlink.c
> > @@ -26,12 +26,15 @@ static size_t br_get_link_af_size(const struct net_device *dev)
> >  {
> >  	struct net_port_vlans *pv;
> >  
> > -	if (br_port_exists(dev))
> > -		pv = nbp_get_vlan_info(br_port_get_rtnl(dev));
> > -	else if (dev->priv_flags & IFF_EBRIDGE)
> > +	if (br_port_exists(dev)) {
> > +		rcu_read_lock();
> > +		pv = nbp_get_vlan_info(br_port_get_rcu(dev));
> > +		rcu_read_unlock();
> 
> right after this rcu_read_unlock(), you no longer are allowed to deref
> pv

Right, that's what I feared, hence my other email :)

But if I reorder it to later it would be OK?

johannes
