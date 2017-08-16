From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH v3] openvswitch: enable NSH support
Date: Wed, 16 Aug 2017 17:31:30 +0800
Message-ID: <20170816093129.GA112234@cran64.bj.intel.com>
References: <1502861730-76203-1-git-send-email-yi.y.yang@intel.com>
 <20170816111921.7a039be5@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, e@erig.me, dev@openvswitch.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:23259 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751287AbdHPJqP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 05:46:15 -0400
Content-Disposition: inline
In-Reply-To: <20170816111921.7a039be5@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 16, 2017 at 11:19:21AM +0200, Jiri Benc wrote:
> Please always CC reviewers of the previous versions, thanks.

Jiri, thank you for quick review. Sorry, I made a mistake on
sending and missed all the CCs, will indeed do this in next version.

> > +	__be16 ver_flags_len;
> > +	u8 md_type;
> > +	u8 next_proto;
> > +	__be32 path_hdr;
> > +	u8 metadata[NSH_M_TYPE2_MAX_LEN-8];
> > +};
> 
> Please get rid of this struct. It's a copy of struct nsh_hdr with some
> space added to the bottom.
> 
> One of the options (though maybe not the best one, feel free to come up
> with something better) is to change struct nsh_md1_ctx to:
> 
> struct nsh_md1_ctx {
> 	__be32 context[];
> };
> 
> and change struct push_nsh_para:
> 
> struct push_nsh_para {
> 	struct nsh_hdr hdr;
> 	u8 metadata[NSH_M_TYPE2_MAX_LEN-8];
> };
> 
> Another option (a better one, though a bit more work) is to get rid of
> push_nsh_para completely and just pass a properly allocated nsh_hdr
> around. Introduce macros and/or functions to help with the allocation.
>

Yeah, good point, we can use dynamic allocation and struct nsh_hdr * to
handle this.

> > +static inline struct nsh_md1_ctx *nsh_md1_ctx(struct nsh_hdr *nsh)
> > +{
> > +	return &nsh->md1;
> > +}
> > +
> > +static inline struct nsh_md2_tlv *nsh_md2_ctx(struct nsh_hdr *nsh)
> > +{
> > +	return nsh->md2;
> > +}
> 
> These are unused, please remove them.

Will remove them, userspace does use them.

> 
> > --- a/include/uapi/linux/openvswitch.h
> > +++ b/include/uapi/linux/openvswitch.h
> [...]
> > +#define NSH_MD1_CONTEXT_SIZE 4
> 
> Please move this to nsh.h and use it there, too, instead of the open
> coded 4.

ovs code is very ugly, it will convert array[4] in
datapath/linux/compat/include/linux/openvswitch.h to other struct, I
have to change context[4] to such format :-), we can use 4 here for
Linux kernel.

> 
> > +static int push_nsh(struct sk_buff *skb, struct sw_flow_key *key,
> > +		    const struct push_nsh_para *pnp)
> > +{
> > +	struct nsh_hdr *nsh;
> > +	size_t length = ((ntohs(pnp->ver_flags_len) & NSH_LEN_MASK)
> > +			     >> NSH_LEN_SHIFT) << 2;
> 
> Once push_nsh_para is removed/changed, this can be changed to a call to
> nsh_hdr_len.

Yes, will do that way.

> 
> > +	flags = (ntohs(nsh->ver_flags_len) & NSH_FLAGS_MASK) >>
> > +		NSH_FLAGS_SHIFT;
> 
> nsh_get_flags

Missed this one :-)

> 
> > +	case OVS_KEY_ATTR_NSH: {
> > +		struct ovs_key_nsh nsh;
> > +		struct ovs_key_nsh nsh_mask;
> > +		size_t size = nla_len(a) / 2;
> > +		struct nlattr attr[1 + DIV_ROUND_UP(sizeof(struct ovs_key_ipv6)
> > +						    , sizeof(struct nlattr))];
> > +		struct nlattr mask[1 + DIV_ROUND_UP(sizeof(struct ovs_key_ipv6)
> > +						    , sizeof(struct nlattr))];
> > +
> > +		attr->nla_type = nla_type(a);
> > +		mask->nla_type = attr->nla_type;
> > +		attr->nla_len = NLA_HDRLEN + size;
> > +		mask->nla_len = attr->nla_len;
> > +		memcpy(attr + 1, (char *)(a + 1), size);
> > +		memcpy(mask + 1, (char *)(a + 1) + size, size);
> 
> This is too hacky. Please find a better way to handle this.
> 
> One option is to create a struct with struct nlattr as the first member
> followed by a char buffer. Still not nice but at least it's clear
> what's the intent.

The issue is nested attributes only can use this way, nested attribute
for SET_MASKED is very special, we have to handle it specially.

> 
> > +static int parse_nsh(struct sk_buff *skb, struct sw_flow_key *key)
> > +{
> > +	struct nsh_hdr *nsh = (struct nsh_hdr *)skb_network_header(skb);
> > +	u8 version, length;
> > +	u32 path_hdr;
> > +	int i;
> > +
> > +	memset(&key->nsh, 0, sizeof(struct ovs_key_nsh));
> > +	version = nsh_get_ver(nsh);
> > +	length = nsh_get_len(nsh);
> > +
> > +	key->nsh.flags = nsh_get_flags(nsh);
> > +	key->nsh.mdtype = nsh->md_type;
> > +	key->nsh.np = nsh->next_proto;
> > +	path_hdr = ntohl(nsh->path_hdr);
> 
> The path_hdr variable is unused.

Will remove it.

> 
> > +	key->nsh.path_hdr = nsh->path_hdr;
> > +	switch (key->nsh.mdtype) {
> > +	case NSH_M_TYPE1:
> > +		if ((length << 2) != NSH_M_TYPE1_LEN)
> 
> Why length << 2?

len in NSH header is number of 4 octets, so need to multiply 4.

> 
> > +			return -EINVAL;
> > +
> > +		for (i = 0; i < 4; i++)
> 
> NSH_MD1_CONTEXT_SIZE

Ok

> 
> > +			key->nsh.context[i] = nsh->md1.context[i];
> > +
> > +		break;
> 
> Will go through the rest later. Feel free to send a new version
> meanwhile.
> 
> Thanks,
> 
>  Jiri

Thank you so much for your comments, will work out new version ASAP.
