From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next v12] openvswitch: enable NSH support
Date: Thu, 19 Oct 2017 19:40:53 +0800
Message-ID: <20171019114052.GA83037@cran64.bj.intel.com>
References: <1508162009-30359-1-git-send-email-yi.y.yang@intel.com>
 <20171018231955.058ec5c8@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>, "pshelar@ovn.org" <pshelar@ovn.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:57949 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753039AbdJSL42 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 07:56:28 -0400
Content-Disposition: inline
In-Reply-To: <20171018231955.058ec5c8@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 05:19:55AM +0800, Jiri Benc wrote:
> On Mon, 16 Oct 2017 21:53:29 +0800, Yi Yang wrote:
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
> > +	err = skb_ensure_writable(skb, skb_network_offset(skb) +
> > +				       NSH_BASE_HDR_LEN);
> > +	if (unlikely(err))
> > +		return err;
> > +
> > +	nh = nsh_hdr(skb);
> > +	length = nsh_hdr_len(nh);
> > +
> > +	/* Make sure the whole NSH header is there */
> > +	err = skb_ensure_writable(skb, skb_network_offset(skb) +
> > +				       length);
> 
> Calling skb_ensure_writable twice is an unnecessary waste in the fast
> path. If anything, the first call should be changed to pskb_may_pull.
> 
> But what we really should do here is to move the header only once. We
> know how much data we're going to write, we have everything stored in
> the key and can calculate it from there.

Actually mdtype can't be set, only push_nsh can set mdtype, so set_nsh
won't have mdtype flow key, we can't get it from flow_key in set_nsh,
only ttl, flags and path_hdr can be set in set_nsh as you can see in code.
I understand your concern is calling skb_ensure_writable twice, so
changing the first one to pskb_may_pull is more appropriate for set_nsh.

> 
> 	length = NSH_BASE_HDR_LEN;
> 	switch (flow_key->nsh.base.mdtype) {
> 	case NSH_MD_TYPE1:
> 		length += sizeof(struct ovs_nsh_key_md1);
> 		break;
> 	case NSH_MD_TYPE2:
> 		length += whatever_way_we_store_the_tlvs_in_flow_key;
> 		break;
> 	}
> 	err = skb_ensure_writable(skb, skb_network_offset(skb) + length);
> 
> However, set_nsh does not support MD type 2, thus the second case is a
> dead code. In both switches in this function. As such, it should be
> removed and added only when MD type 2 is introduced. I'd still keep the
> overall logic to ease the future addition, though. This boils down to:
> 
> 	length = NSH_BASE_HDR_LEN;
> 	/* Assume MD type 1. This function cannot be called for anything
> 	 * else currently. When MD type 2 is added, the line below will
> 	 * have to be turned into a switch on flow_key->nsh.base.mdtype.
> 	 */
> 	length += sizeof(struct ovs_nsh_key_md1);
> 	err = skb_ensure_writable(skb, skb_network_offset(skb) + length);
> 	...
> 	flow_key->nsh.base.path_hdr = nh->path_hdr;
> 	/* Only MD type 1, see the comment above. */
> 	for (i = 0; i < NSH_MD1_CONTEXT_SIZE; i++) {
> 		...
> 
> Please verify I'm not missing something.
> 
> It seems we also rely on the user space checking first whether the
> packet is indeed compatible with the pushed key/mask. Most importantly,
> that it's of the same mdtype and (in the future) that the MD type 2
> TLVs being written actually fit. Seems this is done the same way in the
> other set_* actions, thus fine with me.
> 
>  Jiri
