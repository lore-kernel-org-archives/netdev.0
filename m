From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v4] openvswitch: enable NSH support
Date: Fri, 18 Aug 2017 15:26:01 +0200
Message-ID: <20170818152601.3760aaec@griffin>
References: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, blp@ovn.org,
        e@erig.me, jan.scheurich@ericsson.com
To: Yi Yang <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43994 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751447AbdHRN0F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 09:26:05 -0400
In-Reply-To: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Aug 2017 15:24:31 +0800, Yi Yang wrote:
> +struct nsh_md2_tlv {
> +	__be16 md_class;
> +	u8 type;
> +	u8 length;
> +	/* Followed by variable-length data. */
> +};

What was wrong with the u8[] field that was present at the end of the
struct in the previous version of the patch?

> +#define NSH_M_TYPE2_MAX_LEN 256

This is defined twice, please delete this define and keep the one lower
in the file.

> +#define NSH_DST_PORT    4790     /* UDP Port for NSH on VXLAN. */

This is a VXLAN-GPE port, it has nothing to do with NSH (except that
VXLAN-GPE can contain a NSH packet). It's also unused. Please remove it.

> +/* NSH Metadata Length. */
> +#define NSH_M_TYPE1_MDLEN 16

This is unused and it seems it's not much useful anyway,
sizeof(struct nsh_md1_ctx) provides the same value. Please remove this
define.

> +#define NSH_MD1_CTX(nsh_hdr_ptr) (&(nsh_hdr_ptr)->md1)
> +
> +#define NSH_MD2_CTX(nsh_hdr_ptr) (&(nsh_hdr_ptr)->md2)

Please remove these two. They are unused and would just obscure things
anyway.

> +static inline struct nsh_md1_ctx *nsh_md1_ctx(struct nsh_hdr *nsh)
> +{
> +	return &nsh->md1;
> +}
> +
> +static inline struct nsh_md2_tlv *nsh_md2_ctx(struct nsh_hdr *nsh)
> +{
> +	return &nsh->md2;
> +}

And remove these too, for the same reason. Just use nsh->md1 when you
need the metadata, there's no reason for these helper functions. They
just obscure things.

> +static inline void nsh_set_flags_and_ttl(struct nsh_hdr *nsh, u8 flags, u8 ttl)
> +{
> +	nsh->ver_flags_ttl_len
> +		= htons((ntohs(nsh->ver_flags_ttl_len)
> +			& ~(NSH_FLAGS_MASK | NSH_TTL_MASK))
> +			| ((flags << NSH_FLAGS_SHIFT) & NSH_FLAGS_MASK)
> +			| ((ttl << NSH_TTL_SHIFT) & NSH_TTL_MASK));
> +}
> +
> +static inline void nsh_set_flags_ttl_len(struct nsh_hdr *nsh, u8 flags,
> +					 u8 ttl, u8 len)
> +{
> +	nsh->ver_flags_ttl_len
> +		= htons((ntohs(nsh->ver_flags_ttl_len)
> +			& ~(NSH_FLAGS_MASK | NSH_TTL_MASK | NSH_LEN_MASK))
> +			| ((flags << NSH_FLAGS_SHIFT) & NSH_FLAGS_MASK)
> +			| ((ttl << NSH_TTL_SHIFT) & NSH_TTL_MASK)
> +			| ((len << NSH_LEN_SHIFT) & NSH_LEN_MASK));
> +}

Okay. Could those two perhaps use a common function?

static inline void __nsh_set_flags(struct nsh_hdr *nsh, u16 value, u16 mask)
{
	nsh->ver_flags_ttl_len = nsh->ver_flags_ttl_len & ~htons(mask)
							| htons(value);
}

static inline void nsh_set_flags_and_ttl(struct nsh_hdr *nsh, u8 flags, u8 ttl)
{
	__nsh_set_flags(nsh, flags << NSH_FLAGS_SHIFT | ttl << NSH_TTL_SHIFT,
			NSH_FLAGS_MASK | NSH_TTL_MASK);
}

