From: Josef Bacik <jbacik@fb.com>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Fri, 16 Dec 2016 17:08:55 -0500
Message-ID: <1481926135.24490.8@smtp.office365.com>
References: <CALx6S36OVUqAxq9vNnfHp2eJOuG+gSSg896zzaZoc3Og4tyxFw@mail.gmail.com>
        <1481231024.1911284.813071977.72AF4DEE@webmail.messagingengine.com>
        <1481233016.11849.1@smtp.office365.com>
        <1481243432.4930.145.camel@edumazet-glaptop3.roam.corp.google.com>
        <6C6EE0ED-7E78-4866-8AAF-D75FD4719EF3@fb.com>
        <1481335192.3663.0@smtp.office365.com>
        <1481341624.4930.204.camel@edumazet-glaptop3.roam.corp.google.com>
        <1481343298.4930.208.camel@edumazet-glaptop3.roam.corp.google.com>
        <1481565929.24490.0@smtp.office365.com>
        <3c022731-e703-34ac-55f1-60f5b94b6d62@stressinduktion.org>
        <1481581466.24490.2@smtp.office365.com>
        <CALx6S34S82kFVqYW1M0ZuHx_Mxut4QaLFVerLX4aEsksrFirXg@mail.gmail.com>
        <CAEfhGiyFW1YHmmUYpFv+q4J4r=wSv3ZBZowG69BqkT3p-G4gNw@mail.gmail.com>
        <CALx6S369T_hvoTgyHbmeSiR2p3d68h+0tMKqMmcGYLrKiN3JMA@mail.gmail.com>
        <1481828016.24490.5@smtp.office365.com>
        <aca378b5-aae4-49cf-0542-d1167a5768b8@stressinduktion.org>
        <1481900088.24490.6@smtp.office365.com>
        <1481901684.24490.7@smtp.office365.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Cc: Tom Herbert <tom@herbertland.com>,
        Craig Gallek <kraigatgoog@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:46847 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1758358AbcLPWJO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 17:09:14 -0500
