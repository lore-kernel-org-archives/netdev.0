From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/9] bpf: pre-allocate hash map elements
Date: Mon, 07 Mar 2016 12:08:08 +0100
Message-ID: <56DD6118.7090608@iogearbox.net>
References: <1457315917-1970307-1-git-send-email-ast@fb.com> <1457315917-1970307-4-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457315917-1970307-4-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/07/2016 02:58 AM, Alexei Starovoitov wrote:
[...]
> ---
>   include/linux/bpf.h      |   1 +
>   include/uapi/linux/bpf.h |   3 +
>   kernel/bpf/hashtab.c     | 264 ++++++++++++++++++++++++++++++++++-------------
>   kernel/bpf/syscall.c     |   2 +-
>   4 files changed, 196 insertions(+), 74 deletions(-)

Shouldn't all other map types (like array) need something like this as well to
reserve this for their future flags?

   if (attr->map_flags)
     return ERR_PTR(-EINVAL);

> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index 4b070827200d..c81efb10bbb5 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -37,6 +37,7 @@ struct bpf_map {
>   	u32 key_size;
>   	u32 value_size;
>   	u32 max_entries;
> +	u32 map_flags;

Just naming this 'flags' doesn't work due to the anonymous struct inside that
union, right? :/

>   	u32 pages;
>   	struct user_struct *user;
>   	const struct bpf_map_ops *ops;
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 6496f98d3d68..5eeb2ca9441e 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -101,12 +101,15 @@ enum bpf_prog_type {
>   #define BPF_NOEXIST	1 /* create new element if it didn't exist */
>   #define BPF_EXIST	2 /* update existing element */
>
> +#define BPF_F_NO_PREALLOC	(1ULL << 0)

Nit: Should better be (1U << 0) as map_flags are of __u32.

>   union bpf_attr {
>   	struct { /* anonymous struct used by BPF_MAP_CREATE command */
>   		__u32	map_type;	/* one of enum bpf_map_type */
>   		__u32	key_size;	/* size of key in bytes */
>   		__u32	value_size;	/* size of value in bytes */
>   		__u32	max_entries;	/* max number of entries in a map */
> +		__u32	map_flags;	/* prealloc or not */
>   	};
>
>   	struct { /* anonymous struct used by BPF_MAP_*_ELEM commands */

Thanks,
Daniel
