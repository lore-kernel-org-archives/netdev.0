From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v14] openvswitch: enable NSH support
Date: Tue, 31 Oct 2017 21:08:22 +0100
Message-ID: <20171031210822.6901255a@redhat.com>
References: <1509326974-3750-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, e@erig.me,
        pshelar@ovn.org, davem@davemloft.net
To: Yi Yang <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51730 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932766AbdJaUI0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 16:08:26 -0400
In-Reply-To: <1509326974-3750-1-git-send-email-yi.y.yang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Oct 2017 09:29:34 +0800, Yi Yang wrote:
> +static int set_nsh(struct sk_buff *skb, struct sw_flow_key *flow_key,
> +		   const struct nlattr *a)
> +{
> +	struct nshhdr *nh;
> +	size_t length;
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
> +	/* Make sure the NSH base header is there */
> +	if (!pskb_may_pull(skb, NSH_BASE_HDR_LEN))

This should be skb_network_offset(skb) + NSH_BASE_HDR_LEN.

> +size_t ovs_nsh_key_attr_size(void)
> +{
> +	/* Whenever adding new OVS_NSH_KEY_ FIELDS, we should consider
> +	 * updating this function.
> +	 */
> +	return  nla_total_size(NSH_BASE_HDR_LEN) /* OVS_NSH_KEY_ATTR_BASE */
> +		/* OVS_NSH_KEY_ATTR_MD1 and OVS_NSH_KEY_ATTR_MD2 are
> +		 * mutually exclusive, so the bigger one can cover
> +		 * the small one.
> +		 *
> +		 * OVS_NSH_KEY_ATTR_MD2
> +		 */

A nit, not important but since you'll need to respin anyway: the last
line in the comment above seems to be a left over from some previous
version of the comment. This should be enough:

		/* OVS_NSH_KEY_ATTR_MD1 and OVS_NSH_KEY_ATTR_MD2 are
		 * mutually exclusive, so the bigger one can cover
		 * the small one.
		 */

Or maybe I misunderstood what you meant.

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
> +		case OVS_NSH_KEY_ATTR_MD1:
> +			mdlen = nla_len(a);
> +			memcpy(&nh->md1, nla_data(a), mdlen);

The check for 'size' disappeared from here somehow.

> +			break;
> +
> +		case OVS_NSH_KEY_ATTR_MD2:
> +			mdlen = nla_len(a);
> +			memcpy(&nh->md2, nla_data(a), mdlen);

And here.

 Jiri
