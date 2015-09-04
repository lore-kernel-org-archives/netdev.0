From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 5/6] seccomp: add a way to attach a filter via eBPF fd
Date: Fri, 4 Sep 2015 13:40:24 -0700
Message-ID: <20150904204021.GD1842@Alexeis-MacBook-Pro-2.local>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
 <1441382664-17437-6-git-send-email-tycho.andersen@canonical.com>
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
In-Reply-To: <1441382664-17437-6-git-send-email-tycho.andersen@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 04, 2015 at 10:04:23AM -0600, Tycho Andersen wrote:
> This is the final bit needed to support seccomp filters created via the bpf
> syscall.
> 
> One concern with this patch is exactly what the interface should look like
> for users, since seccomp()'s second argument is a pointer, we could ask
> people to pass a pointer to the fd, but implies we might write to it which
> seems impolite. Right now we cast the pointer (and force the user to cast
> it), which generates ugly warnings. I'm not sure what the right answer is
> here.

I think passing &fd is fine. setsockopt does similar things.

> -#define SECCOMP_FILTER_FLAG_MASK	(SECCOMP_FILTER_FLAG_TSYNC)
> +#define SECCOMP_FILTER_FLAG_MASK	(\
> +	SECCOMP_FILTER_FLAG_TSYNC | SECCOMP_FILTER_FLAG_EBPF)
>  
>  #ifdef CONFIG_SECCOMP
>  
> diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
> index 0f238a4..c29a423 100644
> --- a/include/uapi/linux/seccomp.h
> +++ b/include/uapi/linux/seccomp.h
> @@ -16,6 +16,7 @@
>  
>  /* Valid flags for SECCOMP_SET_MODE_FILTER */
>  #define SECCOMP_FILTER_FLAG_TSYNC	1
> +#define SECCOMP_FILTER_FLAG_EBPF	(1 << 1)
...
> -	prepared = seccomp_prepare_user_filter(filter);
> +	if (flags & SECCOMP_FILTER_FLAG_EBPF)
> +		prepared = seccomp_prepare_ebpf(filter);
> +	else
> +		prepared = seccomp_prepare_user_filter(filter);
> +

I think instead of flag for existing SECCOMP_SET_MODE_FILTER
command, it would have been cleaner to add new command
SECCOMP_SET_MODE_BPF
and pass &fd to it.
Both kernel implementation and user side would look better ?
