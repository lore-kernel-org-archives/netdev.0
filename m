From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 3/6] ebpf: add a way to dump an eBPF program
Date: Fri, 4 Sep 2015 13:27:05 -0700
Message-ID: <20150904202703.GB1842@Alexeis-MacBook-Pro-2.local>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
 <1441382664-17437-4-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tycho Andersen <tycho.andersen@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1441382664-17437-4-git-send-email-tycho.andersen@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 04, 2015 at 10:04:21AM -0600, Tycho Andersen wrote:
> This commit adds a way to dump eBPF programs. The initial implementation
> doesn't support maps, and therefore only allows dumping seccomp ebpf
> programs which themselves don't currently support maps.
> 
> 
> Signed-off-by: Tycho Andersen <tycho.andersen@canonical.com>
> CC: Kees Cook <keescook@chromium.org>
> CC: Will Drewry <wad@chromium.org>
> CC: Oleg Nesterov <oleg@redhat.com>
> CC: Andy Lutomirski <luto@amacapital.net>
> CC: Pavel Emelyanov <xemul@parallels.com>
> CC: Serge E. Hallyn <serge.hallyn@ubuntu.com>
> CC: Alexei Starovoitov <ast@kernel.org>
> CC: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  include/uapi/linux/bpf.h | 15 +++++++++++++++
>  kernel/bpf/syscall.c     | 44 ++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 59 insertions(+)
> 
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 79b825a..c5d8dc2 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -107,6 +107,13 @@ enum bpf_cmd {
>  	 * returns fd or negative error
>  	 */
>  	BPF_PROG_LOAD,
> +
> +	/* dump an existing bpf
> +	 * err = bpf(BPF_PROG_DUMP, union bpf_attr *attr, u32 size)
> +	 * Using attr->prog_fd, attr->dump_insn_cnt, attr->dump_insns
> +	 * returns zero or negative error
> +	 */
> +	BPF_PROG_DUMP,
>  };
>  
>  enum bpf_map_type {
> @@ -160,6 +167,14 @@ union bpf_attr {
>  		__aligned_u64	log_buf;	/* user supplied buffer */
>  		__u32		kern_version;	/* checked when prog_type=kprobe */
>  	};
> +
> +	struct { /* anonymous struct used by BPF_PROG_DUMP command */
> +		__u32		prog_fd;
> +		__u32		dump_insn_cnt;
> +		__aligned_u64	dump_insns;	/* user supplied buffer */
> +		__u8		gpl_compatible;
> +		__u64		prog_id;	/* unique id for this prog */
> +	};

my first reaction was to may be reuse existing struct used to load,
but I guess it's actually cleaner to have a new one like you did.
though prog_fd looks redundant and prog_id is ...

> +	if (put_user((u64) prog, &uattr->prog_id))
> +		goto out;

.. is definitely not secure.

> We export the GPL bit as well as a unique ID for the program so that
> userspace can detect when two seccomp filters were inherited from each
> other and clone the filter tree accordingly.

you mean that in-kernel prog pointer is the same?
I think user space can memcmp insns of programs instead?
Are you trying to solve the case when parent has an FD for bpf program
and child has another FD that points to the same program, and both
doing dump and need to coordinate?
