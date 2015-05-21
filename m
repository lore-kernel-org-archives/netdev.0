From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net-next 1/4] bpf: allow bpf programs to tail-call other
 bpf programs
Date: Thu, 21 May 2015 09:57:57 -0700
Message-ID: <CALCETrWLpL8o9=P0sDGXUgcQ_LOkgJGrVdv0R6eaec=+WHPfkg@mail.gmail.com>
References: <1432079946-9878-1-git-send-email-ast@plumgrid.com>
 <1432079946-9878-2-git-send-email-ast@plumgrid.com> <CALCETrVP=7sCM12cCZVZCCMozGcHyqTsOFvjv7cEpc7Frxj4Xg@mail.gmail.com>
 <555BD2E4.5050608@plumgrid.com> <CALCETrVNwOVRJ4KH6mEo4hPq_QjTCb8mcwRf1sy5kd1nmnSZ+A@mail.gmail.com>
 <555E0A93.2020803@plumgrid.com> <CALCETrX7xAuRoRv7WV+LS-r_pOknQdXPpBEbFy5TqB_6eGTD5Q@mail.gmail.com>
 <555E0D81.6060703@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Zi Shen Lim <zlim.lnx@gmail.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:36489 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756230AbbEUQ6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 12:58:19 -0400
Received: by lbbqq2 with SMTP id qq2so22669210lbb.3
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 09:58:18 -0700 (PDT)
In-Reply-To: <555E0D81.6060703@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2015 at 9:53 AM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On 5/21/15 9:43 AM, Andy Lutomirski wrote:
>>
>> On Thu, May 21, 2015 at 9:40 AM, Alexei Starovoitov <ast@plumgrid.com>
>> wrote:
>>>
>>> On 5/21/15 9:20 AM, Andy Lutomirski wrote:
>>>>
>>>>
>>>>
>>>> What I mean is: why do we need the interface to be "look up this index
>>>> in an array and just to what it references" as a single atomic
>>>> instruction?  Can't we break it down into first "look up this index in
>>>> an array" and then "do this tail call"?
>>>
>>>
>>>
>>> I've actually considered to do this split and do first part as map lookup
>>> and 2nd as 'tail call to this ptr' insn, but it turned out to be
>>> painful: verifier gets more complicated, ctx pointer needs to kept
>>> somewhere, JITs need to special case two things instead of one.
>>> Also I couldn't see a use case for exposing program pointer to the
>>> program itself. I've explored this path only because it felt more
>>> traditional 'goto *ptr' like, but adding new PTR_TO_PROG type to
>>> verifier looked wasteful.
>>
>>
>> At some point, I think that it would be worth extending the verifier
>> to support more general non-integral scalar types. "Pointer to
>> tail-call target" would be just one of them.  "Pointer to skb" might
>> be nice as a real first-class scalar type that lives in a register as
>> opposed to just being magic typed context.
>
>
> well, I don't see a use case for 'pointer to tail-call target',
> but more generic 'pointer to skb' indeed is a useful concept.
> I was thinking more like 'pointer to structure of the type X',
> then we can natively support 'pointer to task_struct',
> 'pointer to inode', etc which will help tracing programs to be
> written in more convenient way.
> Right now pointer walking has to be done via bpf_probe_read()
> helper as demonstrated in tracex1_kern.c example.
> With this future 'pointer to struct of type X' knowledge in verifier
> we'll be able to do 'ptr->field' natively with higher performance.

If you implement that, then you get "pointer to tail-call target" as
well, right?  You wouldn't be allowed to dereference the pointer, but
you could jump to it.

>
>> We'd still need some way to stick fds into a map, but that's not
>> really the verifier's problem.
>
>
> well, they both need to be aware of that. When it comes to safety
> generalization suffers. Have to do extra checks both in map_update_elem
> and in verifier. No way around that.
>

Sure, the verifier needs to know that the things you read from the map
are "pointer to tail-call target", but that seems like a nice thing to
generalize, too.  After all, you could also have arrays of pointers to
other things, too.

--Andy
