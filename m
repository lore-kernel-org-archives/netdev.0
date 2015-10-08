From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v2 net-next 1/3] bpf: enable non-root eBPF programs
Date: Thu, 8 Oct 2015 15:05:28 -0700
Message-ID: <5616E8A8.5020809@plumgrid.com>
References: <1444281803-24274-1-git-send-email-ast@plumgrid.com>
 <1444281803-24274-2-git-send-email-ast@plumgrid.com>
 <1444328452.3935641.405110585.76554E06@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1444328452.3935641.405110585.76554E06-2RFepEojUI2N1INw9kWLP6GC3tUn3ZHUQQ4Iyu8u01E@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/8/15 11:20 AM, Hannes Frederic Sowa wrote:
> Hi Alexei,
>
> On Thu, Oct 8, 2015, at 07:23, Alexei Starovoitov wrote:
>> The feature is controlled by sysctl kernel.unprivileged_bpf_disabled.
>> This toggle defaults to off (0), but can be set true (1).  Once true,
>> bpf programs and maps cannot be accessed from unprivileged process,
>> and the toggle cannot be set back to false.
>
> This approach seems fine to me.
>
> I am wondering if it makes sense to somehow allow ebpf access per
> namespace? I currently have no idea how that could work and on which
> namespace type to depend or going with a prctl or even cgroup maybe. The
> rationale behind this is, that maybe some namespaces like openstack
> router namespaces could make usage of advanced ebpf capabilities in the
> kernel, while other namespaces, especially where untrusted third parties
> are hosted, shouldn't have access to those facilities.
>
> In that way, hosters would be able to e.g. deploy more efficient
> performance monitoring container (which should still need not to run as
> root) while the majority of the users has no access to that. Or think
> about routing instances in some namespaces, etc. etc.

when we're talking about eBPF for networking or performance monitoring
it's all going to be under root anyway. The next question is
how to let the programs run only for traffic or for applications within
namespaces. Something gotta do this demux. It either can be in-kernel
C code which is configured via some API that calls different eBPF
programs based on cgroup or based on netns, or it can be another
eBPF program that does demux on its own.
In case of tracing such 'demuxing' program can be attached to kernel
events and call 'worker' programs via tail_call, so that 'worker'
programs will have an illusion that they're working only with events
that belong to their namespace.
imo existing facilities already allow 'per namespace' eBPF, though
the prog_array used to jump from 'demuxing' bpf into 'worker' bpf
currently is a bit awkward to use (because of FD passing via daemon),
but that will get solved soon.
It feels that in-kernel C code doing filtering may be
'more robust' from namespace isolation point of view, but I don't
think we have a concrete and tested proposal, so I would
experiment with 'demuxing' bpf first.
The programs in general don't have a notion of namespace. They
need to be attached to veth via TC to get packets for
particular namespace.
