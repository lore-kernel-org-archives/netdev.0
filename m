From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: RFC: issues concerning the next NAPI interface
Date: Fri, 24 Aug 2007 15:59:16 +0200
Message-ID: <200708241559.17055.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:49958 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757390AbXHXN7T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 09:59:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

when I tried to get the eHEA driver working with the new interface,
the following issues came up.

1) The current implementation of netif_rx_schedule, netif_rx_complete
=A0 =A0and the net_rx_action have the following problem: netif_rx_sched=
ule
=A0 =A0sets the NAPI_STATE_SCHED flag and adds the NAPI instance to the=
 poll_list.
=A0 =A0netif_rx_action checks NAPI_STATE_SCHED, if set it will add the =
device
=A0 =A0to the poll_list again (as well). netif_rx_complete clears the N=
API_STATE_SCHED.
=A0 =A0If an interrupt handler calls netif_rx_schedule on CPU 2
=A0 =A0after netif_rx_complete has been called on CPU 1 (and the poll f=
unction=20
=A0 =A0has not returned yet), the NAPI instance will be added twice to =
the=20
=A0 =A0poll_list (by netif_rx_schedule and net_rx_action). Problems occ=
ur when=20
=A0 =A0netif_rx_complete is called twice for the device (BUG() called)

2) If an ethernet chip supports multiple receive queues, the queues are=
=20
=A0 =A0currently all processed on the CPU where the interrupt comes in.=
 This
=A0 =A0is because netif_rx_schedule will always add the rx queue to the=
 CPU's
=A0 =A0napi poll_list. The result under heavy presure is that all queue=
s will
=A0 =A0gather on the weakest CPU (with highest CPU load) after some tim=
e as they
=A0 =A0will stay there as long as the entire queue is emptied. On SMP s=
ystems=20
=A0 =A0this behaviour is not desired. It should also work well without =
interrupt
=A0 =A0pinning.
=A0 =A0It would be nice if it is possible to schedule queues to other C=
PU's, or
=A0 =A0at least to use interrupts to put the queue to another cpu (not =
nice for=20
=A0 =A0as you never know which one you will hit).=20
=A0 =A0I'm not sure how bad the tradeoff would be.

3) On modern systems the incoming packets are processed very fast. Espe=
cially
=A0 =A0on SMP systems when we use multiple queues we process only a few=
 packets
=A0 =A0per napi poll cycle. So NAPI does not work very well here and th=
e interrupt=20
=A0 =A0rate is still high. What we need would be some sort of timer pol=
ling mode=20
=A0 =A0which will schedule a device after a certain amount of time for =
high load=20
=A0 =A0situations. With high precision timers this could work well. Cur=
rent
=A0 =A0usual timers are too slow. A finer granularity would be needed t=
o keep the
   latency down (and queue length moderate).

What do you think?

Thanks,
Jan-Bernd
