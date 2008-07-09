From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH] tun: Persistent devices can get stuck in xoff state
Date: Wed, 09 Jul 2008 14:15:50 -0700
Message-ID: <48752A86.3030207@qualcomm.com>
References: <1215584648-13444-1-git-send-email-maxk@qualcomm.com> <200807091715.25464.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:63057 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585AbYGIVPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 17:15:51 -0400
In-Reply-To: <200807091715.25464.borntraeger@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christian Borntraeger wrote:
> Am Mittwoch, 9. Juli 2008 schrieb Max Krasnyansky:
>> The scenario goes like this. App stops reading from tun/tap.
>> TX queue gets full and driver does netif_stop_queue().
>> App closes fd and TX queue gets flushed as part of the cleanup.
>> Next time the app opens tun/tap and starts reading from it but
>> the xoff state is not cleared. We're stuck.
>> Normally xoff state is cleared when netdev is brought up. But
>> in the case of persistent devices this happens only during
>> initial setup.
> 
> Thats interesting. I believe we have seen exactly this behaviour
> with KVM and lots of preallocated tap devices. 
Yeah, it's interesting given that it's (the bug that is) been there for 
at least 2-3 years now :).

> [...]
>> +++ b/drivers/net/tun.c
>> @@ -576,6 +576,11 @@ static int tun_set_iff(struct file *file, struct ifreq 
> *ifr)
>>  	file->private_data = tun;
>>  	tun->attached = 1;
>>
>> +	/* Make sure persistent devices do not get stuck in
>> +	 * xoff state */
>> +	if (netif_running(tun->dev))
>> +		netif_wake_queue(tun->dev);
>> +
>>  	strcpy(ifr->ifr_name, tun->dev->name);
>>  	return 0;
> 
> I think that patch looks ok, but I am curious why you dont clear the xoff 
> state on application close at the same time when the TX queue gets flushed?
Why bother. I mean the packets will be dropped anyway.

Max

