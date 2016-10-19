From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH net-next] bpf: fix potential percpu map overcopy to
 user.
Date: Tue, 18 Oct 2016 17:50:05 -0700
Message-ID: <20161019005004.GA87961@ast-mbp.thefacebook.com>
References: <1476636088-9268-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32963 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933145AbcJSAuK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 20:50:10 -0400
Received: by mail-pf0-f195.google.com with SMTP id i85so796387pfa.0
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 17:50:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1476636088-9268-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 16, 2016 at 09:41:28AM -0700, William Tu wrote:
> When running bpf_map_lookup on percpu elements, the bytes copied to
> userspace depends on num_possible_cpus() * value_size, which could
> potentially be larger than memory allocated from user, which depends
> on sysconf(_SC_NPROCESSORS_CONF) to get the current cpu num.  As a
> result, the inconsistency might corrupt the user's stack.
> 
> The fact that sysconf(_SC_NPROCESSORS_CONF) != num_possible_cpu()
> happens when cpu hotadd is enabled.  For example, in Fusion when
> setting vcpu.hotadd = "TRUE" or in KVM, setting
>   ./qemu-system-x86_64 -smp 2, maxcpus=4 ...
> the num_possible_cpu() will be 4 and sysconf() will be 2[1].
> Currently the any percpu map lookup suffers this issue, try
> samples/bpf/test_maps.c or tracex3.c.
> 
> Th RFC patch adds additional 'size' param from userspace so that
> kernel knows the maximum memory it should copy to the user.
> 
> [1] https://www.mail-archive.com/netdev@vger.kernel.org/msg121183.html
> 
> Signed-off-by: William Tu <u9012063@gmail.com>
> ---
>  include/uapi/linux/bpf.h       |  5 ++++-
>  kernel/bpf/syscall.c           |  5 +++--
>  samples/bpf/fds_example.c      |  2 +-
>  samples/bpf/libbpf.c           |  3 ++-
>  samples/bpf/libbpf.h           |  2 +-
>  samples/bpf/test_maps.c        | 30 +++++++++++++++---------------
>  tools/include/uapi/linux/bpf.h |  5 ++++-
>  7 files changed, 30 insertions(+), 22 deletions(-)
> 
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index f09c70b..fa0c40b 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -123,7 +123,10 @@ union bpf_attr {
>  			__aligned_u64 value;
>  			__aligned_u64 next_key;
>  		};
> -		__u64		flags;
> +		union {
> +			__u64		flags;
> +			__u32		size; /* number of bytes allocated in userspace */
> +		};
...
> -	if (copy_to_user(uvalue, value, value_size) != 0)
> +	if (copy_to_user(uvalue, value, min_t(u32, usize, value_size)) != 0)
>  		goto free_value;

I think such approach won't actually fix anything. User space
may lose some of the values and won't have any idea what was lost.
I think we need to fix sample code to avoid using sysconf(_SC_NPROCESSORS_CONF)
and use /sys/devices/system/cpu/possible instead.
I would argue that glibc should be fixed as well since relying on
ls -d /sys/devices/system/cpu/cpu[0-9]*|wc -l turned out to be incorrect.
