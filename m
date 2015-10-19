From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC] bpf: change bpf syacall to use u64 temp variables
Date: Mon, 19 Oct 2015 12:08:36 -0700
Message-ID: <20151019190835.GA19852@Alexeis-MBP.westell.com>
References: <1445238646-9379-1-git-send-email-yalin.wang2010@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: yalin wang <yalin.wang2010@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33984 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752012AbbJSTIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 15:08:37 -0400
Content-Disposition: inline
In-Reply-To: <1445238646-9379-1-git-send-email-yalin.wang2010@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 19, 2015 at 03:10:46PM +0800, yalin wang wrote:
> This patch change map_lookup_elem() and map_update_elem() function
> to use u64 temp variable if the key_size or value_size is less than
> u64, we don't need use kmalloc() for these small variables.
> 
> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
> ---
>  kernel/bpf/syscall.c | 30 ++++++++++++++++++++----------
>  1 file changed, 20 insertions(+), 10 deletions(-)
> 
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index f640e5f..c82d7bf 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -189,7 +189,8 @@ static int map_lookup_elem(union bpf_attr *attr)
>  	void __user *uvalue = u64_to_ptr(attr->value);
>  	int ufd = attr->map_fd;
>  	struct bpf_map *map;
> -	void *key, *value, *ptr;
> +	u64 key_buf, value_buf;
> +	void *key = &key_buf, *value = &value_buf, *ptr;
>  	struct fd f;
>  	int err;
>  
> @@ -202,7 +203,8 @@ static int map_lookup_elem(union bpf_attr *attr)
>  		return PTR_ERR(map);
>  
>  	err = -ENOMEM;
> -	key = kmalloc(map->key_size, GFP_USER);
> +	if (map->key_size > sizeof(u64))
> +		key = kmalloc(map->key_size, GFP_USER);

I think it's a good optimization for common case.
Performance numbers would be good to prove the point.
Thanks
