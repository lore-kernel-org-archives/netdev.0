From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2 1/5] net: don't reforward packets already
 forwarded by offload device
Date: Fri, 17 Jul 2015 16:37:55 +0200
Message-ID: <55A91343.1090208@6wind.com>
References: <1437033897-8050-1-git-send-email-sfeldma@gmail.com> <1437033897-8050-2-git-send-email-sfeldma@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com,
	simon.horman@netronome.com
To: sfeldma@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38792 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbbGQOh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 10:37:57 -0400
Received: by wicmv11 with SMTP id mv11so44517953wic.1
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 07:37:56 -0700 (PDT)
In-Reply-To: <1437033897-8050-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/07/2015 10:04, sfeldma@gmail.com a =C3=A9crit :
> From: Scott Feldman <sfeldma@gmail.com>
>
> Just before queuing skb for xmit on port, check if skb has been marke=
d by
> switchdev port driver as already fordwarded by device.  If so, drop s=
kb.  A
> non-zero skb->offload_fwd_mark field is set by the switchdev port
> driver/device on ingress to indicate the skb has already been forward=
ed by
> the device to egress ports with matching dev->skb_mark.  The switchde=
v port
> driver would assign a non-zero dev->skb_mark for each device port net=
dev
> during registration, for example.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> ---
>   include/linux/netdevice.h |    6 ++++++
>   include/linux/skbuff.h    |   11 ++++++++++-
>   net/core/dev.c            |   10 ++++++++++
>   3 files changed, 26 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 45cfd79..8364f29 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1456,6 +1456,8 @@ enum netdev_priv_flags {
>    *
>    *	@xps_maps:	XXX: need comments on this one
>    *
> + *	@offload_fwd_mark:	Offload device fwding mark
> + *
>    *	@trans_start:		Time (in jiffies) of last Tx
>    *	@watchdog_timeo:	Represents the timeout that is used by
>    *				the watchdog ( see dev_watchdog() )
> @@ -1697,6 +1699,10 @@ struct net_device {
>   	struct xps_dev_maps __rcu *xps_maps;
>   #endif
>
> +#ifdef CONFIG_NET_SWITCHDEV
> +	u32			offload_fwd_mark;
> +#endif
> +
>   	/* These may be needed for future network-power-down code. */
>
>   	/*
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index d6cdd6e..2edcf50 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -506,6 +506,7 @@ static inline u32 skb_mstamp_us_delta(const struc=
t skb_mstamp *t1,
>    *	@no_fcs:  Request NIC to treat last 4 bytes as Ethernet FCS
>     *	@napi_id: id of the NAPI struct this skb came from
>    *	@secmark: security marking
> + *	@offload_fwd_mark: fwding offload mark
>    *	@mark: Generic packet mark
>    *	@vlan_proto: vlan encapsulation protocol
>    *	@vlan_tci: vlan tag control information
> @@ -650,9 +651,17 @@ struct sk_buff {
>   		unsigned int	sender_cpu;
>   	};
>   #endif
> +	union {
>   #ifdef CONFIG_NETWORK_SECMARK
> -	__u32			secmark;
> +		__u32		secmark;
> +#endif
> +#ifdef CONFIG_NET_SWITCHDEV
> +		__u32		offload_fwd_mark;
>   #endif
> +	};
> +
> +	union {};
> +
Everybody seems to ack. For my knowledge, why did you put this empty un=
ion?


Thank you,
Nicolas
