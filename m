From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: add helper capable of reading out instructions
Date: Tue, 25 Jul 2017 18:40:23 +0200
Message-ID: <59777477.7050609@iogearbox.net>
References: <20170724212236.21903-2-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, oss-drivers@netronome.com,
        kafai@fb.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59196 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753016AbdGYQkZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 12:40:25 -0400
In-Reply-To: <20170724212236.21903-2-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ +Martin ]

On 07/24/2017 11:22 PM, Jakub Kicinski wrote:
> To read translated and jited instructions from the kernel,
> one has to set certain pointers of struct bpf_prog_info to
> pre-allocated user buffers.  Unfortunately, the existing
> bpf_obj_get_info_by_fd() helper zeros struct bpf_prog_info
> before passing it to the kernel.
>
> Keeping the zeroing seems like a good idea in general, since
> kernel will check if the structure was zeroed.  Add a new
> helper for those more advanced users who can be trusted to
> take care of zeroing themselves.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
> I'm happy to change the name of the new function.
>
>   tools/lib/bpf/bpf.c | 10 ++++++++--
>   tools/lib/bpf/bpf.h |  2 ++
>   2 files changed, 10 insertions(+), 2 deletions(-)
>
> diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
> index 412a7c82995a..2703fa282b65 100644
> --- a/tools/lib/bpf/bpf.c
> +++ b/tools/lib/bpf/bpf.c
> @@ -308,13 +308,12 @@ int bpf_map_get_fd_by_id(__u32 id)
>   	return sys_bpf(BPF_MAP_GET_FD_BY_ID, &attr, sizeof(attr));
>   }
>
> -int bpf_obj_get_info_by_fd(int prog_fd, void *info, __u32 *info_len)
> +int __bpf_obj_get_info_by_fd(int prog_fd, void *info, __u32 *info_len)
>   {
>   	union bpf_attr attr;
>   	int err;
>
>   	bzero(&attr, sizeof(attr));
> -	bzero(info, *info_len);

Looks a bit unintentional to me, e.g. 95b9afd3987f ("bpf: Test for bpf
ID") did set up pointers in test_bpf_obj_id(), but later only checked
for the {jited,xlated}_prog_len.

Clearing out the pointers looks not to useful. Lets just push the need
for bzero() to call-sites in general in this case.

>   	attr.info.bpf_fd = prog_fd;
>   	attr.info.info_len = *info_len;
>   	attr.info.info = ptr_to_u64(info);
> @@ -325,3 +324,10 @@ int bpf_obj_get_info_by_fd(int prog_fd, void *info, __u32 *info_len)
>
>   	return err;
>   }
> +
> +int bpf_obj_get_info_by_fd(int prog_fd, void *info, __u32 *info_len)
> +{
> +	bzero(info, *info_len);
> +
> +	return __bpf_obj_get_info_by_fd(prog_fd, info, info_len);
> +}
> diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
> index 418c86e69bcb..e44b423ac07e 100644
> --- a/tools/lib/bpf/bpf.h
> +++ b/tools/lib/bpf/bpf.h
> @@ -58,6 +58,8 @@ int bpf_prog_get_next_id(__u32 start_id, __u32 *next_id);
>   int bpf_map_get_next_id(__u32 start_id, __u32 *next_id);
>   int bpf_prog_get_fd_by_id(__u32 id);
>   int bpf_map_get_fd_by_id(__u32 id);
> +/* Note: bpf_obj_get_info_by_fd() will init info to zeroes */
>   int bpf_obj_get_info_by_fd(int prog_fd, void *info, __u32 *info_len);
> +int __bpf_obj_get_info_by_fd(int prog_fd, void *info, __u32 *info_len);
>
>   #endif
>
