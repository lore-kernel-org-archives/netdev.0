From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [patch net-next 5/8] Introduce sample tc action
Date: Fri, 11 Nov 2016 08:28:50 +0000
Message-ID: <DB3PR05MB0764850867353EEB018FCA5FACBB0@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <1478776988-5400-1-git-send-email-jiri@resnulli.us>
 <1478776988-5400-6-git-send-email-jiri@resnulli.us>
 <5824CBFE.5030502@gmail.com> <5824CCB0.4090302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        Ido Schimmel <idosch@mellanox.com>,
        Elad Raz <eladr@mellanox.com>,
        Nogah Frankel <nogahf@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "geert+renesas@glider.be" <geert+renesas@glider.be>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "linux@roeck-us.net" <linux@roeck-us.net>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>
To: John Fastabend <john.fastabend@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0050.outbound.protection.outlook.com ([104.47.2.50]:1164
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S936119AbcKKInf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 03:43:35 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Yotam Gigi
>Sent: Thursday, November 10, 2016 9:59 PM
>To: 'John Fastabend' <john.fastabend@gmail.com>; Jiri Pirko <jiri@resnulli=
.us>;
>netdev@vger.kernel.org
>Cc: davem@davemloft.net; Ido Schimmel <idosch@mellanox.com>; Elad Raz
><eladr@mellanox.com>; Nogah Frankel <nogahf@mellanox.com>; Or Gerlitz
><ogerlitz@mellanox.com>; jhs@mojatatu.com; geert+renesas@glider.be;
>stephen@networkplumber.org; xiyou.wangcong@gmail.com; linux@roeck-us.net;
>roopa@cumulusnetworks.com
>Subject: RE: [patch net-next 5/8] Introduce sample tc action
>
>
>
>>-----Original Message-----
>>From: John Fastabend [mailto:john.fastabend@gmail.com]
>>Sent: Thursday, November 10, 2016 9:38 PM
>>To: Jiri Pirko <jiri@resnulli.us>; netdev@vger.kernel.org
>>Cc: davem@davemloft.net; Yotam Gigi <yotamg@mellanox.com>; Ido Schimmel
>><idosch@mellanox.com>; Elad Raz <eladr@mellanox.com>; Nogah Frankel
>><nogahf@mellanox.com>; Or Gerlitz <ogerlitz@mellanox.com>;
>>jhs@mojatatu.com; geert+renesas@glider.be; stephen@networkplumber.org;
>>xiyou.wangcong@gmail.com; linux@roeck-us.net; roopa@cumulusnetworks.com
>>Subject: Re: [patch net-next 5/8] Introduce sample tc action
>>
>>On 16-11-10 11:35 AM, John Fastabend wrote:
>>> On 16-11-10 03:23 AM, Jiri Pirko wrote:
>>>> From: Yotam Gigi <yotamg@mellanox.com>
>>>>
>>>> This action allow the user to sample traffic matched by tc classifier.
>>>> The sampling consists of choosing packets randomly, truncating them,
>>>> adding some informative metadata regarding the interface and the origi=
nal
>>>> packet size and mark them with specific mark, to allow further tc rule=
s to
>>>> match and process. The marked sample packets are then injected into th=
e
>>>> device ingress qdisc using netif_receive_skb.
>>>>
>>>> The packets metadata is packed using the ife encapsulation protocol, a=
nd
>>>> the outer packet's ethernet dest, source and eth_type, along with the
>>>> rate, mark and the optional truncation size can be configured from
>>>> userspace.
>>>>
>>>> Example:
>>>> To sample ingress traffic from interface eth1, and redirect the sample=
d
>>>> the sampled packets to interface dummy0, one may use the commands:
>>>>
>>>> tc qdisc add dev eth1 handle ffff: ingress
>>>>
>>>> tc filter add dev eth1 parent ffff: \
>>>> 	   matchall action sample rate 12 mark 17
>>>>
>>>> tc filter add parent ffff: dev eth1 protocol all \
>>>> 	   u32 match mark 17 0xff \
>>>> 	   action mirred egress redirect dev dummy0
>>>>
>>>> Where the first command adds an ingress qdisc and the second starts
>>>> sampling every 12'th packet on dev eth1 and marks the sampled packets =
with
>>>> 17. The third command catches the sampled packets, which are marked wi=
th
>>>> 17, and redirects them to dev dummy0.
>>>
>>> The sampling algorithm was not randomized based on the above commit
>>> log? It really needs to be for all the reasons Roopa mentioned earlier.
>>> Did I miss some email on why it didn't get implemented?
>>>
>>> Also there was an indication the already is actually implemented
>>> correctly so don't we need the hw/sw to behave the same. The whole
>>> argument about sw/hw parity, etc.
>>
>>sorry bit of a typo there corrected 2nd paragraph here...
>>
>>Also there was an indication the hardware is already implemented \
>>correctly so don't we need the hw/sw to behave the same. The argument
>>about sw/hw parity, etc.
>
>Our hardware currently does not support sampling with random behavior, so
>we did implement it in software too.
>
>But, the API is extensible and it is possible to add a random keyword to
>the tc action to allow random sampling. In that case, the keyword will be
>implemented in sw only and our driver will fail offloading it.
>

John, as a result of your question I realized that our hardware does do=20
randomized sampling that I was not aware of. I will use the extensibility o=
f
the API and implement a random keyword, that will be offloaded in our=20
hardware. Those changes will be sent on v2.

Eventually, your question was very relevant :) Thanks!

>>
>>>
>>>>
>>>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>>> ---
>>>
