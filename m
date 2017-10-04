From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/4] bpf: Add file mode configuration into bpf
 maps
Date: Thu, 05 Oct 2017 01:29:49 +0200
Message-ID: <59D56EED.1030804@iogearbox.net>
References: <20171004182932.140028-1-chenbofeng.kernel@gmail.com> <20171004182932.140028-2-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeffrey Vander Stoep <jeffv@google.com>,
        Lorenzo Colitti <lorenzo@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>,
        linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40809 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751169AbdJDX3z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 19:29:55 -0400
In-Reply-To: <20171004182932.140028-2-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/04/2017 08:29 PM, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
>
> Introduce the map read/write flags to the eBPF syscalls that returns the
> map fd. The flags is used to set up the file mode when construct a new
> file descriptor for bpf maps. To not break the backward capability, the
> f_flags is set to O_RDWR if the flag passed by syscall is 0. Otherwise
> it should be O_RDONLY or O_WRONLY. When the userspace want to modify or
> read the map content, it will check the file mode to see if it is
> allowed to make the change.
[...]
> +int bpf_get_file_flag(int flags)
> +{
> +	if ((flags & BPF_F_RDONLY) && (flags & BPF_F_WRONLY))
> +		return -EINVAL;
> +	if (flags & BPF_F_RDONLY)
> +		return O_RDONLY;
> +	if (flags & BPF_F_WRONLY)
> +		return O_WRONLY;
> +	return O_RDWR;
>   }
>
>   /* helper macro to check that unused fields 'union bpf_attr' are zero */
> @@ -345,12 +376,17 @@ static int map_create(union bpf_attr *attr)
>   {
>   	int numa_node = bpf_map_attr_numa_node(attr);
>   	struct bpf_map *map;
> +	int f_flags;
>   	int err;
>
>   	err = CHECK_ATTR(BPF_MAP_CREATE);
>   	if (err)
>   		return -EINVAL;
>
> +	f_flags = bpf_get_file_flag(attr->map_flags);
> +	if (f_flags < 0)
> +		return f_flags;

Wait, I just noticed, given you add BPF_F_RDONLY/BPF_F_WRONLY
to attr->map_flags, and later go into find_and_alloc_map(),
for map alloc, which is e.g. array_map_alloc(). There, we
bail out with EINVAL on attr->map_flags & ~BPF_F_NUMA_NODE,
which is the case for both BPF_F_RDONLY/BPF_F_WRONLY ... I
would have expected that the entire code was tested properly;
what was tested exactly in the set?

>   	if (numa_node != NUMA_NO_NODE &&
>   	    ((unsigned int)numa_node >= nr_node_ids ||
>   	     !node_online(numa_node)))
> @@ -376,7 +412,7 @@ static int map_create(union bpf_attr *attr)
>   	if (err)
>   		goto free_map;
>
> -	err = bpf_map_new_fd(map);
> +	err = bpf_map_new_fd(map, f_flags);
>   	if (err < 0) {
>   		/* failed to allocate fd.
>   		 * bpf_map_put() is needed because the above
> @@ -491,6 +527,11 @@ static int map_lookup_elem(union bpf_attr *attr)
[...]
