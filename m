From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] macvlan: fix failure during registration
Date: Mon, 18 Apr 2016 13:48:12 -0500
Message-ID: <87ega2sqhf.fsf@x220.int.ebiederm.org>
References: <1460992811-46992-1-git-send-email-fruggeri@arista.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>
To: Francesco Ruggeri <fruggeri@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:36521 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbcDRS6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 14:58:38 -0400
In-Reply-To: <1460992811-46992-1-git-send-email-fruggeri@arista.com>
	(Francesco Ruggeri's message of "Mon, 18 Apr 2016 08:20:11 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Francesco Ruggeri <fruggeri@arista.com> writes:

> Resending, did not include netdev the first time ...
>
> If a macvlan/macvtap creation fails in register_netdevice in
> call_netdevice_notifiers(NETDEV_REGISTER) then while cleaning things up in
> rollback_registered_many it invokes macvlan_uninit. This results in
> port->count being decremented twice (in macvlan_uninit and in
> macvlan_common_newlink).
> A similar problem may exist in the ipvlan driver.
> This patch adds priv_flags to struct macvlan_dev and a flag that
> macvlan_uninit can use to determine if it is invoked in the context of a
> failed newlink.
> In macvtap_device_event(NETDEV_UNREGISTER) it also avoids cleaning up
> /dev/tapNN in case creation of the char device had previously failed.
> Tested in 3.18.

These interactions all seem a little bit funny.  At a quick skim it
would make more sense to increment the port count in macvlan_init,
and completely remove the need to mess with port counts anywhere except
macvlan_init and macvlan_uninit.

If for some reason that can't be done the code can easily look at
dev->reg_state.  If dev->reg_state == NETREG_UNITIALIZED it should
be exactly the same as your new flag being set.

> diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
> index a4ccc31..7cf82d8 100644
> --- a/include/linux/if_macvlan.h
> +++ b/include/linux/if_macvlan.h
> @@ -48,6 +48,7 @@ struct macvlan_dev {
>  	netdev_features_t	set_features;
>  	enum macvlan_mode	mode;
>  	u16			flags;
> +	u16			priv_flags;
>  	/* This array tracks active taps. */
>  	struct macvtap_queue	__rcu *taps[MAX_MACVTAP_QUEUES];
>  	/* This list tracks all taps (both enabled and disabled) */
> @@ -63,6 +64,8 @@ struct macvlan_dev {
>  	unsigned int		macaddr_count;
>  };
>  
> +#define MACVLAN_PRIV_FLAG_REGISTERING	1
> +
>  static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
>  				    unsigned int len, bool success,
>  				    bool multicast)
