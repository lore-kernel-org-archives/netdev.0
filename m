From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Mon, 26 Apr 2010 16:03:04 +0200
Message-ID: <1272290584.19143.43.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272014825.7895.7851.camel@edumazet-laptop> <1272060153.8918.8.camel@bigi>
	 <1272118252.8918.13.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:39820 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614Ab0DZODN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 10:03:13 -0400
Received: by bwz19 with SMTP id 19so170467bwz.21
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 07:03:11 -0700 (PDT)
In-Reply-To: <1272118252.8918.13.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 24 avril 2010 =C3=A0 10:10 -0400, jamal a =C3=A9crit :
> On Fri, 2010-04-23 at 18:02 -0400, jamal wrote:
>=20
> > Ive done a setup with the last patch from Changli + net-next - I wi=
ll
> > post test results tomorrow AM.
>=20
> ok, annotated results attached.=20
>=20
> cheers,
> jamal

Jamal, I have a Nehalem setup now, and I can see
_raw_spin_lock_irqsave() abuse is not coming from network tree, but fro=
m
clockevents_notify()

My pktgen sends 1040989pps :

# Samples: 389707198131
#
# Overhead         Command                 Shared Object  Symbol
# ........  ..............  ............................  ......
#
    23.52%            init  [kernel.kallsyms]             [k] _raw_spin=
_lock_irqsave
                      |
                      --- _raw_spin_lock_irqsave
                         |         =20
                         |--94.74%-- clockevents_notify
                         |          lapic_timer_state_broadcast
                         |          acpi_idle_enter_bm
                         |          cpuidle_idle_call
                         |          cpu_idle
                         |          start_secondary
                         |         =20
                         |--4.10%-- tick_broadcast_oneshot_control
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
                         |--0.58%-- lapic_timer_state_broadcast
                         |          acpi_idle_enter_bm
                         |          cpuidle_idle_call
                         |          cpu_idle
                         |          start_secondary
                          --0.58%-- [...]

     8.94%            init  [kernel.kallsyms]             [k] acpi_os_r=
ead_port
                      |
                      --- acpi_os_read_port
                         |         =20
                         |--99.55%-- acpi_hw_read_port
                         |          acpi_hw_read
                         |          acpi_hw_read_multiple
                         |          acpi_hw_register_read
                         |          acpi_read_bit_register



# Samples: 389233082962
#
# Overhead         Command                 Shared Object  Symbol
# ........  ..............  ............................  ......
#
    23.25%            init  [kernel.kallsyms]             [k] _raw_spin=
_lock_irqsave
     8.90%            init  [kernel.kallsyms]             [k] acpi_os_r=
ead_port
     2.93%            init  [kernel.kallsyms]             [k] mwait_idl=
e_with_hints
     1.99%            init  [kernel.kallsyms]             [k] schedule
     1.94%         udpsink  [kernel.kallsyms]             [k] schedule
     1.73%         swapper  [kernel.kallsyms]             [k] _raw_spin=
_lock_irqsave
     1.48%            init  [kernel.kallsyms]             [k] bnx2x_rx_=
int
     1.47%            init  [kernel.kallsyms]             [k] _raw_spin=
_unlock_irqrestore
     1.44%            init  [kernel.kallsyms]             [k] _raw_spin=
_lock
     1.36%         udpsink  [kernel.kallsyms]             [k] udp_recvm=
sg
     1.05%         udpsink  [kernel.kallsyms]             [k] __skb_rec=
v_datagram
     1.05%            init  [kernel.kallsyms]             [k] __udp4_li=
b_lookup
     1.04%         udpsink  [kernel.kallsyms]             [k] copy_user=
_generic_string
     1.04%         udpsink  [kernel.kallsyms]             [k] __slab_fr=
ee
     0.99%            init  [kernel.kallsyms]             [k] select_ta=
sk_rq_fair
     0.99%            init  [kernel.kallsyms]             [k] try_to_wa=
ke_up
     0.98%            init  [kernel.kallsyms]             [k] task_rq_l=
ock
     0.93%            init  [kernel.kallsyms]             [k] tick_broa=
dcast_oneshot_control
     0.89%            init  [kernel.kallsyms]             [k] sock_queu=
e_rcv_skb
     0.89%         udpsink  [kernel.kallsyms]             [k] sock_recv=
_ts_and_drops
     0.88%         udpsink  [kernel.kallsyms]             [k] kfree
     0.79%         swapper  [kernel.kallsyms]             [k] acpi_os_r=
ead_port
     0.76%         udpsink  [kernel.kallsyms]             [k] _raw_spin=
_lock_irqsave
     0.73%         udpsink  [kernel.kallsyms]             [k] inet_recv=
msg
     0.71%         udpsink  [vdso]                        [.] 0x000000f=
fffe431
     0.65%         udpsink  [kernel.kallsyms]             [k] sock_recv=
msg
     0.62%            init  [kernel.kallsyms]             [k] gs_change
     0.61%            init  [kernel.kallsyms]             [k] enqueue_t=
ask_fair
     0.61%            init  [kernel.kallsyms]             [k] eth_type_=
trans
     0.61%            init  [kernel.kallsyms]             [k] sock_def_=
readable
     0.60%         udpsink  [kernel.kallsyms]             [k] _raw_spin=
_lock_bh
     0.59%            init  [kernel.kallsyms]             [k] ip_route_=
input
     0.59%         udpsink  libpthread-2.3.4.so           [.] __pthread=
_disable_asynccancel
     0.56%            init  [kernel.kallsyms]             [k] bnx2x_pol=
l
     0.56%         udpsink  [kernel.kallsyms]             [k] __get_use=
r_4


