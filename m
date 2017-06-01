From: Adel Fuchs via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: Error with printk and bpf_trace_printk
Date: Thu, 1 Jun 2017 14:10:01 +0300
Message-ID: <CAErYV9FFf+70vzpp+0qu0G0PPN0pKd7rfu7CJZ_b-fUrtqjkCw@mail.gmail.com>
References: <CAErYV9EJtbgaWn4KAeoADxnHgj7S+vFdHgu78Y2PxNuhpWrANw@mail.gmail.com>
	<20170530142437.656ec63d@redhat.com>
Reply-To: Adel Fuchs <adelfuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "xdp-newbies-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <xdp-newbies-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org" <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20170530142437.656ec63d-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Jesper,
I tried adding your solution, bpf_debug,  and I'm now able to run the
program with no errors but the trace_pipe file stays empty.
I just added this to my program:

#ifdef DEBUG
/* Only use this for debug output. Notice output from bpf_trace_printk()
* end-up in /sys/kernel/debug/tracing/trace_pipe
*/
#define bpf_debug(fmt, ...) \
({ \
char ____fmt[] = fmt; \
bpf_trace_printk(____fmt, sizeof(____fmt), \
##__VA_ARGS__); \
})
#else
#define bpf_debug(fmt, ...) { } while (0)
#endif


And added a printing command:
bpf_debug("hi");

Do you know what's the problem?

Thanks,
Adel

On Tue, May 30, 2017 at 3:24 PM, Jesper Dangaard Brouer
<brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>
> Notice, there are two mailing lists (Cc'ed) that you should likely ask
> these kind of questions on (instead of netdev), depending on if this is
> mostly related to bpf (iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org) or somehow
> related to XDP (xdp-newbies-u79uwXL29TY76Z2rM5mHXA@public.gmane.org).
>
> See my answer inlined below:
>
> On Sun, 28 May 2017 17:48:20 +0300 Adel Fuchs <adelfuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
>> I have a working eBPF program, and I'm trying to add outputs to it.
>> I'm not able to use both printk and bpf_trace_printk functions. I get
>> this error:
>>
>> ELF contains non-map related relo data in entry 0 pointing to section
>> 8! Compiler bug?!
>>
>> Prog section 'ingress' rejected: Invalid argument (22)!
>>  - Type:         3
>>  - Instructions: 16 (0 over limit)
>>  - License:      GPL
>>
>> Verifier analysis:
>>
>> 0: (bf) r6 = r1
>> 1: (18) r1 = 0x0
>> 3: (85) call bpf_unspec#0
>> unknown func bpf_unspec#0
>>
>> Error fetching program/map!
>> Failed to retrieve (e)BPF data!
>>
>> Are there certain "includes" that I need to add?
>> In addition, I'm not sure I'm using the function correctly. I just
>> wrote: printk("hi")
>
> You obviously cannot call printk directly from and eBPF program.
> I wonder how you got this compiling...
>
> As you hinted yourself, you should be using: bpf_trace_printk().
> But it is actually tricky to use... and not much help is around to
> figure this out.
>
> First of all the output end-up in this file: /sys/kernel/debug/tracing/trace_pipe
> Remember to read the output use 'cat' like:
>
>  sudo cat /sys/kernel/debug/tracing/trace_pipe
>
> And only the first process to read the output gets the output...
>
>
> I deduct you are using the TC/iproute2 examples:
>  https://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git/tree/examples/bpf
>
> Next gotcha is that, you need to provide the char* string in a very
> special way to make this compile correctly.  The iproute2 provide a
> helper define called "printt()" in include/bpf_api.h for this:
>
> #ifndef printt
> # define printt(fmt, ...)                                               \
>         ({                                                              \
>                 char ____fmt[] = fmt;                                   \
>                 trace_printk(____fmt, sizeof(____fmt), ##__VA_ARGS__);  \
>         })
> #endif
>
> Or see my solution here:
> [1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/samples/bpf/xdp_ddos01_blacklist_kern.c#L86:L99
>
>
> Another gotcha I've experienced is that if you format the string
> incorrectly, or use a modifier like %X, which bpf_trace_printk() does
> not seem to understand, then you "hear-nothing"...  Also experienced if
> using more than 3 arguments, then it fails or also go silent. Be
> careful when using this somewhat "flaky" debug facility.
>
> Do remember these bpf_trace_printk() should only be used for debugging,
> as it is very slow...
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   LinkedIn: http://www.linkedin.com/in/brouer
