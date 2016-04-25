From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] macvtap: check minor when unregistering
Date: Mon, 25 Apr 2016 14:01:06 -0500
Message-ID: <87shy9343x.fsf@x220.int.ebiederm.org>
References: <1461449071-7499-1-git-send-email-fruggeri@arista.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Francesco Ruggeri <fruggeri@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59359 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933017AbcDYTLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 15:11:38 -0400
In-Reply-To: <1461449071-7499-1-git-send-email-fruggeri@arista.com> (Francesco
	Ruggeri's message of "Sat, 23 Apr 2016 15:04:31 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francesco Ruggeri <fruggeri@arista.com> writes:

> macvtap_device_event(NETDEV_UNREGISTER) should check vlan->minor to
> determine if it is being invoked in the context of a macvtap_newlink
> that failed, for example in this code sequence:
>
> macvtap_newlink
>   macvlan_common_newlink
>     register_netdevice
>       call_netdevice_notifiers(NETDEV_REGISTER, dev)
>         macvtap_device_event(NETDEV_REGISTER)
>           <fail here, vlan->minor = 0>
>       rollback_registered(dev);
>         rollback_registered_many
>           call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
>             macvtap_device_event(NETDEV_UNREGISTER)
>               <nothing to clean up here>
>
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
> Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>
> ---
>  drivers/net/macvtap.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 95394ed..74cb15a 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -1303,6 +1303,9 @@ static int macvtap_device_event(struct notifier_block *unused,
>  		}
>  		break;
>  	case NETDEV_UNREGISTER:
> +		/* vlan->minor == 0 if NETDEV_REGISTER above failed */
> +		if (vlan->minor == 0)
> +			break;
>  		devt = MKDEV(MAJOR(macvtap_major), vlan->minor);
>  		device_destroy(macvtap_class, devt);
>  		macvtap_free_minor(vlan);
