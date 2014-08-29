From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v8 net-next 2/2] net: filter: split filter.h and expose
 eBPF to user space
Date: Fri, 29 Aug 2014 11:02:58 -0700
Message-ID: <CAADnVQJbgiUK1vt_SDEG6Yee-Ht67e2M82PrHb3Kx533BOF-rg@mail.gmail.com>
References: <1409171833-6979-1-git-send-email-ast@plumgrid.com>
	<1409171833-6979-3-git-send-email-ast@plumgrid.com>
	<5400BAB7.80001@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5400BAB7.80001-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 29, 2014 at 10:39 AM, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On 08/27/2014 10:37 PM, Alexei Starovoitov wrote:
>>
>> allow user space to generate eBPF programs
>>
>> uapi/linux/bpf.h: eBPF instruction set definition
>>
>> linux/filter.h: the rest
>
>
> Very sorry for being late, but just a thought since we're touching user
> space headers anyway ...
>
> Wouldn't it be more consistent to have it organized as follows ...
>
>  - uapi/linux/bpf.h    : classic BPF instruction set parts only
>  - uapi/linux/ebpf.h   : eBPF instruction set definition (which also
>                          includes uapi/linux/bpf.h though)
> ... and have ...
>
>  - uapi/linux/filter.h : just include uapi/linux/bpf.h but rest is empty
>
> That way, it would be more consistent ...
>
> Old legacy application can stay with linux/filter.h; new applications
> based on their needs can choose between linux/{e,}bpf.h and in the kernel,
> we can just include linux/ebpf.h.
>
> Right now, it seems, an eBPF user space program would need to include
> 2 header files in user space (linux/filter.h, linux/bpf.h) which I find
> a bit confusing.

It's been bugging me as well, but I suspect having it the way you
described won't work. Mainly because we cannot do include <uapi/..>
inside uapi/*.h, so we would need to do include <linux/bpf.h>
inside uapi/linux/filter.h, but that will cause serious include path
confusion. That was the reason I didn't simply do include <linux/filter.h>
inside uapi/linux/bpf.h

Also I really dislike 'ebpf' name in all lower case. If we make such header
file name, we would need to rename all macros and function names
to EBPF_... which I find very ugly looking. I think all good abbreviations are
three letters :)
So I very much prefer bpf.h as a main file name.
Later we can move some of old classic BPF defines into
uapi/linux/bpf_common.h and then include it in both uapi/linux/bpf.h
and in uapi/linux/filter.h, then the nuisance of two include files for
user space will go away. Classic users will keep using linux/filter.h
and new apps will include linux/bpf.h only.
I think we should probably do such header optimization later and very carefully.
I'm a bit afraid to touch uapi/linux/filter.h since it's used in so
many user apps.
