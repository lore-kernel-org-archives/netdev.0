From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v11] openvswitch: enable NSH support
Date: Mon, 2 Oct 2017 21:13:08 +0200
Message-ID: <20171002211308.03424ed6@griffin>
References: <1506668610-18505-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, e@erig.me, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Yi Yang <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1506668610-18505-1-git-send-email-yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Sep 2017 15:03:30 +0800, Yi Yang wrote:
> --- a/include/net/nsh.h
> +++ b/include/net/nsh.h
> @@ -304,4 +304,7 @@ static inline void nsh_set_flags_ttl_len(struct nshhdr *nsh, u8 flags,
>  			NSH_FLAGS_MASK | NSH_TTL_MASK | NSH_LEN_MASK);
>  }
>  
> +int skb_push_nsh(struct sk_buff *skb, const struct nshhdr *nh);

[...]
> +int skb_push_nsh(struct sk_buff *skb, const struct nshhdr *src_nsh_hdr)

This is minor but since this patch will need a respin anyway, please
name the variables in the forward declaration and here the same.

> +int skb_pop_nsh(struct sk_buff *skb)
> +{
> +	int err;
> +	struct nshhdr *nsh_hdr = (struct nshhdr *)(skb->data);

Bad name of the variable, clashes with the nsh_hdr function. I pointed
that out already.

> +	size_t length;
> +	__be16 inner_proto;
> +
> +	err = skb_ensure_writable(skb, skb_network_offset(skb) +
> +				       sizeof(struct nshhdr));

You assume that the skb starts at the NSH header, thus the
skb_network_offset is completely unnecessary and introduces just
another assumption on the caller. Also, the sizeof(struct nshhdr) is
wrong: there's no guarantee that the header is not smaller or larger
than that.

More importantly though, why do you need skb_ensure_writable? You don't
write into the header. pkskb_may_pull is enough.

	if (!pskb_may_pull(skb, NSH_BASE_HDR_LEN))
		return -ENOMEM;
	length = nsh_hdr_len(nsh_hdr);
	if (!pskb_may_pull(skb, length))
		return -ENOMEM;

> +static int set_nsh(struct sk_buff *skb, struct sw_flow_key *flow_key,
> +		   const struct nlattr *a)
> +{
> +	struct nshhdr *nh;
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
> +				       sizeof(struct nshhdr));

I missed this before: this is wrong, too. You need to use the real
header size, not sizeof(struct nshhdr). It should be computable from
the flow key.

> +		case OVS_ACTION_ATTR_PUSH_NSH: {
> +			u8 buffer[NSH_HDR_MAX_LEN];
> +			struct nshhdr *nh = (struct nshhdr *)buffer;
> +
> +			nsh_hdr_from_nlattr(nla_data(a), nh,
> +					    NSH_HDR_MAX_LEN);
> +			err = push_nsh(skb, key, (const struct nshhdr *)nh);

Is the cast to const really needed? It looks suspicious. If you added it
because a compiler complained, it's even more suspicious.

> +static int parse_nsh(struct sk_buff *skb, struct sw_flow_key *key)
> +{
> +	struct nshhdr *nh;
> +	unsigned int nh_ofs = skb_network_offset(skb);
> +	u8 version, length;
> +	int err;
> +
> +	err = check_header(skb, nh_ofs + NSH_BASE_HDR_LEN);
> +	if (unlikely(err))
> +		return err;
> +
> +	nh = nsh_hdr(skb);
> +	version = nsh_get_ver(nh);
> +	length = nsh_hdr_len(nh);
> +
> +	if (version != 0)
> +		return -EINVAL;
> +
> +	err = check_header(skb, nh_ofs + length);
> +	if (unlikely(err))
> +		return err;
> +
> +	nh = (struct nshhdr *)skb_network_header(skb);

I really really really hate this. This is the third time I'm telling
you to use the nsh_hdr function. Every time, you change only part of
the places. And this one I even explicitly pointed out in the previous
review.

I'm not supposed to look at my previous review to verify that you
addressed everything. That's your responsibility. Yet I need to do it
because every time, some of my comments remain unaddressed.

> +int nsh_hdr_from_nlattr(const struct nlattr *attr,
> +			struct nshhdr *nh, size_t size)
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
> +			const struct ovs_nsh_key_base *base = nla_data(a);
> +
> +			flags = base->flags;
> +			ttl = base->ttl;
> +			nh->np = base->np;
> +			nh->mdtype = base->mdtype;
> +			nh->path_hdr = base->path_hdr;
> +			break;
> +		}
> +		case OVS_NSH_KEY_ATTR_MD1: {
> +			const struct ovs_nsh_key_md1 *md1 = nla_data(a);
> +
> +			mdlen = nla_len(a);
> +			memcpy(&nh->md1, md1, mdlen);
> +			break;

Looks better. Why not simplify it even more?

		case OVS_NSH_KEY_ATTR_MD1:
			mdlen = nla_len(a);
			memcpy(&nh->md1, nla_data(a), mdlen);
			break;

It's still perfectly readable this way and there's no need for the
braces.

> +		}
> +		case OVS_NSH_KEY_ATTR_MD2: {
> +			const struct u8 *md2 = nla_data(a);
> +
> +			mdlen = nla_len(a);
> +			memcpy(&nh->md2, md2, mdlen);

And here, too.

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
> +			const struct ovs_nsh_key_base *base = nla_data(a);
> +			const struct ovs_nsh_key_base *base_mask = base + 1;
> +
> +			nsh->base = *base;
> +			nsh_mask->base = *base_mask;
> +			break;
> +		}
> +		case OVS_NSH_KEY_ATTR_MD1: {
> +			const struct ovs_nsh_key_md1 *md1 =
> +				(struct ovs_nsh_key_md1 *)nla_data(a);

I'm speechless.

Yes, I don't like the line above. For a reason that I already pointed
out.

I expected more of this version.

 Jiri
