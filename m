From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler (v0.2)
Date: Thu, 06 Jan 2011 05:07:30 +0100
Message-ID: <1294286850.2723.65.camel@edumazet-laptop>
References: <20110104162930.6fa672e3@nehalam>
	 <1294208375.3420.46.camel@edumazet-laptop>
	 <20110105091718.02f8a00f@nehalam>
	 <1294248332.10633.25.camel@edumazet-laptop>
	 <20110105112104.64ad3c86@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:37472 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754902Ab1AFEHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 23:07:36 -0500
Received: by wwi17 with SMTP id 17so16646143wwi.1
        for <netdev@vger.kernel.org>; Wed, 05 Jan 2011 20:07:35 -0800 (PST)
In-Reply-To: <20110105112104.64ad3c86@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 05 janvier 2011 =C3=A0 11:21 -0800, Stephen Hemminger a =C3=
=A9crit :
> This implements the CHOKe packet scheduler based on the existing
> Linux RED scheduler based on the algorithm described in the paper.
>=20
> The core idea is:
>   For every packet arrival:
>   	Calculate Qave
> 	if (Qave < minth)=20
> 	     Queue the new packet
> 	else=20
> 	     Select randomly a packet from the queue=20
> 	     if (both packets from same flow)
> 	     then Drop both the packets
> 	     else if (Qave > maxth)
> 	          Drop packet
> 	     else
> 	       	  Admit packet with probability p (same as RED)
>=20
> See also:
>   Rong Pan, Balaji Prabhakar, Konstantinos Psounis, "CHOKe: a statele=
ss active
>    queue management scheme for approximating fair bandwidth allocatio=
n",=20
>   Proceeding of INFOCOM'2000, March 2000.=20
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20

To be really useful in a wide range of environments, I believe that :

- CHOKe should be able to use an external flow classifier (like say...
SFQ) to compute a token and compare two skbs by this token instead of
custom rxhash or whatever. (rxhash can be the default in absence of flo=
w
classifier). Probably you need to store the token in skb->cb[] to avoid
calling tc_classify() several times for a given packet.=20

http://lwn.net/Articles/236200/
http://kerneltrap.org/mailarchive/linux-netdev/2008/1/31/667679

- Must use a FIFO with O(1) access to Nth skb in queue.
=20
 A linked list makes this implementation too expensive for big queues.

=46or small queues (less than 128 skbs at this moment for SFQ), existin=
g
schedulers are good enough.

CHOKe authors dont mention this in their paper, but their experiments
were done in 1999 with 1Mbs links. minth=3D100 and maxth=3D200, limit=3D=
300

We want to try CHOKe with modern links, probably with minth=3D2000 and
maxth=3D4000 or more.

They said "It is arguably more difficult to drop a randomy chosen packe=
t
since this means removing from a linked-list. Instead of doing this, we
propose to add one extra bit to the packet header. The bit is set to on=
e
if the drop candidate is to be dropped. When a packet advance to the
head of the FIFO buffer, the status of the bit determines whether it is
to be immediately discarded or transmitted on the outgoind line"

If they thought removing a buffer from a linked list was expensive
(!!!), they certainly assumed the previous access to the randomly chose=
n
buffer was faster than the skb unlink !

Using a circular buffer should be enough, using a similar trick than
suggested : when droping an skb from the ring, stick a NULL pointer and
dont memmove() the window to shrink it.

struct skb_ring {
	unsigned int head;
	unsigned int tail;
	unsigned int size; /* a power of two */
	struct sk_buff **table;
};

Doing so avoids the cache misses to adjacent skbs prev/next when
queue/dequeue is done.




