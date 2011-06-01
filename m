From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [BUG] net: cpu offline cause napi stall
Date: Wed, 1 Jun 2011 18:36:28 +0200
Message-ID: <20110601163628.GA2418@osiris.boeblingen.de.ibm.com>
References: <20110601103356.GA45482@tuxmaker.boeblingen.de.ibm.com>
 <1306930399.3476.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frank Blaschka <blaschka@linux.vnet.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([194.196.100.167]:35543 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501Ab1FAQgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 12:36:31 -0400
Content-Disposition: inline
In-Reply-To: <1306930399.3476.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 01, 2011 at 02:13:19PM +0200, Eric Dumazet wrote:
> Le mercredi 01 juin 2011 =E0 12:33 +0200, Frank Blaschka a =E9crit :
> > Hi Dave, Eric,
> >=20
> > during heavy network load we turn off/on cpus.
> > Sometimes this causes a stall on the network device.
> > Digging into the dump I found out following:
> >=20
> > napi is scheduled but does not run. From the I/O buffers
> > and the napi state I see napi/rx_softirq processing has stopped
> > because the budget was reached. napi stays in the
> > softnet_data poll_list and the rx_softirq was raised again.
> >=20
> > I assume at this time the cpu offline comes in.
> > the rx softirq is raised/moved to another cpu but napi stays in the=
 poll_list
> > of the softnet_data of the now offline cpu.
> >=20
> > reviewing dev_cpu_callback (net/core/dev.c) I did not find the poll=
_list
> > is transfered to the new cpu. Do you think this could cause the sta=
ll or
> > did I miss something?
> >=20
> > Thx for your help.
>=20
> Hi Frank
>=20
> I believe you are right, I cant see where the poll_list transfert fro=
m
> dead cpu to online cpu is done.
>=20
> Do you want to prepare a patch ?

=46rank will be offline until next week. I assume the patch below would=
 fix
the problem, however its untested. I doubt we can verify that it really
fixes the problem also until next week (public holiday tomorrow).

diff --git a/net/core/dev.c b/net/core/dev.c
index 6561021..6d6a7cf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5981,6 +5981,8 @@ static int dev_cpu_callback(struct notifier_block=
 *nfb,
 		oldsd->output_queue =3D NULL;
 		oldsd->output_queue_tailp =3D &oldsd->output_queue;
 	}
+	/* Append NAPI poll list from offline CPU. */
+	list_splice_init(&oldsd->poll_list, &sd->poll_list);
=20
 	raise_softirq_irqoff(NET_TX_SOFTIRQ);
 	local_irq_enable();
