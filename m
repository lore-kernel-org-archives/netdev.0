From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] macvlan: fix failure during registration v2
Date: Thu, 21 Apr 2016 12:44:02 -0500
Message-ID: <8737qe6en1.fsf@x220.int.ebiederm.org>
References: <1461188301-4466-1-git-send-email-fruggeri@arista.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>
To: Francesco Ruggeri <fruggeri@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:33498 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145AbcDURyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 13:54:31 -0400
In-Reply-To: <1461188301-4466-1-git-send-email-fruggeri@arista.com> (Francesco
	Ruggeri's message of "Wed, 20 Apr 2016 14:38:21 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francesco Ruggeri <fruggeri@arista.com> writes:

> If macvlan_common_newlink fails in register_netdevice after macvlan_init
> then it decrements port->count twice, first in macvlan_uninit (from
> register_netdevice or rollback_registered) and then again in
> macvlan_common_newlink.
> A similar problem may exist in the ipvlan driver.
> This patch consolidates modifications to port->count into macvlan_init
> and macvlan_uninit (thanks to Eric Biederman for suggesting this approach).
> In macvtap_device_event it also avoids cleaning up in NETDEV_UNREGISTER
> if NETDEV_REGISTER had previously failed.
>
> Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>

The macvlan_init bits obviously corect.

The macvtap bits I don't really understand what is going on.


> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 95394ed..e770221 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -1303,6 +1303,8 @@ static int macvtap_device_event(struct notifier_block *unused,
>  		}
>  		break;
>  	case NETDEV_UNREGISTER:
> +		if (vlan->minor == 0)
> +			break;

I don't understand this bit.  A minor of 0 is never assigned.  That is
clear from the code.  On what code path can you get here without
assigning a minor?

My gut says this either needs a big fat comment explaining what is going
on, or a slight refactoring of the code (like moving port count
increments into macvlan_init) that makes it so this code path can't
happen.

>  		devt = MKDEV(MAJOR(macvtap_major), vlan->minor);
>  		device_destroy(macvtap_class, devt);
>  		macvtap_free_minor(vlan);

Eric
