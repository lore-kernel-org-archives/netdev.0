From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 1/1] tracing, bpf: Implement function bpf_probe_write
Date: Wed, 13 Jul 2016 10:08:51 -0700
Message-ID: <20160713170849.GA76615@ast-mbp.thefacebook.com>
References: <CAMp4zn8ygXFg7kvjShm77zmK2dYVMY2zS8i2mUKwhbfXcyVyig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33687 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162AbcGMRJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 13:09:07 -0400
Content-Disposition: inline
In-Reply-To: <CAMp4zn8ygXFg7kvjShm77zmK2dYVMY2zS8i2mUKwhbfXcyVyig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 13, 2016 at 03:36:11AM -0700, Sargun Dhillon wrote:
> Provides BPF programs, attached to kprobes a safe way to write to
> memory referenced by probes. This is done by making probe_kernel_write
> accessible to bpf functions via the bpf_probe_write helper.

not quite :)

> Signed-off-by: Sargun Dhillon <sargun@sargun.me>
> ---
>  include/uapi/linux/bpf.h  |  3 +++
>  kernel/trace/bpf_trace.c  | 20 ++++++++++++++++++++
>  samples/bpf/bpf_helpers.h |  2 ++
>  3 files changed, 25 insertions(+)
> 
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 406459b..355b565 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -313,6 +313,9 @@ enum bpf_func_id {
>   */
>   BPF_FUNC_skb_get_tunnel_opt,
>   BPF_FUNC_skb_set_tunnel_opt,
> +
> + BPF_FUNC_probe_write, /* int bpf_probe_write(void *dst, void *src,
> int size) */
> +

the patch is against some old kernel.
Please always make the patch against net-next tree and cc netdev list.

> +static u64 bpf_probe_write(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> +{
> + void *dst = (void *) (long) r1;
> + void *unsafe_ptr = (void *) (long) r2;
> + int  size = (int) r3;
> +
> + return probe_kernel_write(dst, unsafe_ptr, size);
> +}

the patch is whitepsace mangled. Please see Documentation/networking/netdev-FAQ.txt

the main issue though that we cannot simply allow bpf to do probe_write,
since it may crash the kernel.
What might be ok is to allow writing into memory of current
user space process only. This way bpf prog will keep kernel safety guarantees,
yet it will be able to modify user process memory when necessary.
Since bpf+tracing is root only, it doesn't pose security risk.
