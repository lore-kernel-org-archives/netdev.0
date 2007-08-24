From: David Miller <davem@davemloft.net>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Fri, 24 Aug 2007 14:37:51 -0700 (PDT)
Message-ID: <20070824.143751.112614506.davem@davemloft.net>
References: <200708241559.17055.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, raisch@de.ibm.com, themann@de.ibm.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	meder@de.ibm.com, tklein@de.ibm.com, stefan.roscher@de.ibm.com
To: ossthema@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59072
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756499AbXHXVhw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 17:37:52 -0400
In-Reply-To: <200708241559.17055.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Jan-Bernd Themann <ossthema@de.ibm.com>
Date: Fri, 24 Aug 2007 15:59:16 +0200

> 1) The current implementation of netif_rx_schedule, netif_rx_complete
> =A0 =A0and the net_rx_action have the following problem: netif_rx_sch=
edule
> =A0 =A0sets the NAPI_STATE_SCHED flag and adds the NAPI instance to t=
he poll_list.
> =A0 =A0netif_rx_action checks NAPI_STATE_SCHED, if set it will add th=
e device
> =A0 =A0to the poll_list again (as well). netif_rx_complete clears the=
 NAPI_STATE_SCHED.
> =A0 =A0If an interrupt handler calls netif_rx_schedule on CPU 2
> =A0 =A0after netif_rx_complete has been called on CPU 1 (and the poll=
 function=20
> =A0 =A0has not returned yet), the NAPI instance will be added twice t=
o the=20
> =A0 =A0poll_list (by netif_rx_schedule and net_rx_action). Problems o=
ccur when=20
> =A0 =A0netif_rx_complete is called twice for the device (BUG() called=
)

Indeed, this is the "who should manage the list" problem.
Probably the answer is that whoever transitions the NAPI_STATE_SCHED
bit from cleared to set should do the list addition.

Patches welcome :-)

> 3) On modern systems the incoming packets are processed very fast. Es=
pecially
> =A0 =A0on SMP systems when we use multiple queues we process only a f=
ew packets
> =A0 =A0per napi poll cycle. So NAPI does not work very well here and =
the interrupt=20
> =A0 =A0rate is still high. What we need would be some sort of timer p=
olling mode=20
> =A0 =A0which will schedule a device after a certain amount of time fo=
r high load=20
> =A0 =A0situations. With high precision timers this could work well. C=
urrent
> =A0 =A0usual timers are too slow. A finer granularity would be needed=
 to keep the
>    latency down (and queue length moderate).

This is why minimal levels of HW interrupt mitigation should be enabled
in your chip.  If it does not support this, you will indeed need to loo=
k
into using high resolution timers or other schemes to alleviate this.

I do not think it deserves a generic core networking helper facility,
the chips that can't mitigate interrupts are few and obscure.
