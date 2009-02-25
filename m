From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: [RFC v1] hand off skb list to other cpu to submit to upper
	layer
Date: Wed, 25 Feb 2009 15:20:23 +0800
Message-ID: <1235546423.2604.556.camel@ymzhang>
References: <20090225063656.GA32635@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com,
	Stephen Hemminger <shemminger@vyatta.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:43362 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751767AbZBYHUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 02:20:44 -0500
In-Reply-To: <20090225063656.GA32635@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-02-25 at 14:36 +0800, Herbert Xu wrote:
> Zhang, Yanmin <yanmin_zhang@linux.intel.com> wrote:
> > =EF=BB=BFSubject: hand off skb list to other cpu to submit to upper=
 layer
> > From: =EF=BB=BFZhang Yanmin <yanmin.zhang@linux.intel.com>
> >=20
> > Recently, I am investigating an ip_forward performance issue with 1=
0G IXGBE NIC.
> > I start the testing on 2 machines. Every machine has 2 10G NICs. Th=
e 1st one seconds
> > packets by pktgen. The 2nd receives the packets from one NIC and fo=
rwards them out
> > from the 2nd NIC. As NICs supports multi-queue, I bind the queues t=
o different logical
> > cpu of different physical cpu while considering cache sharing caref=
ully.
> >=20
> > Comparing with sending speed on the 1st machine, the forward speed =
is not good, only
> > about 60% of sending speed. As a matter of fact, IXGBE driver start=
s NAPI when interrupt
> > arrives. When ip_forward=3D1, receiver collects a packet and forwar=
ds it out immediately.
> > So although IXGBE collects packets with NAPI, the forwarding really=
 has much impact on
> > collection. As IXGBE runs very fast, it drops packets quickly. The =
better way for
> > receiving cpu is doing nothing than just collecting packets.
>=20
Thanks for your comments.

> This doesn't make sense.  With multiqueue RX, every core should be
> working to receive its fraction of the traffic and forwarding them
> out.
I never say the core can't receive and forward packets at the same time=
=2E
I mean the performance isn't good.

>   So you shouldn't have any idle cores to begin with.  The fact
> that you do means that multiqueue RX hasn't maximised its utility,
> so you should tackle that instead of trying redirect traffic away
> from the cores that are receiving.
>From Stephen's explanation, =EF=BB=BFthe packets are being sent with d=
ifferent SRC/DST address
pairs by which harware delivers packets to different queues. we couldn'=
t expect
NIC always puts packets into queues evenly.

The behavior is IXGBE is very fast and cpu couldn't collect packets in =
time if it
collects packets and forwards them at the same time. That causes IXGBE =
drops packets.

>=20
> Of course for NICs that don't support multiqueue RX, or where the
> number of RX queues is less than the number of cores, then a scheme
> like yours may be useful.
IXGBE NIC does support a large number of RX queues. By default, it crea=
tes
CPU_NUM queues. But the performance is not good when we bind queues to
cpu evenly. One reason is cache miss/ping-pong. The forwarder machine h=
as
2 physical cpu and every cpu has 8 logical threads. All 8 logical cpu s=
hare
the last level cache. With my ip_forward testing by pktgen, binding que=
ues
to 8 logical cpu of a physical cpu could have 40% improvement than bind=
ing
queues to 16 logical cpu. So the optimization scenario just needs IXGBE=
 drivers
create 8 queues.

If the machines might have a couple of NICs and every NIC has CPU_NUM q=
ueues,
binding them evenly might cause more cache-miss/ping-pong. I didn't tes=
t
multiple receiving NICs scenario as I couldn't get enough hardware.

Yanmin


