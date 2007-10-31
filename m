From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH]: Fix myri10ge NAPI oops & warnings
Date: Wed, 31 Oct 2007 18:54:00 -0400
Message-ID: <47290788.7070501@myri.com>
References: <4728F636.9080505@myri.com> <20071031144412.723910ba@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:2009 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752759AbXJaWyW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 18:54:22 -0400
In-Reply-To: <20071031144412.723910ba@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 31 Oct 2007 17:40:06 -0400
> Andrew Gallatin <gallatin@myri.com> wrote:
> 
>> When testing the myri10ge driver with 2.6.24-rc1, I found
>> that the machine crashed under heavy load:
>>
>> Unable to handle kernel paging request at 0000000000100108 RIP:
>>   [<ffffffff803cc8dd>] net_rx_action+0x11b/0x184
>>
>> The address corresponds to the list_move_tail() in
>> netif_rx_complete():
>>                      if (unlikely(work == weight))
>>                              list_move_tail(&n->poll_list, list);
>>
>> Eventually, I traced the crashes to calling netif_rx_complete() with
>> work_done == budget.  From looking at other drivers, it appears that
>> one should only call netif_rx_complete() when work_done < budget.
>>
>> To fix it, I changed the test in myri10ge_poll() so that it refers
>> to to work_done rather than looking at the rx ring status.  If
>> work_done is < budget, then that implies we have no more packets to
>> process. Any races will be resolved by the NIC when the write to
>> irq_claim is made.
>>
>> In myri10ge_clean_rx_done(), if we ever exceeded our budget, it would
>> report a work_done one larger than was acutally done.  This is because
>> the increment was done in the conditional, so work_done would be
>> incremented regardless of whether or not the test passed or failed.
>> This would lead to the WARN_ON_ONCE(work > weight); warning in
>> net_rx_action triggering.  I've moved the increment of work_done
>> inside the loop.  Note that this would only be a problem when we had
>> exceeded our budget.
>>
>> Signed off by: Andrew Gallatin <gallatin@myri.com>
>>
>> Andrew Gallatin Myricom Inc
>>
>>
> 
> Yes, this looks right.
> How could the check in netif_rx_complete be changed to catch this better?

I'm sorry, but I don't really know.  I'm afraid that I am
rather clueless about the new NAPI, and found this by
stumbling around in the dark. Naively, it seems like some
global option to override all napi weights (eg, to 1) would
be helpful so that if a driver had this problem, it could
be easily reproduced by the first packet received.  At least
I found setting our weight to one made the bug rather
obvious to me.

Drew


