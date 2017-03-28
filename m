From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [Outreachy kernel] [PATCH] net: Remove unnecessary cast on void
 pointer
Date: Tue, 28 Mar 2017 17:33:23 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1703281732090.3052@hadrien>
References: <20170328125048.GA25091@singhal-Inspiron-5558>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: pablo@netfilter.org, kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com, gregkh@linuxfoundation.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        bridge@lists.linux-foundation.org
To: simran singhal <singhalsimran0@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:4615 "EHLO
        mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751303AbdC1Pd4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 11:33:56 -0400
In-Reply-To: <20170328125048.GA25091@singhal-Inspiron-5558>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 28 Mar 2017, simran singhal wrote:

> The following Coccinelle script was used to detect this:
> @r@
> expression x;
> void* e;
> type T;
> identifier f;
> @@
> (
>   *((T *)e)
> |
>   ((T *)x)[...]
> |
>   ((T*)x)->f
> |
>
> - (T*)
>   e
> )
>
> Signed-off-by: simran singhal <singhalsimran0@gmail.com>
> ---
>  net/bridge/netfilter/ebtables.c         |  2 +-
>  net/ipv4/netfilter/arp_tables.c         | 20 ++++++++------------
>  net/ipv4/netfilter/ip_tables.c          | 20 ++++++++------------
>  net/ipv6/netfilter/ip6_tables.c         | 20 ++++++++------------
>  net/netfilter/ipset/ip_set_bitmap_gen.h |  4 ++--
>  net/netfilter/ipset/ip_set_core.c       |  2 +-
>  net/netfilter/nf_conntrack_proto.c      |  2 +-
>  net/netfilter/nft_set_hash.c            |  2 +-
>  net/netfilter/xt_hashlimit.c            | 10 +++++-----
>  9 files changed, 35 insertions(+), 47 deletions(-)
>
> diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
> index 79b6991..bdc629e 100644
> --- a/net/bridge/netfilter/ebtables.c
> +++ b/net/bridge/netfilter/ebtables.c
> @@ -1713,7 +1713,7 @@ static int compat_copy_entry_to_user(struct ebt_entry *e, void __user **dstptr,
>  	if (*size < sizeof(*ce))
>  		return -EINVAL;
>
> -	ce = (struct ebt_entry __user *)*dstptr;
> +	ce = *dstptr;
>  	if (copy_to_user(ce, e, sizeof(*ce)))
>  		return -EFAULT;
>
> diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
> index 6241a81..f046c12 100644
> --- a/net/ipv4/netfilter/arp_tables.c
> +++ b/net/ipv4/netfilter/arp_tables.c
> @@ -310,7 +310,7 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
>  	for (hook = 0; hook < NF_ARP_NUMHOOKS; hook++) {
>  		unsigned int pos = newinfo->hook_entry[hook];
>  		struct arpt_entry *e
> -			= (struct arpt_entry *)(entry0 + pos);
> +			= (entry0 + pos);

The parentheses are not needed here.  The newline is not needed either.

>
>  		if (!(valid_hooks & (1 << hook)))
>  			continue;
> @@ -354,14 +354,12 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
>  					if (pos == oldpos)
>  						goto next;
>
> -					e = (struct arpt_entry *)
> -						(entry0 + pos);
> +					e = (entry0 + pos);

Again, drop the parentheses.

>  				} while (oldpos == pos + e->next_offset);
>
>  				/* Move along one */
>  				size = e->next_offset;
> -				e = (struct arpt_entry *)
> -					(entry0 + pos + size);
> +				e = (entry0 + pos + size);

And again.

>  				if (pos + size >= newinfo->size)
>  					return 0;
>  				e->counters.pcnt = pos;
> @@ -376,16 +374,14 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
>  					if (!xt_find_jump_offset(offsets, newpos,
>  								 newinfo->number))
>  						return 0;
> -					e = (struct arpt_entry *)
> -						(entry0 + newpos);
> +					e = (entry0 + newpos);

etc :)

julia

