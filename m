From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2] tracing/kprobes: expose maxactive for kretprobe in
 kprobe_events
Date: Fri, 31 Mar 2017 10:08:39 -0400
Message-ID: <20170331100839.45f42b8c@gandalf.local.home>
References: <1490966424-20335-1-git-send-email-alban@kinvolk.io>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alban Crequy <alban@kinvolk.io>,
        Alexei Starovoitov <ast@kernel.org>,
        Jonathan Corbet <corbet@lwn.net>,
        Ingo Molnar <mingo@redhat.com>, Shuah Khan <shuah@kernel.org>,
        Masami Hiramatsu <mhiramat@kernel.org>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Omar Sandoval <osandov@fb.com>,
        Anton Blanchard <anton@samba.org>, linux-doc@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-kselftest@vger.kernel.org, iago@kinvolk.io,
        michael@kinvolk.io, lukasz.dorau@intel.com,
        vitalii.chernookyi@intel.com, marcin.slusarz@intel.com,
        sarah.jelinek@intel.com, gabor.buella@intel.com
To: Alban Crequy <alban.crequy@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1490966424-20335-1-git-send-email-alban@kinvolk.io>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 31 Mar 2017 15:20:24 +0200
Alban Crequy <alban.crequy@gmail.com> wrote:

> When a kretprobe is installed on a kernel function, there is a maximum
> limit of how many calls in parallel it can catch (aka "maxactive"). A
> kernel module could call register_kretprobe() and initialize maxactive
> (see example in samples/kprobes/kretprobe_example.c).
> 
> But that is not exposed to userspace and it is currently not possible to
> choose maxactive when writing to /sys/kernel/debug/tracing/kprobe_events
> 
> The default maxactive can be as low as 1 on single-core with a
> non-preemptive kernel. This is too low and we need to increase it not
> only for recursive functions, but for functions that sleep or resched.
> 
> This patch updates the format of the command that can be written to
> kprobe_events so that maxactive can be optionally specified.
> 
> I need this for a bpf program attached to the kretprobe of
> inet_csk_accept, which can sleep for a long time.
> 
> This patch includes a basic selftest:
> 
> > # ./ftracetest -v  test.d/kprobe/
> > === Ftrace unit tests ===
> > [1] Kprobe dynamic event - adding and removing	[PASS]
> > [2] Kprobe dynamic event - busy event check	[PASS]
> > [3] Kprobe dynamic event with arguments	[PASS]
> > [4] Kprobes event arguments with types	[PASS]
> > [5] Kprobe dynamic event with function tracer	[PASS]
> > [6] Kretprobe dynamic event with arguments	[PASS]
> > [7] Kretprobe dynamic event with maxactive	[PASS]
> >
> > # of passed:  7
> > # of failed:  0
> > # of unresolved:  0
> > # of untested:  0
> > # of unsupported:  0
> > # of xfailed:  0
> > # of undefined(test bug):  0  
> 
> BugLink: https://github.com/iovisor/bcc/issues/1072
> Signed-off-by: Alban Crequy <alban@kinvolk.io>
> 
> ---
> 
> Changes since v1:
> - Remove "(*)" from documentation. (Review from Masami Hiramatsu)
> - Fix support for "r100" without the event name (Review from Masami Hiramatsu)
> - Get rid of magic numbers within the code.  (Review from Steven Rostedt)
>   Note that I didn't use KRETPROBE_MAXACTIVE_ALLOC since that patch is not
>   merged.
> - Return -E2BIG when maxactive is too big.
> - Add basic selftest
> ---
>  Documentation/trace/kprobetrace.txt                |  4 ++-
>  kernel/trace/trace_kprobe.c                        | 39 ++++++++++++++++++----
>  .../ftrace/test.d/kprobe/kretprobe_maxactive.tc    | 39 ++++++++++++++++++++++
>  3 files changed, 75 insertions(+), 7 deletions(-)
>  create mode 100644 tools/testing/selftests/ftrace/test.d/kprobe/kretprobe_maxactive.tc
> 
> diff --git a/Documentation/trace/kprobetrace.txt b/Documentation/trace/kprobetrace.txt
> index 41ef9d8..7051a20 100644
> --- a/Documentation/trace/kprobetrace.txt
> +++ b/Documentation/trace/kprobetrace.txt
> @@ -23,7 +23,7 @@ current_tracer. Instead of that, add probe points via
>  Synopsis of kprobe_events
>  -------------------------
>    p[:[GRP/]EVENT] [MOD:]SYM[+offs]|MEMADDR [FETCHARGS]	: Set a probe
> -  r[:[GRP/]EVENT] [MOD:]SYM[+0] [FETCHARGS]		: Set a return probe
> +  r[MAXACTIVE][:[GRP/]EVENT] [MOD:]SYM[+0] [FETCHARGS]	: Set a return probe
>    -:[GRP/]EVENT						: Clear a probe
>  
>   GRP		: Group name. If omitted, use "kprobes" for it.
> @@ -32,6 +32,8 @@ Synopsis of kprobe_events
>   MOD		: Module name which has given SYM.
>   SYM[+offs]	: Symbol+offset where the probe is inserted.
>   MEMADDR	: Address where the probe is inserted.
> + MAXACTIVE	: Maximum number of instances of the specified function that
> +		  can be probed simultaneously, or 0 for the default.

BTW, to me, 0 means none (no instances can probe). This should have a
better description of what "0" actually means.

-- Steve


>  
>   FETCHARGS	: Arguments. Each probe can have up to 128 args.
>    %REG		: Fetch register REG
