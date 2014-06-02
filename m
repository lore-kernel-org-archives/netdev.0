From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 net-next 0/2] split BPF out of core networking
Date: Mon, 02 Jun 2014 10:57:56 +0200
Message-ID: <538C3C94.3080206@redhat.com>
References: <1401692506-7796-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401692506-7796-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/02/2014 09:01 AM, Alexei Starovoitov wrote:
> This patch set splits BPF out of core networking into generic component
>
> patch #1 splits filter.c into two logical pieces: generic BPF core and socket
> filters. It only moves functions around. No real changes.
>
> patch #2 adds hidden CONFIG_BPF that seccomp/tracing can select
>
> The main value of the patch is not a NET separation, but rather logical boundary
> between generic BPF core and socket filtering. All socket specific code stays in
> net/core/filter.c and kernel/bpf/core.c is for generic BPF infrastructure (both
> classic and internal).
>
> Note that CONFIG_BPF_JIT is still under NET, so NET-less configs cannot use
> BPF JITs yet. This can be cleaned up in the future. Also it seems to makes sense
> to split up filter.h into generic and socket specific as well to cleanup the
> boundary further.

Hm, I really don't like that 'ripping code and headers apart' and then we believe
it's a generic abstraction. So far seccomp-BPF could live with the current state
since it was introduced, the rest of users (vast majority) is in the networking
domain (and invoked through tcpdump et al) ...

There are still parts in seccomp that show some BPF weaknesses in terms of being
'generic', for example shown in seccomp, we need to go once again over the filter
instructions after doing the usual filter sanity checks, just to whitelist what
seccomp may do in BPF.

I have not yet thought about it deeply enough, but I think we should avoid
something similar in other non-networking areas but abstract that cleanly w/o
such hacks first, for example.

> Tested with several NET and NET-less configs on arm and x86
>
> V1->V2:
> rebase on top of net-next
> split filter.c into kernel/bpf/core.c instead of net/bpf/core.c
>
> Alexei Starovoitov (2):
>    net: filter: split filter.c into two files
>    net: filter: split BPF out of core networking
>
>   arch/Kconfig           |    6 +-
>   include/linux/filter.h |    2 +
>   kernel/Makefile        |    1 +
>   kernel/bpf/Makefile    |    5 +
>   kernel/bpf/core.c      | 1063 ++++++++++++++++++++++++++++++++++++++++++++++++
>   net/Kconfig            |    1 +
>   net/core/filter.c      | 1023 +---------------------------------------------
>   7 files changed, 1079 insertions(+), 1022 deletions(-)
>   create mode 100644 kernel/bpf/Makefile
>   create mode 100644 kernel/bpf/core.c
>
