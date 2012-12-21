From: Yury Stankevich <urykhy@gmail.com>
Subject: Re: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Fri, 21 Dec 2012 18:14:25 +0400
Message-ID: <50D46EC1.2040608@gmail.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com> <50CDFB6A.3090806@mojatatu.com> <50CE1A04.1000405@mojatatu.com> <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr> <50CE3203.9080007@mojatatu.com> <50CF1071.1050405@mojatatu.com> <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com> <50D06177.2090905@mojatatu.com> <CAASe=fR6Hm2dxp=1wDchtrzqnaH6qacHpg2wrsqLfmGpPbQ9Fg@mail.gmail.com> <50D1A8A7.1090002@mojatatu.com> <50D1AB7E.5060000@mojatatu.com> <50D2D229.6040802@gmail.com> <50D305FD.7000901@mojatatu.com> <50D327CD.3050904@gmail.com> <50D45E25.7050703@mojatatu.com> <50D46060.2070308@gmail.com> <50D4692
 8.9070809@mojatatu.com>
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
Received: from mail-la0-f44.google.com ([209.85.215.44]:55122 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121Ab2LUOOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 09:14:32 -0500
In-Reply-To: <50D46928.9070809@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


well.
let me describe whole picture i want to achieve

1. use htb/sfq on ingress.

i got a traffic, and use few u32 filters to direct it to 3 flows,
priority, interactive, and bulk.
as http normally pass to interactive flow, i want to move long donwload=
s
to the bulk one.

how i trying to find these downloads:

iptables -t mangle -A POSTROUTING -p tcp --dport 80 -m connmark --mark =
0
-m connbytes --connbytes 204800: --connbytes-dir both --connbytes-mode
bytes -j CONNMARK --set-mark 0xa
so, http connection where more than 200K downloaded, must got a
connection mark.

since ingress traffic hits qos before netfilter,
i use xt action, to copy connection mark, to a packet.
(action xt -j CONNMARK --restore-mark )
from this moment, i expect packet must have a restored mark

after this, i can use high priority tc filter .. handle 0xa fw flowid 1=
:102
to direct packet with mark 0xa to 1:102 flow (bulk).

now about a problem.

1. i run http download, once i get 200K - i can see that rule in
POSTROUTING is triggered and connection mark is installed (iptables -L
-n -v mangle -- can show number of packets matched by rule)

2. i see to tc stats for my flows, and i see, that packets still going
to interactive flow, not bulk as i expect.

3. from tc -s filter show dev usb0 parent ffff:
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

i can see that packets must reach xt action.

4. lets try to check packets mark with iptables,
if mark restored by xt action - i must be able to match it in preroutin=
g
rule.
iptables -t mangle -A PREROUTING -m mark --mark 0xa -j NFLOG --nflog-gr=
oup 1

but this rule not macthesd - so, no mark is restored by xt action.

maybe im completely wrong here, and such mode can't work for some reaso=
n ?

21.12.2012 17:50, Jamal Hadi Salim =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 12-12-21 08:13 AM, Yury Stankevich wrote:
>=20
>> sure,
>> i use it ingress,
>> so, i need to use tc xt action
>> to get mark on the packet, before filter on ifb will run.
>=20
> Ok. So does ifb see it?
>=20
>> prerouting rule, in turn, used to test if mark was actually restored=
=2E
>=20
> No experience with connmark, but - in order to restore something has
> to store it, correct?
>=20
>> in practice:
>> 1. prerouting rule - is not fired. so, no packets with mark was seen=
=2E
>> 2. filter on ifb - do not pass traffic to flow configured.
>> looks like `CONNMARK --restore` is not really called.
>>
>=20
> My suspicion is that it is not set to begin with...
>=20
> cheers,
> jamal
>=20


--=20
Linux registered user #402966 // pub 1024D/E99AF373 <pgp.mit.edu>
