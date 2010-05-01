From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Sat, 01 May 2010 08:14:02 +0200
Message-ID: <1272694442.2230.86.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>
	 <1272514176.2201.85.camel@edumazet-laptop> <1272540952.4258.161.camel@bigi>
	 <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
	 <1272545108.2222.65.camel@edumazet-laptop> <1272547061.4258.174.camel@bigi>
	 <1272547307.2222.83.camel@edumazet-laptop> <1272548258.4258.185.camel@bigi>
	 <1272548980.2222.87.camel@edumazet-laptop> <1272549408.4258.189.camel@bigi>
	 <1272573383.3969.8.camel@bigi>  <1272655814.3879.8.camel@bigi>
	 <1272660000.2230.4.camel@edumazet-laptop>  <1272672394.14499.1.camel@bigi>
	 <1272693424.2230.75.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:48554 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107Ab0EAGOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 02:14:10 -0400
Received: by bwz19 with SMTP id 19so483908bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 23:14:08 -0700 (PDT)
In-Reply-To: <1272693424.2230.75.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 01 mai 2010 =C3=A0 07:57 +0200, Eric Dumazet a =C3=A9crit :
> Le vendredi 30 avril 2010 =C3=A0 20:06 -0400, jamal a =C3=A9crit :
>=20
> > Yes, Nehalem.=20
> > RPS off is better (~700Kpp) than RPS on(~650kpps). Are you seeing t=
he
> > same trend on the old hardware?
> >=20
>=20
> Of course not ! Or else RPS would be useless :(
>=20
> I changed your program a bit to use EV_PERSIST, (to avoid epoll_ctl()
> overhead for each packet...)
>=20
> RPS off : 220.000 pps=20
>=20
> RPS on (ee mask) : 700.000 pps  (with a slightly modified tg3 driver)
> 96% of delivered packets

BTW, using ee mask, cpu4 is not used at _all_, even for the user
threads. Scheduler does a bad job IMHO.

Using fe mask, I get all packets (sent at 733311pps by my pktgen
machine), and my CPU0 even has idle time !!!

Limit seems to be around 800.000 pps

-----------------------------------------------------------------------=
-------------------------------------------------
   PerfTop:    5616 irqs/sec  kernel:93.9% [1000Hz cycles],  (all, 8 CP=
Us)
-----------------------------------------------------------------------=
-------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ _______

             3492.00  6.2% __slab_free                 vmlinux
             2334.00  4.2% _raw_spin_lock              vmlinux
             2314.00  4.1% _raw_spin_lock_irqsave      vmlinux
             1807.00  3.2% ip_rcv                      vmlinux
             1605.00  2.9% schedule                    vmlinux
             1474.00  2.6% __netif_receive_skb         vmlinux
             1464.00  2.6% kfree                       vmlinux
             1405.00  2.5% ip_route_input              vmlinux
             1318.00  2.4% __copy_to_user_ll           vmlinux
             1214.00  2.2% __alloc_skb                 vmlinux
             1160.00  2.1% nf_hook_slow                vmlinux
             1020.00  1.8% eth_type_trans              vmlinux
              860.00  1.5% sched_clock_local           vmlinux
              775.00  1.4% read_tsc                    vmlinux
              773.00  1.4% ipt_do_table                vmlinux
              766.00  1.4% _raw_spin_unlock_irqrestore vmlinux
              748.00  1.3% sock_recv_ts_and_drops      vmlinux
              747.00  1.3% ia32_sysenter_target        vmlinux
              740.00  1.3% select_nohz_load_balancer   vmlinux
              644.00  1.2% __kmalloc_track_caller      vmlinux
              596.00  1.1% tg3_read32                  vmlinux
              566.00  1.0% __udp4_lib_lookup           vmlinux




