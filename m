From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 2/2] ptr_ring_ll: pop/push multiple objects at once
Date: Tue, 15 Nov 2016 20:42:03 -0800
Message-ID: <582BE39B.9050007@gmail.com>
References: <20161111043857.1547.70337.stgit@john-Precision-Tower-5810>
 <20161111044432.1547.65342.stgit@john-Precision-Tower-5810>
 <20161115010140-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36759 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752757AbcKPEmR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 23:42:17 -0500
In-Reply-To: <20161115010140-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-14 03:06 PM, Michael S. Tsirkin wrote:
> On Thu, Nov 10, 2016 at 08:44:32PM -0800, John Fastabend wrote:
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> 
> This will naturally reduce the cache line bounce
> costs, but so will a _many API for ptr-ring,
> doing lock-add many-unlock.
> 
> the number of atomics also scales better with the lock:
> one per push instead of one per queue.
> 
> Also, when can qdisc use a _many operation?
> 

On dequeue we can pull off many skbs instead of one at a time and
then either (a) pass them down as an array to the driver (I started
to write this on top of ixgbe and it seems like a win) or (b) pass
them one by one down to the driver and set the xmit_more bit correctly.

The pass one by one also seems like a win because we avoid the lock
per skb.

On enqueue qdisc side its a bit more evasive to start doing this.


[...]

>> +++ b/net/sched/sch_generic.c
>> @@ -571,7 +571,7 @@ static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc,
>>  	struct skb_array_ll *q = band2list(priv, band);
>>  	int err;
>>  
>> -	err = skb_array_ll_produce(q, skb);
>> +	err = skb_array_ll_produce(q, &skb);
>>  
>>  	if (unlikely(err)) {
>>  		net_warn_ratelimited("drop a packet from fast enqueue\n");
> 
> I don't see a pop many operation here.
> 

Patches need a bit of cleanup looks like it was part of another patch.

.John