In-Reply-To: <1481901684.24490.7@smtp.office365.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 16, 2016 at 10:21 AM, Josef Bacik <jbacik@fb.com> wrote:
> On Fri, Dec 16, 2016 at 9:54 AM, Josef Bacik <jbacik@fb.com> wrote:
>> On Thu, Dec 15, 2016 at 7:07 PM, Hannes Frederic Sowa 
>> <hannes@stressinduktion.org> wrote:
>>> Hi Josef,
>>> 
>>> On 15.12.2016 19:53, Josef Bacik wrote:
>>>>  On Tue, Dec 13, 2016 at 6:32 PM, Tom Herbert 
>>>> <tom@herbertland.com> wrote:
>>>>>  On Tue, Dec 13, 2016 at 3:03 PM, Craig Gallek 
>>>>> <kraigatgoog@gmail.com>
>>>>>  wrote:
>>>>>>   On Tue, Dec 13, 2016 at 3:51 PM, Tom Herbert 
>>>>>> <tom@herbertland.com>
>>>>>>  wrote:
>>>>>>>   I think there may be some suspicious code in 
>>>>>>> inet_csk_get_port. At
>>>>>>>   tb_found there is:
>>>>>>> 
>>>>>>>                   if (((tb->fastreuse > 0 && reuse) ||
>>>>>>>                        (tb->fastreuseport > 0 &&
>>>>>>>                         
>>>>>>> !rcu_access_pointer(sk->sk_reuseport_cb) &&
>>>>>>>                         sk->sk_reuseport && uid_eq(tb->fastuid,
>>>>>>>  uid))) &&
>>>>>>>                       smallest_size == -1)
>>>>>>>                           goto success;
>>>>>>>                   if 
>>>>>>> (inet_csk(sk)->icsk_af_ops->bind_conflict(sk,
>>>>>>>  tb, true)) {
>>>>>>>                           if ((reuse ||
>>>>>>>                                (tb->fastreuseport > 0 &&
>>>>>>>                                 sk->sk_reuseport &&
>>>>>>> 
>>>>>>>  !rcu_access_pointer(sk->sk_reuseport_cb) &&
>>>>>>>                                 uid_eq(tb->fastuid, uid))) &&
>>>>>>>                               smallest_size != -1 && --attempts 
>>>>>>> >= 0) {
>>>>>>>                                   spin_unlock_bh(&head->lock);
>>>>>>>                                   goto again;
>>>>>>>                           }
>>>>>>>                           goto fail_unlock;
>>>>>>>                   }
>>>>>>> 
>>>>>>>   AFAICT there is redundancy in these two conditionals.  The 
>>>>>>> same clause
>>>>>>>   is being checked in both: (tb->fastreuseport > 0 &&
>>>>>>>   !rcu_access_pointer(sk->sk_reuseport_cb) && sk->sk_reuseport 
>>>>>>> &&
>>>>>>>   uid_eq(tb->fastuid, uid))) && smallest_size == -1. If this is 
>>>>>>> true the
>>>>>>>   first conditional should be hit, goto done,  and the second 
>>>>>>> will never
>>>>>>>   evaluate that part to true-- unless the sk is changed (do we 
>>>>>>> need
>>>>>>>   READ_ONCE for sk->sk_reuseport_cb?).
>>>>>>   That's an interesting point... It looks like this function also
>>>>>>   changed in 4.6 from using a single local_bh_disable() at the 
>>>>>> beginning
>>>>>>   with several spin_lock(&head->lock) to exclusively
>>>>>>   spin_lock_bh(&head->lock) at each locking point.  Perhaps the 
>>>>>> full bh
>>>>>>   disable variant was preventing the timers in your stack trace 
>>>>>> from
>>>>>>   running interleaved with this function before?
>>>>> 
>>>>>  Could be, although dropping the lock shouldn't be able to affect 
>>>>> the
>>>>>  search state. TBH, I'm a little lost in reading function, the
>>>>>  SO_REUSEPORT handling is pretty complicated. For instance,
>>>>>  rcu_access_pointer(sk->sk_reuseport_cb) is checked three times 
>>>>> in that
>>>>>  function and also in every call to inet_csk_bind_conflict. I 
>>>>> wonder if
>>>>>  we can simply this under the assumption that SO_REUSEPORT is only
>>>>>  allowed if the port number (snum) is explicitly specified.
>>>> 
>>>>  Ok first I have data for you Hannes, here's the time distributions
>>>>  before during and after the lockup (with all the debugging in 
>>>> place the
>>>>  box eventually recovers).  I've attached it as a text file since 
>>>> it is
>>>>  long.
>>> 
>>> Thanks a lot!
>>> 
>>>>  Second is I was thinking about why we would spend so much time 
>>>> doing the
>>>>  ->owners list, and obviously it's because of the massive amount of
>>>>  timewait sockets on the owners list.  I wrote the following dumb 
>>>> patch
>>>>  and tested it and the problem has disappeared completely.  Now I 
>>>> don't
>>>>  know if this is right at all, but I thought it was weird we 
>>>> weren't
>>>>  copying the soreuseport option from the original socket onto the 
>>>> twsk.
>>>>  Is there are reason we aren't doing this currently?  Does this 
>>>> help
>>>>  explain what is happening?  Thanks,
>>> 
>>> The patch is interesting and a good clue, but I am immediately a bit
>>> concerned that we don't copy/tag the socket with the uid also to 
>>> keep
>>> the security properties for SO_REUSEPORT. I have to think a bit more
>>> about this.
>>> 
>>> We have seen hangs during connect. I am afraid this patch wouldn't 
>>> help
>>> there while also guaranteeing uniqueness.
>> 
>> 
>> Yeah so I looked at the code some more and actually my patch is 
>> really bad.  If sk2->sk_reuseport is set we'll look at 
>> sk2->sk_reuseport_cb, which is outside of the timewait sock, so 
>> that's definitely bad.
>> 
>> But we should at least be setting it to 0 so that we don't do this 
>> normally.  Unfortunately simply setting it to 0 doesn't fix the 
>> problem.  So for some reason having ->sk_reuseport set to 1 on a 
>> timewait socket makes this problem non-existent, which is strange.
>> 
>> So back to the drawing board I guess.  I wonder if doing what craig 
>> suggested and batching the timewait timer expires so it hurts less 
>> would accomplish the same results.  Thanks,
> 
> Wait no I lied, we access the sk->sk_reuseport_cb, not sk2's.  This 
> is the code
> 
>                        if ((!reuse || !sk2->sk_reuse ||
>                            sk2->sk_state == TCP_LISTEN) &&
>                            (!reuseport || !sk2->sk_reuseport ||
>                             rcu_access_pointer(sk->sk_reuseport_cb) ||
>                             (sk2->sk_state != TCP_TIME_WAIT &&
>                             !uid_eq(uid, sock_i_uid(sk2))))) {
> 
>                                if (!sk2->sk_rcv_saddr || 
> !sk->sk_rcv_saddr ||
>                                    sk2->sk_rcv_saddr == 
> sk->sk_rcv_saddr)
>                                        break;
>                        }
> 
> so in my patches case we now have reuseport == 1, sk2->sk_reuseport 
> == 1.  But now we are using reuseport, so sk->sk_reuseport_cb should 
> be non-NULL right?  So really setting the timewait sock's 
> sk_reuseport should have no bearing on how this loop plays out right? 
>  Thanks,


So more messing around and I noticed that we basically don't do the 
tb->fastreuseport logic at all if we've ended up with a non 
SO_REUSEPORT socket on that tb.  So before I fully understood what I 
was doing I fixed it so that after we go through ->bind_conflict() once 
with a SO_REUSEPORT socket, we reset tb->fastreuseport to 1 and set the 
uid to match the uid of the socket.  This made the problem go away.  
Tom pointed out that if we bind to the same port on a different address 
and we have a non SO_REUSEPORT socket with the same address on this tb 
then we'd be screwed with my code.

Which brings me to his proposed solution.  We need another hash table 
that is indexed based on the binding address.  Then each node 
corresponds to one address/port binding, with non-SO_REUSEPORT entries 
having only one entry, and normal SO_REUSEPORT entries having many.  
This cleans up the need to search all the possible sockets on any given 
tb, we just go and look at the one we care about.  Does this make 
sense?  Thanks,

Josef
