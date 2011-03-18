From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: LRO disable warnings on kernel 2.6.38
Date: Fri, 18 Mar 2011 14:17:57 +0000
Message-ID: <1300457877.26693.53.camel@localhost>
References: <1300446743.11985.317.camel@firesoul.comx.local>
	 <1300453519.2888.118.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12515 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754075Ab1CROSF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 10:18:05 -0400
In-Reply-To: <1300453519.2888.118.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-03-18 at 14:05 +0100, Eric Dumazet wrote:
> Le vendredi 18 mars 2011 =C3=A0 12:12 +0100, Jesper Dangaard Brouer a=
 =C3=A9crit :
> > Hi
> >=20
> > I'm seeing the LRO disable warnings using kernel 2.6.38:
> >=20
> > [    8.664759] NET: Registered protocol family 10
> > [    8.838148] ADDRCONF(NETDEV_UP): eth71: link is not ready
> > [    8.872639] ------------[ cut here ]------------
> > [    8.872645] WARNING: at net/core/dev.c:1363 dev_disable_lro+0x7b=
/0x80()
> > [    8.872647] Hardware name: ProLiant DL370 G6
> > [    8.872648] Modules linked in: ipv6 nf_conntrack ip_tables loop =
i7core_edac edac_core ipmi_si ipmi_msghandler joydev hpilo pcspkr sg hp=
sa igb ata_piix netxen_nic dca [last unloaded: scsi_wait_scan]
> > [    8.872660] Pid: 2221, comm: sysctl Not tainted 2.6.38-comx04 #2
> > [    8.872662] Call Trace:
> > [    8.872671]  [<ffffffff81056e1f>] ? warn_slowpath_common+0x7f/0x=
c0
> > [    8.872675]  [<ffffffff81056e7a>] ? warn_slowpath_null+0x1a/0x20
> > [    8.872680]  [<ffffffff8140c0ab>] ? dev_disable_lro+0x7b/0x80
> > [    8.872686]  [<ffffffff81474f27>] ? devinet_sysctl_forward+0x147=
/0x180
> > [    8.872691]  [<ffffffff811872f7>] ? proc_sys_call_handler+0x97/0=
xd0
> > [    8.872700]  [<ffffffff81187344>] ? proc_sys_write+0x14/0x20
> > [    8.872704]  [<ffffffff81124148>] ? vfs_write+0xc8/0x180
> > [    8.872707]  [<ffffffff81124301>] ? sys_write+0x51/0x90
> > [    8.872712]  [<ffffffff8100b8c2>] ? system_call_fastpath+0x16/0x=
1b
> > [    8.872714] ---[ end trace 6245283cb8d484cc ]---
> >=20
> > The strange part is that I didn't see this warning on my testlab an=
d
> > pre-prod servers.  The warning is from the first production server,
> > which got kernel 2.6.38 deployed this morning.
> >=20
> > The NIC driver is igb.
> >=20
> > The only difference in hardware between the production and
> > pre-production server (which didn't show the warning), is the
> > prod-server have an extra dual-port original Intel NIC, dev-named
> > "eth71".  And its just after the init of eth71, the warning occurs.
> >=20
> > We usually use a 6 port NIC from Hotlava, which is based on the sam=
e
> > chip 82576 and also uses the same igb driver.
> >=20
> > Intel orig NIC eth71
> >  albpd4:~# ethtool -i eth71
> >  driver: igb
> >  version: 2.1.0-k2
> >  firmware-version: 1.2-1
> >  bus-info: 0000:21:00.0
> >=20
> > Hotlava Intel chip based NIC eth51:
> >  albpd4:~# ethtool -i eth51
> >  driver: igb
> >  version: 2.1.0-k2
> >  firmware-version: 1.2-1
> >  bus-info: 0000:1d:00.1
> >=20
> > I don't understand why I don't see the warning on my pre-prod serve=
r,
> > which only have the Hotlava NIC?!?
> >=20
>=20
> Hmm, WARN_ON() message is not very nice in this case I'm afraid, we d=
ont
> even know offender

WARN is correct as this is a driver bug.  But I agree that the
device/driver ID should be included.

Ben.

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 0b88eba..571ab70 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1361,7 +1361,8 @@ void dev_disable_lro(struct net_device *dev)
>  			dev->ethtool_ops->set_flags(dev, flags);
>  		}
>  	}
> -	WARN_ON(dev->features & NETIF_F_LRO);
> +	if (dev->features & NETIF_F_LRO)
> +		netdev_err(dev, "Could not disable LRO\n");
>  }
>  EXPORT_SYMBOL(dev_disable_lro);
> =20
>=20
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

