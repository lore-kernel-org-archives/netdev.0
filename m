From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Sun, 02 May 2010 12:54:50 +0200
Message-ID: <1272797690.2173.26.camel@edumazet-laptop>
References: <20100429182347.GA8512@gargoyle.fritz.box>
	 <1272568347.2209.11.camel@edumazet-laptop>
	 <20100429214144.GA10663@gargoyle.fritz.box>
	 <20100430.163857.180417789.davem@davemloft.net>
	 <20100501110000.GB9434@gargoyle.fritz.box>
	 <1272783366.2173.13.camel@edumazet-laptop>
	 <20100502092020.GA9655@gargoyle.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org, arjan@infradead.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:58796 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754280Ab0EBKy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 06:54:56 -0400
Received: by bwz19 with SMTP id 19so828170bwz.21
        for <netdev@vger.kernel.org>; Sun, 02 May 2010 03:54:54 -0700 (PDT)
In-Reply-To: <20100502092020.GA9655@gargoyle.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 02 mai 2010 =C3=A0 11:20 +0200, Andi Kleen a =C3=A9crit :
> > I tried it on the right spot (since my bench was only doing recvmsg=
()
> > calls, I had to patch wait_for_packet() in net/core/datagram.c
> >=20
> > udp_recvmsg -> __skb_recv_datagram -> wait_for_packet ->
> > schedule_timeout
> >=20
> > Unfortunatly, using io_schedule_timeout() did not solve the problem=
=2E
>=20
> Hmm, too bad. Weird.
>=20
> >=20
> > Tell me if you need some traces or something.
>=20
> I'll try to reproduce it and see what I can do.
>=20

Here the perf report on the latest test done, I confirm I am using
io_schedule_timeout() in this kernel.

In this test, all 16 queues of one BCM57711E NIC (1Gb link) delivers
 packets at about 1.300.000 pps to 16 cpus (one cpu per queue) and thes=
e
packets are then redistributed by RPS to same 16 cpus, generating about
650.000 IPI per second.

top says :
Cpu(s):  3.0%us, 17.3%sy,  0.0%ni, 22.4%id, 28.2%wa,  0.0%hi, 29.1%si,
0.0%st


# Samples: 321362570767
#
# Overhead         Command                 Shared Object  Symbol
# ........  ..............  ............................  ......
#
    25.08%            init  [kernel.kallsyms]             [k] _raw_spin=
_lock_irqsave
                      |
                      --- _raw_spin_lock_irqsave
                         |         =20
                         |--93.47%-- clockevents_notify
                         |          lapic_timer_state_broadcast
                         |          acpi_idle_enter_bm
                         |          cpuidle_idle_call
                         |          cpu_idle
                         |          start_secondary
                         |         =20
                         |--4.70%-- tick_broadcast_oneshot_control
                         |          tick_notify
                         |          notifier_call_chain
                         |          __raw_notifier_call_chain
                         |          raw_notifier_call_chain
                         |          clockevents_do_notify
                         |          clockevents_notify
                         |          lapic_timer_state_broadcast
                         |          acpi_idle_enter_bm
                         |          cpuidle_idle_call
                         |          cpu_idle
                         |          start_secondary
                         |         =20
                         |--0.64%-- generic_exec_single
                         |          __smp_call_function_single
                         |          net_rps_action_and_irq_enable
=2E..
     9.72%            init  [kernel.kallsyms]             [k] acpi_os_r=
ead_port
                      |
                      --- acpi_os_read_port
                         |         =20
                         |--99.45%-- acpi_hw_read_port
                         |          acpi_hw_read
                         |          acpi_hw_read_multiple
                         |          acpi_hw_register_read
                         |          acpi_read_bit_register
                         |          acpi_idle_enter_bm
                         |          cpuidle_idle_call
                         |          cpu_idle
                         |          start_secondary
                         |         =20
                          --0.55%-- acpi_hw_read
                                    acpi_hw_read_multiple

powertop says :
     PowerTOP version 1.11      (C) 2007 Intel Corporation

Cn                Avg residency       P-states (frequencies)
C0 (cpu running)        (68.9%)         2.93 Ghz    46.5%
polling           0.0ms ( 0.0%)         2.80 Ghz     5.1%
C1 mwait          0.0ms ( 0.0%)         2.53 Ghz     3.0%
C2 mwait          0.0ms (31.1%)         2.13 Ghz     2.8%
                                        1.60 Ghz    38.2%

Wakeups-from-idle per second : 45177.8  interval: 5.0s
no ACPI power usage estimate available

Top causes for wakeups:
   9.9% (40863.0)       <interrupt> : eth1-fp-7=20
   9.9% (40861.0)       <interrupt> : eth1-fp-8=20
   9.9% (40858.0)       <interrupt> : eth1-fp-5=20
   9.9% (40855.2)       <interrupt> : eth1-fp-10=20
   9.9% (40847.6)       <interrupt> : eth1-fp-14=20
   9.9% (40847.2)       <interrupt> : eth1-fp-12=20
   9.9% (40835.0)       <interrupt> : eth1-fp-1=20
   9.9% (40834.2)       <interrupt> : eth1-fp-3=20
   9.9% (40834.0)       <interrupt> : eth1-fp-6=20
   9.9% (40829.6)       <interrupt> : eth1-fp-4=20
   1.0% (4002.0)     <kernel core> : hrtimer_start_range_ns (tick_sched=
_timer)=20
   0.4% (1725.6)       <interrupt> : extra timer interrupt=20
   0.0% (  4.0)     <kernel core> : usb_hcd_poll_rh_status (rh_timer_fu=
nc)
   0.0% (  2.0)     <kernel core> : clocksource_watchdog (clocksource_w=
atchdog)
   0.0% (  2.0)             snmpd : hrtimer_start_range_ns (hrtimer_wak=
eup)


