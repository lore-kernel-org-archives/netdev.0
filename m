From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCHv1] xen-netfront: always keep the Rx ring full
 of requests
Date: Mon, 6 Oct 2014 17:00:22 +0100
Message-ID: <5432BC96.6060709@citrix.com>
References: <1412256826-18874-1-git-send-email-david.vrabel@citrix.com> <5432B6D2.9030503@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: annie li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:42045 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753221AbaJFQCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2014 12:02:50 -0400
In-Reply-To: <5432B6D2.9030503@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/14 16:35, annie li wrote:
> 
> On 2014/10/2 9:33, David Vrabel wrote:
>> A full Rx ring only requires 1 MiB of memory.  This is not enough
>> memory that it is useful to dynamically scale the number of Rx
>> requests in the ring based on traffic rates.
>>
>> Keeping the ring full of Rx requests handles bursty traffic better
>> than trying to converges on an optimal number of requests to keep
>> filled.
>>
>> On a 4 core host, an iperf -P 64 -t 60 run from dom0 to a 4 VCPU guest
>> improved from 5.1 Gbit/s to 5.6 Gbit/s.  Gains with more bursty
>> traffic are expected to be higher.
> 
> Although removing sysfs is connected with the code change for full Rx
> ring utilization, I assume it is better to split this patch into two to
> make it simpler?

I don't see how splitting the patch would be an improvement.

>>   +    queue->rx.req_prod_pvt = req_prod;
>> +
>> +    /* Not enough requests? Try again later. */
>> +    if (req_prod - queue->rx.rsp_cons < NET_RX_SLOTS_MIN) {
>> +        mod_timer(&queue->rx_refill_timer, jiffies + (HZ/10));
>> +        return;
> 
> If the previous for loop breaks because of failure of
> xennet_alloc_one_rx_buffer, then notify_remote_via_irq is missed here if
> the code returns directly.

This is deliberate -- there's no point notifying the backend if there
aren't enough requests for the next packet.  Since we don't know what
the next packet might be we assume it's the largest possible.

David
