From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: Re: [PATCH] X.25: decrement netdev reference counts on unload
Date: Wed, 8 Dec 2010 09:48:30 +1100
Message-ID: <AANLkTikG_4XXiNQPe-vGa8Uysx_XUQzNb6nYk5fAbKQr@mail.gmail.com>
References: <20101207194330.GA22608@noc.grnet.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Apollon Oikonomopoulos <apollon@noc.grnet.gr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:50738 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325Ab0LGWye convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 17:54:34 -0500
Received: by fxm18 with SMTP id 18so409919fxm.2
        for <netdev@vger.kernel.org>; Tue, 07 Dec 2010 14:54:33 -0800 (PST)
In-Reply-To: <20101207194330.GA22608@noc.grnet.gr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the patch.
Can reproduce it on a vm here, I'll verify it when have access to some
X.25 networks tomorrow.

2010/12/8 Apollon Oikonomopoulos <apollon@noc.grnet.gr>:
> Hello,
>
> We came across this bug when we accidentally loaded and unloaded the =
x25
> kernel module on a host with KVM virtual machines. All subsequent
> attempts to stop a KVM instance resulted in the KVM process entering =
D
> state. Reproducing this behaviour can be done in the following way:
>
> 1. modprobe x25
> 2. tunctl && ifconfig tap0 up
> 3. rmmod x25
> 4. tunctl -d tap0 (hangs)
>
> A patch follows - we don't use X.25 ourselves so I'm not sure it won'=
t
> panic someone's system.
>
> Regards,
> Apollon
>
> PS: I am not subscribed to the list, so please copy any replies to my
> address. Thanks!
> ----
> x25 does not decrement the network device reference counts on module =
unload.
> Thus unregistering any pre-existing interface after unloading the x25=
 module
> hangs and results in
>
> =A0unregister_netdevice: waiting for tap0 to become free. Usage count=
 =3D 1
>
> This patch decrements the reference counts of all interfaces in x25_l=
ink_free,
> the way it is already done in x25_link_device_down for NETDEV_DOWN ev=
ents.
>
> Signed-off-by: Apollon Oikonomopoulos <apollon@noc.grnet.gr>
> ---
> =A0net/x25/x25_link.c | =A0 =A01 +
> =A01 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/net/x25/x25_link.c b/net/x25/x25_link.c
> index 73e7b95..b25c646 100644
> --- a/net/x25/x25_link.c
> +++ b/net/x25/x25_link.c
> @@ -394,6 +394,7 @@ void __exit x25_link_free(void)
> =A0 =A0 =A0 =A0list_for_each_safe(entry, tmp, &x25_neigh_list) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nb =3D list_entry(entry, struct x25_ne=
igh, node);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__x25_remove_neigh(nb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_put(nb->dev);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0write_unlock_bh(&x25_neigh_list_lock);
> =A0}
> --
> 1.7.1
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
