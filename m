From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: add additional lock to qdisc to increase
 enqueue/dequeue fairness
Date: Tue, 23 Mar 2010 21:54:27 +0100
Message-ID: <1269377667.2915.25.camel@edumazet-laptop>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:34336 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754313Ab0CWUyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 16:54:31 -0400
Received: by bwz1 with SMTP id 1so2266377bwz.21
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 13:54:29 -0700 (PDT)
In-Reply-To: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 mars 2010 =C3=A0 13:25 -0700, Alexander Duyck a =C3=A9crit =
:
> The qdisc layer shows a significant issue when you start transmitting=
 from
> multiple CPUs.  The issue is that the transmit rate drops significant=
ly, and I
> believe it is due to the fact that the spinlock is shared between the=
 1
> dequeue, and n-1 enqueue cpu threads.  In order to improve this situa=
tion I am
> adding one additional lock which will need to be obtained during the =
enqueue
> portion of the path.  This essentially allows sch_direct_xmit to jump=
 to
> near the head of the line when attempting to obtain the lock after
> completing a transmit.
>=20
> Running the script below I saw an increase from 200K packets per seco=
nd to
> 1.07M packets per second as a result of this patch.
>=20
> for j in `seq 0 15`; do
> 	for i in `seq 0 7`; do
> 		netperf -H <ip> -t UDP_STREAM -l 600 -N -T $i -- -m 6 &
> 	done
> done
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>=20

Hi Alexander

Thats a pretty good topic :)

So to speedup a pathological case (dozen of cpus all sending to same
queue), you suggest adding a spin_lock to fast path, slowing down norma=
l
cases ?

Quite frankly, the real problem in this case is not the reduced
throughput, but fact that one cpu can stay a long time doing the xmits
to device, of skb queued by other cpus. This can hurt latencies a lot,
for real time threads for example...

I wonder if ticket spinlocks are not the problem. Maybe we want a
variant of spinlocks, so that cpu doing transmits can get the lock
before other cpus...



