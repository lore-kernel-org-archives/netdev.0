From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v3] openvswitch: enable NSH support
Date: Wed, 16 Aug 2017 11:19:21 +0200
Message-ID: <20170816111921.7a039be5@griffin>
References: <1502861730-76203-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Garver <e@erig.me>
To: Yi Yang <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40002 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751068AbdHPJTZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 05:19:25 -0400
In-Reply-To: <1502861730-76203-1-git-send-email-yi.y.yang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please always CC reviewers of the previous versions, thanks.

On Wed, 16 Aug 2017 13:35:30 +0800, Yi Yang wrote:
> v2->v3
>  - Change OVS_KEY_ATTR_NSH to nested key to handle
>    length-fixed attributes and length-variable
>    attriubte more flexibly.
>  - Remove struct ovs_action_push_nsh completely
>  - Add code to handle nested attribute for SET_MASKED
>  - Change PUSH_NSH to use the nested OVS_KEY_ATTR_NSH
>    to transfer NSH header data.
>  - Fix comments and coding style issues by Jiri and Eric

Thanks! I like this version. I think we're almost there. A few more
comments below.

> +struct push_nsh_para {
> +	__be16 ver_flags_len;
> +	u8 md_type;
> +	u8 next_proto;
> +	__be32 path_hdr;
> +	u8 metadata[NSH_M_TYPE2_MAX_LEN-8];
> +};

Please get rid of this struct. It's a copy of struct nsh_hdr with some
space added to the bottom.

One of the options (though maybe not the best one, feel free to come up
with something better) is to change struct nsh_md1_ctx to:

struct nsh_md1_ctx {
	__be32 context[];
};

and change struct push_nsh_para:

struct push_nsh_para {
	struct nsh_hdr hdr;
	u8 metadata[NSH_M_TYPE2_MAX_LEN-8];
};

Another option (a better one, though a bit more work) is to get rid of
push_nsh_para completely and just pass a properly allocated nsh_hdr
around. Introduce macros and/or functions to help with the allocation.

> +static inline struct nsh_md1_ctx *nsh_md1_ctx(struct nsh_hdr *nsh)
> +{
> +	return &nsh->md1;
> +}
> +
> +static inline struct nsh_md2_tlv *nsh_md2_ctx(struct nsh_hdr *nsh)
> +{
> +	return nsh->md2;
> +}

These are unused, please remove them.

> --- a/include/uapi/linux/openvswitch.h
> +++ b/include/uapi/linux/openvswitch.h
[...]
> +#define NSH_MD1_CONTEXT_SIZE 4

Please move this to nsh.h and use it there, too, instead of the open
coded 4.

> +static int push_nsh(struct sk_buff *skb, struct sw_flow_key *key,
> +		    const struct push_nsh_para *pnp)
> +{
> +	struct nsh_hdr *nsh;
> +	size_t length = ((ntohs(pnp->ver_flags_len) & NSH_LEN_MASK)
> +			     >> NSH_LEN_SHIFT) << 2;

Once push_nsh_para is removed/changed, this can be changed to a call to
nsh_hdr_len.

> +	flags = (ntohs(nsh->ver_flags_len) & NSH_FLAGS_MASK) >>
> +		NSH_FLAGS_SHIFT;

nsh_get_flags

> +	case OVS_KEY_ATTR_NSH: {
> +		struct ovs_key_nsh nsh;
> +		struct ovs_key_nsh nsh_mask;
> +		size_t size = nla_len(a) / 2;
> +		struct nlattr attr[1 + DIV_ROUND_UP(sizeof(struct ovs_key_ipv6)
> +						    , sizeof(struct nlattr))];
> +		struct nlattr mask[1 + DIV_ROUND_UP(sizeof(struct ovs_key_ipv6)
> +						    , sizeof(struct nlattr))];
> +
> +		attr->nla_type = nla_type(a);
> +		mask->nla_type = attr->nla_type;
> +		attr->nla_len = NLA_HDRLEN + size;
> +		mask->nla_len = attr->nla_len;
> +		memcpy(attr + 1, (char *)(a + 1), size);
> +		memcpy(mask + 1, (char *)(a + 1) + size, size);

This is too hacky. Please find a better way to handle this.

One option is to create a struct with struct nlattr as the first member
followed by a char buffer. Still not nice but at least it's clear
what's the intent.

> +static int parse_nsh(struct sk_buff *skb, struct sw_flow_key *key)
> +{
> +	struct nsh_hdr *nsh = (struct nsh_hdr *)skb_network_header(skb);
> +	u8 version, length;
> +	u32 path_hdr;
> +	int i;
> +
> +	memset(&key->nsh, 0, sizeof(struct ovs_key_nsh));
> +	version = nsh_get_ver(nsh);
> +	length = nsh_get_len(nsh);
> +
> +	key->nsh.flags = nsh_get_flags(nsh);
> +	key->nsh.mdtype = nsh->md_type;
> +	key->nsh.np = nsh->next_proto;
> +	path_hdr = ntohl(nsh->path_hdr);

The path_hdr variable is unused.

> +	key->nsh.path_hdr = nsh->path_hdr;
> +	switch (key->nsh.mdtype) {
> +	case NSH_M_TYPE1:
> +		if ((length << 2) != NSH_M_TYPE1_LEN)

Why length << 2?

> +			return -EINVAL;
> +
> +		for (i = 0; i < 4; i++)

NSH_MD1_CONTEXT_SIZE

> +			key->nsh.context[i] = nsh->md1.context[i];
> +
> +		break;

Will go through the rest later. Feel free to send a new version
meanwhile.

Thanks,

 Jiri
