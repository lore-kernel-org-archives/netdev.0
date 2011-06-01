From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] net: cpu offline cause napi stall
Date: Wed, 01 Jun 2011 18:55:21 +0200
Message-ID: <1306947321.2890.5.camel@edumazet-laptop>
References: <20110601103356.GA45482@tuxmaker.boeblingen.de.ibm.com>
	 <1306930399.3476.1.camel@edumazet-laptop>
	 <20110601163628.GA2418@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frank Blaschka <blaschka@linux.vnet.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:37544 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758895Ab1FAQzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 12:55:25 -0400
In-Reply-To: <20110601163628.GA2418@osiris.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 juin 2011 =C3=A0 18:36 +0200, Heiko Carstens a =C3=A9cri=
t :
> On Wed, Jun 01, 2011 at 02:13:19PM +0200, Eric Dumazet wrote:
> > Le mercredi 01 juin 2011 =C3=A0 12:33 +0200, Frank Blaschka a =C3=A9=
crit :
> > > Hi Dave, Eric,
> > >=20
> > > during heavy network load we turn off/on cpus.
> > > Sometimes this causes a stall on the network device.
> > > Digging into the dump I found out following:
> > >=20
> > > napi is scheduled but does not run. From the I/O buffers
> > > and the napi state I see napi/rx_softirq processing has stopped
> > > because the budget was reached. napi stays in the
> > > softnet_data poll_list and the rx_softirq was raised again.
> > >=20
> > > I assume at this time the cpu offline comes in.
> > > the rx softirq is raised/moved to another cpu but napi stays in t=
he poll_list
> > > of the softnet_data of the now offline cpu.
> > >=20
> > > reviewing dev_cpu_callback (net/core/dev.c) I did not find the po=
ll_list
> > > is transfered to the new cpu. Do you think this could cause the s=
tall or
> > > did I miss something?
> > >=20
> > > Thx for your help.
> >=20
> > Hi Frank
> >=20
> > I believe you are right, I cant see where the poll_list transfert f=
rom
> > dead cpu to online cpu is done.
> >=20
> > Do you want to prepare a patch ?
>=20
> Frank will be offline until next week. I assume the patch below would=
 fix
> the problem, however its untested. I doubt we can verify that it real=
ly
> fixes the problem also until next week (public holiday tomorrow).
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6561021..6d6a7cf 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5981,6 +5981,8 @@ static int dev_cpu_callback(struct notifier_blo=
ck *nfb,
>  		oldsd->output_queue =3D NULL;
>  		oldsd->output_queue_tailp =3D &oldsd->output_queue;
>  	}
> +	/* Append NAPI poll list from offline CPU. */
> +	list_splice_init(&oldsd->poll_list, &sd->poll_list);
> =20
>  	raise_softirq_irqoff(NET_TX_SOFTIRQ);
>  	local_irq_enable();

Same here, I'll be offline for the next 4 days ;)

Please make sure we raise NET_RX_SOFTIRQ on new cpu if necessary.



