From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC net-next] bpf: taint loading !is_gpl programs
Date: Tue, 04 Apr 2017 23:12:11 +0200
Message-ID: <58E40C2B.7040802@iogearbox.net>
References: <20170404183354.8579-1-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Aaron Conole <aconole@bytheb.org>,
        Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170404183354.8579-1-aconole@bytheb.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/04/2017 08:33 PM, Aaron Conole wrote:
> The eBPF framework is used for more than just socket level filtering.  It
> can also provide tracing, and even change the way packets coming into the
> system look.  Most of the eBPF callable symbols are available to non-gpl
> programs, and this includes helper functions which modify packets.  This
> allows proprietary eBPF code to link to the kernel and make decisions
> which can negatively impact network performance.
>
> Since the sources for these programs are only available under a proprietary
> license, it seems better to treat them the same as other proprietary
> modules: set the system taint flag.  An exemption is made for socket-level
> filters, since they do not really impact networking for the whole kernel.
>
> Signed-off-by: Aaron Conole <aconole@bytheb.org>
> ---
>   kernel/bpf/syscall.c | 5 +++++
>   1 file changed, 5 insertions(+)
>
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index ab0cf4c4..1255b51 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -860,6 +860,11 @@ static int bpf_prog_load(union bpf_attr *attr)
>
>   	bpf_prog_kallsyms_add(prog);
>   	trace_bpf_prog_load(prog, err);
> +	if (type != BPF_PROG_TYPE_SOCKET_FILTER && !is_gpl && !(err < 0)) {
> +		if (!test_taint(TAINT_PROPRIETARY_MODULE))
> +			pr_warn("bpf license '%s' taints kernel.\n", license);
> +		add_taint(TAINT_PROPRIETARY_MODULE, LOCKDEP_STILL_OK);
> +	}
>   	return err;
>
>   free_used_maps:
>

Nacked-by: Daniel Borkmann <daniel@iogearbox.net>

This is proposal completely unreasonable; what the purpose of .gpl_only
flags is agreed upon since the beginning is that some of the helpers
are only available if the program is loaded as gpl, f.e. bpf_ktime_get_ns(),
bpf_probe_read(), bpf_probe_write_user(), bpf_trace_printk(),
bpf_skb_event_output(), etc. Now, suddenly switching from one kernel
version to another, existing programs would out of a sudden taint the
kernel, which by itself is unacceptable. There are also many other
subsystems that can modify packets, or affect system performance
negatively if configured wrongly and which in addition *don't require* a
hard capable(CAP_SYS_ADMIN) restriction like such eBPF programs already
do, perhaps should we taint them as well? Plus tracing programs are
attached to passively monitor systems performance, not even modifying
data structures ... The current purpose of .gpl_only is fine as-is, and
there's work in progress for a generic dump mechanism that works with
all program types to improve introspection aspect if that's what you're
after, starting to taint is, in a way, breaking existing applications
and this is not acceptable.
