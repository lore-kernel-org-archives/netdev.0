From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 PATCH 2/2] add ndo_set_port_profile op support for enic dynamic vnics
Date: Wed, 28 Apr 2010 15:32:47 +0200
Message-ID: <201004281532.47875.arnd@arndb.de>
References: <20100428044235.8646.61943.stgit@savbu-pc100.cisco.com> <20100428044240.8646.27412.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:53340 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753218Ab0D1NdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 09:33:01 -0400
In-Reply-To: <20100428044240.8646.27412.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 28 April 2010, Scott Feldman wrote:
> +static int enic_set_port_profile(struct net_device *netdev,
> +       struct ifla_port_profile *ipp)
> +{
> +       struct enic *enic = netdev_priv(netdev);
> +       struct vic_provinfo *vp;
> +       u8 oui[3] = VIC_PROVINFO_CISCO_OUI;
> +       u8 *mac = ipp->mac;
> +       int err;
> +
> +       memset(&enic->port_profile, 0, sizeof(enic->port_profile));
> +
> +       if (!enic_is_dynamic(enic))
> +               return -EOPNOTSUPP;

Not sure I understand how this fits together. You said in an earlier mail:

> > Anything that ties port profiles to VFs seems fundamentally flawed AFAICT,
> > at least when we want to extend this to adapters that don't do it in firmware.
>
> Ya, I tend I agree.  Let's just make port-profile a setting of any netdev,
> an eth, macvtap, eth.x, bond, etc.  That's probably what I should have done
> in the first place.  Something like:

I thought you had meant that we can do the association of attached interfaces
through any interface, rather than tying it to the slave interface. While I'm
not sure I read your code correctly, it seems like you now only talk to the
slave interface, not to the master at all!

At least the check above should be 'if (enic_is_dynamic(enic)) return -EOPNOTSUPP',
not the other way round.
Moreover, if the netdev is the master here, you only allow a single slave, which
is not enough for larger setups (n > 1), though that could be a limitation of your
first version.

Passing just the slave device however would not work in the general case, as I
tried to point out in the mail you replied to. If the slave interface is owned
by a guest using PCI passthrough, or it sits below a stack of nested interfaces
(vlan, bridge, tap, vhost, ...), it's impossible to know what interface is
responsible for setting up the slave. Note that you cannot perform the association
through the slave interface itself because the remote switch would discard any
traffic originating from an unassociated interface.

> +static int enic_get_port_profile(struct net_device *netdev,
> +       struct ifla_port_profile *ipp)
> +{
> +       struct enic *enic = netdev_priv(netdev);
> +       int done, err, error;
> +
> +       enic->port_profile.status = IFLA_PORT_PROFILE_STATUS_UNKNOWN;
> +
> +       spin_lock(&enic->devcmd_lock);
> +       err = vnic_dev_init_done(enic->vdev, &done, &error);
> +       spin_unlock(&enic->devcmd_lock);
> +
> +       if (err || error)
> +               enic->port_profile.status = IFLA_PORT_PROFILE_STATUS_ERROR;
> +
> +       if (!done)
> +               enic->port_profile.status = IFLA_PORT_PROFILE_STATUS_INPROGRESS;
> +
> +       if (!error)
> +               enic->port_profile.status = IFLA_PORT_PROFILE_STATUS_SUCCESS;
> +
> +       memcpy(ipp, &enic->port_profile, sizeof(enic->port_profile));
> +
> +       return 0;
> +}
> +

Similarly, this interface only passes back a single port profile association,
where it should have a way to return all of the slave ports.

	Arnd
