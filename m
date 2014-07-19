From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] net: sctp: inherit auth_capable on INIT collisions
Date: Fri, 18 Jul 2014 22:23:33 -0400
Message-ID: <53C9D6A5.6040209@gmail.com>
References: <1405620319-2021-1-git-send-email-dborkman@redhat.com> <53C93157.1050002@gmail.com> <53C972BE.5090700@redhat.com> <53C998DE.2030805@gmail.com> <53C99BEF.1010203@redhat.com> <53C9A7B8.1020504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jgunthorpe@obsidianresearch.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:55858 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755327AbaGSCXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2014 22:23:37 -0400
In-Reply-To: <53C9A7B8.1020504@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/18/2014 07:03 PM, Daniel Borkmann wrote:
> On 07/19/2014 12:13 AM, Daniel Borkmann wrote:
>> On 07/18/2014 11:59 PM, Vlad Yasevich wrote:
>>> On 07/18/2014 03:17 PM, Daniel Borkmann wrote:
>>>> On 07/18/2014 04:38 PM, Vlad Yasevich wrote:
>>>> ...
>>>>> Why is the original value of asoc->peer.auth_capable = 0?
>>>>> In case of collision, asoc is the old association that
>>>>> existed on the system.  That association was created as part of
>>>>> sending the INIT.  If it is processing a duplicate COOKIE-ECHO
>>>>> as you say, then it has already processed the INIT-ACK and
>>>>> should have determined that the peer is auth capable.
>>>>>
>>>>> Thus the capability of the new and the old associations should
>>>>> be same if we are in fact processing case B (collision).
> 
> What I can see is the following that leads to this situation:
> 
> 1) asoc A sends the INIT, goes from CLOSED into COOKIE_WAIT
> 2) asoc B receives it, calls into sctp_sf_do_5_1B_init() where it
>    actually creates asoc B, responds with INIT_ACK, goes from CLOSED
>    into COOKIE_WAIT

I think this is a race.  asoc B doesn't exist yet.  we have a listening
socket that responds normally to the INIT-ACK.  The next thing that happens
is the app initiates a connection thus creating asoc B and triggering INIT.

> 3) asoc A receives INIT, thus collision, calls into sctp_sf_do_5_2_1_siminit()
> 3.1) asoc A calls into sctp_sf_do_unexpected_init(), creates a temp asoc,
>      does sctp_process_init() on the temp asoc (auth_cap=1, random etc set),
>      replies w/ temp asoc with INIT_ACK
> 4) asoc B gets INIT_ACK, calls sctp_sf_do_5_1C_ack (and thus SCTP_PEER_INIT
>    via interpreter), sees auth_cap=1, stores random etc; asoc B transitions
>    from COOKIE_WAIT into COOKIE_ECHOED
> 5) asoc A calls into sctp_sf_do_5_2_4_dupcook(), does the tietag compare,
>    finds action B, creates temp asoc calls sctp_process_init() on it
>    sees auth_cap=1, random etc; then we call into sctp_assoc_update()
>    and migrate all params; what I see there is that random, chunks, hmac
>    migrate from NULL each to the new values stored in the temp asoc
>    (and thus we'd need auth_cap as well to be correct); after that, I
>    see that asoc A goes from COOKIE_WAIT into ESTABLISHED (which seems
>    to be in accordance to the RFC: "The endpoint should stay in or enter
>    the ESTABLISHED state but it MUST ...")

I see.

> 6) later on, asoc B goes from COOKIE_ECHOED into ESTABLISHED
> 
> So that led me to the resolution of transferring 'caps' over via
> sctp_assoc_update(). In that case, asoc A transitions from 0 -> 1
> as previous 'caps' haven't been stored in the actual asoc. It stayed
> so far always in a temp asoc that we threw away after a reply.

Thanks for the analysis.   The collisions in COOKIE_WAIT state is definitely
a hole and it looks like all capabilities need to be updated and we should
probably do an audit to make sure we don't miss anything else.

-vlad

> 
>>>>> If not, then something else if wrong and my guess is that all
>>>>> other capabilities would be wrong too.
>>>>
>>>> I agree that they might likely also be flawed.
>>>>
>>>> Ok, let me dig further.
>>>
>>> So I think I know why case D ends up not authenticating the COOKIE-ACK.
>>> Most likely the reason is the following statement:
>>>   repl = sctp_make_cookie_ack(new_asoc, chunk);
>>>
>>> Note that we use new_asoc, instead of current asoc.
>>
>> Thanks, I will give it a try.
>>
>> Btw, noticed also that when we have AUTH + COOKIE_ECHO collisions,
>> we don't seem to handle them properly either. The normal case works
>> fine, but in case of a collision both sides seem to use wrong RANDOM
>> etc params, and thus discard the handshake due to bad signature.
>>
>>> Not sure why case B is dumping core yet.
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
