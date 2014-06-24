From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v6 net-next 1/4] net: flow_dissector: avoid multiple calls
 in eBPF
Date: Tue, 24 Jun 2014 10:14:55 +0200
Message-ID: <53A9337F.50707@redhat.com>
References: <1398882591-30422-1-git-send-email-chema@google.com> <1401389758-13252-1-git-send-email-chema@google.com> <5387C8AD.6000909@redhat.com> <CA+ZOOTNobzzJPgQnVVZ+b6rRD=0_pdjUB8q5FQVkbO+dob0BSg@mail.gmail.com> <538C6FD8.9040305@redhat.com> <CAMEtUuyduk1sHBeVm=d5GYEgB4ma7sVFYeBLdapbeEpQY9nA1Q@mail.gmail.com> <538D884E.5030007@redhat.com> <CAMEtUuxK5hV_eORRLaSHSiwF5X82Ae91vL6W0-6au48v8H6bAA@mail.gmail.com> <CA+ZOOTPdDDeGxZVGXVRZmjkxqkGefgDLrawo_9YXbjwTQ_FLzA@mail.gmail.com> <538EDE1A.8060305@redhat.com> <CA+ZOOTONwNt2xpwUc=tqhP=m31KZTzij-rrAHVh6g3hVYgKaEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Chema Gonzalez <chema@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+ZOOTONwNt2xpwUc=tqhP=m31KZTzij-rrAHVh6g3hVYgKaEw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/20/2014 11:56 PM, Chema Gonzalez wrote:
...
>>>> Anyway as I said before I'm not excited about either.
>>>> I don't think we should be adding classic BPF extensions any more.
>>>> The long term headache of supporting classic BPF extensions
>>>> outweighs the short term benefits.
 >>>
>>> I see a couple of issues with (effectively) freezing classic BPF
>>> development while waiting for direct eBPF access to happen. The first
>>> one is that the kernel has to accept it. I can see many questions
>>> about this, especially security and usability (I'll send an email
>>> about the "split BPF out of core later"). Now, the main issue is
>>> whether/when the tools will support it. IMO, this is useful iff I can
>>> quickly write/reuse filters and run tcpdump filters based on them. I'm
>>> trying to get upstream libpcap to accept support for raw (classic) BPF
>>> filters, and it's taking a long time. I can imagine how they may be
>>> less receptive about supporting a Linux-only eBPF mechanism. Tools do
>>> matter.
 >
> This is a high-level decision, more than a technical one. Do we want
> to freeze classic BPF development in linux, even before we have a
> complete eBPF replacement, and zero eBPF tool (libpcap) support?

In my opinion, I don't think we strictly have to hard-freeze it. The
only concern I see is that conceptually hooking into the flow_dissector
to read out all keys for further processing on top of them 1) sort
of breaks/bypasses the concept of BPF (as it's actually the task of
BPF itself for doing this), 2) effectively freezes any changes to the
flow_dissector as BPF applications making use of it now depend on the
provided offsets for doing further processing on top of them, 3) it
can already be resolved by (re-)writing the kernel's flow dissector
in C-like syntax in user space iff eBPF can be loaded from there with
similar performance. So shouldn't we rather work towards that as a
more generic approach/goal in the mid term and w/o having to maintain
a very short term intermediate solution that we need to special case
along the code and have to carry around forever ...

>> Grepping through libpcap code, which tries to be platform independent,
>> it seems after all the years, the only thing where you can see support
>> for in their code is SKF_AD_PKTTYPE and SKF_AD_PROTOCOL. Perhaps they
 >
> Actually they recently added MOD/XOR support. Woo-hoo!

Great to hear, still quite some things missing, unfortunately. :/

>> just don't care, perhaps they do, who knows, but it looks to me a bit
>> that they are reluctant to these improvements, maybe for one reason
>> that other OSes don't support it.
 >
>  From the comments in the MOD/XOR patch, the latter seem to be the issue.

Yep, that's the pain you need to live with when trying to be multi
OS capable. I assume in its very origin, the [libpcap] compiler was
probably not designed for handling such differences in various
operating systems (likely even ran in user space from libpcap directly).

>> That was also one of the reasons that
>> led me to start writing bpf_asm (net/tools/) for having a small DSL
>> for more easily trying out BPF code while having _full_ control over it.
>>
>> Maybe someone should start a binary-compatible Linux-only version of
>> libpcap, where tcpdump will transparently make use of these low level
>> improvements eventually. </rant> ;)
 >
> There's too much code dependent on libpcap to make a replacement possible.

Well, I wrote binary-compatible, so applications on top of it won't
care much if it could be used as drop-in replacement. That would perhaps
also allow for fanout and other features to be used ...
