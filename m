From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next 1/4] bpf: allow bpf programs to tail-call other
 bpf programs
Date: Thu, 21 May 2015 10:16:52 -0700
Message-ID: <555E1304.7080909@plumgrid.com>
References: <1432079946-9878-1-git-send-email-ast@plumgrid.com> <1432079946-9878-2-git-send-email-ast@plumgrid.com> <CALCETrVP=7sCM12cCZVZCCMozGcHyqTsOFvjv7cEpc7Frxj4Xg@mail.gmail.com> <555BD2E4.5050608@plumgrid.com> <CALCETrVNwOVRJ4KH6mEo4hPq_QjTCb8mcwRf1sy5kd1nmnSZ+A@mail.gmail.com> <555E0A93.2020803@plumgrid.com> <CALCETrX7xAuRoRv7WV+LS-r_pOknQdXPpBEbFy5TqB_6eGTD5Q@mail.gmail.com> <555E0D81.6060703@plumgrid.com> <CALCETrWLpL8o9=P0sDGXUgcQ_LOkgJGrVdv0R6eaec=+WHPfkg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Michael Holzheu <holzheu-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Zi Shen Lim <zlim.lnx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrWLpL8o9=P0sDGXUgcQ_LOkgJGrVdv0R6eaec=+WHPfkg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 5/21/15 9:57 AM, Andy Lutomirski wrote:
> On Thu, May 21, 2015 at 9:53 AM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>> On 5/21/15 9:43 AM, Andy Lutomirski wrote:
>>>
>>> On Thu, May 21, 2015 at 9:40 AM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
>>> wrote:
>>>>
>>>> On 5/21/15 9:20 AM, Andy Lutomirski wrote:
>>>>>
>>>>>
>>>>>
>>>>> What I mean is: why do we need the interface to be "look up this index
>>>>> in an array and just to what it references" as a single atomic
>>>>> instruction?  Can't we break it down into first "look up this index in
>>>>> an array" and then "do this tail call"?
>>>>
>>>>
>>>>
>>>> I've actually considered to do this split and do first part as map lookup
>>>> and 2nd as 'tail call to this ptr' insn, but it turned out to be
>>>> painful: verifier gets more complicated, ctx pointer needs to kept
>>>> somewhere, JITs need to special case two things instead of one.
>>>> Also I couldn't see a use case for exposing program pointer to the
>>>> program itself. I've explored this path only because it felt more
>>>> traditional 'goto *ptr' like, but adding new PTR_TO_PROG type to
>>>> verifier looked wasteful.
>>>
>>>
>>> At some point, I think that it would be worth extending the verifier
>>> to support more general non-integral scalar types. "Pointer to
>>> tail-call target" would be just one of them.  "Pointer to skb" might
>>> be nice as a real first-class scalar type that lives in a register as
>>> opposed to just being magic typed context.
>>
>>
>> well, I don't see a use case for 'pointer to tail-call target',
>> but more generic 'pointer to skb' indeed is a useful concept.
>> I was thinking more like 'pointer to structure of the type X',
>> then we can natively support 'pointer to task_struct',
>> 'pointer to inode', etc which will help tracing programs to be
>> written in more convenient way.
>> Right now pointer walking has to be done via bpf_probe_read()
>> helper as demonstrated in tracex1_kern.c example.
>> With this future 'pointer to struct of type X' knowledge in verifier
>> we'll be able to do 'ptr->field' natively with higher performance.
>
> If you implement that, then you get "pointer to tail-call target" as
> well, right?  You wouldn't be allowed to dereference the pointer, but
> you could jump to it.

not really. Such 'pointer to tail-call target' would still be separate
type and treated specially through the verifier.
'pointer to datastructure' can be generalized for different structs,
because they are data, whereas 'pointer to code' is different in
a sense of what program will be able to do with such pointer.
The program will be able to read certain fields with proper alignment
from such 'pointer to datastruct' and type of datastruct would need
to be tracked, but 'pointer to code' have nothing interesting from
the program point of view. It can only jump there.
It cannot store in anywhere, because the life time of code pointer
is within this program lifetime (programs run under rcu).
As soon as program got this 'pointer to code' it needs to jump to it.
Whereas 'pointer to data' have different lifetimes.

>>> We'd still need some way to stick fds into a map, but that's not
>>> really the verifier's problem.
>>
>>
>> well, they both need to be aware of that. When it comes to safety
>> generalization suffers. Have to do extra checks both in map_update_elem
>> and in verifier. No way around that.
>>
>
> Sure, the verifier needs to know that the things you read from the map
> are "pointer to tail-call target", but that seems like a nice thing to
> generalize, too.  After all, you could also have arrays of pointers to
> other things, too.

Theoretically, yes, but I'd like to implement only practical things ;)
This bpf_tail_call() solves real need while 'array of pointers to
other things' sounds really nice, but I don't see a demand for it yet.
I'm not saying we'll never implement it, only not right now.
