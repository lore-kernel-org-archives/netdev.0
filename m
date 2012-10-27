From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next] netxen: explicity handle pause autoneg
 parameter
Date: Fri, 26 Oct 2012 22:37:15 -0200
Message-ID: <20121026223715.35553d20@obelix.rh>
References: <1351271832-21275-1-git-send-email-fbl@redhat.com>
	<1351285842.2584.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37887 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753515Ab2J0AhW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 20:37:22 -0400
In-Reply-To: <1351285842.2584.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Oct 2012 22:10:42 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Fri, 2012-10-26 at 15:17 -0200, Flavio Leitner wrote:
> > The hardware doesn't support controlling pause frames autoneg, so
> > report that back correctly to userspace.
> > 
> > Signed-off-by: Flavio Leitner <fbl@redhat.com>
> > ---
> >  drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c | 6 ++++++
> >  1 file changed, 6 insertions(+)
> > 
> > I don't have the hardware handy to test this, so I appreciate
> > if someone could do it.
> > 
> > diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
> > index 10468e7..b4b46f9 100644
> > --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
> > +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
> > @@ -488,6 +488,8 @@ netxen_nic_get_pauseparam(struct net_device *dev,
> >  	__u32 val;
> >  	int port = adapter->physical_port;
> >  
> > +	pause->autoneg = AUTONEG_DISABLE;
> 
> AUTONEG_DISABLE is really meant for use in ethtool_cmd::autoneg, not
> ethtool_pauseparam::autoneg.  (Though they are both really booleans so
> this works in practice.)

I saw few places using it. I will change to 0 instead, though as the
meaning for both use-cases are the same (auto negotiation being enabled or
disabled) and probably won't change, maybe we could just share.
 
> >  	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
> >  		if ((port < 0) || (port >= NETXEN_NIU_MAX_GBE_PORTS))
> >  			return;
> > @@ -532,6 +534,10 @@ netxen_nic_set_pauseparam(struct net_device *dev,
> >  	struct netxen_adapter *adapter = netdev_priv(dev);
> >  	__u32 val;
> >  	int port = adapter->physical_port;
> > +
> > +	if (pause->autoneg)
> > +		return -EOPNOTSUPP;
> 
> Should be -EINVAL; the operation (ETHTOOL_SPAUSEPARAM) is supported but
> not these particular arguments.

agree, fixing on v2.
thanks,
fbl
