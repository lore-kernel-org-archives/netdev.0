From: Paul Moore <pmoore@redhat.com>
Subject: Re: [RFC PATCH v2 10/18] calipso: Set the calipso socket label to match the secattr.
Date: Sun, 07 Feb 2016 14:56:08 -0500
Message-ID: <9580708.OYiE7xvQSN@sifl>
References: <1452246774-13241-11-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Huw Davies <huw@codeweavers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55373 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754715AbcBGT4L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Feb 2016 14:56:11 -0500
In-Reply-To: <1452246774-13241-11-git-send-email-huw@codeweavers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, January 08, 2016 09:52:46 AM Huw Davies wrote:
> CALIPSO is a hop-by-hop IPv6 option.  A lot of this patch is based on
> the equivalent CISPO code.  The main difference is due to manipulating
> the options in the hop-by-hop header.
> 
> Signed-off-by: Huw Davies <huw@codeweavers.com>

...

> diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
> index d7df7a4..ce803e2 100644
> --- a/net/ipv6/calipso.c
> +++ b/net/ipv6/calipso.c
> @@ -44,6 +44,17 @@
>  #include <linux/atomic.h>
>  #include <linux/bug.h>
>  #include <asm/unaligned.h>
> +#include <linux/crc-ccitt.h>
> +
> +/* Maximium size of the calipso option including
> + * the two-byte TLV header.
> + */
> +#define CALIPSO_OPT_LEN_MAX (2 + 252)
> +
> +/* Size of the minimum calipso option including
> + * the two-byte TLV header.
> + */
> +#define CALIPSO_HDR_LEN (2 + 8)
> 
>  /* List of available DOI definitions */
>  static DEFINE_SPINLOCK(calipso_doi_list_lock);
> @@ -297,6 +308,584 @@ doi_walk_return:
>  	return ret_val;
>  }
> 
> +/**
> + * calipso_map_cat_hton - Perform a category mapping from host to network
> + * @doi_def: the DOI definition
> + * @secattr: the security attributes
> + * @net_cat: the zero'd out category bitmap in network/CIPSO format

I think that should be CALIPSO ;)

I didn't notice that mistake anywhere else but it is very possible I missed 
it; a quick 'grep -i "cipso"' on your patches might be a good idea.

> +/**
> + * calipso_genopt - Generate a CALIPSO option
> + * @buf: the option buffer
> + * @start: offset from which to write
> + * @buf_len: the size of opt_buf
> + * @doi_def: the CALIPSO DOI to use
> + * @secattr: the security attributes
> + *
> + * Description:
> + * Generate a CALIPSO option using the DOI definition and security
> attributes + * passed to the function. This also generates upto three bytes
> of leading + * padding that ensures that the option is 4n + 2 aligned.  It
> returns the + * number of bytes written (including any initial padding).
> + */
> +static int calipso_genopt(unsigned char *buf, u32 start, u32 buf_len,
> +			  const struct calipso_doi *doi_def,
> +			  const struct netlbl_lsm_secattr *secattr)
> +{
> +	int ret_val;
> +	u32 len, pad;
> +	u16 crc;
> +	static const unsigned char padding[4] = {2, 1, 0, 3};
> +	unsigned char *calipso;
> +
> +	/* CALIPSO has 4n + 2 alignment */
> +	pad = padding[start % 4];

It's probably quicker to use a bitmask than a modulus operation.

> +	if (buf_len <= start + pad + CALIPSO_HDR_LEN)
> +		return -ENOSPC;
> +
> +	if ((secattr->flags & NETLBL_SECATTR_MLS_LVL) == 0)
> +		return -EPERM;
> +
> +	len = CALIPSO_HDR_LEN;
> +
> +	if (secattr->flags & NETLBL_SECATTR_MLS_CAT) {
> +		ret_val = calipso_map_cat_hton(doi_def,
> +					       secattr,
> +					       buf + start + pad + len,
> +					       buf_len - start - pad - len);
> +		if (ret_val < 0)
> +			return ret_val;
> +		len += ret_val;
> +	}
> +
> +	calipso_pad_write(buf, start, pad);
> +	calipso = buf + start + pad;

Help me understand why we would need to pad before the CALIPSO option?  
Assuming any preceding options are properly aligned, or there are no preceding 
options at all, this should never be needed, yes?

> +	calipso[0] = IPV6_TLV_CALIPSO;
> +	calipso[1] = len - 2;
> +	*(__be32 *)(calipso + 2) = htonl(doi_def->doi);
> +	calipso[6] = (len - CALIPSO_HDR_LEN) / 4;
> +	calipso[7] = secattr->attr.mls.lvl,
> +	crc = crc_ccitt(0xffff, calipso, len);
> +	crc = ~crc;

Why not just "crc = ~crc_ccitt(...);"?

> +	calipso[8] = crc & 0xff;
> +	calipso[9] = (crc >> 8) & 0xff;

Do we need to convert the checksum to network byte order?

> +	return pad + len;
> +}
> +
> +/* Hop-by-hop hdr helper functions
> + */
> +
> +/**
> + * calipso_opt_update - Replaces socket's hop options with a new set
> + * @sk: the socket
> + * @hop: new hop options
> + *
> + * Description:
> + * Replaces @sk's hop options with @hop.  @hop may be NULL to leave
> + * the socket with no hop options.
> + *
> + */
> +static int calipso_opt_update(struct sock *sk, struct ipv6_opt_hdr *hop)
> +{
> +	struct ipv6_txoptions *old = txopt_get(inet6_sk(sk)), *txopts;
> +
> +	txopts = ipv6_renew_options_kern(sk, old, IPV6_HOPOPTS,
> +					 hop, hop ? ipv6_optlen(hop) : 0);
> +	txopt_put(old);
> +	if (IS_ERR(txopts))
> +		return PTR_ERR(txopts);
> +
> +	txopts = ipv6_update_options(sk, txopts);
> +
> +	if (txopts) {
> +		atomic_sub(txopts->tot_len, &sk->sk_omem_alloc);
> +		txopt_put(txopts);
> +	}

Vertical whitespace between the txopts assignment and the if conditional.

> +	return 0;
> +}
> +
> +/**
> + * calipso_tlv_len - Returns the length of the TLV.
> + * @tlv: the TLV
> + *
> + * Description:
> + * Returns the length of the provided TLV option.
> + */
> +static int calipso_tlv_len(unsigned char *tlv)
> +{
> +	if (tlv[0] == IPV6_TLV_PAD1)
> +		return 1;
> +	return tlv[1] + 2;
> +}

