From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH][RFC] sctp: fix reporting of unknown parameters
Date: Fri, 18 Feb 2011 09:43:30 -0500
Message-ID: <4D5E8592.2040606@hp.com>
References: <20110217231208.GA28281@midget.suse.cz> <4D5E575A.9000905@cn.fujitsu.com> <20110218120142.GA24525@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Shan Wei <shanwei@cn.fujitsu.com>, linux-sctp@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46365 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758250Ab1BRQZb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Feb 2011 11:25:31 -0500
In-Reply-To: <20110218120142.GA24525@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2011 07:01 AM, Jiri Bohac wrote:
> On Fri, Feb 18, 2011 at 07:26:18PM +0800, Shan Wei wrote:
>> Jiri Bohac wrote, at 02/18/2011 07:12 AM:
>>> commit 5fa782c2f5ef6c2e4f04d3e228412c9b4a4c8809 re-worked the 
>>> handling of unknown parameters. sctp_init_cause_fixed() can now
>>> return -ENOSPC if there is not enough tailroom in the error
>>> chunk skb. When this happens, the error header is not appended to
>>> the error chunk. In that case, the payload of the unknown parameter
>>> should not be appended either.
>>>
>>> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
>>
>> For this case, there is no more tailroom in skb
> 
> not always true:
> 
> both sctp_init_cause_fixed() and sctp_addto_chunk_fixed() get
> passesd WORD_ROUND(ntohs(param.p->length) as the paylen/len
> parameter.
> 
> sctp_init_cause_fixed() does:
> 	len = sizeof(sctp_errhdr_t) + paylen;
>         if (skb_tailroom(chunk->skb) < len)
> 	                return -ENOSPC;
> 
> if paylen is only slightly smaller than the tailroom (by less
> than sizeof(sctp_errhdr_t) bytes), -ENOSPEC will be returned and
> the header will not be appended to the error chunk.
> 
> But later sctp_addto_chunk_fixed() does this check:
> 	if (skb_tailroom(chunk->skb) >= len)
> which will pass and the unknown parameter value will be appended
> to the error chunk without the error header.
> 
>> we send incomplete INIT-ACK chunk. With your patch, this chunk also 
>> can't info the sender of INIT Chunk which parameter is not unrecognized.
>> So maybe this handle is not perfect. 
> 
> The logic of not reporting unknown parameters for which we don't
> have space in the pre-allocated buffer remains unchanged.
> 


Hi Jiri

I agree.  Good catch.  If we can not add the error header to that packet, then we definitely
should not be adding the error payload either.

We also don't want to abort as Shan Wei suggested.  It is allowed, when exceeding the MTU to
drop errors that would not otherwise fit into the packet.  It just may so happen that we
can report subsequent unknown parameters, but not this one in particular.

Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

-vlad



