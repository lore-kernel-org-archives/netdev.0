From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH net] bpf: split eBPF out of NET
Date: Thu, 23 Oct 2014 20:23:55 -0700
Message-ID: <20141024032355.GB7879@thin>
References: <1414114868-28228-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1414114868-28228-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 23, 2014 at 06:41:08PM -0700, Alexei Starovoitov wrote:
> introduce two configs:
> - hidden CONFIG_BPF to select eBPF interpreter that classic socket filters
>   depend on
> - visible CONFIG_BPF_SYSCALL (default off) that tracing and sockets can use
> 
> that solves several problems:
> - tracing and others that wish to use eBPF don't need to depend on NET.
>   They can use BPF_SYSCALL to allow loading from userspace or select BPF
>   to use it directly from kernel in NET-less configs.
> - in 3.18 programs cannot be attached to events yet, so don't force it on
> - when the rest of eBPF infra is there in 3.19+, it's still useful to
>   switch it off to minimize kernel size
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Thanks for working on this!  A few nits below, but otherwise this looks
good to me.  Once this gets appropriate reviews from net and bpf folks,
please let me know if you want this to go through the net tree, the tiny
tree, or some other tree.

> 
> bloat-o-meter on x64 shows:
> add/remove: 0/60 grow/shrink: 0/2 up/down: 0/-15601 (-15601)

Very nice!  Please do include the bloat-o-meter stats in the commit
message.

> tested with many different config combinations. Hopefully didn't miss anything.
> 
>  init/Kconfig        |   14 ++++++++++++++
>  kernel/Makefile     |    2 +-
>  kernel/bpf/Makefile |    6 +++---
>  kernel/bpf/core.c   |    9 +++++++++
>  net/Kconfig         |    2 +-
>  5 files changed, 28 insertions(+), 5 deletions(-)
> 
> diff --git a/init/Kconfig b/init/Kconfig
> index 3ee28ae..340fd92 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1341,6 +1341,10 @@ config SYSCTL_ARCH_UNALIGN_ALLOW
>  config HAVE_PCSPKR_PLATFORM
>  	bool
>  
> +# interpreter that classic socket filters depend on
> +config BPF
> +	boolean

s/boolean/bool/

> +
>  menuconfig EXPERT
>  	bool "Configure standard kernel features (expert users)"
>  	# Unhide debug options, to make the on-by-default options visible
> @@ -1521,6 +1525,16 @@ config EVENTFD
>  
>  	  If unsure, say Y.
>  
> +# syscall, maps, verifier
> +config BPF_SYSCALL
> +	bool "Enable bpf() system call" if EXPERT
> +	select ANON_INODES
> +	select BPF
> +	default n
> +	help
> +	  Enable the bpf() system call that allows to manipulate eBPF
> +	  programs and maps via file descriptors.

Not sure this one goes under EXPERT, especially since it currently has
"default n".

> --- a/kernel/bpf/core.c
> +++ b/kernel/bpf/core.c
> @@ -655,3 +655,12 @@ void bpf_prog_free(struct bpf_prog *fp)
>  	schedule_work(&aux->work);
>  }
>  EXPORT_SYMBOL_GPL(bpf_prog_free);
> +
> +/* To execute LD_ABS/LD_IND instructions __bpf_prog_run() may call
> + * skb_copy_bits(), so provide a weak definition of it for NET-less config.
> + */
> +int __weak skb_copy_bits(const struct sk_buff *skb, int offset, void *to,
> +			 int len)
> +{
> +	return -EFAULT;
> +}

Please discuss this in the commit message.  What are the implications of
ending up with this implementation that always returns -EFAULT?

> diff --git a/net/Kconfig b/net/Kconfig
> index 6272420..99815b5 100644
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -6,7 +6,7 @@ menuconfig NET
>  	bool "Networking support"
>  	select NLATTR
>  	select GENERIC_NET_UTILS
> -	select ANON_INODES
> +	select BPF

Why does this not need to select ANON_INODES anymore?  Did *only* BPF
use that, so it only needs to occur via BPF_SYSCALL?  If so, can you
document that in the commit message?

>  	---help---
>  	  Unless you really know what you are doing, you should say Y here.
>  	  The reason is that some programs need kernel networking support even
> -- 
> 1.7.9.5
> 
