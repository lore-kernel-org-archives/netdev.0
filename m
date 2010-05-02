From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Sun, 02 May 2010 17:32:55 +0200
Message-ID: <1272814375.2173.75.camel@edumazet-laptop>
References: <20100429182347.GA8512@gargoyle.fritz.box>
	 <1272568347.2209.11.camel@edumazet-laptop>
	 <20100429214144.GA10663@gargoyle.fritz.box>
	 <20100430.163857.180417789.davem@davemloft.net>
	 <20100501110000.GB9434@gargoyle.fritz.box>
	 <1272783366.2173.13.camel@edumazet-laptop>
	 <20100502092020.GA9655@gargoyle.fritz.box>
	 <1272797690.2173.26.camel@edumazet-laptop>
	 <20100502071324.1a95fdad@infradead.org>
	 <1272810448.2173.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:53504 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755999Ab0EBPdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 11:33:06 -0400
Received: by bwz19 with SMTP id 19so896813bwz.21
        for <netdev@vger.kernel.org>; Sun, 02 May 2010 08:33:02 -0700 (PDT)
In-Reply-To: <1272810448.2173.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 02 mai 2010 =C3=A0 16:27 +0200, Eric Dumazet a =C3=A9crit :
> Le dimanche 02 mai 2010 =C3=A0 07:13 -0700, Arjan van de Ven a =C3=A9=
crit :
> > >=20
> > > Cn                Avg residency       P-states (frequencies)
> > > C0 (cpu running)        (68.9%)         2.93 Ghz    46.5%
> > > polling           0.0ms ( 0.0%)         2.80 Ghz     5.1%
> > > C1 mwait          0.0ms ( 0.0%)         2.53 Ghz     3.0%
> > > C2 mwait          0.0ms (31.1%)         2.13 Ghz     2.8%
> > >                                         1.60 Ghz    38.2%
> >=20
> > I bet your system advertizes C2 with the same latency as C1,
> > but with lower power... which means Linux will pretty much never
> > pick C1.... no matter how much you take Andi's patch.
> >=20
> > this is a bios thing... and until we put in the patch to override t=
he
> > bios values (I can dust it off but it might need a bit of tweaking
> > since it was against .31) Andi's patch alone won't cut it... you al=
so
> > need a non-lying bios ;)
> >=20
> >=20
> >=20
> # pwd
> /sys/devices/system/cpu/cpu15/cpuidle
> # grep . */*
> state0/desc:CPUIDLE CORE POLL IDLE
> state0/latency:0
> state0/name:C0
> state0/power:4294967295
> state0/time:0
> state0/usage:0
> state1/desc:ACPI FFH INTEL MWAIT 0x0
> state1/latency:1
> state1/name:C1
> state1/power:1000
> state1/time:433855186
> state1/usage:126869
> state2/desc:ACPI FFH INTEL MWAIT 0x10
> state2/latency:64
> state2/name:C2
> state2/power:500
> state2/time:198095020416
> state2/usage:76287744
>=20
> C2 latency seems to be 64  (us ?), while C1 seems to be 1
>=20
> BIOS Information
> 	Vendor: HP
> 	Version: I24
> 	Release Date: 10/01/2009
>=20
> # powertop
> PowerTOP 1.11   (C) 2007, 2008 Intel Corporation=20
>=20
> Collecting data for 5 seconds=20
>=20
>=20
> Your CPU supports the following C-states : C1 C2 C3=20
> Your BIOS reports the following C-states : C1 C2=20
>=20
> C3 seems to be disabled in BIOS
>=20

I took a look at BIOS settings and enabled the minimum sleep state to b=
e
C6 (instead of C3, the default). Now we see C3 being available...

No changes, only more IPI delivered during the test, and more overhead
in clockevents_notify()

# grep . */*
state0/desc:CPUIDLE CORE POLL IDLE
state0/latency:0
state0/name:C0
state0/power:4294967295
state0/time:0
state0/usage:0
state1/desc:ACPI FFH INTEL MWAIT 0x0
state1/latency:1
state1/name:C1
state1/power:1000
state1/time:39432
state1/usage:119
state2/desc:ACPI FFH INTEL MWAIT 0x10
state2/latency:64
state2/name:C2
state2/power:500
state2/time:3170745
state2/usage:11177
state3/desc:ACPI FFH INTEL MWAIT 0x20
state3/latency:96
state3/name:C3
state3/power:350
state3/time:1030987453
state3/usage:14047019

-----------------------------------------------------------------------=
----------------------------------------------------
   PerfTop:   15984 irqs/sec  kernel:98.5% [1000Hz cycles],  (all, 16 C=
PUs)
-----------------------------------------------------------------------=
----------------------------------------------------

             samples  pcnt function                       DSO
             _______ _____ ______________________________ _______

            23822.00 40.2% _raw_spin_lock_irqsave         vmlinux
             4413.00  7.4% acpi_os_read_port              vmlinux
             1426.00  2.4% _raw_spin_lock                 vmlinux
             1284.00  2.2% _raw_spin_unlock_irqrestore    vmlinux
             1247.00  2.1% schedule                       vmlinux
             1137.00  1.9% bnx2x_rx_int                   vmlinux
              643.00  1.1% tick_broadcast_oneshot_control vmlinux
              597.00  1.0% copy_user_generic_string       vmlinux
              595.00  1.0% __napi_complete                vmlinux
              550.00  0.9% call_function_single_interrupt vmlinux
              548.00  0.9% bnx2x_msix_fp_int              vmlinux
              486.00  0.8% __netif_receive_skb            vmlinux
              461.00  0.8% bnx2x_poll                     vmlinux
              433.00  0.7% eth_type_trans                 vmlinux
              428.00  0.7% acpi_idle_enter_bm             vmlinux
              422.00  0.7% sock_recv_ts_and_drops         vmlinux
              382.00  0.6% __udp4_lib_lookup              vmlinux
              369.00  0.6% __slab_free                    vmlinux
              357.00  0.6% ip_route_input                 vmlinux
              341.00  0.6% kfree                          vmlinux
              335.00  0.6% ipt_do_table                   vmlinux
              334.00  0.6% ip_rcv                         vmlinux
              332.00  0.6% udp_recvmsg                    vmlinux
              317.00  0.5% __kmalloc_node_track_caller    vmlinux

    37.46%            init  [kernel.kallsyms]             [k] _raw_spin=
_lock_irqsave
                      |
                      --- _raw_spin_lock_irqsave
                         |         =20
                         |--95.58%-- clockevents_notify
                         |          lapic_timer_state_broadcast
                         |          acpi_idle_enter_bm
                         |          cpuidle_idle_call
                         |          cpu_idle
                         |          start_secondary
                         |         =20
                         |--3.27%-- tick_broadcast_oneshot_control
                         |          tick_notify
                         |          notifier_call_chain
                         |          __raw_notifier_call_chain
                         |          raw_notifier_call_chain
                         |          clockevents_do_notify
                         |          clockevents_notify
                         |          lapic_timer_state_broadcast
                         |          acpi_idle_enter_bm


