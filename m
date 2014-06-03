From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net] xen-netback: Fix slot estimation
Date: Tue, 3 Jun 2014 21:24:31 +0100
Message-ID: <538E2EFF.7000103@citrix.com>
References: <1401802336-25182-1-git-send-email-zoltan.kiss@citrix.com> <063D6719AE5E284EB5DD2968C1650D6D1725674B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"wei.liu2@citrix.com" <wei.liu2@citrix.com>,
	"paul.durrant@citrix.com" <paul.durrant@citrix.com>,
	"linux@eikelenboom.it" <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:32038 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbaFCUYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 16:24:36 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725674B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/14 14:52, David Laight wrote:
> From: netdev-owner@vger.kernel.org
>> @@ -615,9 +608,27 @@ static void xenvif_rx_action(struct xenvif *vif)
>>
>>   		/* If the skb may not fit then bail out now */
>>   		if (!xenvif_rx_ring_slots_available(vif, max_slots_needed)) {
>> +			/* If the skb needs more than MAX_SKB_FRAGS slots, it
>> +			 * can happen that the frontend never gives us enough.
>> +			 * To avoid spining on that packet, first we put it back
>> +			 * to the top of the queue, but if the next try fail,
>> +			 * we drop it.
>> +			 */
>> +			if (max_slots_needed > MAX_SKB_FRAGS &&
>> +			    vif->rx_last_skb_slots == MAX_SKB_FRAGS) {
>> +				kfree_skb(skb);
>> +				vif->rx_last_skb_slots = 0;
>> +				continue;
>> +			}
>
> A silent discard here doesn't seem right at all.
> While it stops the kernel crashing, or the entire interface locking
> up; it is likely to leave one connection 'stuck' - a TCP retransmission
> is likely to include the same fragments.
>  From a user point of view this as almost as bad.

Yes, we are aware of this problem for a while. However I have an idea to 
solve that in a way that we don't lose performance, and these packets 
can pass through as well. See my patch called "Fix handling of skbs 
requiring too many slots"

Zoli
