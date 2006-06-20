From: Chase Venters <chase.venters@clientec.com>
Subject: Re: [PATCH] Fix recommended permissions for /dev/net/tun
Date: Tue, 20 Jun 2006 11:46:18 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0606201145260.13882@turbotaz.ourhouse>
References: <1150817723.17609.81.camel@hades.cambridge.redhat.com>
 <1150820326.17609.88.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay03.pair.com ([209.68.5.17]:34313 "HELO relay03.pair.com")
	by vger.kernel.org with SMTP id S1751174AbWFTQqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 12:46:21 -0400
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1150820326.17609.88.camel@hades.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Jun 2006, David Woodhouse wrote:

> On Tue, 2006-06-20 at 16:35 +0100, David Woodhouse wrote:
>> There's no reason to restrict unprivileged users from opening
>> the /dev/net/tun device node -- to do anything exciting requires
>> CAP_NET_ADMIN or a persistent device which is owned by the user in
>> question anyway.
>
> Hm, I lie. Let us alter reality to match my previous perception of it...

Perhaps you lie again :)

Are you sure you're adding a capable(CAP_SYS_ADMIN)? :P

> [PATCH] Require CAP_SYS_ADMIN to create tuntap devices.
>
> The tuntap driver allows an admin to create persistent devices and
> assign ownership of them to individual users. Unfortunately, relaxing
> the permissions on the /dev/net/tun device node _also_ allows those
> users to create arbitrary new devices of their own. This patch corrects
> that, and adjusts the recommended permissions for the device node
> accordingly.
>
> Signed-Off-By: David Woodhouse <dwmw2@infradead.org>
>
> diff --git a/Documentation/networking/tuntap.txt b/Documentation/networking/tuntap.txt
> index 76750fb..839cbb7 100644
> --- a/Documentation/networking/tuntap.txt
> +++ b/Documentation/networking/tuntap.txt
> @@ -39,10 +39,13 @@ Copyright (C) 1999-2000 Maxim Krasnyansk
>      mknod /dev/net/tun c 10 200
>
>   Set permissions:
> -     e.g. chmod 0700 /dev/net/tun
> -     if you want the device only accessible by root. Giving regular users the
> -     right to assign network devices is NOT a good idea. Users could assign
> -     bogus network interfaces to trick firewalls or administrators.
> +     e.g. chmod 0666 /dev/net/tun
> +     There's no harm in allowing the device to be accessible by non-root users,
> +     since CAP_NET_ADMIN is required for creating network devices or for
> +     connecting to network devices which aren't owned by the user in question.
> +     If you want to create persistent devices and give ownership of them to
> +     unprivileged users, then you need the /dev/net/tun device to be usable by
> +     those users.
>
>   Driver module autoloading
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index a1ed2d9..6c62d5c 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -490,6 +490,9 @@ static int tun_set_iff(struct file *file
>
> 		err = -EINVAL;
>
> +		if (!capable(CAP_NET_ADMIN))
> +			return -EPERM;
> +
> 		/* Set dev type */
> 		if (ifr->ifr_flags & IFF_TUN) {
> 			/* TUN device */
>
>
>

Thanks,
Chase
