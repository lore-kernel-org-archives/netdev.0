From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH v2] net: fix a double free issue for neighbour entry
Date: Wed, 20 May 2015 17:22:39 +0800
Message-ID: <555C525F.1040006@windriver.com>
References: <1432085113-25063-1-git-send-email-ying.xue@windriver.com> <alpine.LFD.2.11.1505201003150.1557@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>, <alexei@purestorage.com>,
	<joern@purestorage.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39336 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbbETJYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 05:24:16 -0400
In-Reply-To: <alpine.LFD.2.11.1505201003150.1557@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/2015 03:35 PM, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 20 May 2015, Ying Xue wrote:
> 
>> --- a/net/core/neighbour.c
>> +++ b/net/core/neighbour.c
>> @@ -958,6 +958,9 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
>>  	if (neigh->nud_state & (NUD_CONNECTED | NUD_DELAY | NUD_PROBE))
>>  		goto out_unlock_bh;
>>  
>> +	if (neigh->dead)
>> +		goto out_unlock_bh;
>> +
> 
> 	Returning 0 in all cases is wrong.

Good catch!
Yes, you are right. We should return 1 especially when neigh->dead == 1.

 May be you can goto
> to another new label where nud_state check can allow valid
> address to be used. See my idea:
> 
> http://marc.info/?l=linux-netdev&m=142816363503402&w=2
> 
> 	I.e. return 0 for NUD_STALE, drop skb and return 1
> otherwise.
> 
>>  	if (!(neigh->nud_state & (NUD_STALE | NUD_INCOMPLETE))) {
>>  		if (NEIGH_VAR(neigh->parms, MCAST_PROBES) +
>>  		    NEIGH_VAR(neigh->parms, APP_PROBES)) {
>> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
>> index c65b93a..5889774 100644
>> --- a/net/ipv4/ip_output.c
>> +++ b/net/ipv4/ip_output.c
>> @@ -200,7 +200,7 @@ static inline int ip_finish_output2(struct sock *sk, struct sk_buff *skb)
>>  	rcu_read_lock_bh();
>>  	nexthop = (__force u32) rt_nexthop(rt, ip_hdr(skb)->daddr);
>>  	neigh = __ipv4_neigh_lookup_noref(dev, nexthop);
>> -	if (unlikely(!neigh))
>> +	if (unlikely(!neigh || !atomic_read(&neigh->refcnt)))
> 
> 	You should forget about refcnt. kfree_rcu in neigh_destroy
> will not free neigh while RCU readers are present. Still,
> neigh_destroy runs in parallel with readers and I hope they can
> use the stored address safely.

I know touching neigh entry in ip_finish_output2() without identifying if
atomic_read(&neigh->refcnt)==0 under RCU lock is absolutely safe for us. But in
some extent we can say the issue is not much a closely relationship to RCU lock.
The key problem for us is how efficiently we can prevent neigh refcnt from being
increased from 0 to 1 on the path of dst_neigh_output().

Regards,
Ying

 I mean, neigh_event_send allowing
> neigh_resolve_output to use address in NUD_STALE state on dead=1
> by returning 0 and reaching the dev_queue_xmit call.
> 
> 	Still, another inefficiency remains: how can
> __neigh_event_send indicate to ip_finish_output2 that
> dead=1 entry is [to be] removed and new entry needs to
> be created. It seems the ->output method returns code
> but skb is freed in all cases. The result is that we
> drop single skb in such condition. But such optimization
> should not be part of this bugfix.
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
> 
