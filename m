From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] rps: shortcut net_rps_action()
Date: Mon, 19 Apr 2010 14:14:04 +0200
Message-ID: <1271679244.3845.43.camel@edumazet-laptop>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <1271489739.16881.4586.camel@edumazet-laptop>
	 <1271525519.3929.3.camel@bigi>
	 <1271583573.16881.4798.camel@edumazet-laptop>
	 <1271590476.16881.4925.camel@edumazet-laptop>
	 <1271669822.16881.7520.camel@edumazet-laptop>
	 <k2u412e6f7f1004190248s8ac633beof2475645e799f2ea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:61880 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899Ab0DSMOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 08:14:11 -0400
Received: by bwz25 with SMTP id 25so5476893bwz.28
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 05:14:09 -0700 (PDT)
In-Reply-To: <k2u412e6f7f1004190248s8ac633beof2475645e799f2ea@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 avril 2010 =C3=A0 17:48 +0800, Changli Gao a =C3=A9crit :
> On Mon, Apr 19, 2010 at 5:37 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > net_rps_action() is a bit expensive on NR_CPUS=3D64..4096 kernels, =
even if
> > RPS is not active.
> >
> > I add a flag to scan cpumask only if at least one IPI was scheduled=
=2E
> > Even cpumask_weight() might be expensive on some setups, where
> > nr_cpumask_bits could be very big (4096 for example)
>=20
> How about using a array to save the cpu IDs. The number of CPUs, to
> which the IPI will be sent, should be small.
>=20

Yes it should be small, yet the two arrays would be big enough to make
softnet_data first part use at least two cache lines instead of one,
even in the case we handle one cpu/IPI per net_rps_action()

As several packets can be enqueued for a given cpu, we would need to
keep bitmasks.
We would have to add one test in enqueue_to_backlog()

if (cpu_test_and_set(cpu, mask)) {
	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
	array[nb++] =3D cpu;
}



