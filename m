From: Yury Stankevich <urykhy@gmail.com>
Subject: Re: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Thu, 20 Dec 2012 18:59:25 +0400
Message-ID: <50D327CD.3050904@gmail.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com> <50CDFB6A.3090806@mojatatu.com> <50CE1A04.1000405@mojatatu.com> <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr> <50CE3203.9080007@mojatatu.com> <50CF1071.1050405@mojatatu.com> <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com> <50D06177.2090905@mojatatu.com> <CAASe=fR6Hm2dxp=1wDchtrzqnaH6qacHpg2wrsqLfmGpPbQ9Fg@mail.gmail.com> <50D1A8A7.1090002@mojatatu.com> <50D1AB7E.5060000@mojatatu.com> <50D2D229.6040802@gmail.com> <50D305FD.7000901@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hasan Chowdhury <shemonc@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jan Engelhardt <jengelh@inai.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:56467 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917Ab2LTPZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 10:25:00 -0500
In-Reply-To: <50D305FD.7000901@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

interesting,

#tc -s filter show dev usb0 parent ffff:
filter protocol ip pref 49152 u32
filter protocol ip pref 49152 u32 fh 800: ht divisor 1
filter protocol ip pref 49152 u32 fh 800::800 order 2048 key ht 800 bkt
0 terminal flowid ???  (rule hit 707 success 707)
  match 00000000/00000000 at 0 (success 707 )
	action order 1: tablename: mangle  hook: NF_IP_PRE_ROUTING
	target  CONNMARK restore
	index 5 ref 1 bind 1 installed 394 sec used 11 sec
	Action statistics:
	Sent 783783 bytes 707 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

	action order 2: mirred (Egress Redirect to device ifb0) stolen
 	index 5 ref 1 bind 1 installed 394 sec used 11 sec
 	Action statistics:
	Sent 783783 bytes 707 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

so, looks like packets was sent to CONNMARK target.

but...
i make a iptables rule to log packets with 0xa mark:

Chain PREROUTING (policy ACCEPT 1308 packets, 848K bytes)
 pkts bytes target     prot opt in     out     source
destination
    0     0 NFLOG      all  --  *      *       0.0.0.0/0
0.0.0.0/0            mark match 0xa nflog-group 1

Chain POSTROUTING (policy ACCEPT 1240 packets, 550K bytes)
 pkts bytes target     prot opt in     out     source
destination
    1    40 CONNMARK   tcp  --  *      *       0.0.0.0/0
0.0.0.0/0            tcp dpt:80 connmark match  0x0 connbytes 204800
connbytes mode bytes connbytes direction both CONNMARK set 0xa

idea is:
i run downloading, rule from POSTROUTING must fire if i download more
than ~200K,
tc filter call to CONNMARK restore, must restore mark (0xa) for packets
belong to this connection.
so i expect, that PREROUTING rule must notice the restored mark, but it
doesn't.
maybe i miss something ?


20.12.2012 16:35, Jamal Hadi Salim =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>=20
> Could be your setup. I didnt do a lot of testing but
> from my notes (running different kernel at the moment):
>=20
> #try to point to everything (no iptables setup)
> tc filter add dev eth0 parent ffff: protocol ip u32 match u32 0 0 flo=
wid
> 23:23 action xt -j CONNMARK --restore-mark
> #let it run for a 1 sec then display with
> tc -s filter show dev eth0 parent ffff:
>=20
> ----
> filter protocol ip pref 49152 u32
> filter protocol ip pref 49152 u32 fh 800: ht divisor 1
> filter protocol ip pref 49152 u32 fh 800::800 order 2048 key ht 800 b=
kt
> 0 flowid 23:23
>   match 00000000/00000000 at 0
>     action order 1: tablename: mangle  hook: NF_IP_PRE_ROUTING
>     target  CONNMARK restore
>     index 1 ref 1 bind 1 installed 3 sec used 1 sec
>     Action statistics:
>     Sent 280 bytes 4 pkt (dropped 0, overlimits 0 requeues 0)
>     backlog 0b 0p requeues 0
> ----
>=20
> cheers,
> jamal
>=20
> On 12-12-20 03:54 AM, Yury Stankevich wrote:
>> 19.12.2012 15:56, Jamal Hadi Salim =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> Hasan/Yury, if you test this please use the latest iproute2 with on=
ly
>>> the first patch I posted (originally from Hasan). Hasan please use =
that
>>> patch not your version - if theres anything wrong we can find out s=
ooner
>>> before the patch becomes final.
>>
>> Hello,
>> 3.7.1 kernel with 3.7.0 iproute,
>> patch-xt, xt-p1 + linkage fix was applyed
>> command successfully performed, but actually doesn't work.
>>
>> command:
>> tc filter add dev $dev parent ffff: protocol ip u32 match u32 0 0 \
>>              action xt -j CONNMARK --restore-mark \
>>              action mirred egress redirect dev ifb0
>> then i use filter:
>>
>> tc filter add dev ifb0 protocol ip parent 1: prio 2 handle 0xa fw fl=
owid
>> 1:102
>>
>> iptables line:
>> iptable -t mangle -A POSTROUTING -p tcp --dport 80 -m connmark --mar=
k 0
>> -m connbytes --connbytes 204800: --connbytes-dir both --connbytes-mo=
de
>> bytes -j CONNMARK --set-mark 0xa
>>
>> once i run a test to download 300K file,
>> from iptables counters i can see that rule in POSTROUTING is trigger=
ed,
>> but from `tc -s qdisc show dev ifb0` i see that no packets was sent =
to
>> 1:102 flow.
>>
>> btw,
>> tc -p -s filter show dev ifb0 parent 1:
>> do not show stats `(rule hit 416 success 0)` for this (filter protoc=
ol
>> ip pref 2 fw handle 0xa classid 1:102) rule.
>>
>>
>>
>=20


--=20
Linux registered user #402966 // pub 1024D/E99AF373 <pgp.mit.edu>
