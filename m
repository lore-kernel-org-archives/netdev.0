From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: neigh_periodic_timer expires too often
Date: Fri, 31 Jul 2009 14:50:41 +0200
Message-ID: <4A72E8A1.2070705@gmail.com>
References: <4A717985.7060909@nokia.com> <4A719CDB.3060004@gmail.com> <4A71AF1D.9020000@nokia.com> <4A72E204.3050704@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kristo Tero (Nokia-D/Tampere)" <Tero.Kristo@nokia.com>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37522 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbZGaMup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2009 08:50:45 -0400
In-Reply-To: <4A72E204.3050704@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Luciano Coelho a =E9crit :
> Coelho Luciano (Nokia-D/Helsinki) wrote:
>> ext Eric Dumazet wrote:
>> =20
>>> So please test it and tell me/us you like it :)
>>>      =20
>>
>> I applied your patch on top of the 2.6.28 I'm using and will start
>> testing it now.  I can also try to test it on top of 2.6.31-rc4 plus
>> wireless-testing stuff, if needed.
>>
>> I'll tell you that I liked your patch in a moment (I actually alread=
y
>> liked it, but I'll wait until I know it works before I tell you ;)
>>  =20
>=20
> Just a small update.  We have run some very basic tests with 2.6.28.=20
> The patch seems to work fine and we don't see excessive wake-ups from
> neigh anymore (thanks Tero for helping with the tests).  We will stil=
l
> run one of our full release test rounds in order to make sure that th=
ere
> are no regressions.  I'll let you know when we have some more results=
=2E
>=20

Thanks for the update, I am running this patch on net-next-2.6 with no =
problem.

An 'easy' way to count how many time gc fired is to look at 10th column=
s of /proc/net/stat/arp_cache :


$ cat /proc/net/stat/arp_cache ; cat /proc/uptime ; sleep 150 ; cat /pr=
oc/net/stat/arp_cache=20
entries  allocs destroys hash_grows  lookups hits  res_failed  rcv_prob=
es_mcast rcv_probes_ucast  periodic_gc_runs forced_gc_runs unresolved_d=
iscards
000000fd  00000059 0000050e 00000001  00004552 0000032b  00000022  0000=
0000 00000000  000013e5 00000000 00000000
000000fd  000000df 00000003 00000002  000005a5 0000014d  00000010  0000=
0000 00000000  00000000 00000000 00000000
000000fd  000000cb 00000000 00000000  0000054f 00000141  00000011  0000=
0000 00000000  00000000 00000000 00000000
000000fd  000000b2 00000000 00000001  000005ec 000001d7  0000001d  0000=
0000 00000000  00000000 00000000 00000004
000000fd  000000de 00000000 00000001  000005f7 0000019b  00000027  0000=
0000 00000000  00000000 00000000 00000000
000000fd  000000e5 00000000 00000000  000005db 0000018e  00000027  0000=
0000 00000000  00000000 00000000 00000000
000000fd  000000d3 00000000 00000002  000005e4 0000018a  00000024  0000=
0000 00000000  00000000 00000000 00000000
000000fd  000000c3 00000000 00000000  000005ba 000001a0  00000025  0000=
0000 00000000  00000000 00000000 00000000
79173.78 0.31
entries  allocs destroys hash_grows  lookups hits  res_failed  rcv_prob=
es_mcast rcv_probes_ucast  periodic_gc_runs forced_gc_runs unresolved_d=
iscards
000000fd  00000059 0000050f 00000001  00004569 00000342  00000022  0000=
0000 00000000  000013ee 00000000 00000000
000000fd  000000df 00000003 00000002  000005a8 00000150  00000010  0000=
0000 00000000  00000000 00000000 00000000
000000fd  000000cb 00000000 00000000  00000550 00000142  00000011  0000=
0000 00000000  00000000 00000000 00000000
000000fd  000000b2 00000000 00000001  000005ed 000001d8  0000001d  0000=
0000 00000000  00000000 00000000 00000004
000000fd  000000de 00000000 00000001  000005f8 0000019c  00000027  0000=
0000 00000000  00000000 00000000 00000000
000000fd  000000e6 00000000 00000000  000005df 00000190  00000027  0000=
0000 00000000  00000000 00000000 00000000
000000fd  000000d3 00000000 00000002  000005e6 0000018c  00000024  0000=
0000 00000000  00000000 00000000 00000000
000000fd  000000c3 00000000 00000000  000005bc 000001a1  00000025  0000=
0000 00000000  00000000 00000000 00000000


In a 150 second interval, it was fired 10 times, even with a 256 slots =
hash table,
instead of 2560 times with pristine kernel.

On my dev machine, neigh_timer_handler is now at the bottom of powertop=
 :)

Wakeups-from-idle per second :  2.5     interval: 10.0s
no ACPI power usage estimate available

Top causes for wakeups:
  24.0% (  4.0)     <kernel core> : usb_hcd_poll_rh_status (rh_timer_fu=
nc)
  18.6% (  3.1)     <kernel core> : bnx2_timer (bnx2_timer)
  12.0% (  2.0)     <kernel core> : clocksource_watchdog (clocksource_w=
atchdog)
   6.0% (  1.0)     <kernel core> : tg3_timer (tg3_timer)
   6.0% (  1.0)             bond0 : queue_delayed_work (delayed_work_ti=
mer_fn)
   6.0% (  1.0)              ntpd : hrtimer_start_range_ns (it_real_fn)
   6.0% (  1.0)     <kernel core> : run_timer_softirq (htable_gc)
   5.4% (  0.9)            hpsmhd : hrtimer_start_range_ns (hrtimer_wak=
eup)
   3.0% (  0.5)       <interrupt> : cciss0
   2.4% (  0.4)     <kernel core> : dev_watchdog (dev_watchdog)
   1.8% (  0.3)     <kernel core> : queue_delayed_work (delayed_work_ti=
mer_fn)
   1.2% (  0.2)          <(null)> : (hrtimer_wakeup)
   1.2% (  0.2)            master : start_this_handle (commit_timeout)
   1.2% (  0.2)         snmptrapd : hrtimer_start_range_ns (hrtimer_wak=
eup)
   1.2% (  0.2)           pdflush : wb_kupdate (wb_timer_fn)
   0.6% (  0.1)       <interrupt> : eth0
   0.6% (  0.1)            master : hrtimer_start_range_ns (hrtimer_wak=
eup)
   0.6% (  0.1)              ntpd : blk_plug_device (blk_unplug_timeout=
)
   0.6% (  0.1)           syslogd : hrtimer_start (it_real_fn)
   0.6% (  0.1)              init : hrtimer_start_range_ns (hrtimer_wak=
eup)
   0.6% (  0.1)              ntpd : start_this_handle (commit_timeout)
   0.6% (  0.1)     <kernel core> : neigh_timer_handler (neigh_timer_ha=
ndler)
