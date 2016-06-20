From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: rcu locking issue in mpls output code?
Date: Mon, 20 Jun 2016 09:19:05 -0600
Message-ID: <7d7097bc-ce10-d8e1-4a90-36045c7d2041@cumulusnetworks.com>
References: <20160620004546.GP20238@wantstofly.org>
 <8d325ab7-bc46-dd69-288a-571d56efc545@cumulusnetworks.com>
 <20160620063055.GR20238@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Robert Shearman <rshearma@brocade.com>, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:34502 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881AbcFTPTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 11:19:07 -0400
Received: by mail-io0-f179.google.com with SMTP id 5so133459514ioy.1
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 08:19:07 -0700 (PDT)
In-Reply-To: <20160620063055.GR20238@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/20/16 12:30 AM, Lennert Buytenhek wrote:
> On Sun, Jun 19, 2016 at 08:19:20PM -0600, David Ahern wrote:
>
>>> diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
>>> index fb31aa8..802956b 100644
>>> --- a/net/mpls/mpls_iptunnel.c
>>> +++ b/net/mpls/mpls_iptunnel.c
>>> @@ -105,12 +105,15 @@ static int mpls_output(struct net *net, struct sock *sk, struct sk_buff *skb)
>>>  		bos = false;
>>>  	}
>>>
>>> +	rcu_read_lock_bh();
>>>  	if (rt)
>>>  		err = neigh_xmit(NEIGH_ARP_TABLE, out_dev, &rt->rt_gateway,
>>>  				 skb);
>>>  	else if (rt6)
>>>  		err = neigh_xmit(NEIGH_ND_TABLE, out_dev, &rt6->rt6i_gateway,
>>>  				 skb);
>>> +	rcu_read_unlock_bh();
>>> +
>>>  	if (err)
>>>  		net_dbg_ratelimited("%s: packet transmission failed: %d\n",
>>>  				    __func__, err);
>>>
>>
>> I think those need to be added to neigh_xmit in the
>>
>> 	if (likely(index < NEIGH_NR_TABLES)) {
>>
>> 	}
>
> That'll force callers that don't need the extra protection (i.e.
> mpls_forward(), since that always runs from softirq and it's enough
> to protect the neigh state with rcu_read_lock() from softirq and we're
> already running under rcu_read_lock() when we get to neigh_xmit()) to
> eat the useless overhead of an extra rcu_read_{,un}lock_bh() pair, but
> sure, functionally that's correct, I think, and in my workload I don't
> care about MPLS forwarding performance anyway. ;-)

__neigh_lookup_noref expects bh level protection. Since the if block in 
neigh_xmit requires the locking seems like this the appropriate place 
for it.

>
> Want me to send a patch moving it to neigh_xmit() ?

Roopa/Robert: agree?
