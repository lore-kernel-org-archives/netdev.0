From: Chunhui He <hchunhui@mail.ustc.edu.cn>
Subject: Re: [PATCH] net: neigh: disallow state transition DELAY->STALE in
 neigh_update()
Date: Mon, 25 Jul 2016 08:13:49 +0000 (UTC)
Message-ID: <20160725.081349.445701096084716570.hchunhui@mail.ustc.edu.cn>
References: <alpine.LFD.2.11.1607220954060.1764@ja.home.ssi.bg>
	<20160722.124757.283248020246505940.hchunhui@mail.ustc.edu.cn>
	<e0d3e238-312e-a0e2-9501-29beb7e2ef27@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, davem@davemloft.net, dsa@cumulusnetworks.com,
	nicolas.dichtel@6wind.com, roopa@cumulusnetworks.com,
	rshearma@brocade.com, dbarroso@fastly.com, martinbj2008@gmail.com,
	rick.jones2@hp.com, koct9i@gmail.com, edumazet@google.com,
	tgraf@suug.ch, ebiederm@xmission.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hideaki.yoshifuji@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ustc.edu.cn ([202.38.64.46]:44303 "EHLO ustc.edu.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751007AbcGYIOX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jul 2016 04:14:23 -0400
In-Reply-To: <e0d3e238-312e-a0e2-9501-29beb7e2ef27@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
On Mon, 25 Jul 2016 14:20:29 +0900, YOSHIFUJI Hideaki/吉藤英明 <hideaki.yoshifuji@miraclelinux.com> wrote:
> Hi,
> 
> Chunhui He wrote:
>> Hi,
>> 
>> On Fri, 22 Jul 2016 10:20:01 +0300 (EEST), Julian Anastasov <ja@ssi.bg> wrote:
>>>
>>> 	Hello,
>>>
>>> On Thu, 21 Jul 2016, Chunhui He wrote:
>>>
>>>> If neigh entry was CONNECTED and address is not changed, and if new state is
>>>> STALE, entry state will not change. Because DELAY is not in CONNECTED, it's
>>>> possible to change state from DELAY to STALE.
>>>>
>>>> That is bad. Consider a host in IPv4 nerwork, a neigh entry in STALE state
>>>> is referenced to send packets, so goes to DELAY state. If the entry is not
>>>> confirmed by upper layer, it goes to PROBE state, and sends ARP request.
>>>> The neigh host sends ARP reply, then the entry goes to REACHABLE state.
>>>> But the entry state may be reseted to STALE by broadcast ARP packets, before
>>>> the entry goes to PROBE state. So it's possible that the entry will never go
>>>> to REACHABLE state, without external confirmation.
>>>>
>>>> In my case, the gateway refuses to send unicast packets to me, before it sees
>>>> my ARP request. So it's critical to enter REACHABLE state by sending ARP
>>>> request, but not by external confirmation.
>>>>
>>>> This fixes neigh_update() not to change to STALE if old state is CONNECTED or
>>>> DELAY.
>>>>
>>>> Signed-off-by: Chunhui He <hchunhui@mail.ustc.edu.cn>
>>>> ---
>>>>  net/core/neighbour.c | 2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
>>>> index 510cd62..29429eb 100644
>>>> --- a/net/core/neighbour.c
>>>> +++ b/net/core/neighbour.c
>>>> @@ -1152,7 +1152,7 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
>>>>  		} else {
>>>>  			if (lladdr == neigh->ha && new == NUD_STALE &&
>>>>  			    ((flags & NEIGH_UPDATE_F_WEAK_OVERRIDE) ||
>>>> -			     (old & NUD_CONNECTED))
>>>> +			     (old & (NUD_CONNECTED | NUD_DELAY)))
>>>>  			    )
>>>>  				new = old;
>>>>  		}
>>>
>>> 	You change looks correct to me. But this place
>>> has more problems. There is no good reason to set NUD_STALE
>>> for any state that is NUD_VALID if address is not changed.
>>> This matches perfectly the comment above this code:
>>> NUD_STALE should change a NUD_VALID state only when
>>> address changes. It also means that IPv6 does not need
>>> to provide NEIGH_UPDATE_F_WEAK_OVERRIDE anymore when
>>> NEIGH_UPDATE_F_OVERRIDE is also present.
>>>
>> 
>> The NEIGH_UPDATE_F_WEAK_OVERRIDE is confusing to me, so I choose not to deal
>> with the flag.
> 
> IPv6 depends on WEAK_OVERRIDE.  Please do not change.
>

