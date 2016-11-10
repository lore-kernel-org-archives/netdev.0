From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [patch net-next 5/8] Introduce sample tc action
Date: Thu, 10 Nov 2016 19:58:33 +0000
Message-ID: <AM3PR05MB07594EA6AE3C0D4C71FEA155ACB80@AM3PR05MB0759.eurprd05.prod.outlook.com>
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
Received: from mail-db5eur01on0071.outbound.protection.outlook.com ([104.47.2.71]:5920
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S965272AbcKKBaN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 20:30:13 -0500
In-Reply-To: <5824CCB0.4090302@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: John Fastabend [mailto:john.fastabend@gmail.com]
>Sent: Thursday, November 10, 2016 9:38 PM
>To: Jiri Pirko <jiri@resnulli.us>; netdev@vger.kernel.org
>Cc: davem@davemloft.net; Yotam Gigi <yotamg@mellanox.com>; Ido Schimmel
><idosch@mellanox.com>; Elad Raz <eladr@mellanox.com>; Nogah Frankel
><nogahf@mellanox.com>; Or Gerlitz <ogerlitz@mellanox.com>;
>jhs@mojatatu.com; geert+renesas@glider.be; stephen@networkplumber.org;
>xiyou.wangcong@gmail.com; linux@roeck-us.net; roopa@cumulusnetworks.com
>Subject: Re: [patch net-next 5/8] Introduce sample tc action
>
>On 16-11-10 11:35 AM, John Fastabend wrote:
>> On 16-11-10 03:23 AM, Jiri Pirko wrote:
>>> From: Yotam Gigi <yotamg@mellanox.com>
>>>
>>> This action allow the user to sample traffic matched by tc classifier.
>>> The sampling consists of choosing packets randomly, truncating them,
>>> adding some informative metadata regarding the interface and the origin=
al
>>> packet size and mark them with specific mark, to allow further tc rules=
 to
>>> match and process. The marked sample packets are then injected into the
>>> device ingress qdisc using netif_receive_skb.
>>>
>>> The packets metadata is packed using the ife encapsulation protocol, an=
d
>>> the outer packet's ethernet dest, source and eth_type, along with the
>>> rate, mark and the optional truncation size can be configured from
>>> userspace.
>>>
>>> Example:
>>> To sample ingress traffic from interface eth1, and redirect the sampled
>>> the sampled packets to interface dummy0, one may use the commands:
>>>
>>> tc qdisc add dev eth1 handle ffff: ingress
>>>
>>> tc filter add dev eth1 parent ffff: \
>>> 	   matchall action sample rate 12 mark 17
>>>
>>> tc filter add parent ffff: dev eth1 protocol all \
>>> 	   u32 match mark 17 0xff \
>>> 	   action mirred egress redirect dev dummy0
>>>
>>> Where the first command adds an ingress qdisc and the second starts
>>> sampling every 12'th packet on dev eth1 and marks the sampled packets w=
ith
>>> 17. The third command catches the sampled packets, which are marked wit=
h
>>> 17, and redirects them to dev dummy0.
>>
>> The sampling algorithm was not randomized based on the above commit
>> log? It really needs to be for all the reasons Roopa mentioned earlier.
>> Did I miss some email on why it didn't get implemented?
>>
>> Also there was an indication the already is actually implemented
>> correctly so don't we need the hw/sw to behave the same. The whole
>> argument about sw/hw parity, etc.
>
>sorry bit of a typo there corrected 2nd paragraph here...
>
>Also there was an indication the hardware is already implemented \
>correctly so don't we need the hw/sw to behave the same. The argument
>about sw/hw parity, etc.

Our hardware currently does not support sampling with random behavior, so=20
we did implement it in software too.=20

But, the API is extensible and it is possible to add a random keyword to=20
the tc action to allow random sampling. In that case, the keyword will be
implemented in sw only and our driver will fail offloading it.

>
>>
>>>
>>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>> ---
>>