etc.

> +static int push_nsh(struct sk_buff *skb, struct sw_flow_key *key,
> +		    const struct nsh_hdr *nsh_src)
> +{
[...]
> +	if (!skb->inner_protocol)
> +		skb_set_inner_protocol(skb, skb->protocol);

I was wondering about this during the reviews of the previous versions.
Now I've given this more thought but I still don't see it - why is the
inner_protocol set here?

> +	case OVS_KEY_ATTR_NSH: {
> +		struct ovs_key_nsh nsh;
> +		struct ovs_key_nsh nsh_mask;
> +		size_t size = nla_len(a) / 2;
> +		struct nlattr attr[1 + size / sizeof(struct nlattr) + 1];
> +		struct nlattr mask[1 + size / sizeof(struct nlattr) + 1];
> +
> +		attr->nla_type = nla_type(a);
> +		mask->nla_type = attr->nla_type;
> +		attr->nla_len = NLA_HDRLEN + size;
> +		mask->nla_len = attr->nla_len;
> +		memcpy(attr + 1, (char *)(a + 1), size);
> +		memcpy(mask + 1, (char *)(a + 1) + size, size);

No, please. See my reply to the previous version for how to do this in
a less hacky way.

> +		case OVS_ACTION_ATTR_PUSH_NSH: {
> +			u8 buffer[256];
> +			struct nsh_hdr *nsh_hdr = (struct nsh_hdr *)buffer;
> +			const struct nsh_hdr *nsh_src = nsh_hdr;
> +
> +			nsh_hdr_from_nlattr(nla_data(a), nsh_hdr);

This is very dangerous security wise. You have to protect against
buffer overflow, one way or other. The current code may not overflow
(I have not checked that, though) but a future addition may break the
assumption without being obvious it's a problem.

Note that the previous version had exactly the same problem but it was
hidden and I didn't notice it. Which means that getting rid of that
push_nsh_para struct was a very good thing, the code is more clean and
more obvious now.

> +static int parse_nsh(struct sk_buff *skb, struct sw_flow_key *key)
> +{
> +	struct nsh_hdr *nsh = (struct nsh_hdr *)skb_network_header(skb);
> +	u8 version, length;
> +	int err;
> +
> +	err = check_header(skb, NSH_BASE_HDR_LEN);
> +	if (unlikely(err))
> +		return err;
> +
> +	memset(&key->nsh, 0, sizeof(struct ovs_key_nsh));

This is unnecessary and expensive. We're initializing all the fields
below.

> +	version = nsh_get_ver(nsh);
> +	length = nsh_hdr_len(nsh);

You have to reload nsh after pskb_may_pull (which is called by
check_header).

> +	if (version != 0)
> +		return -EINVAL;
> +
> +	if (nsh->md_type == NSH_M_TYPE1 && length != NSH_M_TYPE1_LEN)
> +		return -EINVAL;
> +
> +	if (nsh->md_type == NSH_M_TYPE2 && length < NSH_BASE_HDR_LEN)
> +		return -EINVAL;

This might better be merged to the switch below. Or are you concerned
about potentially expensive pskb_may_pull with unchecked length? In
that case, it would be better to convert to switch and reject on
unknown md_types.

> +	err = check_header(skb, length);
> +	if (unlikely(err))
> +		return err;
> +
> +	key->nsh.flags = nsh_get_flags(nsh);

Again, need to reload nsh.

> +	key->nsh.ttl = nsh_get_ttl(nsh);
> +	key->nsh.mdtype = nsh->md_type;
> +	key->nsh.np = nsh->next_proto;
> +	key->nsh.path_hdr = nsh->path_hdr;
> +	switch (key->nsh.mdtype) {
> +	case NSH_M_TYPE1:
> +		memcpy(key->nsh.context, nsh->md1.context,
> +		       sizeof(nsh->md1));
> +		break;
> +	case NSH_M_TYPE2:
> +		/* Don't support MD type 2 metedata parsing yet */
> +		break;
> +	default:
> +		return -EINVAL;
> +	}

This is the switch I mentioned above.

> +struct ovs_key_nsh {
> +	__u8 flags;
> +	__u8 ttl;
> +	__u8 mdtype;
> +	__u8 np;

Just u8, please, this is kernel internal.

> +size_t ovs_nsh_key_attr_size(void)
> +{
> +	/* Whenever adding new OVS_NSH_KEY_ FIELDS, we should consider
> +	 * updating this function.
> +	 */
> +	return  nla_total_size(8)      /* OVS_NSH_KEY_ATTR_BASE */

NSH_BASE_HDR_LEN, perhaps? Not that much important, though.

> +		switch (type) {
> +		case OVS_NSH_KEY_ATTR_BASE: {
> +			const struct ovs_nsh_key_base *base =
> +				(struct ovs_nsh_key_base *)nla_data(a);
> +			flags = base->flags;
> +			ttl = base->ttl;
> +			nsh->next_proto = base->np;
> +			nsh->md_type = base->mdtype;
> +			nsh->path_hdr = base->path_hdr;

Wouldn't it be nicer if the fields of struct ovs_nsh_key_base and of
struct nsh_hdr had the same names?

> +		case OVS_NSH_KEY_ATTR_MD1: {
> +			const struct ovs_nsh_key_md1 *md1 =
> +				(struct ovs_nsh_key_md1 *)nla_data(a);
> +			struct nsh_md1_ctx *md1_dst = nsh_md1_ctx(nsh);
> +
> +			has_md1 = true;
> +			mdlen = nla_len(a);
> +			memcpy(md1_dst, md1, mdlen);

How can we be sure there's enough room in the nsh buffer? See also my
previous remark.

> +			break;
> +		}
> +		case OVS_NSH_KEY_ATTR_MD2: {
> +			const struct u8 *md2 = nla_data(a);
> +			struct nsh_md2_tlv *md2_dst = nsh_md2_ctx(nsh);
> +
> +			has_md2 = true;
> +			mdlen = nla_len(a);
> +			if ((mdlen > NSH_M_TYPE2_MD_MAX_LEN) ||
> +			    (mdlen == 0)) {
> +				OVS_NLERR(
> +				    1,
> +				    "length %d of nsh attr %d is invalid",
> +				    mdlen,
> +				    type
> +				);
> +				return -EINVAL;
> +			}
> +			memcpy(md2_dst, md2, mdlen);

And, more importantly, here. It seems that it's currently capped at
256 bytes by the mdlen check yet it's too fragile. Either add a
parameter with the nsh buffer size or find other way to make this more
robust. Otherwise we're going to hunt a buffer overflow in a year.

> +	if ((has_md1 && nsh->md_type != NSH_M_TYPE1) ||
> +	    (has_md2 && nsh->md_type != NSH_M_TYPE2)) {
> +		OVS_NLERR(1,
> +			  "nsh attribute has unmatched MD type %d.",
> +			  nsh->md_type);
> +		return -EINVAL;
> +	}

What if both type 1 and type 2 attributes were specified? Or neither?
This condition does not catch that.

> +	/* nsh header length  = NSH_BASE_HDR_LEN + mdlen */
> +	nsh_set_flags_ttl_len(nsh, flags, ttl,
> +			      (NSH_BASE_HDR_LEN + mdlen) >> 2);

Just specify the len. It's the job of the helper function to convert it
to whatever format is needed in the header. (I'm talking about the
">> 2". That should not be done by the caller but by the helper
function.)

Out of time for today, will continue the review next week. Again, feel
free to send a new version meanwhile or wait for the rest of the
review, whatever works better for you.

 Jiri
