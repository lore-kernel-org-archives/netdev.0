From: Josef Bacik <jbacik@fb.com>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Sat, 17 Dec 2016 13:26:00 +0000
Message-ID: <286A21B1-2A15-4DDF-B334-A016DA3D52EA@fb.com>
References: <CALx6S36OVUqAxq9vNnfHp2eJOuG+gSSg896zzaZoc3Og4tyxFw@mail.gmail.com>
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
 <1481926135.24490.8@smtp.office365.com>
 <CALx6S34qacbD-zxvEJyDVsp1_U_tkL_t0hEXrtfffBALsDMxEw@mail.gmail.com>
 <1481928610.17731.0@smtp.office365.com>,<e32b5375-38fb-1fd8-d97a-bf740e368205@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Tom Herbert <tom@herbertland.com>,
        Craig Gallek <kraigatgoog@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45159 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752614AbcLQN0h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 08:26:37 -0500
In-Reply-To: <e32b5375-38fb-1fd8-d97a-bf740e368205@stressinduktion.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Dec 17, 2016, at 6:09 AM, Hannes Frederic Sowa <hannes@stressinduktion=
.org> wrote:
>=20
>> On 16.12.2016 23:50, Josef Bacik wrote:
>>> On Fri, Dec 16, 2016 at 5:18 PM, Tom Herbert <tom@herbertland.com> wrot=
e:
>>>> On Fri, Dec 16, 2016 at 2:08 PM, Josef Bacik <jbacik@fb.com> wrote:
>>>>> On Fri, Dec 16, 2016 at 10:21 AM, Josef Bacik <jbacik@fb.com> wrote:
>>>>>=20
>>>>>> On Fri, Dec 16, 2016 at 9:54 AM, Josef Bacik <jbacik@fb.com> wrote:
>>>>>>=20
>>>>>> On Thu, Dec 15, 2016 at 7:07 PM, Hannes Frederic Sowa
>>>>>> <hannes@stressinduktion.org> wrote:
>>>>>>>=20
>>>>>>> Hi Josef,
>>>>>>>=20
>>>>>>>> On 15.12.2016 19:53, Josef Bacik wrote:
>>>>>>>>=20
>>>>>>>>  On Tue, Dec 13, 2016 at 6:32 PM, Tom Herbert <tom@herbertland.com=
>
>>>>>>>> wrote:
>>>>>>>>>=20
>>>>>>>>>  On Tue, Dec 13, 2016 at 3:03 PM, Craig Gallek
>>>>>>>>> <kraigatgoog@gmail.com>
>>>>>>>>>  wrote:
>>>>>>>>>>=20
>>>>>>>>>>   On Tue, Dec 13, 2016 at 3:51 PM, Tom Herbert
>>>>>>>>>> <tom@herbertland.com>
>>>>>>>>>>  wrote:
>>>>>>>>>>>=20
>>>>>>>>>>>   I think there may be some suspicious code in
>>>>>>>>>>> inet_csk_get_port. At
>>>>>>>>>>>   tb_found there is:
>>>>>>>>>>>=20
>>>>>>>>>>>                   if (((tb->fastreuse > 0 && reuse) ||
>>>>>>>>>>>                        (tb->fastreuseport > 0 &&
>>>>>>>>>>>=20
>>>>>>>>>>> !rcu_access_pointer(sk->sk_reuseport_cb) &&
>>>>>>>>>>>                         sk->sk_reuseport && uid_eq(tb->fastuid,
>>>>>>>>>>>  uid))) &&
>>>>>>>>>>>                       smallest_size =3D=3D -1)
>>>>>>>>>>>                           goto success;
>>>>>>>>>>>                   if
>>>>>>>>>>> (inet_csk(sk)->icsk_af_ops->bind_conflict(sk,
>>>>>>>>>>>  tb, true)) {
>>>>>>>>>>>                           if ((reuse ||
>>>>>>>>>>>                                (tb->fastreuseport > 0 &&
>>>>>>>>>>>                                 sk->sk_reuseport &&
>>>>>>>>>>>=20
>>>>>>>>>>>  !rcu_access_pointer(sk->sk_reuseport_cb) &&
>>>>>>>>>>>                                 uid_eq(tb->fastuid, uid))) &&
>>>>>>>>>>>                               smallest_size !=3D -1 &&
>>>>>>>>>>> --attempts >=3D
>>>>>>>>>>> 0) {
>>>>>>>>>>>                                   spin_unlock_bh(&head->lock);
>>>>>>>>>>>                                   goto again;
>>>>>>>>>>>                           }
>>>>>>>>>>>                           goto fail_unlock;
>>>>>>>>>>>                   }
>>>>>>>>>>>=20
>>>>>>>>>>>   AFAICT there is redundancy in these two conditionals.  The
>>>>>>>>>>> same
>>>>>>>>>>> clause
>>>>>>>>>>>   is being checked in both: (tb->fastreuseport > 0 &&
>>>>>>>>>>>   !rcu_access_pointer(sk->sk_reuseport_cb) &&
>>>>>>>>>>> sk->sk_reuseport &&
>>>>>>>>>>>   uid_eq(tb->fastuid, uid))) && smallest_size =3D=3D -1. If thi=
s
>>>>>>>>>>> is true
>>>>>>>>>>> the
>>>>>>>>>>>   first conditional should be hit, goto done,  and the second
>>>>>>>>>>> will
>>>>>>>>>>> never
>>>>>>>>>>>   evaluate that part to true-- unless the sk is changed (do
>>>>>>>>>>> we need
>>>>>>>>>>>   READ_ONCE for sk->sk_reuseport_cb?).
>>>>>>>>>>=20
>>>>>>>>>>   That's an interesting point... It looks like this function als=
o
>>>>>>>>>>   changed in 4.6 from using a single local_bh_disable() at the
>>>>>>>>>> beginning
>>>>>>>>>>   with several spin_lock(&head->lock) to exclusively
>>>>>>>>>>   spin_lock_bh(&head->lock) at each locking point.  Perhaps
>>>>>>>>>> the full
>>>>>>>>>> bh
>>>>>>>>>>   disable variant was preventing the timers in your stack
>>>>>>>>>> trace from
>>>>>>>>>>   running interleaved with this function before?
>>>>>>>>>=20
>>>>>>>>>=20
>>>>>>>>>  Could be, although dropping the lock shouldn't be able to
>>>>>>>>> affect the
>>>>>>>>>  search state. TBH, I'm a little lost in reading function, the
>>>>>>>>>  SO_REUSEPORT handling is pretty complicated. For instance,
>>>>>>>>>  rcu_access_pointer(sk->sk_reuseport_cb) is checked three times i=
n
>>>>>>>>> that
>>>>>>>>>  function and also in every call to inet_csk_bind_conflict. I
>>>>>>>>> wonder
>>>>>>>>> if
>>>>>>>>>  we can simply this under the assumption that SO_REUSEPORT is onl=
y
>>>>>>>>>  allowed if the port number (snum) is explicitly specified.
>>>>>>>>=20
>>>>>>>>=20
>>>>>>>>  Ok first I have data for you Hannes, here's the time distribution=
s
>>>>>>>>  before during and after the lockup (with all the debugging in
>>>>>>>> place
>>>>>>>> the
>>>>>>>>  box eventually recovers).  I've attached it as a text file
>>>>>>>> since it is
>>>>>>>>  long.
>>>>>>>=20
>>>>>>>=20
>>>>>>> Thanks a lot!
>>>>>>>=20
>>>>>>>>  Second is I was thinking about why we would spend so much time
>>>>>>>> doing
>>>>>>>> the
>>>>>>>>  ->owners list, and obviously it's because of the massive amount o=
f
>>>>>>>>  timewait sockets on the owners list.  I wrote the following
>>>>>>>> dumb patch
>>>>>>>>  and tested it and the problem has disappeared completely.  Now
>>>>>>>> I don't
>>>>>>>>  know if this is right at all, but I thought it was weird we
>>>>>>>> weren't
>>>>>>>>  copying the soreuseport option from the original socket onto
>>>>>>>> the twsk.
>>>>>>>>  Is there are reason we aren't doing this currently?  Does this
>>>>>>>> help
>>>>>>>>  explain what is happening?  Thanks,
>>>>>>>=20
>>>>>>>=20
>>>>>>> The patch is interesting and a good clue, but I am immediately a bi=
t
>>>>>>> concerned that we don't copy/tag the socket with the uid also to
>>>>>>> keep
>>>>>>> the security properties for SO_REUSEPORT. I have to think a bit mor=
e
>>>>>>> about this.
>>>>>>>=20
>>>>>>> We have seen hangs during connect. I am afraid this patch
>>>>>>> wouldn't help
>>>>>>> there while also guaranteeing uniqueness.
>>>>>>=20
>>>>>>=20
>>>>>>=20
>>>>>> Yeah so I looked at the code some more and actually my patch is
>>>>>> really
>>>>>> bad.  If sk2->sk_reuseport is set we'll look at
>>>>>> sk2->sk_reuseport_cb, which
>>>>>> is outside of the timewait sock, so that's definitely bad.
>>>>>>=20
>>>>>> But we should at least be setting it to 0 so that we don't do this
>>>>>> normally.  Unfortunately simply setting it to 0 doesn't fix the
>>>>>> problem.  So
>>>>>> for some reason having ->sk_reuseport set to 1 on a timewait
>>>>>> socket makes
>>>>>> this problem non-existent, which is strange.
>>>>>>=20
>>>>>> So back to the drawing board I guess.  I wonder if doing what craig
>>>>>> suggested and batching the timewait timer expires so it hurts less
>>>>>> would
>>>>>> accomplish the same results.  Thanks,
>>>>>=20
>>>>>=20
>>>>> Wait no I lied, we access the sk->sk_reuseport_cb, not sk2's.  This
>>>>> is the
>>>>> code
>>>>>=20
>>>>>                        if ((!reuse || !sk2->sk_reuse ||
>>>>>                            sk2->sk_state =3D=3D TCP_LISTEN) &&
>>>>>                            (!reuseport || !sk2->sk_reuseport ||
>>>>>                             rcu_access_pointer(sk->sk_reuseport_cb) |=
|
>>>>>                             (sk2->sk_state !=3D TCP_TIME_WAIT &&
>>>>>                             !uid_eq(uid, sock_i_uid(sk2))))) {
>>>>>=20
>>>>>                                if (!sk2->sk_rcv_saddr ||
>>>>> !sk->sk_rcv_saddr
>>>>> ||
>>>>>                                    sk2->sk_rcv_saddr =3D=3D
>>>>> sk->sk_rcv_saddr)
>>>>>                                        break;
>>>>>                        }
>>>>>=20
>>>>> so in my patches case we now have reuseport =3D=3D 1, sk2->sk_reusepo=
rt
>>>>> =3D=3D 1.
>>>>> But now we are using reuseport, so sk->sk_reuseport_cb should be
>>>>> non-NULL
>>>>> right?  So really setting the timewait sock's sk_reuseport should
>>>>> have no
>>>>> bearing on how this loop plays out right?  Thanks,
>>>>=20
>>>>=20
>>>>=20
>>>> So more messing around and I noticed that we basically don't do the
>>>> tb->fastreuseport logic at all if we've ended up with a non
>>>> SO_REUSEPORT
>>>> socket on that tb.  So before I fully understood what I was doing I
>>>> fixed it
>>>> so that after we go through ->bind_conflict() once with a SO_REUSEPORT
>>>> socket, we reset tb->fastreuseport to 1 and set the uid to match the
>>>> uid of
>>>> the socket.  This made the problem go away.  Tom pointed out that if
>>>> we bind
>>>> to the same port on a different address and we have a non SO_REUSEPORT
>>>> socket with the same address on this tb then we'd be screwed with my
>>>> code.
>>>>=20
>>>> Which brings me to his proposed solution.  We need another hash
>>>> table that
>>>> is indexed based on the binding address.  Then each node corresponds
>>>> to one
>>>> address/port binding, with non-SO_REUSEPORT entries having only one
>>>> entry,
>>>> and normal SO_REUSEPORT entries having many.  This cleans up the
>>>> need to
>>>> search all the possible sockets on any given tb, we just go and look
>>>> at the
>>>> one we care about.  Does this make sense?  Thanks,
>>>>=20
>>> Hi Josef,
>>>=20
>>> Thinking about it some more the hash table won't work because of the
>>> rules of binding different addresses to the same port. What I think we
>>> can do is to change inet_bind_bucket to be structure that contains all
>>> the information used to detect conflicts (reuse*, if, address, uid,
>>> etc.) and a list of sockets that share that exact same information--
>>> for instance all socket in timewait state create through some listener
>>> socket should wind up on single bucket. When we do the bind_conflict
>>> function we only should have to walk this buckets, not the full list
>>> of sockets.
>>>=20
>>> Thoughts on this?
>>=20
>> This sounds good, maybe tb->owners be a list of say
>>=20
>> struct inet_unique_shit {
>>    struct sock_common sk;
>>    struct hlist socks;
>> };
>>=20
>> Then we make inet_unique_shit like twsks', just copy the relevant
>> information, then hang the real sockets off of the socks hlist.=20
>> Something like that?  Thanks,
>=20
> As a counter idea: can we push up a flag to the inet_bind_bucket that we
> check in the fast- way style that indicates that we have wildcarded
> non-reuse(port) in there, so we can skip the bind_bucket much more
> quickly? This wouldn't require a new data structure.

So take my current duct tape fix and augment it with more information in th=
e bind bucket?  I'm not sure how to make this work without at least having =
a list of the binded addrs as well to make sure we are really ok.  I suppos=
e we could save the fastreuseport address that last succeeded to make it wo=
rk properly, but I'd have to make it protocol agnostic and then have a call=
back to have the protocol to make sure we don't have to do the bind_conflic=
t run.  Is that what you were thinking of?  Thanks,

Josef=
