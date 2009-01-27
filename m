From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PANIC] lro + iscsi or lro + skb text search causes panic
Date: Tue, 27 Jan 2009 00:12:05 -0600
Message-ID: <497EA5B5.5090806@cs.wisc.edu>
References: <alpine.WNT.2.00.0901221234420.4188@jbrandeb-desk1.amr.corp.intel.com> <20090122232131.GA22771@gondor.apana.org.au> <4979097B.4040108@cs.wisc.edu> <20090125.213222.192571170.davem@davemloft.net> <20090126223022.GA24046@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, olaf.kirch@oracle.com, tgraf@suug.ch,
	kkeil@suse.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:56747 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899AbZA0GM7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 01:12:59 -0500
In-Reply-To: <20090126223022.GA24046@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sun, Jan 25, 2009 at 09:32:22PM -0800, David Miller wrote:
>> From: Mike Christie <michaelc@cs.wisc.edu>
>> Date: Thu, 22 Jan 2009 18:04:11 -0600
>>
>>> With the patch running against linus's git tree, my box locks
>>> up. You cannot ping it. I do not get a oops or anything in the logs,
>>> and the keyboard does not respond. I will try to get some oops
>>> output and more info.
>> Herbert, any idea offhand?
> 
> Yeah, I missed an offset update in there :) Here's a better version.
> 
> net: Fix frag_list handling in skb_seq_read
> 
> The frag_list handling was broken in skb_seq_read:
> 
> 1) We didn't add the stepped offset when looking at the head
> are of fragments other than the first.
> 
> 2) We didn't take the stepped offset away when setting the data
> pointer in the head area.
> 
> 3) The frag index wasn't reset.
> 
> This patch fixes both issues.
> 

It oopsd for me in skb_seq_read. addr2line said it was 
linux-2.6/net/core/skbuff.c:2228, which is this line:


while (st->frag_idx < skb_shinfo(st->cur_skb)->nr_frags) {


I added some printks in there and it looks like we hit this:

         } else if (st->root_skb == st->cur_skb &&
                    skb_shinfo(st->root_skb)->frag_list) {
                 st->cur_skb = skb_shinfo(st->root_skb)->frag_list;
                 st->frag_idx = 0;
                 goto next_skb;
         }


Then when we hit the goto and start again, and we oops when we hit that 
"while (st->frag_idx < skb_shinfo(st->cur_skb)->nr_frags)" line.
