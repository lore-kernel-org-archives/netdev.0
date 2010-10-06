From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH] net: netif_set_real_num_rx_queues may cap
 num_rx_queues at init time
Date: Wed, 06 Oct 2010 20:49:05 +0200
Message-ID: <1286390945.9417.46.camel@edumazet-laptop>
References: <20101004220042.3471.92774.stgit@jf-dev1-dcblab>
	 <1286256926.2457.2.camel@edumazet-laptop> <4CAB4D8F.8080108@intel.com>
	 <1286296476.2307.5.camel@achroite.uk.solarflarecom.com>
	 <4CAB6447.6040407@intel.com> <4CAC8D11.2060604@intel.com>
	 <1286377633.2371.11.camel@achroite.uk.solarflarecom.com>
	 <1286378626.9417.24.camel@edumazet-laptop>
	 <1286379105.2371.15.camel@achroite.uk.solarflarecom.com>
	 <20101006181458.GA6817@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33096 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754672Ab0JFStO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 14:49:14 -0400
Received: by fxm4 with SMTP id 4so1374128fxm.19
        for <netdev@vger.kernel.org>; Wed, 06 Oct 2010 11:49:13 -0700 (PDT)
In-Reply-To: <20101006181458.GA6817@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 octobre 2010 =C3=A0 11:14 -0700, Matt Carlson a =C3=A9cr=
it :

> Yes.  We were missing a call to this function in the legacy case.
>=20
>=20
> [PATCH net-next] tg3: Set real_num_rx_queues for non-multiq devs
>=20
> Commit 2ddaad397c47de012dfb956b0c05540da1a0dde5 entitled "tg3: Use
> netif_set_real_num_{rx,tx}_queues()" added a new call to
> netif_set_real_num_rx_queues in tg3_enable_msix().  This call also ne=
eds
> to be added to the legacy path to correctly reflect the actual number=
 of
> rx queues.
>=20
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> ---
>  drivers/net/tg3.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 16e1a95..e5b9ec5 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -8906,6 +8906,7 @@ defcfg:
>  		tp->irq_cnt =3D 1;
>  		tp->napi[0].irq_vec =3D tp->pdev->irq;
>  		netif_set_real_num_tx_queues(tp->dev, 1);
> +		netif_set_real_num_rx_queues(tp->dev, 1);
>  	}
>  }
> =20

Thanks, this fixed the thing for me, once device is UP

# insmod drivers/net/tg3.ko
# grep . /sys/class/net/eth3/queues/*/rps_cpus
/sys/class/net/eth3/queues/rx-0/rps_cpus:00000000
/sys/class/net/eth3/queues/rx-1/rps_cpus:00000000
/sys/class/net/eth3/queues/rx-2/rps_cpus:00000000
/sys/class/net/eth3/queues/rx-3/rps_cpus:00000000
/sys/class/net/eth3/queues/rx-4/rps_cpus:00000000
# echo ff >/sys/class/net/eth3/queues/rx-2/rps_cpus
# grep . /sys/class/net/eth3/queues/*/rps_cpus
/sys/class/net/eth3/queues/rx-0/rps_cpus:00000000
/sys/class/net/eth3/queues/rx-1/rps_cpus:00000000
/sys/class/net/eth3/queues/rx-2/rps_cpus:000000ff
/sys/class/net/eth3/queues/rx-3/rps_cpus:00000000
/sys/class/net/eth3/queues/rx-4/rps_cpus:00000000
# ifconfig eth3 up
# grep . /sys/class/net/eth3/queues/*/rps_cpus
00000000

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


