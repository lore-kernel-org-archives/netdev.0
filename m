From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Tue, 06 Oct 2015 10:39:45 +0200
Message-ID: <561388D1.30406@iogearbox.net>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com> <1444078101-29060-2-git-send-email-ast@plumgrid.com> <5612F639.2050305@iogearbox.net> <56131B1F.80002@plumgrid.com> <20151006071347.GB14093@gmail.com> <561380BB.4040506@iogearbox.net> <20151006082048.GA18287@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151006082048.GA18287-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/06/2015 10:20 AM, Ingo Molnar wrote:
>
> * Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org> wrote:
>
>> On 10/06/2015 09:13 AM, Ingo Molnar wrote:
>>>
>>> * Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>>>
>>>> On 10/5/15 3:14 PM, Daniel Borkmann wrote:
>>>>> One scenario that comes to mind ... what happens when there are kernel
>>>>> pointers stored in skb->cb[] (either from the current layer or an old
>>>>> one from a different layer that the skb went through previously, but
>>>>> which did not get overwritten)?
>>>>>
>>>>> Socket filters could read a portion of skb->cb[] also when unprived and
>>>>> leak that out through maps. I think the verifier doesn't catch that,
>>>>> right?
>>>>
>>>> grrr. indeed. previous layer before sk_filter() can leave junk in there.
>>>
>>> Could this be solved by activating zeroing/sanitizing of this data if there's an
>>> active BPF function around that can access that socket?
>>
>> I think this check could only be done in sk_filter() for testing these
>> conditions (unprivileged user + access to cb area), so it would need to
>> happen from outside a native eBPF program. :/
>
> Yes, the kernel (with code running outside of any eBPF program) would guarantee
> that those data fields are zeroed/sanitized, if there's an eBPF program that is
> attached to that socket.
>
>> [...] Also classic BPF would then need to test for it, since a socket filter
>> doesn't really know whether native eBPF is loaded there or a classic-to-eBPF
>> transformed one, and classic never makes use of this. Anyway, it could be done
>> by adding a bit flag cb_access:1 to the bpf_prog, set it during eBPF
>> verification phase, and test it inside sk_filter() if I see it correctly.
>
> That could also be done in an unlikely() branch, to keep the cost to the non-eBPF
> case near zero.

Yes, agreed. For the time being, the majority of users are coming from the
classic BPF side anyway and the unlikely() could still be changed later on
if it should not be the case anymore. The flag and bpf_func would share the
same cacheline as well.

>> The reason is that this sanitizing must only be done in the 'top-level' program
>> that is run from sk_filter() _directly_, because a user at any time could decide
>> to put an already loaded eBPF fd into a tail call map. And cb[] is then used to
>> pass args/state around between two programs, thus it cannot be unconditionally
>> cleared from within the program. The association to a socket filter
>> (SO_ATTACH_BPF) happens at a later time after a native eBPF program has already
>> been loaded via bpf(2).
>
> So zeroing tends to be very cheap and it could also be beneficial to performance
> in terms of bringing the cacheline into the CPU cache. But I really don't know the
> filter code so I'm just handwaving.
>
> Thanks,
>
> 	Ingo
