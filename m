From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net v2] net: sctp: test if association is dead in sctp_wake_up_waiters
Date: Wed, 09 Apr 2014 08:56:26 -0400
Message-ID: <5345437A.6040602@gmail.com>
References: <de3e98e644dde7dcaea9a952de38eb32a2959eeb.1396999714.git.dborkman@redhat.com> <5345003B.8080601@redhat.com> <534521D0.7050707@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevic@redhat.com>
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:36055 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932798AbaDIM42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 08:56:28 -0400
In-Reply-To: <534521D0.7050707@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2014 06:32 AM, Daniel Borkmann wrote:
> On 04/09/2014 10:09 AM, Daniel Borkmann wrote:
>> On 04/09/2014 01:10 AM, Vlad Yasevich wrote:
>>  > On 04/08/2014 06:23 PM, Daniel Borkmann wrote:
>>  >> In function sctp_wake_up_waiters() we need to involve a test
>>  >> if the association is declared dead. If so, we don't have any
>>  >> reference to a possible sibling association anymore and need
>>  >> to invoke sctp_write_space() instead and normally walk the
>>  >> socket's associations and notify them of new wmem space. The
>>  >> reason for special casing is that, otherwise, we could run
>>  >> into the following issue:
>>  >>
>>  >> sctp_association_free()
>>  >> `-> list_del(&asoc->asocs)         <-- poisons list pointer
>>  >>      asoc->base.dead = true
>>  >>      sctp_outq_free(&asoc->outqueue)
>>  >>      `-> __sctp_outq_teardown()
>>  >>       `-> sctp_chunk_free()
>>  >>        `-> consume_skb()
>>  >>         `-> sctp_wfree()
>>  >>          `-> sctp_wake_up_waiters() <-- dereferences poisoned
>> pointers
>>  >>                                         if asoc->ep->sndbuf_policy=0
>>  >>
>>  >> Therefore, only walk the list in an 'optimized' way if we find
>>  >> that the current association is still active. It's also more
>>  >> clean in that context to just use list_del_init() when we call
>>  >> sctp_association_free(). Stress-testing seems fine now.
>>  >
>>  > One of the reasons that we don't use list_del_init() here is that
>>  > we want to be able to trap on uninitialized/corrupt list manipulation,
>>  > just like you did.  If it wasn't there, the bug would have been
>> hidden.
>>  >
>>  > Please keep it there.  The rest of the patch is fine.
>>
>> Test run over night and I've seen no issues.
>>
>> But I'd still question the usage of asoc->base.dead though, I think
>> this approach of testing for asoc->base.dead is a bit racy (perhaps
>> general usage of it, imho) - at least here there's a tiny window where
>> we poison pointers before we actually declare the associaton dead.
>>
>> Also, I think even if we would have deleted ourselves from the list
>> after declaring the association dead, a different CPU accessing this
>> association via sctp_wfree() might already have gotten past the
>> asoc->base.dead test while we declare it dead in the meantime.
> 
> Ok, I think we can scratch that thought ... what happens is that parallel
> calls to sctp_sendmsg() are protected under lock_sock()/release_sock()
> pair as already stated in the code and within that lock, we are setting
> sctp_set_owner_w() for each chunk. When we call sctp_primitive_SEND(),
> still under lock, we might eventually end up in sctp_packet_transmit(),
> if I follow the path correctly, and orphan the skb in
> sctp_packet_set_owner_w()
> [ which basically would mean, we actually uncharge the accounted memory by
> orphaning _before_ we call dev_queue_xmit() since commit 4c3a5bdae293
> ("sctp: Don't charge for data in sndbuf again when transmitting packet")
> but that's perhaps a different story ] and set a new destructor. The
> only thing where in that context an association can be freed up by
> sctp_association_free() is if sctp_primitive_SEND() returns with error.
> So even in that case, we're still protected under
> lock_sock()/release_sock()
> when we flush the outq, so testing asoc->base.dead should be okay then,
> quite unintuitive though. Thus, patch seems fine, if wished, I could
> still document that in the commit message? Vlad, are we on the same
> page? ;)

yes, socket lock protects the reading of writing to any association
variables.

-vlad

> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
