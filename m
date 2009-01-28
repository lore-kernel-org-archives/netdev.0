From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PANIC] lro + iscsi or lro + skb text search causes panic
Date: Wed, 28 Jan 2009 12:22:51 -0600
Message-ID: <4980A27B.8050908@cs.wisc.edu>
References: <46A00B48CC54E4468EF6911F877AC4CA01EF2BDB@blrx3m10.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	olaf.kirch@oracle.com, tgraf@suug.ch, kkeil@suse.de
To: Shyam_Iyer@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:46402 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751524AbZA1SXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jan 2009 13:23:46 -0500
In-Reply-To: <46A00B48CC54E4468EF6911F877AC4CA01EF2BDB@blrx3m10.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shyam_Iyer@Dell.com wrote:
> 
> Mike Christie wrote:
>> Herbert Xu wrote:
>>> On Sun, Jan 25, 2009 at 09:32:22PM -0800, David Miller wrote:
>>>> From: Mike Christie <michaelc@cs.wisc.edu>
>>>> Date: Thu, 22 Jan 2009 18:04:11 -0600
>>>>
>>>>> With the patch running against linus's git tree, my box locks up. 
>>>>> You cannot ping it. I do not get a oops or anything in the logs,
> and 
>>>>> the keyboard does not respond. I will try to get some oops output 
>>>>> and more info.
>>>> Herbert, any idea offhand?
>>> Yeah, I missed an offset update in there :) Here's a better version.
>>>
>>> net: Fix frag_list handling in skb_seq_read
>>>
>>> The frag_list handling was broken in skb_seq_read:
>>>
>>> 1) We didn't add the stepped offset when looking at the head are of 
>>> fragments other than the first.
>>>
>>> 2) We didn't take the stepped offset away when setting the data 
>>> pointer in the head area.
>>>
>>> 3) The frag index wasn't reset.
>>>
>>> This patch fixes both issues.
>>>
> 
>> It oopsd for me in skb_seq_read. addr2line said it was
> linux-2.6/net/core/skbuff.c:2228, which is this line:
> 
> 
>> while (st->frag_idx < skb_shinfo(st->cur_skb)->nr_frags) {
> 
> 
>> I added some printks in there and it looks like we hit this:
> 
>>         } else if (st->root_skb == st->cur_skb &&
>>                   skb_shinfo(st->root_skb)->frag_list) {
>>                 st->cur_skb = skb_shinfo(st->root_skb)->frag_list;
>>                 st->frag_idx = 0;
>>                 goto next_skb;
>>        }
> 
> 
> 
> Actually I did some testing and added a few printks and found that the
> st->cur_skb->data was 0 and hence the ptr used by iscsi_tcp was null.
> This caused the kernel panic.




Yeah, that is what Jesse saw too. I never got a null ptr though. That is 
probably why he oopsed, but I could login but would get what looked like 
corrupted packets instead of oopsing.




> 
>  	if (abs_offset < block_limit) {
> -		*data = st->cur_skb->data + abs_offset;
> +		*data = st->cur_skb->data + (abs_offset -
> st->stepped_offset);
> 
>  I enabled the debug_tcp and with a few printks found that the code in
> my scenario did not go to the next_skb label as described by Mike and
> could find that the sequence being followed was this -
> 
> It hit this if condition -
>  if (st->cur_skb->next) {
>                 st->cur_skb = st->cur_skb->next;
>                 st->frag_idx = 0;
>                 goto next_skb;



Yeah, I must have been cross eyed that night. I was hitting this too, 
and that caused me to hit the loop again.


> 
> And so, now the st pointer is shifted to the next skb whereas actually
> it should have hit the second else if first since the data is in the
> frag_list.
> 
> else if (st->root_skb == st->cur_skb &&
>                    skb_shinfo(st->root_skb)->frag_list) {
>                 st->cur_skb = skb_shinfo(st->root_skb)->frag_list;
>                 goto next_skb;
>         }
> 
> 
> Reversing the two conditions the attached patch fixes the issue for me
> on top of Herbert's patches.  I have done the testing on the ixgbe
> adapter itself and verified the fix using some amount of data transfer
> as well.
> 
> Signed-off-by: Shyam Iyer <shyam_iyer@dell.com>
> 
> --- skbuff.c.orig	2009-01-29 01:12:03.000000000 +0530
> +++ skbuff.c	2009-01-29 01:34:57.000000000 +0530
> @@ -2039,15 +2039,15 @@
>  		st->frag_data = NULL;
>  	
>  
> -	if (st->cur_skb->next) {
> -		st->cur_skb = st->cur_skb->next;
> -		st->frag_idx = 0;
> -		goto next_skb;
> -	} else if (st->root_skb == st->cur_skb &&
> +	if (st->root_skb == st->cur_skb &&
>  		   skb_shinfo(st->root_skb)->frag_list) {
>  		st->cur_skb = skb_shinfo(st->root_skb)->frag_list;
>  		st->frag_idx=0;


I think you diffed this against the wrong source. In the upstream code 
this is
st->frag_idx = 0;

so the patch does not apply.


>  		goto next_skb;
> +	} else if (st->cur_skb->next) {
> +		st->cur_skb = st->cur_skb->next;
> +		st->frag_idx = 0;
> +		goto next_skb;
>  	}
>  
>  	return 0;
> 

Nice catch. Patch works for me. Thanks!

