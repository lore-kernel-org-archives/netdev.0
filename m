From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Hitting BUG_ON() from napi_enable in e1000e
Date: Tue, 15 Nov 2011 23:32:28 -0800
Message-ID: <CAL3LdT6CZectGNpeC+FeK5wokX-NN6SZdn7VfYHGJThz35sNZQ@mail.gmail.com>
References: <4EC16DE3.5020701@stratus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Mike McElroy <mike.mcelroy@stratus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49052 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754242Ab1KPHca convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 02:32:30 -0500
Received: by bke11 with SMTP id 11so203343bke.19
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 23:32:28 -0800 (PST)
In-Reply-To: <4EC16DE3.5020701@stratus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2011 at 11:37, Mike McElroy <mike.mcelroy@stratus.com> =
wrote:
>
> Hitting the BUG_ON in napi_enable(). Code inspection shows that this =
can
> only be triggered by calling napi_enable() twice without an interveni=
ng
> napi_disable().
>
> I saw the following sequence of events in the stack trace:
>
> 1) We simulated a cable pull using an Extreme switch.
> 2) e1000_tx_timeout() was entered.
> 3) e1000_reset_task() was called. Saw the message from e_err() in the
> console log.
> 4) e1000_reinit_locked was called. This function calls e1000_down() a=
nd
> e1000_up(). These functions call napi_disable() and napi_enable()
> respectively.
> 5) Then on another thread, a monitor task saw carrier was down and ex=
ecuted
> 'ip set link down' and 'ip set link up' commands.
> 6) Saw the '_E1000_RESETTING'warning fron the e1000_close function.
> 7) Either the e1000_open() executed between the e1000_down() and e100=
0_up()
> calls in step 4 or the e1000_open() call executed after the e0001_up(=
) call.
> In either case, napi_enable() is called twice which triggers the BUG_=
ON.
>
> This code sequence is present in the e1000 driver also.
>
> There are two bugs here:
> 1) The napi_enable() and napi_disable() should only be called in the
> e1000_open and e1000_close functions respectively
> 2) There no synchronization preventing a call to the driver close whi=
le
> executing error processing.
>
> Here is a patch for the napi_enable BUG_ON:
>
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.=
c
> index 5ec1f99..e1af6fa 100755
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -4242,9 +4242,6 @@ int e1000e_up(struct e1000_adapter *adapter)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0clear_bit(__E1000_DOWN, &adapter->state);
>
> -#ifdef CONFIG_E1000E_NAPI
> - =C2=A0 =C2=A0 =C2=A0 napi_enable(&adapter->napi);
> -#endif
> =C2=A0#ifdef CONFIG_E1000E_MSIX
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (adapter->msix_entries)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0e1000_configur=
e_msix(adapter);
> @@ -4307,10 +4304,6 @@ void e1000e_down(struct e1000_adapter *adapter=
)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* flush both disables and wait for them t=
o finish */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0e1e_flush();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0usleep_range(10000, 20000);
> -
> -#ifdef CONFIG_E1000E_NAPI
> - =C2=A0 =C2=A0 =C2=A0 napi_disable(&adapter->napi);
> -#endif
> =C2=A0 =C2=A0 =C2=A0 =C2=A0e1000_irq_disable(adapter);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0del_timer_sync(&adapter->watchdog_timer);
> @@ -4677,6 +4670,10 @@ static int e1000_close(struct net_device *netd=
ev)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pm_runtime_get_sync(&pdev->dev);
>
> +#ifdef CONFIG_E1000E_NAPI
> + =C2=A0 =C2=A0 =C2=A0 napi_disable(&adapter->napi);
> +#endif
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!test_bit(__E1000_DOWN, &adapter->stat=
e)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0e1000e_down(ad=
apter);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0e1000_free_irq=
(adapter);
>

Thanks, I will add this patch to my queue.

--=20
Cheers,
Jeff
