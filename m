From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [RFC] ndo_validate_skb: Let the netdev check a valid skb content
Date: Thu, 07 Jan 2010 18:50:35 +0100
Message-ID: <4B461EEB.7040806@hartkopp.net>
References: <4B326E2F.2050709@hartkopp.net> <20100107.004101.217821816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Wolfgang Grandegger <wg@grandegger.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:31744 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085Ab0AGRul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 12:50:41 -0500
In-Reply-To: <20100107.004101.217821816.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Oliver Hartkopp <oliver@hartkopp.net>
> Date: Wed, 23 Dec 2009 20:23:27 +0100
> 
>> @@ -2034,6 +2035,14 @@ int dev_queue_xmit(struct sk_buff *skb)
>>  			goto out_kfree_skb;
>>  	}
>>  
>> +	/* If the device offers a function to validate the skb content, let
>> +	 * it check the skb and return an error to the caller if it fails.
>> +	 */ 
>> +	if (ops->ndo_validate_skb && ops->ndo_validate_skb(skb)) {
>> +		rc = -EINVAL;
>> +		goto out_kfree_skb;
>> +	}
>> +
> 
> To me this is as valuable as no error at all and simply having
> the driver drop the frame.  Which is what we do now.  I can
> sniff at the receiver to see that the device never transmitted
> the frame.
> 
> Is this getting this generic -EINVAL back so important that it's
> worth adding the new if() test for the NULL method to every packet
> that traverses the machine?  Keep in mind we can route at rates
> exceeding 1 million packets per second, so ever cycle you add
> here really matters.
> 
> If you want to place the hooks still, put them out of the fast
> path, which is probably in AF_PACKET.  We can extend this to
> call the validation function from other "untrusted" sources.
> 
> But do realize that you're not saving anything, things like
> queueing disciplines and traffic classifiers in the qdisc
> layer can modify any part of the packet however they wish.
> 
> So even if the CAN protocol layer itself emitted a valid
> frame, the qdisc layer can "corrupt" it.

I see. Thanks for your detailed answer!

Indeed silently drop the invalid CAN frame inside the driver (and increase
dev->stats.tx_dropped) looks like the best solution to me now.

If people try to push rubbish into the device, tx_dropped is an appropriate
indication.

Thanks,
Oliver

