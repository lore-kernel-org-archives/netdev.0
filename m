From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: [PATCH net-next] netxen: write IP address to firmware when
	using bonding
Date: Tue, 29 Nov 2011 05:58:14 -0600
Message-ID: <13A253B3F9BEFE43B93C09CF75F63CAA81602BBEA2@MNEXMB1.qlogic.org>
References: <1322073791-15223-1-git-send-email-andy@greyhouse.net>
 <20111123.160922.1983654308126240492.davem@davemloft.net>
 <13A253B3F9BEFE43B93C09CF75F63CAA81602BBE98@MNEXMB1.qlogic.org>,<20111128204326.GH25132@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Sony Chacko <sony.chacko@qlogic.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:5687 "EHLO
	TX2EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754746Ab1K2L7Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 06:59:16 -0500
In-Reply-To: <20111128204326.GH25132@gospo.rdu.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes virt would be fine.

Thanks,
Rajesh
________________________________________
From: Andy Gospodarek [andy@greyhouse.net]
Sent: Tuesday, November 29, 2011 2:13 AM
To: Rajesh Borundia
Cc: David Miller; andy@greyhouse.net; netdev; Sony Chacko
Subject: Re: [PATCH net-next] netxen: write IP address to firmware when using bonding

On Mon, Nov 28, 2011 at 12:02:28AM -0600, Rajesh Borundia wrote:
> Hi Andy,
>
> We need to restore the ip address after the adapter reset.
> netxen_restore_indev_addr is the function that restores normal ip addresses
> and vlan ip addresses. If we could find bond device directly from slave then
> we can use netxen_config_indev_addr to add the ip address of the bond device.
> Otherwise we may need to cache the bond ip address in function netxen_list_config_vlan_ip
> and change the condition from
>
> if (!is_vlan_dev(dev))
>                 return;
>
> to
>
> if (!is_vlan_dev(dev) && !is_bond_dev(dev))
>                 return;
>

I don't think this was what you were originally intending, but what
about changing the name of the vlan_ip_list (and the vlan functions that
modify/read it) to something different and use it for all virtual or
stacked devices?

Something like 'virtual' or 'virt' might work instead of 'vlan.'
Something else that denotes that a device at a higher layer than just
the physical device has an IP address that we need to know about, but
that the device is not specific to VLANs.

> Some of the code in if and else part is repeated.
> If possible can we have small functions for that ?
> eg:
> if (!is_netxen_netdev(dev))
> +                       goto done;
> +
> +               adapter = netdev_priv(dev);
> +               if (!adapter)
> +                       goto done;
> +
> +               if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
> +                       goto done;
> +
> +               netxen_config_indev_addr(adapter, orig_dev, event);
>
>

I could change that.  I started to look at sharing some code, but
decided against too much initial code churn.  Since the fundamental idea
behind this chance seems acceptable, I can take a look at it more
closely.

I'll take a look at this and send a v2 of this patch.


> Rajesh
> ________________________________________
> From: David Miller [davem@davemloft.net]
> Sent: Thursday, November 24, 2011 11:08 AM
> To: andy@greyhouse.net
> Cc: netdev; Sony Chacko; Rajesh Borundia
> Subject: Re: [PATCH net-next] netxen: write IP address to firmware when using bonding
>
> From: Andy Gospodarek <andy@greyhouse.net>
> Date: Wed, 23 Nov 2011 22:24:27 -0500
>
> > Are you talking about adding a macro like this:
> >
> >       for_each_dev_in_bond(bond,slave) {
> >               [...]
> >       }
> >
> > to replace the statements I added that were like this:
> >
> >       for_each_netdev_rcu(&init_net, slave) {
> >               if (slave->master == dev) {
> >                       [...]
> >               }
> >       }
> >
> > If so, that totally seems reasonable.  If were requesting something
> > else, please let me know.
>
> Yes, some helper that walks the device list and tries to find
> a device whose ->master matches 'dev'.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
