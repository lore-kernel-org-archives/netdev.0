From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/6] net: inform NETDEV_CHANGE callbacks which
 flags were changed
Date: Mon, 27 May 2013 13:18:52 +0200
Message-ID: <20130527111852.GA1830@minipsycho.brq.redhat.com>
References: <1369653376-4731-1-git-send-email-timo.teras@iki.fi>
 <1369653376-4731-2-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:39350 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757704Ab3E0LS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 07:18:58 -0400
Received: by mail-ea0-f177.google.com with SMTP id q14so3850291eaj.22
        for <netdev@vger.kernel.org>; Mon, 27 May 2013 04:18:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1369653376-4731-2-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, May 27, 2013 at 01:16:11PM CEST, timo.teras@iki.fi wrote:
>In certain cases (like the follow up commit to arp.c) will need to
>check which flags actually changed to avoid excessive work.
>
>Ben Hutchings nicely worded why to put these transient flags to
>struct net_device for the time being:
>> It's inelegant to put transient data associated with an event in a
>> persistent data structure.  On the other hand, having every user cac=
he
>> the old state is pretty awful as well.
>>
>> Really, netdev notifiers should be changed to accept a structure tha=
t
>> encapsulates the changes rather than just a pointer to the net_devic=
e.
>> But making such a change would be an enormous pain and error-prone
>> because notifier functions aren't type-safe.
>>
>> As an interim solution, I think either the general flags_changed or
>> old_flags would be preferable to defining extra transient flags.
>
>Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>
>Acked-by: Ben Hutchings <bhutchings@solarflare.com>
>---
> include/linux/netdevice.h | 4 +++-
> net/core/dev.c            | 5 ++++-
> 2 files changed, 7 insertions(+), 2 deletions(-)
>
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index ea7b6bc..f336e03 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -1112,7 +1112,9 @@ struct net_device {
> 	/* Hardware header description */
> 	const struct header_ops *header_ops;
>=20
>-	unsigned int		flags;	/* interface flags (a la BSD)	*/
>+	unsigned int		flags;		/* interface flags (a la BSD)	*/
>+	unsigned int		flags_changed;	/* flags that are being changed
>+						 * valid during NETDEV_CHANGE notifier */
> 	unsigned int		priv_flags; /* Like 'flags' but invisible to userspace=
=2E
> 					     * See if.h for definitions. */
> 	unsigned short		gflags;
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 50c02de..bbaa3c2 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -4742,8 +4742,11 @@ void __dev_notify_flags(struct net_device *dev,=
 unsigned int old_flags)
> 	}
>=20
> 	if (dev->flags & IFF_UP &&
>-	    (changes & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI | IFF_VOLATILE)=
))
>+	    (changes & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI | IFF_VOLATILE)=
)) {
>+		dev->flags_changed =3D changes;
> 		call_netdevice_notifiers(NETDEV_CHANGE, dev);
>+		dev->flags_changed =3D 0;
>+	}
> }

Hold on with this please. I'm working on netdev notifier extension. One
would be able to pass custom structure with an event after that. I plan
to post this today/tomorrow.

>=20
> /**
>--=20
>1.8.2.3
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
