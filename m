From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net RESEND] bonding: don't change to 802.3ad mode while
 ARP monitoring is running
Date: Tue, 19 Nov 2013 09:48:56 +0800
Message-ID: <528AC388.6030908@huawei.com>
References: <528710F7.7050207@huawei.com>	 <1384796682.4774.26.camel@dcbw.foobar.com>	 <20131118.154838.776189725378131169.davem@davemloft.net> <1384815032.4774.55.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <fubar@us.ibm.com>, <andy@greyhouse.net>, <nikolay@redhat.com>,
	<vfalico@redhat.com>, <netdev@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:22569 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881Ab3KSBuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 20:50:15 -0500
In-Reply-To: <1384815032.4774.55.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/19 6:50, Dan Williams wrote:
> On Mon, 2013-11-18 at 15:48 -0500, David Miller wrote:
>> From: Dan Williams <dcbw@redhat.com>
>> Date: Mon, 18 Nov 2013 11:44:42 -0600
>>
>>> On Sat, 2013-11-16 at 14:30 +0800, Ding Tianhong wrote:
>>>> Because the ARP monitoring is not support for 802.3ad, but I still
>>>> could change the mode to 802.3ad from ab mode while ARP monitoring
>>>> is running, it is incorrect.
>>>>
>>>> So add a check for 802.3ad in bonding_store_mode to fix the problem,
>>>> and make a new macro BOND_NO_USES_ARP() to simplify the code.
>>>
>>> Instead of failing, couldn't the code stop ARP monitoring and allow the
>>> mode change?  This is similar to setting miimon, which disables ARP
>>> monitoring, or setting ARP monitoring, which disables miimon.
>>>
>>> 	if (new_value && bond->params.arp_interval) {
>>> 		pr_info("%s: MII monitoring cannot be used with ARP monitoring. Disabling ARP monitoring...\n",
>>> 			bond->dev->name);
>>> 		bond->params.arp_interval = 0;
>>> 		if (bond->params.arp_validate)
>>> 			bond->params.arp_validate = BOND_ARP_VALIDATE_NONE;
>>> 	}
>>>
>>> Bond mode is the most important bond option, so it seems like it should
>>> override any of the other sub-options.  I know the code doesn't do this
>>> now, but maybe instead of the patch you propose, it would be nicer to
>>> allow the mode change instead?
>>
>> I agree with Dan, if other mode changes behave this way (by dropping the
>> incompatible feature) we should make 802.3ad do so as well at the very
>> least for consistency.
> 
> Currently ALB and TLB modes will fail if arp_interval > 0, so Ding's
> patch is technically correct.
> 
> Instead, I'm proposing that 'mode' trumps all, and if the user changes
> the mode, conflicting values should be cleared or reset.  Otherwise
> userspace has to duplicate a lot of kernel logic/validation.  For
> example:
> 
> 1) set mode to ROUNDROBIN
> 2) set arp_interval
> 3) set mode to ALB or TLB
> 4) FAIL - incompatible with arp_interval
> 5) ok, set arp_interval to zero
> 6) set mode to ALB or TLB
> 7) SUCCESS
> 
> Wouldn't it be nice if the kernel handled clearing arp_interval for us,
> since it knows that arp_interval is incompatible with ALB/TLB...
> 
> Could be done separately.  I have no objection to Ding's patch other
> than "life could be even better".
> 
> Dan
> 
> 
agree, it could be better, when we set the mode which only support mii, we should
disable the arp monitoring if arp_interval > 0, and restart mii monitor, I will rebuild
the patch and resend it later.

Regards
Ding

> 
> .
> 
