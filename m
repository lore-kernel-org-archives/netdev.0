From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 1/2] net: inform NETDEV_CHANGE callbacks which
 flags were changed
Date: Thu, 23 May 2013 17:31:02 +0100
Message-ID: <1369326662.6963.4.camel@bwh-desktop.uk.level5networks.com>
References: <1369303109-12003-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34718 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403Ab3EWQbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 12:31:06 -0400
In-Reply-To: <1369303109-12003-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-23 at 12:58 +0300, Timo Ter=C3=A4s wrote:
> In certain cases (like the follow up commit to arp.c) will need to
> check which flags actually changed to avoid excessive work.
>=20
> Ben Hutchings nicely worded why to put these transient flags to
> struct net_device for the time being:
> > It's inelegant to put transient data associated with an event in a
> > persistent data structure.  On the other hand, having every user ca=
che
> > the old state is pretty awful as well.
> >
> > Really, netdev notifiers should be changed to accept a structure th=
at
> > encapsulates the changes rather than just a pointer to the net_devi=
ce.
> > But making such a change would be an enormous pain and error-prone
> > because notifier functions aren't type-safe.
> >
> > As an interim solution, I think either the general priv_flags_chang=
ed or
> > old_priv_flags would be preferable to defining extra transient flag=
s.
>=20
> Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
> Cc: Ben Hutchings <bhutchings@solarflare.com>

Could you delete the two instances of 'priv_' from the quoted text?  I
was confused about to which flags field was being changed.  With that,
you may add 'Acked-by: Ben Hutchings <bhutchings@solarflare.com>'

Ben.

> ---
>  include/linux/netdevice.h | 4 +++-
>  net/core/dev.c            | 5 ++++-
>  2 files changed, 7 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 7dd535d..86c155a 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1112,7 +1112,9 @@ struct net_device {
>  	/* Hardware header description */
>  	const struct header_ops *header_ops;
> =20
> -	unsigned int		flags;	/* interface flags (a la BSD)	*/
> +	unsigned int		flags;		/* interface flags (a la BSD)	*/
> +	unsigned int		flags_changed;	/* flags that are being changed
> +						 * valid during NETDEV_CHANGE notifier */
>  	unsigned int		priv_flags; /* Like 'flags' but invisible to userspac=
e.
>  					     * See if.h for definitions. */
>  	unsigned short		gflags;
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 7229bc3..221634f 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4741,8 +4741,11 @@ void __dev_notify_flags(struct net_device *dev=
, unsigned int old_flags)
>  	}
> =20
>  	if (dev->flags & IFF_UP &&
> -	    (changes & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI | IFF_VOLATILE=
)))
> +	    (changes & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI | IFF_VOLATILE=
))) {
> +		dev->flags_changed =3D changes;
>  		call_netdevice_notifiers(NETDEV_CHANGE, dev);
> +		dev->flags_changed =3D 0;
> +	}
>  }
> =20
>  /**

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
