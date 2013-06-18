From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 4/5] net: sctp: decouple cleaning socket data
 from endpoint
Date: Tue, 18 Jun 2013 18:55:27 -0400
Message-ID: <51C0E55F.1010409@gmail.com>
References: <1371545720-22950-1-git-send-email-dborkman@redhat.com> <1371545720-22950-5-git-send-email-dborkman@redhat.com> <20130618142240.GA27099@hmsreliant.think-freely.org> <51C08492.7040602@redhat.com> <51C089BF.2040603@gmail.com> <20130618174503.GB27099@hmsreliant.think-freely.org> <51C0A3B9.80905@gmail.com> <20130618191234.GD27099@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:52325 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932644Ab3FRWzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 18:55:31 -0400
In-Reply-To: <20130618191234.GD27099@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/2013 03:12 PM, Neil Horman wrote:
> On Tue, Jun 18, 2013 at 02:15:21PM -0400, Vlad Yasevich wrote:
>> On 06/18/2013 01:45 PM, Neil Horman wrote:
>>> On Tue, Jun 18, 2013 at 12:24:31PM -0400, Vlad Yasevich wrote:
>>>> On 06/18/2013 12:02 PM, Daniel Borkmann wrote:
>>>>> On 06/18/2013 04:22 PM, Neil Horman wrote:
>>>>>> I like this idea, but I think I'm maybe missing something from it - we
>>>>>> reference
>>>>>> the socket in both the receive and send paths (sctp_unpack_cookie, is
>>>>>> specifically called from the rx path, which makes use of sp->hmac).  a
>>>>>> socket
>>>>>> destructor can be called from __sk_free when sk_wmem_alloc reaches
>>>>>> zero, but we
>>>>>> use sk_refcnt in the rx path to prevent premature socket cleanup.  If
>>>>>> we drain
>>>>>> our send queeue while wer'e still processing rx messages, what
>>>>>> prevents us from
>>>>>> freeing the socket in the tx path, via sk_free while we're still using
>>>>>> the
>>>>>> socket in the rx path.  Note I don't think this patch is wrong per-se,
>>>>>> but it
>>>>>> seems to me there is more work to do to properly interlock the use of
>>>>>> sk_refcnt
>>>>>> and sk_wmem_alloc here (unless I'm just missing something obvious,
>>>>>> which is
>>>>>> entirely possible, I've been in the sun alot lately :) ).
>>>>>
>>>>> Hm, __sk_free() calls sk_prot_free() which frees our socket structure
>>>>> and in
>>>>> sctp_wfree() we do a sctp_association_put(asoc) after sock_wfree(skb).
>>>>>
>>>>> So no matter if having this patch or not, couldn't this use-after-free like
>>>>> scenario already happen with the current code?
>>>>>
>>>>> F.e. through a given call graph like that:
>>>>>
>>>>> sctp_wfree(skb):
>>>>>   1) sock_wfree(skb)
>>>>>      -> __sk_free()
>>>>
>>>> I don't think this can happen.  sk_wmem_alloc is set to 1 in sk_alloc()
>>>> and that acts as a guard to make sure that sk_free() has been called
>>>> before we try to free things up.  So, in this partcular case, for
>>>> __sk_free() to be called, sk_free() had to be called meaning the
>>>> last ref on the socket was released.  However, that's not possible since
>>>> we are still holding the association and thus holding the socket
>>>> associated with it.
>>>>
>>> I see what your saying, and I agree, with that bias added in sk_alloc, it looks
>>> like we won't ever call __sk_free until sk_wmem_alloc is 1 _and_ sk_refcnt is 0.
>>> It still seems messy and confusing though.  It would make more sense to me to
>>> increment the refcount an additional time when the socket is initalized, and
>>> then decrement it again when the socket is closed and sk_wmem_alloc reaches
>>> zero.  That would isolate the refcounting to a single variable.
>>
>> See commit 2b85a34e911bf483c27cfdd124aeb1605145dc80.  The whole
>> sk_wmem_alloc tric was done so that we dont have to do
>> sock_hold/sock_put on transmits.
>>
> I know about why it was done, I'm just proposing that we don't have to do it
> that way to get the speedup it gives us, and make the code a bit more clear at
> the same time.  If we set the refcnt to 2 at init time, we can decrement that
> added initial bias when the sk is marked as SOCK_DEAD and the sk_wmem_queued
> reaches 0.  We still don't have to do a sock_hold/put on every tx, and we keep
> all the reference counting in one location.

sorry, not following..  regardless, this seems to have gotten a bit off 
topic.  I am going to take a deeper look at Daniel's to make sure it 
doesn't introduce any races.

-vlad

>
> Alternatively we can move all the reference counting to sk_wmem_alloc, and have
> sock_hold/put increment that field by one instead of sk_refcnt, meaning we could
> remove that field
>
> We don't really have to do any of this, of course, but not having looked at it
> in some time, it seems confusing to me to have have a single additional ref
> count tracked in sk_wmem_alloc.
>
>> It might be good to see if we can do that in sctp as well.
> Not sure what you mean by "that" here.  You mean remove the additional uses of
> sctp_hold/put?
>
> Neil
>
>>
>> -vlad
>>
>>
>>> Neil
>>>
>>>> -vlad
>>>>
>>>>>       -> sk_prot_free(.., sk)
>>>>>        -> kmem_cache_free(.., sk) or kfree(sk)
>>>>>   2) __sctp_write_space(asoc)
>>>>>   3) sctp_association_put(asoc)
>>>>>      -> sctp_association_destroy(asoc)
>>>>>       -> sctp_endpoint_put(asoc->ep)
>>>>>        -> sctp_endpoint_destroy(ep)
>>>>>         -> crypto_free_hash(sctp_sk(ep->base.sk)->hmac)
>>>>>            (etc, all unconditionally accessed while sk is
>>>>>             already dead/freed)
>>>>>
>>>>> Then, this might need a fix in general. :-)
>>>>>
>>>>> Assuming you would reduce the buffer space via setsockopt(.., SO_SNDBUF,
>>>>> ..),
>>>>> you might end up with a minimum buffer space of SOCK_MIN_SNDBUF [*] and
>>>>> a call to
>>>>> sk->sk_write_space(sk), which is sctp_write_space() and calls
>>>>> __sctp_write_space()
>>>>> on all asocs belonging to the socket, but it seems not to alter the current
>>>>> sk->sk_wmem_alloc I think, but rather sk->sk_sndbuf.
>>>>>
>>>>> [*] Btw, shouldn't this rather be (2048 + sizeof(struct sk_buff)) or
>>>>>      SKB_TRUESIZE(2048), at least like in SOCK_MIN_RCVBUF since we operate
>>>>>      on skb->truesize as well?
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>>>
>>
>>
