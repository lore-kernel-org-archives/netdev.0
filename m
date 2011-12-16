From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: twice past the taps, thence out to net?
Date: Fri, 16 Dec 2011 20:34:04 +0100
Message-ID: <1324064044.2621.20.camel@edumazet-laptop>
References: <4EE8F884.1010304@hp.com>
	 <CAGK4HS-+jj9cvvirDm96oRvRJdwC+2kjE_LnSOXBuQy0pfnQjg@mail.gmail.com>
	 <1323970998.2769.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EEA3D58.5010101@hp.com>
	 <20111215104440.1eef9e47@s6510.linuxnetplumber.net>
	 <1323975606.2769.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EEA730E.5010405@hp.com> <1324009676.2562.9.camel@edumazet-laptop>
	 <CAEuXFEy02BAL4+=RNOi7u=-4WBvwPpvTOJKPcwND2yxW+hw9FA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	tcpdump-workers@lists.tcpdump.org, netdev@vger.kernel.org,
	Matthew Vick <matthew.vick@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35719 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264Ab1LPTeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 14:34:08 -0500
Received: by wgbdr13 with SMTP id dr13so6737226wgb.1
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 11:34:07 -0800 (PST)
In-Reply-To: <CAEuXFEy02BAL4+=RNOi7u=-4WBvwPpvTOJKPcwND2yxW+hw9FA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 d=C3=A9cembre 2011 =C3=A0 10:28 -0800, Jesse Brandeburg =
a =C3=A9crit :
> On Thu, Dec 15, 2011 at 8:27 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le jeudi 15 d=C3=A9cembre 2011 =C3=A0 14:22 -0800, Rick Jones a =C3=
=A9crit :
> >> On 12/15/2011 11:00 AM, Eric Dumazet wrote:
> >> >> Device's work better if the driver proactively manages stop_que=
ue/wake_queue.
> >> >> Old devices used TX_BUSY, but newer devices tend to manage the =
queue
> >> >> themselves.
> >> >>
> >> >
> >> > Some 'new' drivers like igb can be fooled in case skb is gso seg=
mented ?
> >> >
> >> > Because igb_xmit_frame_ring() needs skb_shinfo(skb)->nr_frags + =
4
> >> > descriptors, igb should stop its queue not at MAX_SKB_FRAGS + 4,=
 but
> >> > MAX_SKB_FRAGS*4
>=20
> can you please help me understand the need for MAX_SKB_FRAGS * 4 as
> the requirement?  Currently driver uses logic like
>=20
> in hard_start_tx: hey I just finished a tx, I should stop the qdisc i=
f
> I don't have room (in tx descriptors) for a worst case transmit skb
> (MAX_SKB_FRAGS + 4) the next time I'm called.
> when cleaning from interrupt: My cleanup is done, do I have enough
> free tx descriptors (should be MAX_SKB_FRAGS + 4) for a worst case
> transmit?  If yes, restart qdisc.
>=20
> I'm missing the jump from the above logic to using MAX_SKB_FRAGS * 4
> (=3D=3D (18 * 4) =3D=3D 72) as the minimum number of descriptors I ne=
ed for a
> worst case TSO.  Each descriptor can point to up to 16kB of contiguou=
s
> memory, typically we use 1 for offload context setup, 1 for skb->data=
,
> and 1 for each page.  I think we may be overestimating with
> MAX_SKB_FRAGS + 4, but that should be no big deal.

Did you read my second patch ?

Problem is you wakeup the queue too soon (16 available descriptors,
while a full TSO packet needs more than that)

How would you explain high 'requeues' number if it was not the problem =
?

Also, its suboptimal to wakeup the queue if available space is very low=
,
since only _one_ packet may be dequeued from qdisc (you pay high cost i=
n
cache line bouncing)

My first patch was about a very rare event : A full TSO packet is
segmented in gso_segment() [ say if you dynamically disable sg on eth
device and an old tcp buffer is retransmitted ] : You end with 16 skbs
delivered to NIC : In this case we can hit tx ring limit at 4th or 5th
skb, and Rick complains tcpdump outputs some packets several times ;)

Since igb needs 4 descriptors for linear skb, I said : 4 *
MAX_SKB_FRAGS, but real problem is addressed in my second patch, I
believe ?
