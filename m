From: pi3orama <pi3orama@163.com>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY maps trace data output when perf sampling
Date: Wed, 21 Oct 2015 23:06:47 +0800
Message-ID: <586A5B33-C9C9-433D-B6E9-019264BF7DDB@163.com>
References: <1445325735-121694-2-git-send-email-xiakaixu@huawei.com> <5626C5CE.8080809@plumgrid.com> <20151021091254.GF2881@worktop.programming.kicks-ass.net> <56276968.6070604@huawei.com> <20151021113316.GM17308@twins.programming.kicks-ass.net> <56277BCE.6030400@huawei.com> <20151021121713.GC3604@twins.programming.kicks-ass.net> <56279634.5000606@huawei.com> <20151021134951.GH3604@twins.programming.kicks-ass.net> <1D2C9396-01CB-4981-B493-EA311F0457E7@163.com> <20151021140921.GI3604@twins.programming.kicks-ass.net>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Wangnan (F)" <wangnan0@huawei.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	xiakaixu <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net,
	linux-kernel@vger.kernel.org, hekuang@huawei.com,
	netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151021140921.GI3604@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



=B7=A2=D7=D4=CE=D2=B5=C4 iPhone

> =D4=DA 2015=C4=EA10=D4=C221=C8=D5=A3=AC=CF=C2=CE=E710:09=A3=ACPeter Z=
ijlstra <peterz@infradead.org> =D0=B4=B5=C0=A3=BA
>=20
> On Wed, Oct 21, 2015 at 10:01:46PM +0800, pi3orama wrote:
>>> =D4=DA 2015=C4=EA10=D4=C221=C8=D5=A3=AC=CF=C2=CE=E79:49=A3=ACPeter =
Zijlstra <peterz@infradead.org> =D0=B4=B5=C0=A3=BA
>>>=20
>>>> On Wed, Oct 21, 2015 at 09:42:12PM +0800, Wangnan (F) wrote:
>>>> How can an eBPF program access a !local event:
>>>>=20
>>>> when creating perf event array we don't care which perf event
>>>> is for which CPU, so perf program can access any perf event in
>>>> that array.
>>>=20
>>> So what is stopping the eBPF thing from calling perf_event_read_loc=
al()
>>> on a !local event and triggering a kernel splat?
>>=20
>> I can understand the perf_event_read_local() case, but I really can'=
t understand
>> what is stopping us to write to an atomic field belong to a !local p=
erf event.
>> Could you please give a further explanation?
>=20
> I simply do not get how this eBPF stuff works.
>=20
> Either I have access to !local events and I can hand one to
> perf_event_read_local() and cause badness, or I do not have access to
> !local events and the whole 'soft enable/disable' thing is simple.
>=20
> They cannot be both true.
>=20
> So explain; how does this eBPF stuff work.

I think I get your point this time, and let me explain the eBPF stuff t=
o you.

You are aware that BPF programmer can break the system in this way:

A=3Dget_non_local_perf_event()
perf_event_read_local(A)
BOOM!

However the above logic is impossible because BPF program can't work th=
is
way.

=46irst of all, it is impossible for a BPF program directly invoke a ke=
rnel function.=20
Doesn't like kernel module, BPF program can only invoke functions desig=
ned for=20
them, like what this patch does. So the ability of BPF programs is stri=
ctly
restricted by kernel. If we don't allow BPF program call perf_event_rea=
d_local()
across core, we can check this and return error in function we provide =
for them.

Second: there's no way for a BPF program directly access a perf event. =
All perf
events have to be wrapped by a map and be accessed by BPF functions des=
cribed
above. We don't allow BPF program fetch array element from that map. So=
=20
pointers of perf event is safely protected from BPF program.

In summary, your either-or logic doesn't hold in BPF world. A BPF progr=
am can
only access perf event in a highly restricted way. We don't allow it ca=
lling
perf_event_read_local() across core, so it can't.

Thank you.
