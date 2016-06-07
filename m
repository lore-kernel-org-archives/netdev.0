From: Pavel Andrianov <andrianov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Subject: Re: [ldv-project] [net] libertas: potential race condition
Date: Tue, 07 Jun 2016 18:54:23 +0400
Message-ID: <5756E01F.6080107@ispras.ru>
References: <57569424.9040906@ispras.ru> <1465310395.29158.2.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, ldv-project-tpLiQldItUH5n4uC9ZG1Ww@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vaishali.thakkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1465310395.29158.2.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

07.06.2016 18:39, Dan Williams =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Tue, 2016-06-07 at 13:30 +0400, Pavel Andrianov wrote:
>> Hi!
>>
>> There is a potential race condition in
>> drivers/net/wireless/libertas/libertas.ko.
>> In the function lbs_hard_start_xmit(..), line 159, a socket buffer
>> is
>> written to priv->current_skb with a spin_lock protection.
>> In the function lbs_mac_event_disconnected(..), lines 50-51, the
>> field
>> current_skb is cleaned. There is no protection used. The
>> corresponding
>> handlers are activated at the same time in lbs_start_card(..) and
>> then
>> may be executed simultaneously. Note, there are two structures
>> lbs_netdev_ops and mesh_netdev_ops, which have the target handler
>> lbs_hard_start_xmit.
>> Is it a real race or I have missed something?
> Yeah, it looks like it should be grabbing priv->driver_lock before
> clearing priv->currenttxskb in lbs_mac_event_disconnected().  Care to
> submit a patch after testing?  Do you have any of that hardware?
>
> Dan
I have no that hardware and I have some doubts about the simple fix,=20
you've suggested. For instance, in lbs_hard_start_xmit the lock is=20
acquired twice and the priv->tx_pending_len can be modified also by=20
lbs_mac_event_disconnected (even if spin_lock will be added to=20
lbs_mac_event_disconnected). Moreover, the function lbs_send_tx_feedbac=
k=20
also cleaned priv->currenttxskb, but it happens also without any=20
protection. Thus, the fix has to be more complicated, and I have no=20
ideas about it.

--=20
Pavel Andrianov
Linux Verification Center, ISPRAS
web: http://linuxtesting.org
e-mail: andrianov-ufN2psIa012HXe+LvDLADg@public.gmane.org

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