Perhaps rename this to calipso_opt_len() and change the argument from tlv to 
opt?

There may also be a desire to make this a generic ipv6 function; to be honest 
I'm surprised there isn't one to do this already.

> +/**
> + * calipso_opt_find - Finds the CALIPSO option in an IPv6 hop ...
> + * @hop: the hop options header
> + * @start: on return holds the offset of any leading padding
> + * @end: on return holds the offset of the first non-pad TLV after CALIPSO
> + *
> + * Description:
> + * Finds the space occupied by a CALIPSO option (including any leading and
> + * trailing padding).
> + *
> + * If a CALIPSO option exists set @start and @end to the
> + * offsets within @hop of the start of padding before the first
> + * CALIPSO option and the end of padding after the first CALIPSO
> + * option.  In this case the function returns 0.
> + *
> + * In the absence of a CALIPSO option, @start and @end will be
> + * set to the start and end of any trailing padding in the header.
> + * This is useful when appending a new option, as the caller may want
> + * to overwrite some of this padding.  In this case the function will
> + * return -ENOENT.
> + */
> +static int calipso_opt_find(struct ipv6_opt_hdr *hop, unsigned int *start,
> +			    unsigned int *end)
> +{
> +	unsigned int opt_len = ipv6_optlen(hop), offset;
> +	unsigned char *p;
> +	bool found = false, found_next = false;
> +
> +	*start = *end = 0;

Ungh.  I'm being very, very nit-picky here but I never liked this double 
assignment style.

> +	p = (unsigned char *)hop;

It seems like "opts" or something similar would be more descriptive than "p".

> +	offset = 2;
> +	while (offset < opt_len) {
> +		u8 val_type = p[offset];
> +		u8 val_len = calipso_tlv_len(p + offset);

Be consistent, "p[offset]" and not "p + offset" please.

> +
> +		if (offset + val_len > opt_len)
> +			return -EINVAL;
> +		switch (val_type) {
> +		case IPV6_TLV_CALIPSO:
> +			if (found) {
> +				found_next = true;
> +				break;
> +			}
> +			found = true;
> +			if (!*start)
> +				*start = offset;
> +			*end = offset + val_len;
> +			break;
> +		case IPV6_TLV_PAD1:
> +		case IPV6_TLV_PADN:
> +			if (!found && !*start)
> +				*start = offset;
> +			if (found && !found_next)
> +				*end = offset + val_len;
> +			break;
> +		default:
> +			if (!found)
> +				*start = 0;
> +			else
> +				found_next = true;
> +		}
> +		offset += val_len;
> +	}
> +	if (!*start)
> +		*start = opt_len;
> +	if (!*end)
> +		*end = opt_len;
> +
> +	return found ? 0 : -ENOENT;

Okay, this whole function seems unnecessarily complex.  I understand that some 
of this is due to the tracking of the padding, but what about something like 
what is shown below?  My apologies if I missed some subtle behavior in the 
original code.

int calipso_opt_find(struct ipv6_opt_hdr *hop,
                     unsigned int *start,
                     unsigned int *end)
{
	int rc = -ENOENT;
	unsigned int opt_len;
	unsigned int spot, spot_s, spot_e;
	unsigned char *opt = hop;

	opt_len = ipv6_optlen(hop);
	while (opt_iter <= opt_len) {
		switch (opt[spot]) {
		case IPV6_TLV_PAD1:
		case IPv6_TLV_PADN:
			if (spot_e)
				spot_e = spot;
			break;
		case IPV6_TLV_CALIPSO:
			rc = 0;
			spot_e = spot;
			break;
		default:
			if (spot_e == 0)
				spot_s = spot;
			else
				goto out;
		}
		spot += calipso_tlv_len(opt[spot]);
	}

out:
	if (spot_s)
		*start = spot_s + calipso_tlv_len(opt[spot_s]);
	else
		*start = 0;
	if (spot_e)
		*end = spot_e + calipso_tlv_len(opt[spot_e]);
	else
		*end = opt_len;

	return rc;
}

> +/**
> + * calipso_opt_insert - Inserts a CALIPSO option into an IPv6 hop opt hdr.
> + * @old: the original hop options header
> + * @doi_def: the CALIPSO DOI to use
> + * @secattr: the specific security attributes of the socket
> + *
> + * Description:
> + * Creates a new hop options header based on @old with a
> + * CALIPSO option added to it.  If @old already contains a CALIPSO
> + * option this is overwritten, otherwise the new option is appended
> + * after any existing options.  If @old is NULL then the new header
> + * will contain just the CALIPSO option and any needed padding.
> + *
> + */
> +static struct ipv6_opt_hdr *
> +calipso_opt_insert(struct ipv6_opt_hdr *old,
> +		   const struct calipso_doi *doi_def,
> +		   const struct netlbl_lsm_secattr *secattr)

How about renaming "old" to "hop"?

> +{
> +	unsigned int start, end, next_opt, buf_len, pad;
> +	struct ipv6_opt_hdr *new;
> +	int ret_val;
> +
> +	if (old) {
> +		ret_val = calipso_opt_find(old, &start, &end);
> +		if (ret_val && ret_val != -ENOENT)
> +			return ERR_PTR(ret_val);
> +		if (end != ipv6_optlen(old))
> +			next_opt = end;
> +		else
> +			next_opt = 0;
> +		buf_len = ipv6_optlen(old) - ((end - start) & ~7) +
> +			CALIPSO_OPT_LEN_MAX;
> +	} else {
> +		start = 0;
> +		next_opt = 0;
> +		buf_len = sizeof(*old) + CALIPSO_OPT_LEN_MAX;
> +	}
> +
> +	new = kzalloc(buf_len, GFP_ATOMIC);
> +	if (!new)
> +		return ERR_PTR(-ENOMEM);
> +
> +	if (start > 2)
> +		memcpy(new, old, start);
> +	ret_val = calipso_genopt((unsigned char *)new, start, buf_len, doi_def,
> +				 secattr);
> +	if (ret_val < 0)
> +		return ERR_PTR(ret_val);
> +
> +	end = start + ret_val;
> +
> +	if (WARN_ON_ONCE(end & 3)) {
> +		kfree(new);
> +		return ERR_PTR(-EINVAL);
> +	}

Vertical whitespace.

Also, considering the code in calipso_genopt(), are we ever going to see the 
buffer not properly sized?  In other words, beyond early development, is there 
any chance of the WARN_ON_ONCE ever triggering?

> +	pad = ((end & 7) + (next_opt & 7)) & 7;
> +
> +	calipso_pad_write((unsigned char *)new, end, pad);
> +	buf_len = end + pad;
> +
> +	if (next_opt) {
> +		memcpy((char *)new + end + pad, (char *)old + next_opt,
> +		       ipv6_optlen(old) - next_opt);
> +		buf_len += ipv6_optlen(old) - next_opt;

It seems like the code might be simplified if we always put the CALIPSO at the 
end, what do you think?

> +	}
> +
> +	new->nexthdr = 0;
> +	new->hdrlen = buf_len / 8 - 1;
> +
> +	return new;
> +}
> +
> +/**
> + * calipso_opt_del - Removes the CALIPSO option from an option header
> + * @old: the original header
> + * @new: the new header
> + *
> + * Description:
> + * Creates a new header based on @old without any CALIPSO option.  If @old
> + * doesn't contain a CALIPSO option it returns -ENOENT.  If @old contains
> + * no other non-padding options, it returns zero with @new set to NULL.
> + * Otherwise it returns zero, creates a new header without the CALIPSO
> + * option (and removing as much padding as possible) and returns with
> + * @new set to that header.
> + *
> + */
> +static int calipso_opt_del(struct ipv6_opt_hdr *old,
> +			   struct ipv6_opt_hdr **new)
> +{
> +	int ret_val;
> +	unsigned int start, end, delta, pad;
> +
> +	ret_val = calipso_opt_find(old, &start, &end);
> +	if (ret_val)
> +		return ret_val;
> +
> +	if (start == sizeof(*old) && end == ipv6_optlen(old)) {
> +		/* There's no other option in the header so return NULL */
> +		*new = NULL;
> +		return 0;
> +	}
> +
> +	delta = (end - start) & ~7;
> +	*new = kzalloc(ipv6_optlen(old) - delta, GFP_ATOMIC);
> +	if (!*new)
> +		return -ENOMEM;

Why not simply use the option buffer that has already been allocated since we 
are guaranteed that the new length will be shorter?  What am I missing?

> +	memcpy(*new, old, start);
> +	(*new)->hdrlen -= delta / 8;
> +	pad = (end - start) & 7;
> +	calipso_pad_write((unsigned char *)*new, start, pad);
> +	if (end != ipv6_optlen(old))
> +		memcpy((char *)*new + start + pad, (char *)old + end,
> +		       ipv6_optlen(old) - end);
> +
> +	return 0;
> +}

-- 
paul moore
security @ redhat
