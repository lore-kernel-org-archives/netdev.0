From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net v2] net: sctp: test if association is dead in sctp_wake_up_waiters
Date: Wed, 09 Apr 2014 08:52:44 -0400
Message-ID: <5345429C.6030108@gmail.com>
References: <de3e98e644dde7dcaea9a952de38eb32a2959eeb.1396999714.git.dborkman@redhat.com> <5345003B.8080601@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevic@redhat.com>
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:52124 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932597AbaDIMwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 08:52:47 -0400
In-Reply-To: <5345003B.8080601@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2014 04:09 AM, Daniel Borkmann wrote:
> On 04/09/2014 01:10 AM, Vlad Yasevich wrote:
>> On 04/08/2014 06:23 PM, Daniel Borkmann wrote:
>>> In function sctp_wake_up_waiters() we need to involve a test
>>> if the association is declared dead. If so, we don't have any
>>> reference to a possible sibling association anymore and need
>>> to invoke sctp_write_space() instead and normally walk the
>>> socket's associations and notify them of new wmem space. The
>>> reason for special casing is that, otherwise, we could run
>>> into the following issue:
>>>
>>> sctp_association_free()
>>> `-> list_del(&asoc->asocs)         <-- poisons list pointer
>>>      asoc->base.dead = true
>>>      sctp_outq_free(&asoc->outqueue)
>>>      `-> __sctp_outq_teardown()
>>>       `-> sctp_chunk_free()
>>>        `-> consume_skb()
>>>         `-> sctp_wfree()
>>>          `-> sctp_wake_up_waiters() <-- dereferences poisoned pointers
>>>                                         if asoc->ep->sndbuf_policy=0
>>>
>>> Therefore, only walk the list in an 'optimized' way if we find
>>> that the current association is still active. It's also more
>>> clean in that context to just use list_del_init() when we call
>>> sctp_association_free(). Stress-testing seems fine now.
>>
>> One of the reasons that we don't use list_del_init() here is that
>> we want to be able to trap on uninitialized/corrupt list manipulation,
>> just like you did.  If it wasn't there, the bug would have been hidden.
>>
>> Please keep it there.  The rest of the patch is fine.
> 
> Test run over night and I've seen no issues.
> 
> But I'd still question the usage of asoc->base.dead though, I think
> this approach of testing for asoc->base.dead is a bit racy (perhaps
> general usage of it, imho) - at least here there's a tiny window where
> we poison pointers before we actually declare the associaton dead.
> 
> Also, I think even if we would have deleted ourselves from the list
> after declaring the association dead, a different CPU accessing this
> association via sctp_wfree() might already have gotten past the
> asoc->base.dead test while we declare it dead in the meantime.

sctp_wfree is the destructor for the chunk.  Chunks are freed directly
by association while under lock.  So, a different CPU can't be running
sctp_wfree while another CPU is destroying the association as both
actions happen under the same socket lock.

The times we check asoc->base.dead is when we've cached an association
pointer for later processing.  In between cache and processing, the
association may have been freed and is simply still around due to
reference counts.  We check asoc->base.dead under a lock, so it
should always be safe to check and not race against sctp_association_free().

-vlad

-vlad

> 
> Imho, this still needs to be resolved differently. I'll look further ...
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
