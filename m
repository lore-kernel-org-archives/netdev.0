From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v3 1/2] bpf: Add bpf_current_task_in_cgroup helper
Date: Thu, 11 Aug 2016 22:24:24 +0200
Message-ID: <57ACDEF8.20600@iogearbox.net>
References: <20160811185140.GA28294@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, tj@kernel.org
To: Sargun Dhillon <sargun@sargun.me>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56144 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbcHKUY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 16:24:28 -0400
In-Reply-To: <20160811185140.GA28294@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sargun,

just some minor comment inline.

On 08/11/2016 08:51 PM, Sargun Dhillon wrote:
[...]
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index 1113423..6c01ab1 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -319,4 +319,26 @@ extern const struct bpf_func_proto bpf_get_stackid_proto;
>   void bpf_user_rnd_init_once(void);
>   u64 bpf_user_rnd_u32(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
>
> +/* Helper to fetch a cgroup pointer based on index.
> + * @map: a cgroup arraymap
> + * @idx: index of the item you want to fetch
> + *
> + * Returns pointer on success,
> + * Error code if item not found, or out-of-bounds access
> + */
> +static inline struct cgroup *fetch_arraymap_ptr(struct bpf_map *map, int idx)
> +{
> +	struct cgroup *cgrp;
> +	struct bpf_array *array = container_of(map, struct bpf_array, map);

Nit, please keep it in this reverse tree like order (whenever possible)
to be consistent with kernel coding style:

	struct bpf_array *array = container_of(map, struct bpf_array, map);
	struct cgroup *cgrp;

> +	if (unlikely(idx >= array->map.max_entries))
> +		return ERR_PTR(-E2BIG);
> +
> +	cgrp = READ_ONCE(array->ptrs[idx]);
> +	if (unlikely(!cgrp))
> +		return ERR_PTR(-EAGAIN);
> +
> +	return cgrp;
> +}

I think this inline helper doesn't buy us too much to be honest. First,
it really should be prefixed with bpf_* if this is exposed like this to
avoid potential naming clashes with other headers, but apart from that
a generic function to fetch an array map pointer returning a cgroup
is also not really generic. We have other specialized array maps also
fetching a pointer apart from cgroup, so either we make a real generic
helper for use in all of them, or just add the content of above into the
bpf_current_task_in_cgroup() helper directly. Probably just going for
the latter is more straight forward and likely also smaller diff.

Rest looks otherwise good to me, thanks!
