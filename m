From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Tue, 6 Oct 2015 10:50:36 -0700
Message-ID: <561409EC.5050005@plumgrid.com>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
 <1444078101-29060-2-git-send-email-ast@plumgrid.com>
 <5612F639.2050305@iogearbox.net> <56131B1F.80002@plumgrid.com>
 <20151006071347.GB14093@gmail.com> <561380BB.4040506@iogearbox.net>
 <20151006082048.GA18287@gmail.com> <561388D1.30406@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <561388D1.30406-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/6/15 1:39 AM, Daniel Borkmann wrote:
>>> [...] Also classic BPF would then need to test for it, since a socket
>>> filter
>>> doesn't really know whether native eBPF is loaded there or a
>>> classic-to-eBPF
>>> transformed one, and classic never makes use of this. Anyway, it
>>> could be done
>>> by adding a bit flag cb_access:1 to the bpf_prog, set it during eBPF
>>> verification phase, and test it inside sk_filter() if I see it
>>> correctly.
>>
>> That could also be done in an unlikely() branch, to keep the cost to
>> the non-eBPF
>> case near zero.
>
> Yes, agreed. For the time being, the majority of users are coming from the
> classic BPF side anyway and the unlikely() could still be changed later on
> if it should not be the case anymore. The flag and bpf_func would share the
> same cacheline as well.

was also thinking that we can do it only in paths that actually
have multiple protocol layers, since today bpf is mainly used with
tcpdump(raw_socket) and new af_packet fanout both have cb cleared
on RX, because it just came out of alloc_skb and no layers were called,
and on TX we can clear 20 bytes in dev_queue_xmit_nit().
af_unix/netlink also have clean skb. Need to analyze tun and sctp...
but it feels overly fragile to save a branch in sk_filter,
so planning to go with
if(unlikely(prog->cb_access)) memset in sk_filter().
