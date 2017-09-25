From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v9] openvswitch: enable NSH support
Date: Mon, 25 Sep 2017 20:14:39 +0200
Message-ID: <20170925201439.08460295@griffin>
References: <1506348969-6233-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, e@erig.me,
        davem@davemloft.net
To: Yi Yang <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4047 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753917AbdIYSOn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 25 Sep 2017 14:14:43 -0400
In-Reply-To: <1506348969-6233-1-git-send-email-yi.y.yang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Sep 2017 22:16:09 +0800, Yi Yang wrote:
> +	skb->protocol = htons(ETH_P_NSH);
> +	skb_reset_mac_header(skb);
> +	skb_reset_mac_len(skb);
> +	skb_reset_network_header(skb);

The last two lines are swapped. Network header needs to be reset before
mac_len.

> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(skb_push_nsh);
> +
> +int skb_pop_nsh(struct sk_buff *skb)
> +{
> +	struct nshhdr *nsh_hdr = (struct nshhdr *)(skb->data);
> +	size_t length;
> +	u16 inner_proto;

__be16 inner_proto.

> +static int push_nsh(struct sk_buff *skb, struct sw_flow_key *key,
> +		    const struct nshhdr *src_nsh_hdr)
> +{
> +	int err;
> +
> +	err = skb_push_nsh(skb, src_nsh_hdr);
> +	if (err)
> +		return err;
> +
> +	key->eth.type = htons(ETH_P_NSH);

I wonder why you have this assignment here. The key is invalidated,
thus nothing should rely on key->eth.type. However, looking at the code
and ovs_fragment in particular, I'm not sure that's the case. Could you
please explain why it is needed? And why the reverse of it is not
needed in pop_nsh?

> +
> +	/* safe right before invalidate_flow_key */
> +	key->mac_proto = MAC_PROTO_NONE;
> +	invalidate_flow_key(key);
> +	return 0;
> +}
[...]
> +static int set_nsh(struct sk_buff *skb, struct sw_flow_key *flow_key,
> +		   const struct nlattr *a)
> +{
> +	struct nshhdr *nsh_hdr;
> +	int err;
> +	u8 flags;
> +	u8 ttl;
> +	int i;
> +
> +	struct ovs_key_nsh key;
> +	struct ovs_key_nsh mask;
> +
> +	err = nsh_key_from_nlattr(a, &key, &mask);
> +	if (err)
> +		return err;
> +
> +	err = skb_ensure_writable(skb, skb_network_offset(skb) +
> +				  sizeof(struct nshhdr));

Whitespace nit: the sizeof should be aligned to skb_network_offset.

> +	if (unlikely(err))
> +		return err;
> +
> +	nsh_hdr = (struct nshhdr *)skb_network_header(skb);

Please use the nsh_hdr function (I'm sure I already requested that in
the previous review?). It means renaming the nsh_hdr variable.

> @@ -1210,6 +1307,21 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>  		case OVS_ACTION_ATTR_POP_ETH:
>  			err = pop_eth(skb, key);
>  			break;
> +
> +		case OVS_ACTION_ATTR_PUSH_NSH: {
> +			u8 buffer[NSH_HDR_MAX_LEN];
> +			struct nshhdr *nsh_hdr = (struct nshhdr *)buffer;
> +			const struct nshhdr *src_nsh_hdr = nsh_hdr;
> +
> +			nsh_hdr_from_nlattr(nla_data(a), nsh_hdr,
> +					    NSH_HDR_MAX_LEN);
> +			err = push_nsh(skb, key, src_nsh_hdr);

Is the src_nsh_hdr variable really necessary? Cannot be nsh_hdr passed
directly to push_nsh, relying on automatic retyping to const?

By the way, nsh_hdr is a poor name for a variable, it clashes with the
nsh_hdr function. For clarity, please rename the variables in the whole
patch to something else.

> +static int parse_nsh(struct sk_buff *skb, struct sw_flow_key *key)
> +{
> +	struct nshhdr *nsh_hdr;
> +	unsigned int nh_ofs = skb_network_offset(skb);
> +	u8 version, length;
> +	int err;
> +
> +	err = check_header(skb, nh_ofs + NSH_BASE_HDR_LEN);
> +	if (unlikely(err))
> +		return err;
> +
> +	nsh_hdr = (struct nshhdr *)skb_network_header(skb);

Again, rename the variable and use the nsh_hdr function.

> +	version = nsh_get_ver(nsh_hdr);
> +	length = nsh_hdr_len(nsh_hdr);
> +
> +	if (version != 0)
> +		return -EINVAL;
> +
> +	err = check_header(skb, nh_ofs + length);
> +	if (unlikely(err))
> +		return err;
> +
> +	nsh_hdr = (struct nshhdr *)skb_network_header(skb);

Ditto.

> +struct ovs_key_nsh {
> +	u8 flags;
> +	u8 ttl;
> +	u8 mdtype;
> +	u8 np;
> +	__be32 path_hdr;
> +	__be32 context[NSH_MD1_CONTEXT_SIZE];
> +};

This should be:

struct ovs_key_nsh {
	struct ovs_nsh_key_base base;
	__be32 context[NSH_MD1_CONTEXT_SIZE];
};

to capture the real dependency. Implicitly depending on ovs_key_nsh
starting with the same fields as ovs_nsh_key_base will only lead to bugs
in the future.

> +int nsh_hdr_from_nlattr(const struct nlattr *attr,
> +			struct nshhdr *nsh, size_t size)
> +{
> +	struct nlattr *a;
> +	int rem;
> +	u8 flags = 0;
> +	u8 ttl = 0;
> +	int mdlen = 0;
> +
> +	/* validate_nsh has check this, so we needn't do duplicate check here
> +	 */
> +	nla_for_each_nested(a, attr, rem) {
> +		int type = nla_type(a);
> +
> +		switch (type) {
> +		case OVS_NSH_KEY_ATTR_BASE: {
> +			const struct ovs_nsh_key_base *base =
> +				(struct ovs_nsh_key_base *)nla_data(a);

It's not necessary to retype void * explicitly. Just assign it.

> +			flags = base->flags;
> +			ttl = base->ttl;
> +			nsh->np = base->np;
> +			nsh->mdtype = base->mdtype;
> +			nsh->path_hdr = base->path_hdr;
> +			break;
> +		}
> +		case OVS_NSH_KEY_ATTR_MD1: {
> +			const struct ovs_nsh_key_md1 *md1 =
> +				(struct ovs_nsh_key_md1 *)nla_data(a);

It's not necessary to retype void * explicitly. Just assign it.

> +			struct nsh_md1_ctx *md1_dst = &nsh->md1;
> +
> +			mdlen = nla_len(a);
> +			memcpy(md1_dst, md1, mdlen);

Why the variable? Just memcpy to &nsh->md1.

> +			break;
> +		}
> +		case OVS_NSH_KEY_ATTR_MD2: {
> +			const struct u8 *md2 = nla_data(a);
> +			struct nsh_md2_tlv *md2_dst = &nsh->md2;
> +
> +			mdlen = nla_len(a);
> +			memcpy(md2_dst, md2, mdlen);

Ditto.

> +int nsh_key_from_nlattr(const struct nlattr *attr,
> +			struct ovs_key_nsh *nsh, struct ovs_key_nsh *nsh_mask)
> +{
> +	struct nlattr *a;
> +	int rem;
> +
> +	/* validate_nsh has check this, so we needn't do duplicate check here
> +	 */
> +	nla_for_each_nested(a, attr, rem) {
> +		int type = nla_type(a);
> +
> +		switch (type) {
> +		case OVS_NSH_KEY_ATTR_BASE: {
> +			const struct ovs_nsh_key_base *base =
> +				(struct ovs_nsh_key_base *)nla_data(a);

It's not necessary to retype void * explicitly. Just assign it.

> +			const struct ovs_nsh_key_base *base_mask = base + 1;
> +
> +			memcpy(nsh, base, sizeof(*base));
> +			memcpy(nsh, base_mask, sizeof(*base_mask));

The second memcpy should copy to nsh_mask, not nsh.

If you modify struct ovs_key_nsh as suggested above, this becomes a
simple:

nsh->base = *base;
nsh_mask->base = *base_mask;

I'm perfectly fine with memcpy, too, though.

> +static int nsh_key_put_from_nlattr(const struct nlattr *attr,
> +				   struct sw_flow_match *match, bool is_mask,
> +				   bool is_push_nsh, bool log)
> +{
> +	struct nlattr *a;
> +	int rem;
> +	bool has_base = false;
> +	bool has_md1 = false;
> +	bool has_md2 = false;
> +	u8 mdtype = 0;
> +	int mdlen = 0;
> +
> +	if (unlikely(is_push_nsh && is_mask))
> +		return -EINVAL;

Wrap this in WARN_ON. (And note that you don't need unlikely with
WARN_ON.)

> +		case OVS_NSH_KEY_ATTR_MD2:
> +			if (!is_push_nsh) /* Not supported MD type 2 yet */
> +				return -ENOTSUPP;
> +
> +			has_md2 = true;
> +			mdlen = nla_len(a);
> +			if ((mdlen > NSH_CTX_HDRS_MAX_LEN) ||
> +			    (mdlen <= 0)) {
> +				WARN_ON_ONCE(1);

But here, the WARN_ON_ONCE is completely inappropriate. This condition
does not indicate a kernel bug but rather invalid data from the user
space. OVS_NLERR should be here instead.

> +		if (is_push_nsh &&
> +		    (!has_base || (!has_md1 && !has_md2))) {
> +			OVS_NLERR(
> +			    1,
> +			    "push nsh attributes are invalid for type %d.",
> +			    mdtype
> +			);

"Missing nsh base and/or metadata attribute." or something like that
would be a better error message.

> +static int nsh_key_to_nlattr(const struct ovs_key_nsh *nsh, bool is_mask,
> +			     struct sk_buff *skb)
> +{
> +	struct nlattr *start;
> +	struct ovs_nsh_key_base base;
> +	struct ovs_nsh_key_md1 md1;
> +
> +	memcpy(&base, nsh, sizeof(base));
> +
> +	if (is_mask || nsh->mdtype == NSH_M_TYPE1)
> +		memcpy(md1.context, nsh->context, sizeof(md1));
> +
> +	start = nla_nest_start(skb, OVS_KEY_ATTR_NSH);
> +	if (!start)
> +		return -EMSGSIZE;
> +
> +	if (nla_put(skb, OVS_NSH_KEY_ATTR_BASE, sizeof(base), &base))

The 'base' variable is not needed, let alone copy to it, just use
&nsh->base here.

> +		goto nla_put_failure;
> +
> +	if (is_mask || nsh->mdtype == NSH_M_TYPE1) {
> +		if (nla_put(skb, OVS_NSH_KEY_ATTR_MD1, sizeof(md1), &md1))

Likewise, no need for the copy.

> +	return ((ret != 0) ? false : true);

Too little coffee or too late in the night, right? ;-)

 Jiri
