From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next v14] openvswitch: enable NSH support
Date: Wed, 1 Nov 2017 12:07:59 +0800
Message-ID: <20171101040759.GB66272@localhost.localdomain>
References: <1509326974-3750-1-git-send-email-yi.y.yang@intel.com>
 <20171031210822.6901255a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>, "pshelar@ovn.org" <pshelar@ovn.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:31834 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751053AbdKAEMp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 00:12:45 -0400
Content-Disposition: inline
In-Reply-To: <20171031210822.6901255a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 01, 2017 at 04:08:22AM +0800, Jiri Benc wrote:
> On Mon, 30 Oct 2017 09:29:34 +0800, Yi Yang wrote:
> > +static int set_nsh(struct sk_buff *skb, struct sw_flow_key *flow_key,
> > +		   const struct nlattr *a)
> > +{
> > +	struct nshhdr *nh;
> > +	size_t length;
> > +	int err;
> > +	u8 flags;
> > +	u8 ttl;
> > +	int i;
> > +
> > +	struct ovs_key_nsh key;
> > +	struct ovs_key_nsh mask;
> > +
> > +	err = nsh_key_from_nlattr(a, &key, &mask);
> > +	if (err)
> > +		return err;
> > +
> > +	/* Make sure the NSH base header is there */
> > +	if (!pskb_may_pull(skb, NSH_BASE_HDR_LEN))
> 
> This should be skb_network_offset(skb) + NSH_BASE_HDR_LEN.
> 

Fixed in v15.

> > +size_t ovs_nsh_key_attr_size(void)
> > +{
> > +	/* Whenever adding new OVS_NSH_KEY_ FIELDS, we should consider
> > +	 * updating this function.
> > +	 */
> > +	return  nla_total_size(NSH_BASE_HDR_LEN) /* OVS_NSH_KEY_ATTR_BASE */
> > +		/* OVS_NSH_KEY_ATTR_MD1 and OVS_NSH_KEY_ATTR_MD2 are
> > +		 * mutually exclusive, so the bigger one can cover
> > +		 * the small one.
> > +		 *
> > +		 * OVS_NSH_KEY_ATTR_MD2
> > +		 */
> 
> A nit, not important but since you'll need to respin anyway: the last
> line in the comment above seems to be a left over from some previous
> version of the comment. This should be enough:
> 
> 		/* OVS_NSH_KEY_ATTR_MD1 and OVS_NSH_KEY_ATTR_MD2 are
> 		 * mutually exclusive, so the bigger one can cover
> 		 * the small one.
> 		 */
> 
> Or maybe I misunderstood what you meant.
> 
Fixed it per the above one.

> > +int nsh_hdr_from_nlattr(const struct nlattr *attr,
> > +			struct nshhdr *nh, size_t size)
> > +{
> > +	struct nlattr *a;
> > +	int rem;
> > +	u8 flags = 0;
> > +	u8 ttl = 0;
> > +	int mdlen = 0;
> > +
> > +	/* validate_nsh has check this, so we needn't do duplicate check here
> > +	 */
> > +	nla_for_each_nested(a, attr, rem) {
> > +		int type = nla_type(a);
> > +
> > +		switch (type) {
> > +		case OVS_NSH_KEY_ATTR_BASE: {
> > +			const struct ovs_nsh_key_base *base = nla_data(a);
> > +
> > +			flags = base->flags;
> > +			ttl = base->ttl;
> > +			nh->np = base->np;
> > +			nh->mdtype = base->mdtype;
> > +			nh->path_hdr = base->path_hdr;
> > +			break;
> > +		}
> > +		case OVS_NSH_KEY_ATTR_MD1:
> > +			mdlen = nla_len(a);
> > +			memcpy(&nh->md1, nla_data(a), mdlen);
> 
> The check for 'size' disappeared from here somehow.
> 
> > +			break;
> > +
> > +		case OVS_NSH_KEY_ATTR_MD2:
> > +			mdlen = nla_len(a);
> > +			memcpy(&nh->md2, nla_data(a), mdlen);
> 
> And here.

validate_nsh checked netlink attributes but can't check size, yes, we
should add size check for mdlen, v15 has had them. Please check v15,
thanks a lot.