It seems like IPv6 always sets WEAK_OVERRIDE.

As Julian said, maybe there is no good reason to set NUD_STALE for any state
that is NUD_VALID if address is not changed, even WEAK_OVERRIDE is not set.
So we may eliminate WEAK_OVERRIDE in that branch.

I think this change should not break IPv6.

>> 
>>> 	By this way the state machine can continue with
>>> the resolving: NUD_STALE -> NUD_DELAY (traffic) ->
>>> NUD_PROBE (retries) -> NUD_REACHABLE (unicast reply)
>>> while the address is not changed. Your change covers only
>>> NUD_DELAY, not NUD_PROBE, so it is better to allow more
>>> retries to send. We should not give up until success (NUD_REACHABLE).
>>>
>> 
>> I have thought about this.
>> The origin code allows NUD_DELAY -> NUD_STALE and NUD_PROBE -> NUD_STALE.
>> This part was imported to kernel since v2.1.79, I don't know clearly why it
>> allows that.
>> 
>> My analysis:
>> (1) As shown in my previous mail, NUD_DELAY -> NUD_STALE may cause "dead loop",
>> so it should be fixed.
>> 
>> (2) But NUD_PROBE -> NUD_STALE is acceptable, because in NUD_PROBE, ARP request
>> has been sent, it is sufficient to break the "dead loop".
>> More attempts are accomplished by the following sequence:
>> NUD_STALE --> NUD_DELAY -(sent req)-> NUD_PROBE -(reset by neigh_update())->
>> NUD_STALE --> NUD_DELAY -(send req again)-> ... -->
>> NUD_REACHABLE
>> 
>> 
>> But I also agree your change.
>> 
>>> 	Second problem: NEIGH_UPDATE_F_WEAK_OVERRIDE has no
>>> priority over NEIGH_UPDATE_F_ADMIN. For example, now I can not
>>> change from NUD_PERMANENT to NUD_STALE:
>>>
>>> # ip neigh add 192.168.168.111 lladdr 00:11:22:33:44:55 nud perm dev wlan0
>>> # ip neigh show to 192.168.168.111
>>> 192.168.168.111 dev wlan0 lladdr 00:11:22:33:44:55 PERMANENT
>>> # ip neigh change 192.168.168.111 lladdr 00:11:22:33:44:55 nud stale dev wlan0
>>> # ip neigh show to 192.168.168.111
>>> 192.168.168.111 dev wlan0 lladdr 00:11:22:33:44:55 PERMANENT
>>>
>>> 	IMHO, here is how this place should look:
>>>
>>> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
>>> index 5cdc62a..2b1cb91 100644
>>> --- a/net/core/neighbour.c
>>> +++ b/net/core/neighbour.c
>>> @@ -1151,10 +1151,8 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
>>>  				goto out;
>>>  		} else {
>>>  			if (lladdr == neigh->ha && new == NUD_STALE &&
>>> -			    ((flags & NEIGH_UPDATE_F_WEAK_OVERRIDE) ||
>>> -			     (old & NUD_CONNECTED))
>>> -			    )
>>> -				new = old;
>>> +			    !(flags & NEIGH_UPDATE_F_ADMIN))
>>> +				goto out;
>>>  		}
>>>  	}
>>>
>>> 	Any thoughts?
>>>  
>>> Regards
>>>
>>> --
>>> Julian Anastasov <ja@ssi.bg>
>> 
>> Regards,
>> Chunhui He
>> 
> 
> -- 
> 吉藤英明 <hideaki.yoshifuji@miraclelinux.com>
> ミラクル・リナックス株式会社 技術本部 サポート部

Regards,
Chunhui
