From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Fri, 02 Dec 2011 21:22:49 +0100
Message-ID: <1322857369.2762.63.camel@edumazet-laptop>
References: <1322841935.2762.33.camel@edumazet-laptop>
	 <20111202.131304.981034697414242002.davem@davemloft.net>
	 <1322850989.2762.47.camel@edumazet-laptop>
	 <20111202.134040.638198723589712419.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: subramanian.vijay@gmail.com, therbert@google.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43160 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820Ab1LBUWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 15:22:54 -0500
Received: by bkas6 with SMTP id s6so4294915bka.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 12:22:53 -0800 (PST)
In-Reply-To: <20111202.134040.638198723589712419.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 d=C3=A9cembre 2011 =C3=A0 13:40 -0500, David Miller a =C3=
=A9crit :

> Yes, for non-SG this always was technically possible.
>=20

Yes this can, I reproduced it very easily.

I find this hard to believe...

[ 2179.697991] ------------[ cut here ]------------
[ 2179.698000] WARNING: at net/ipv4/tcp_output.c:850 tcp_transmit_skb+0=
x846/0x8f0()
[ 2179.698001] Hardware name: ProLiant BL460c G6
[ 2179.698011] Pid: 0, comm: swapper Tainted: G        W    3.2.0-rc2+ =
#187
[ 2179.698012] Call Trace:
[ 2179.698014]  <IRQ>  [<ffffffff8104715f>] warn_slowpath_common+0x7f/0=
xc0
[ 2179.698020]  [<ffffffff810471ba>] warn_slowpath_null+0x1a/0x20
[ 2179.698022]  [<ffffffff815d8386>] tcp_transmit_skb+0x846/0x8f0
[ 2179.698025]  [<ffffffff815d9621>] tcp_retransmit_skb+0x1a1/0x5f0
[ 2179.698027]  [<ffffffff815daf5d>] tcp_retransmit_timer+0x1bd/0x640
[ 2179.698030]  [<ffffffff815db578>] tcp_write_timer+0x198/0x200
[ 2179.698034]  [<ffffffff810579bf>] run_timer_softirq+0x12f/0x3e0
[ 2179.698039]  [<ffffffff81295924>] ? timerqueue_add+0x74/0xc0
[ 2179.698041]  [<ffffffff815db3e0>] ? tcp_retransmit_timer+0x640/0x640
[ 2179.698045]  [<ffffffff810753b5>] ? ktime_get+0x65/0xe0
[ 2179.698047]  [<ffffffff8104e929>] __do_softirq+0xa9/0x240
[ 2179.698050]  [<ffffffff81075b76>] ? do_timer+0x2b6/0x480
[ 2179.698053]  [<ffffffff8106fb90>] ? hrtimer_interrupt+0x130/0x220
[ 2179.698057]  [<ffffffff816d526c>] call_softirq+0x1c/0x30
[ 2179.698061]  [<ffffffff81004115>] do_softirq+0x55/0x90
[ 2179.698063]  [<ffffffff8104edde>] irq_exit+0x9e/0xc0
[ 2179.698066]  [<ffffffff816d5a3e>] smp_apic_timer_interrupt+0x6e/0x99
[ 2179.698068]  [<ffffffff816d3d8b>] apic_timer_interrupt+0x6b/0x70



diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 58f69ac..92ce7c3 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -847,6 +847,7 @@ static int tcp_transmit_skb(struct sock *sk, struct=
 sk_buff *skb, int clone_it,
=20
 	/* Build TCP header and checksum it. */
 	th =3D tcp_hdr(skb);
+	WARN_ON((((unsigned long)th) & 3) !=3D 0);
 	th->source		=3D inet->inet_sport;
 	th->dest		=3D inet->inet_dport;
 	th->seq			=3D htonl(tcb->seq);
