From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v8 net-next 1/3] filter: add Extended BPF interpreter and converter
Date: Mon, 10 Mar 2014 19:57:46 -0700
Message-ID: <CAMEtUuy5Hd51_6bnTT5EeU3mwy4brZZb=K+=sycE-msjxSHsog@mail.gmail.com>
References: <1394431444-6987-1-git-send-email-ast@plumgrid.com>
	<1394431444-6987-2-git-send-email-ast@plumgrid.com>
	<20140310.215104.2095195123238829635.davem@davemloft.net>
	<CA+55aFx7rdm9DGOTTgAKTHNkdfrvQYhT9PRs5MhUPr1gQzWEgA@mail.gmail.com>
	<9b7e4f89-468b-4d02-91ea-3e91d61934bd@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Ingo Molnar <mingo@kernel.org>, Will Drewry <wad@chromium.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Jesse Gross <jesse@nicira.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?ISO-8859-1?Q?Fr=E9d=E9ric_Weisbecker?= <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9b7e4f89-468b-4d02-91ea-3e91d61934bd@email.android.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 10, 2014 at 7:20 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> Bool vs bitfield are orthogonal, at least under gcc, unless I'm completely out to sea.  It is probably not a good idea to create a bitfield when it doesn't buy you anything, lest you generate rmw instructions when byte stores would do.
>

access to upper fields of sk_filter is not in critical path, therefore
my preference
is to save space.
In this case:
struct sk_filter {
        atomic_t                refcnt;
        unsigned int            len;
        unsigned int            len_ext;
        bool or unsigned int:1            jited;
        and the rest are pointers.

so either u32:1 or bool approach adds 4 bytes.
The reason I used bitfield is that I was expecting someone to complain
about overall size
increase and I can optimize it later into:
        unsigned int            len:15;
        unsigned int            len_ext:15;
        unsigned int            jited:1;
without touching arch/*/net/*jit files, since filter len fits.

Only lower part is cache sensitive, since 'insns/insns_ext' need to come close
enough to 'bpf_func', so that interpreter (called via SK_RUN_FILTER macro)
starts executing insns out of cache.

Thanks
Alexei

> On March 10, 2014 7:02:18 PM PDT, Linus Torvalds <torvalds@linux-foundation.org> wrote:
>>On Mon, Mar 10, 2014 at 6:51 PM, David Miller <davem@davemloft.net>
>>wrote:
>>> From: Alexei Starovoitov <ast@plumgrid.com>
>>> Date: Sun,  9 Mar 2014 23:04:02 -0700
>>>
>>>> +     unsigned int            jited:1;
>>>
>>> The C language has a proper type for boolean states, please therefore
>>> use 'bool', true, and false.
>>
>>No, the C standard actually has no such thing.
>>
>>In a structure, a bitfield is actually better than bool, because it
>>takes only one bit. A "bool" takes at least a byte.
>>
>>Now, in this case it may not be an issue (looks like there are no
>>other uses that can use the better packing, so bit/byte/word is all
>>the same), but I really really want to make it clear that it is not at
>>all true that "bool" is somehow better than a single-bit bitfield. The
>>bitfield can pack *much* better, and I would actually say that it's
>>generally a *better* idea to use a bitfield, because you can much more
>>easily expand on it later by adding other bitfields.
>>
>>There are very few actual real advantages to "bool". The magic casting
>>behavior is arguably an advantage (the implicit cast in assigning to a
>>bitfield truncates to the low bits, the implicit cast on assignment to
>>"bool" does a test against zero), but is also quite arguably a
>>possible source of confusion and can cause problems down the line when
>>converting from bool to a bitfield (for the afore-mentioned packing
>>reasons).
>>
>>So please don't sell "bool" as some kind of panacea. It has at least
>>as many problems as it has advantages.
>>
>>I would generally suggest that people only use "bool" for function
>>return types, and absolutely nothing else. Seriously.
>>
>>              Linus
>
> --
> Sent from my mobile phone.  Please pardon brevity and lack of formatting.