>  				} else {
>  					/* ... this is a fallthru */
>  					newpos = pos + e->next_offset;
>  					if (newpos >= newinfo->size)
>  						return 0;
>  				}
> -				e = (struct arpt_entry *)
> -					(entry0 + newpos);
> +				e = (entry0 + newpos);
>  				e->counters.pcnt = pos;
>  				pos = newpos;
>  			}
> @@ -683,7 +679,7 @@ static int copy_entries_to_user(unsigned int total_size,
>  	for (off = 0, num = 0; off < total_size; off += e->next_offset, num++){
>  		const struct xt_entry_target *t;
>
> -		e = (struct arpt_entry *)(loc_cpu_entry + off);
> +		e = (loc_cpu_entry + off);
>  		if (copy_to_user(userptr + off, e, sizeof(*e))) {
>  			ret = -EFAULT;
>  			goto free_counters;
> @@ -1130,7 +1126,7 @@ compat_copy_entry_from_user(struct compat_arpt_entry *e, void **dstptr,
>  	int h;
>
>  	origsize = *size;
> -	de = (struct arpt_entry *)*dstptr;
> +	de = *dstptr;
>  	memcpy(de, e, sizeof(struct arpt_entry));
>  	memcpy(&de->counters, &e->counters, sizeof(e->counters));
>
> @@ -1324,7 +1320,7 @@ static int compat_copy_entry_to_user(struct arpt_entry *e, void __user **dstptr,
>  	int ret;
>
>  	origsize = *size;
> -	ce = (struct compat_arpt_entry __user *)*dstptr;
> +	ce = *dstptr;
>  	if (copy_to_user(ce, e, sizeof(struct arpt_entry)) != 0 ||
>  	    copy_to_user(&ce->counters, &counters[i],
>  	    sizeof(counters[i])) != 0)
> diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
> index 384b857..af57eea 100644
> --- a/net/ipv4/netfilter/ip_tables.c
> +++ b/net/ipv4/netfilter/ip_tables.c
> @@ -382,7 +382,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
>  	   to 0 as we leave), and comefrom to save source hook bitmask */
>  	for (hook = 0; hook < NF_INET_NUMHOOKS; hook++) {
>  		unsigned int pos = newinfo->hook_entry[hook];
> -		struct ipt_entry *e = (struct ipt_entry *)(entry0 + pos);
> +		struct ipt_entry *e = (entry0 + pos);
>
>  		if (!(valid_hooks & (1 << hook)))
>  			continue;
> @@ -424,14 +424,12 @@ mark_source_chains(const struct xt_table_info *newinfo,
>  					if (pos == oldpos)
>  						goto next;
>
> -					e = (struct ipt_entry *)
> -						(entry0 + pos);
> +					e = (entry0 + pos);
>  				} while (oldpos == pos + e->next_offset);
>
>  				/* Move along one */
>  				size = e->next_offset;
> -				e = (struct ipt_entry *)
> -					(entry0 + pos + size);
> +				e = (entry0 + pos + size);
>  				if (pos + size >= newinfo->size)
>  					return 0;
>  				e->counters.pcnt = pos;
> @@ -446,16 +444,14 @@ mark_source_chains(const struct xt_table_info *newinfo,
>  					if (!xt_find_jump_offset(offsets, newpos,
>  								 newinfo->number))
>  						return 0;
> -					e = (struct ipt_entry *)
> -						(entry0 + newpos);
> +					e = (entry0 + newpos);
>  				} else {
>  					/* ... this is a fallthru */
>  					newpos = pos + e->next_offset;
>  					if (newpos >= newinfo->size)
>  						return 0;
>  				}
> -				e = (struct ipt_entry *)
> -					(entry0 + newpos);
> +				e = (entry0 + newpos);
>  				e->counters.pcnt = pos;
>  				pos = newpos;
>  			}
> @@ -834,7 +830,7 @@ copy_entries_to_user(unsigned int total_size,
>  		const struct xt_entry_match *m;
>  		const struct xt_entry_target *t;
>
> -		e = (struct ipt_entry *)(loc_cpu_entry + off);
> +		e = (loc_cpu_entry + off);
>  		if (copy_to_user(userptr + off, e, sizeof(*e))) {
>  			ret = -EFAULT;
>  			goto free_counters;
> @@ -1229,7 +1225,7 @@ compat_copy_entry_to_user(struct ipt_entry *e, void __user **dstptr,
>  	int ret = 0;
>
>  	origsize = *size;
> -	ce = (struct compat_ipt_entry __user *)*dstptr;
> +	ce = *dstptr;
>  	if (copy_to_user(ce, e, sizeof(struct ipt_entry)) != 0 ||
>  	    copy_to_user(&ce->counters, &counters[i],
>  	    sizeof(counters[i])) != 0)
> @@ -1366,7 +1362,7 @@ compat_copy_entry_from_user(struct compat_ipt_entry *e, void **dstptr,
>  	struct xt_entry_match *ematch;
>
>  	origsize = *size;
> -	de = (struct ipt_entry *)*dstptr;
> +	de = *dstptr;
>  	memcpy(de, e, sizeof(struct ipt_entry));
>  	memcpy(&de->counters, &e->counters, sizeof(e->counters));
>
> diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
> index 1e15c54..ef730e9 100644
> --- a/net/ipv6/netfilter/ip6_tables.c
> +++ b/net/ipv6/netfilter/ip6_tables.c
> @@ -411,7 +411,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
>  	   to 0 as we leave), and comefrom to save source hook bitmask */
>  	for (hook = 0; hook < NF_INET_NUMHOOKS; hook++) {
>  		unsigned int pos = newinfo->hook_entry[hook];
> -		struct ip6t_entry *e = (struct ip6t_entry *)(entry0 + pos);
> +		struct ip6t_entry *e = (entry0 + pos);
>
>  		if (!(valid_hooks & (1 << hook)))
>  			continue;
> @@ -453,14 +453,12 @@ mark_source_chains(const struct xt_table_info *newinfo,
>  					if (pos == oldpos)
>  						goto next;
>
> -					e = (struct ip6t_entry *)
> -						(entry0 + pos);
> +					e = (entry0 + pos);
>  				} while (oldpos == pos + e->next_offset);
>
>  				/* Move along one */
>  				size = e->next_offset;
> -				e = (struct ip6t_entry *)
> -					(entry0 + pos + size);
> +				e = (entry0 + pos + size);
>  				if (pos + size >= newinfo->size)
>  					return 0;
>  				e->counters.pcnt = pos;
> @@ -475,16 +473,14 @@ mark_source_chains(const struct xt_table_info *newinfo,
>  					if (!xt_find_jump_offset(offsets, newpos,
>  								 newinfo->number))
>  						return 0;
> -					e = (struct ip6t_entry *)
> -						(entry0 + newpos);
> +					e = (entry0 + newpos);
>  				} else {
>  					/* ... this is a fallthru */
>  					newpos = pos + e->next_offset;
>  					if (newpos >= newinfo->size)
>  						return 0;
>  				}
> -				e = (struct ip6t_entry *)
> -					(entry0 + newpos);
> +				e = (entry0 + newpos);
>  				e->counters.pcnt = pos;
>  				pos = newpos;
>  			}
> @@ -863,7 +859,7 @@ copy_entries_to_user(unsigned int total_size,
>  		const struct xt_entry_match *m;
>  		const struct xt_entry_target *t;
>
> -		e = (struct ip6t_entry *)(loc_cpu_entry + off);
> +		e = (loc_cpu_entry + off);
>  		if (copy_to_user(userptr + off, e, sizeof(*e))) {
>  			ret = -EFAULT;
>  			goto free_counters;
> @@ -1258,7 +1254,7 @@ compat_copy_entry_to_user(struct ip6t_entry *e, void __user **dstptr,
>  	int ret = 0;
>
>  	origsize = *size;
> -	ce = (struct compat_ip6t_entry __user *)*dstptr;
> +	ce = *dstptr;
>  	if (copy_to_user(ce, e, sizeof(struct ip6t_entry)) != 0 ||
>  	    copy_to_user(&ce->counters, &counters[i],
>  	    sizeof(counters[i])) != 0)
> @@ -1394,7 +1390,7 @@ compat_copy_entry_from_user(struct compat_ip6t_entry *e, void **dstptr,
>  	struct xt_entry_match *ematch;
>
>  	origsize = *size;
> -	de = (struct ip6t_entry *)*dstptr;
> +	de = *dstptr;
>  	memcpy(de, e, sizeof(struct ip6t_entry));
>  	memcpy(&de->counters, &e->counters, sizeof(e->counters));
>
> diff --git a/net/netfilter/ipset/ip_set_bitmap_gen.h b/net/netfilter/ipset/ip_set_bitmap_gen.h
> index 6f09a99..d302d98 100644
> --- a/net/netfilter/ipset/ip_set_bitmap_gen.h
> +++ b/net/netfilter/ipset/ip_set_bitmap_gen.h
> @@ -232,7 +232,7 @@ mtype_list(const struct ip_set *set,
>  		if (!test_bit(id, map->members) ||
>  		    (SET_WITH_TIMEOUT(set) &&
>  #ifdef IP_SET_BITMAP_STORED_TIMEOUT
> -		     mtype_is_filled((const struct mtype_elem *)x) &&
> +		     mtype_is_filled(x) &&
>  #endif
>  		     ip_set_timeout_expired(ext_timeout(x, set))))
>  			continue;
> @@ -249,7 +249,7 @@ mtype_list(const struct ip_set *set,
>  		if (mtype_do_list(skb, map, id, set->dsize))
>  			goto nla_put_failure;
>  		if (ip_set_put_extensions(skb, set, x,
> -		    mtype_is_filled((const struct mtype_elem *)x)))
> +		    mtype_is_filled(x)))
>  			goto nla_put_failure;
>  		ipset_nest_end(skb, nested);
>  	}
> diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
> index c296f9b..10a3694 100644
> --- a/net/netfilter/ipset/ip_set_core.c
> +++ b/net/netfilter/ipset/ip_set_core.c
> @@ -1915,7 +1915,7 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
>  		ret = -EFAULT;
>  		goto done;
>  	}
> -	op = (unsigned int *)data;
> +	op = data;
>
>  	if (*op < IP_SET_OP_VERSION) {
>  		/* Check the version at the beginning of operations */
> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
> index 48d8354..ec665c8 100644
> --- a/net/netfilter/nf_conntrack_proto.c
> +++ b/net/netfilter/nf_conntrack_proto.c
> @@ -202,7 +202,7 @@ static int kill_l3proto(struct nf_conn *i, void *data)
>  static int kill_l4proto(struct nf_conn *i, void *data)
>  {
>  	struct nf_conntrack_l4proto *l4proto;
> -	l4proto = (struct nf_conntrack_l4proto *)data;
> +	l4proto = data;
>  	return nf_ct_protonum(i) == l4proto->l4proto &&
>  	       nf_ct_l3num(i) == l4proto->l3proto;
>  }
> diff --git a/net/netfilter/nft_set_hash.c b/net/netfilter/nft_set_hash.c
> index 5f65272..8ec086b 100644
> --- a/net/netfilter/nft_set_hash.c
> +++ b/net/netfilter/nft_set_hash.c
> @@ -352,7 +352,7 @@ static int nft_hash_init(const struct nft_set *set,
>
>  static void nft_hash_elem_destroy(void *ptr, void *arg)
>  {
> -	nft_set_elem_destroy((const struct nft_set *)arg, ptr, true);
> +	nft_set_elem_destroy(arg, ptr, true);
>  }
>
>  static void nft_hash_destroy(const struct nft_set *set)
> diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
> index 2a6dfe8..762e187 100644
> --- a/net/netfilter/xt_hashlimit.c
> +++ b/net/netfilter/xt_hashlimit.c
> @@ -119,7 +119,7 @@ static int
>  cfg_copy(struct hashlimit_cfg2 *to, void *from, int revision)
>  {
>  	if (revision == 1) {
> -		struct hashlimit_cfg1 *cfg = (struct hashlimit_cfg1 *)from;
> +		struct hashlimit_cfg1 *cfg = from;
>
>  		to->mode = cfg->mode;
>  		to->avg = cfg->avg;
> @@ -895,7 +895,7 @@ static void *dl_seq_start(struct seq_file *s, loff_t *pos)
>  static void *dl_seq_next(struct seq_file *s, void *v, loff_t *pos)
>  {
>  	struct xt_hashlimit_htable *htable = s->private;
> -	unsigned int *bucket = (unsigned int *)v;
> +	unsigned int *bucket = v;
>
>  	*pos = ++(*bucket);
>  	if (*pos >= htable->cfg.size) {
> @@ -909,7 +909,7 @@ static void dl_seq_stop(struct seq_file *s, void *v)
>  	__releases(htable->lock)
>  {
>  	struct xt_hashlimit_htable *htable = s->private;
> -	unsigned int *bucket = (unsigned int *)v;
> +	unsigned int *bucket = v;
>
>  	if (!IS_ERR(bucket))
>  		kfree(bucket);
> @@ -980,7 +980,7 @@ static int dl_seq_real_show(struct dsthash_ent *ent, u_int8_t family,
>  static int dl_seq_show_v1(struct seq_file *s, void *v)
>  {
>  	struct xt_hashlimit_htable *htable = s->private;
> -	unsigned int *bucket = (unsigned int *)v;
> +	unsigned int *bucket = v;
>  	struct dsthash_ent *ent;
>
>  	if (!hlist_empty(&htable->hash[*bucket])) {
> @@ -994,7 +994,7 @@ static int dl_seq_show_v1(struct seq_file *s, void *v)
>  static int dl_seq_show(struct seq_file *s, void *v)
>  {
>  	struct xt_hashlimit_htable *htable = s->private;
> -	unsigned int *bucket = (unsigned int *)v;
> +	unsigned int *bucket = v;
>  	struct dsthash_ent *ent;
>
>  	if (!hlist_empty(&htable->hash[*bucket])) {
> --
> 2.7.4
>
> --
> You received this message because you are subscribed to the Google Groups "outreachy-kernel" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to outreachy-kernel+unsubscribe@googlegroups.com.
> To post to this group, send email to outreachy-kernel@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/outreachy-kernel/20170328125048.GA25091%40singhal-Inspiron-5558.
> For more options, visit https://groups.google.com/d/optout.
>
