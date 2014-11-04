From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 6/7] bpf: allow eBPF programs to use maps
Date: Tue, 04 Nov 2014 10:50:51 +0100
Message-ID: <5458A17B.7030904@redhat.com>
References: <1415069656-14138-1-git-send-email-ast@plumgrid.com> <1415069656-14138-7-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1415069656-14138-7-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/04/2014 03:54 AM, Alexei Starovoitov wrote:
> expose bpf_map_lookup_elem(), bpf_map_update_elem(), bpf_map_delete_elem()
> map accessors to eBPF programs
>
> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
...
> +#include <linux/bpf.h>
> +#include <linux/rcupdate.h>
> +
> +/* called from eBPF program under rcu lock
> + *
> + * if kernel subsystem is allowing eBPF programs to call this function,
> + * inside its own verifier_ops->get_func_proto() callback it should return
> + * bpf_map_lookup_elem_proto, so that verifier can properly checks the arguments
> + */
> +static u64 bpf_map_lookup_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> +{
> +	/* verifier checked that R1 contains a valid pointer to bpf_map
> +	 * and R2 points to a program stack and map->key_size bytes were
> +	 * initialized
> +	 */
> +	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
> +	void *key = (void *) (unsigned long) r2;
> +	void *value;
> +
> +	WARN_ON_ONCE(!rcu_read_lock_held());
> +
> +	value = map->ops->map_lookup_elem(map, key);
> +
> +	/* lookup() returns either pointer to element value or NULL
> +	 * which is the meaning of PTR_TO_MAP_VALUE_OR_NULL type
> +	 */
> +	return (unsigned long) value;
> +}
> +
> +struct bpf_func_proto bpf_map_lookup_elem_proto = {
> +	.func = bpf_map_lookup_elem,
> +	.gpl_only = false,
> +	.ret_type = RET_PTR_TO_MAP_VALUE_OR_NULL,
> +	.arg1_type = ARG_CONST_MAP_PTR,
> +	.arg2_type = ARG_PTR_TO_MAP_KEY,
> +};
> +
> +/* called from eBPF program under rcu lock */
> +static u64 bpf_map_update_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> +{
> +	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
> +	void *key = (void *) (unsigned long) r2;
> +	void *value = (void *) (unsigned long) r3;
> +
> +	WARN_ON_ONCE(!rcu_read_lock_held());
> +
> +	return map->ops->map_update_elem(map, key, value, r4);
> +}
> +
> +struct bpf_func_proto bpf_map_update_elem_proto = {
> +	.func = bpf_map_update_elem,
> +	.gpl_only = false,
> +	.ret_type = RET_INTEGER,
> +	.arg1_type = ARG_CONST_MAP_PTR,
> +	.arg2_type = ARG_PTR_TO_MAP_KEY,
> +	.arg3_type = ARG_PTR_TO_MAP_VALUE,
> +	.arg4_type = ARG_ANYTHING,
> +};
> +
> +/* called from eBPF program under rcu lock */
> +static u64 bpf_map_delete_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> +{
> +	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
> +	void *key = (void *) (unsigned long) r2;
> +
> +	WARN_ON_ONCE(!rcu_read_lock_held());
> +
> +	return map->ops->map_delete_elem(map, key);
> +}

These WARN_ON_ONCE(!rcu_read_lock_held()) seem odd. While I see the point that
you're holding RCU read lock on the lookup, can you elaborate on your RCU usage
here and why it's necessary for delete/update?

I suspect due to the synchronize_rcu() you're using and not using any RCU
accessors but plain memcpy() e.g. in case of the array ...?

> +struct bpf_func_proto bpf_map_delete_elem_proto = {
> +	.func = bpf_map_delete_elem,
> +	.gpl_only = false,
> +	.ret_type = RET_INTEGER,
> +	.arg1_type = ARG_CONST_MAP_PTR,
> +	.arg2_type = ARG_PTR_TO_MAP_KEY,
> +};
>
