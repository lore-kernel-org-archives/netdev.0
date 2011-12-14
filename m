From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] net: do not pass vlan pkts to real dev pkt handler also
Date: Wed, 14 Dec 2011 20:52:38 +0100
Message-ID: <4EE8FE86.90009@gmail.com>
References: <20111212221923.5356.43629.stgit@vifc.jf.intel.com> <20111212225622.GA7083@minipsycho> <1323738532.8333.7.camel@vi> <20111213142114.GB2702@minipsycho> <1323796263.8333.20.camel@vi> <20111213214537.GC2702@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vasu Dev <vasu.dev@linux.intel.com>, Vasu Dev <vasu.dev@intel.com>,
	netdev@vger.kernel.org, devel@open-fcoe.org, eric.dumazet@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:34781 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755196Ab1LNTw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 14:52:29 -0500
Received: by eaaj10 with SMTP id j10so1161308eaa.19
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2011 11:52:28 -0800 (PST)
In-Reply-To: <20111213214537.GC2702@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/12/2011 22:45, Jiri Pirko a =E9crit :
> Tue, Dec 13, 2011 at 06:11:03PM CET, vasu.dev@linux.intel.com wrote:
>> On Tue, 2011-12-13 at 15:21 +0100, Jiri Pirko wrote:
>>> Tue, Dec 13, 2011 at 02:08:52AM CET, vasu.dev@linux.intel.com wrote=
:
>>>> On Mon, 2011-12-12 at 23:56 +0100, Jiri Pirko wrote:
>>>>> Mon, Dec 12, 2011 at 11:19:23PM CET, vasu.dev@intel.com wrote:
>>>>>> The orig_dev has to be updated before going another round
>>>>>> for vlan pkts, otherwise currently unmodified real orig_dev
>>>>>> causes vlan pkt delivered to real orig_dev also.
>>>>>>
>>>>>> The fcoe stack doesn't expects its vlan pkts on real dev
>>>>>> and it causes crash in fcoe stack.
>>>>>
>>>>> Could you please provide more info on where exactly it would cras=
h and
>>>>> why?
>>>>
>>>> Its in fcoe stack due to its fip rx skb list getting corrupt as sa=
me skb
>>>> instance getting queued twice without being cloned, though list wa=
s well
>>>> protected by its spin lock, it was queued on its two fcoe instance=
s, one
>>>> on real dev and other on its vlan.
>>>>
>>>> I could also handle this gracefully in fcoe stack by cloning but a=
ny
>>>> case netdev should not forward vlan pkt to its read dev pkt handle=
r also
>>>> and that is getting fixed with this patch, so patch will restore
>>>> orig_dev uses for *only* vlan pkts as it was with recursive
>>>> __netif_receive_skb calling prior to commit 0dfe178.
>>>
>>>
>>> I do not see into fcoe code, but wouldn't it be good to do skb
>>> skb_share_check in fcoe_ctlr_recv? I suppose that would solve your
>>> problem and looks legal to me.
>>>
>>
>> Yes that will fix along with dropping vlan pkts on real dev, so some
>> additional checking for dropping also. In fact that is what I meant =
in
>> my last response by "I could also handle this gracefully in fcoe sta=
ck
>> by cloning" as skb_share_check() does that conditionally.
>>
>> But as far as this patch goes, are you okay with the fix to not forw=
ard
>> vlan pkt on real dev pkt handler ? I think this is required regardle=
ss
>> of fcoe stack fixing for shared skb since otherwise all upper layers=
 of
>> real dev pkt handler has to handle with un-expected vlan pkts also.
>
> I think that's what orig_dev is destined for. To provide a possiblili=
ty
> to do this. I would like to leave that as it is.

I agree with Jiri.

If a protocol handler is registered on a particular device (instead of =
NULL), then the handler will=20
receive whatever is received on this device. This is true for bridge, f=
or bonding and probably for=20
all other "stackable" devices. I don't see any reason to handle it in a=
 different way for vlan.

	Nicolas.
