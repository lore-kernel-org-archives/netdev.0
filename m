From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next V8] net: introduce ethernet teaming device
Date: Tue, 15 Nov 2011 19:35:40 +0100
Message-ID: <1321382140.2856.38.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1321085808-6871-1-git-send-email-jpirko@redhat.com>
	 <4EC160B4.2040709@hp.com> <20111115015616.GA25132@gospo.rdu.redhat.com>
	 <4EC29FE7.70904@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, tgraf@infradead.org,
	ebiederm@xmission.com, mirqus@gmail.com, kaber@trash.net,
	greearb@candelatech.com, jesse@nicira.com, fbl@redhat.com,
	benjamin.poirier@gmail.com, jzupka@redhat.com, ivecera@redhat.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65045 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752161Ab1KOSfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 13:35:46 -0500
Received: by wwe5 with SMTP id 5so6573877wwe.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 10:35:44 -0800 (PST)
In-Reply-To: <4EC29FE7.70904@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 novembre 2011 =C3=A0 09:22 -0800, Rick Jones a =C3=A9crit :
> > On most modern systems I suspect there will be little to no differe=
nce
> > between bonding RX peformance and team performance.
> >
> > If there is any now, I suspect team and bond performance to be simi=
lar
> > by the time team has to account for the corner-cases bonding has al=
ready
> > resolved.  :-)
> >
> > Benchmarks may prove otherwise, but I've yet to see Jiri produce
> > anything.  My initial testing doesn't demonstrate any measureable
> > differences with 1Gbps interfaces on a multi-core, multi-socket sys=
tem.
>=20
> I wouldn't expect much difference in terms of bandwidth, I was thinki=
ng=20
> the demonstration would be made in the area of service demand (CPU=20
> consumed per unit work) and perhaps aggregate packets per second.

Well,

bonding is a NETIF_F_LLTX driver, but uses following rwlock in xmit
path :

read_lock(&bond->curr_slave_lock);
=2E..
read_unlock(&bond->curr_slave_lock);

Two atomic operations on a contended cache line.

On a 16 cpu machine, here is some "perf stat" data of such workload :
(each thread doing 10.000.000 atomic_inc(&somesharedvar) )

# perf stat ./atomic 16

 Performance counter stats for './atomic 16':

      48016,104204 task-clock                #   15,566 CPUs utilized  =
       =20
               555 context-switches          #    0,000 M/sec          =
       =20
                15 CPU-migrations            #    0,000 M/sec          =
       =20
               175 page-faults               #    0,000 M/sec          =
       =20
   121 669 943 013 cycles                    #    2,534 GHz            =
       =20
   121 321 455 748 stalled-cycles-frontend   #   99,71% frontend cycles=
 idle  =20
   103 375 494 290 stalled-cycles-backend    #   84,96% backend  cycles=
 idle  =20
       611 624 619 instructions              #    0,01  insns per cycle=
       =20
                                             #   198,36  stalled cycles=
 per insn
       184 530 032 branches                  #    3,843 M/sec          =
       =20
           581 513 branch-misses             #    0,32% of all branches=
       =20

       3,084672937 seconds time elapsed

Cost per 'read_lock/read_unlock pair' : at least 616 ns

While on one cpu only :

# perf stat ./atomic 1

 Performance counter stats for './atomic 1':

         83,475050 task-clock                #    0,998 CPUs utilized  =
       =20
                 3 context-switches          #    0,000 M/sec          =
       =20
                 1 CPU-migrations            #    0,000 M/sec          =
       =20
               144 page-faults               #    0,002 M/sec          =
       =20
       211 508 600 cycles                    #    2,534 GHz            =
       =20
       193 502 947 stalled-cycles-frontend   #   91,49% frontend cycles=
 idle  =20
       124 428 400 stalled-cycles-backend    #   58,83% backend  cycles=
 idle  =20
        30 870 434 instructions              #    0,15  insns per cycle=
       =20
                                             #    6,27  stalled cycles =
per insn
        10 163 364 branches                  #  121,753 M/sec          =
       =20
             9 633 branch-misses             #    0,09% of all branches=
       =20

       0,083679928 seconds time elapsed

Cost per 'read_lock/read_unlock pair' : 16 ns


Of course, bonding could be changed to use RCU as well,
if someone feels the need.

But teaming was designed to be RCU ready from the beginning.

exi
