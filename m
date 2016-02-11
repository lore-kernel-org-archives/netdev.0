From: Huw Davies <huw@codeweavers.com>
Subject: Re: [RFC PATCH v2 10/18] calipso: Set the calipso socket label to
 match the secattr.
Date: Thu, 11 Feb 2016 14:54:27 +0000
Message-ID: <20160211145427.GB31695@merlot>
References: <1452246774-13241-11-git-send-email-huw@codeweavers.com>
 <9580708.OYiE7xvQSN@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.codeweavers.com ([216.251.189.131]:46951 "EHLO
	mail.codeweavers.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbcBKOyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 09:54:35 -0500
Content-Disposition: inline
In-Reply-To: <9580708.OYiE7xvQSN@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 07, 2016 at 02:56:08PM -0500, Paul Moore wrote:
> On Friday, January 08, 2016 09:52:46 AM Huw Davies wrote:
> > +/**
> > + * calipso_genopt - Generate a CALIPSO option
> > + * @buf: the option buffer
> > + * @start: offset from which to write
> > + * @buf_len: the size of opt_buf
> > + * @doi_def: the CALIPSO DOI to use
> > + * @secattr: the security attributes
> > + *
> > + * Description:
> > + * Generate a CALIPSO option using the DOI definition and security
> > attributes + * passed to the function. This also generates upto three bytes
> > of leading + * padding that ensures that the option is 4n + 2 aligned.  It
> > returns the + * number of bytes written (including any initial padding).
> > + */
> > +static int calipso_genopt(unsigned char *buf, u32 start, u32 buf_len,
> > +			  const struct calipso_doi *doi_def,
> > +			  const struct netlbl_lsm_secattr *secattr)
> > +{
> > +	int ret_val;
> > +	u32 len, pad;
> > +	u16 crc;
> > +	static const unsigned char padding[4] = {2, 1, 0, 3};
> > +	unsigned char *calipso;
> > +
> > +	/* CALIPSO has 4n + 2 alignment */
> > +	pad = padding[start % 4];
> 
> It's probably quicker to use a bitmask than a modulus operation.

Ok.
 
> > +	if (buf_len <= start + pad + CALIPSO_HDR_LEN)
> > +		return -ENOSPC;
> > +
> > +	if ((secattr->flags & NETLBL_SECATTR_MLS_LVL) == 0)
> > +		return -EPERM;
> > +
> > +	len = CALIPSO_HDR_LEN;
> > +
> > +	if (secattr->flags & NETLBL_SECATTR_MLS_CAT) {
> > +		ret_val = calipso_map_cat_hton(doi_def,
> > +					       secattr,
> > +					       buf + start + pad + len,
> > +					       buf_len - start - pad - len);
> > +		if (ret_val < 0)
> > +			return ret_val;
> > +		len += ret_val;
> > +	}
> > +
> > +	calipso_pad_write(buf, start, pad);
> > +	calipso = buf + start + pad;
> 
> Help me understand why we would need to pad before the CALIPSO option?  
> Assuming any preceding options are properly aligned, or there are no preceding 
> options at all, this should never be needed, yes?

Options may end at any alignment, so the preceding option might end at
4n+1, say, followed by three bytes of padding.  What we'd like to do
is replace those three bytes with one byte and start the CALIPSO
option at 4n+2.  So in this case, we need to write a single padding
byte before the CALIPSO option.
 
> > +	calipso[0] = IPV6_TLV_CALIPSO;
> > +	calipso[1] = len - 2;
> > +	*(__be32 *)(calipso + 2) = htonl(doi_def->doi);
> > +	calipso[6] = (len - CALIPSO_HDR_LEN) / 4;
> > +	calipso[7] = secattr->attr.mls.lvl,
> > +	crc = crc_ccitt(0xffff, calipso, len);
> > +	crc = ~crc;
> 
> Why not just "crc = ~crc_ccitt(...);"?

No reason, will fix.
 
> > +	calipso[8] = crc & 0xff;
> > +	calipso[9] = (crc >> 8) & 0xff;
> 
> Do we need to convert the checksum to network byte order?

Not according to https://tools.ietf.org/html/rfc1662#section-3.1
(which is referenced from rfc 5570 when describing the CRC-16):

 Frame Check Sequence (FCS) Field

      The Frame Check Sequence field defaults to 16 bits (two octets).
      The FCS is transmitted least significant octet first, which
      contains the coefficient of the highest term.

Also, I obtained a packet capture from a Trusted Solaris box, and
this appears to be consistant with that.
 
> > +/**
> > + * calipso_tlv_len - Returns the length of the TLV.
> > + * @tlv: the TLV
> > + *
> > + * Description:
> > + * Returns the length of the provided TLV option.
> > + */
> > +static int calipso_tlv_len(unsigned char *tlv)
> > +{
> > +	if (tlv[0] == IPV6_TLV_PAD1)
> > +		return 1;
> > +	return tlv[1] + 2;
> > +}
> 
> Perhaps rename this to calipso_opt_len() and change the argument from tlv to 
> opt?

That would be confusing w.r.t. ipv6_optlen().  By calling it _tlv_len I'm
trying to distinguish the length of a TLV value from the length of the
entire hop option.  Other suggestions are welcome.
 
> There may also be a desire to make this a generic ipv6 function; to be honest 
> I'm surprised there isn't one to do this already.

I'll leave it internal for now; if the network guys want it, they can shout.

Actually, I need to tweak this function.  We can't guarantee that we can
access tlv[1] without knowing the hop option length.  I'm thinking of
something like this, which also checks that the entire TLV value
sits within the hop opt.

static int calipso_tlv_len(struct ipv6_opt_hdr *opt, unsigned int offset)
{
        unsigned char *tlv = (unsigned char *)opt;
        unsigned int opt_len = ipv6_optlen(opt), tlv_len;

        if (offset < sizeof(*opt) || offset >= opt_len)
                return -EINVAL;
        if (tlv[offset] == IPV6_TLV_PAD1)
                return 1;
        if (offset + 1 >= opt_len)
                return -EINVAL;
        tlv_len = tlv[offset + 1] + 2;
        if (offset + tlv_len > opt_len)
                return -EINVAL;
        return tlv_len;
}

> [calipso_opt_find]
> Okay, this whole function seems unnecessarily complex.  I understand that some 
> of this is due to the tracking of the padding, but what about something like 
> what is shown below?  My apologies if I missed some subtle behavior in the 
> original code.
> 
> int calipso_opt_find(struct ipv6_opt_hdr *hop,
>                      unsigned int *start,
>                      unsigned int *end)
> {
> 	int rc = -ENOENT;
> 	unsigned int opt_len;
> 	unsigned int spot, spot_s, spot_e;
> 	unsigned char *opt = hop;
> 
> 	opt_len = ipv6_optlen(hop);
> 	while (opt_iter <= opt_len) {
> 		switch (opt[spot]) {
> 		case IPV6_TLV_PAD1:
> 		case IPv6_TLV_PADN:
> 			if (spot_e)
> 				spot_e = spot;
> 			break;
> 		case IPV6_TLV_CALIPSO:
> 			rc = 0;
> 			spot_e = spot;
> 			break;
> 		default:
> 			if (spot_e == 0)
> 				spot_s = spot;
> 			else
> 				goto out;
> 		}
> 		spot += calipso_tlv_len(opt[spot]);
> 	}
> 
> out:
> 	if (spot_s)
> 		*start = spot_s + calipso_tlv_len(opt[spot_s]);
> 	else
> 		*start = 0;
> 	if (spot_e)
> 		*end = spot_e + calipso_tlv_len(opt[spot_e]);
> 	else
> 		*end = opt_len;
> 
> 	return rc;
> }

Yes, a version like this is much nicer, thanks!  Though I can't deal
with 'spot' and 'opt' ;-)

> > +/**
> > + * calipso_opt_insert - Inserts a CALIPSO option into an IPv6 hop opt hdr.
> > + * @old: the original hop options header
> > + * @doi_def: the CALIPSO DOI to use
> > + * @secattr: the specific security attributes of the socket
> > + *
> > + * Description:
> > + * Creates a new hop options header based on @old with a
> > + * CALIPSO option added to it.  If @old already contains a CALIPSO
> > + * option this is overwritten, otherwise the new option is appended
> > + * after any existing options.  If @old is NULL then the new header
> > + * will contain just the CALIPSO option and any needed padding.
> > + *
> > + */
> > +static struct ipv6_opt_hdr *
> > +calipso_opt_insert(struct ipv6_opt_hdr *old,
> > +		   const struct calipso_doi *doi_def,
> > +		   const struct netlbl_lsm_secattr *secattr)
> 
> How about renaming "old" to "hop"?

Sure.

> > +{
> > +	unsigned int start, end, next_opt, buf_len, pad;
> > +	struct ipv6_opt_hdr *new;
> > +	int ret_val;
> > +
> > +	if (old) {
> > +		ret_val = calipso_opt_find(old, &start, &end);
> > +		if (ret_val && ret_val != -ENOENT)
> > +			return ERR_PTR(ret_val);
> > +		if (end != ipv6_optlen(old))
> > +			next_opt = end;
> > +		else
> > +			next_opt = 0;
> > +		buf_len = ipv6_optlen(old) - ((end - start) & ~7) +
> > +			CALIPSO_OPT_LEN_MAX;
> > +	} else {
> > +		start = 0;
> > +		next_opt = 0;
> > +		buf_len = sizeof(*old) + CALIPSO_OPT_LEN_MAX;
> > +	}
> > +
> > +	new = kzalloc(buf_len, GFP_ATOMIC);
> > +	if (!new)
> > +		return ERR_PTR(-ENOMEM);
> > +
> > +	if (start > 2)
> > +		memcpy(new, old, start);
> > +	ret_val = calipso_genopt((unsigned char *)new, start, buf_len, doi_def,
> > +				 secattr);
> > +	if (ret_val < 0)
> > +		return ERR_PTR(ret_val);
> > +
> > +	end = start + ret_val;
> > +
> > +	if (WARN_ON_ONCE(end & 3)) {
> > +		kfree(new);
> > +		return ERR_PTR(-EINVAL);
> > +	}
> 
> Vertical whitespace.
> 
> Also, considering the code in calipso_genopt(), are we ever going to see the 
> buffer not properly sized?  In other words, beyond early development, is there 
> any chance of the WARN_ON_ONCE ever triggering?

I'll remove them.

> > +	pad = ((end & 7) + (next_opt & 7)) & 7;
> > +
> > +	calipso_pad_write((unsigned char *)new, end, pad);
> > +	buf_len = end + pad;
> > +
> > +	if (next_opt) {
> > +		memcpy((char *)new + end + pad, (char *)old + next_opt,
> > +		       ipv6_optlen(old) - next_opt);
> > +		buf_len += ipv6_optlen(old) - next_opt;
> 
> It seems like the code might be simplified if we always put the CALIPSO at the 
> end, what do you think?

I tried and it actually makes life more complicated.  That's primarily
because you have to figure out how many pad bytes there are at the end
of the existing hop option.  If we stick with replacing the existing
one, we get all the information we need from calipso_opt_find().

I have however made this function a bit simpler by removing 'next_opt'.

> > +	}
> > +
> > +	new->nexthdr = 0;
> > +	new->hdrlen = buf_len / 8 - 1;
> > +
> > +	return new;
> > +}
> > +
> > +/**
> > + * calipso_opt_del - Removes the CALIPSO option from an option header
> > + * @old: the original header
> > + * @new: the new header
> > + *
> > + * Description:
> > + * Creates a new header based on @old without any CALIPSO option.  If @old
> > + * doesn't contain a CALIPSO option it returns -ENOENT.  If @old contains
> > + * no other non-padding options, it returns zero with @new set to NULL.
> > + * Otherwise it returns zero, creates a new header without the CALIPSO
> > + * option (and removing as much padding as possible) and returns with
> > + * @new set to that header.
> > + *
> > + */
> > +static int calipso_opt_del(struct ipv6_opt_hdr *old,
> > +			   struct ipv6_opt_hdr **new)
> > +{
> > +	int ret_val;
> > +	unsigned int start, end, delta, pad;
> > +
> > +	ret_val = calipso_opt_find(old, &start, &end);
> > +	if (ret_val)
> > +		return ret_val;
> > +
> > +	if (start == sizeof(*old) && end == ipv6_optlen(old)) {
> > +		/* There's no other option in the header so return NULL */
> > +		*new = NULL;
> > +		return 0;
> > +	}
> > +
> > +	delta = (end - start) & ~7;
> > +	*new = kzalloc(ipv6_optlen(old) - delta, GFP_ATOMIC);
> > +	if (!*new)
> > +		return -ENOMEM;
> 
> Why not simply use the option buffer that has already been allocated since we 
> are guaranteed that the new length will be shorter?  What am I missing?

The buffer is actually part of a bigger buffer that holds all of the
txopts.  In principle we could do it this way, but we've have to
update all of the ptrs in that structure.  That's going to be more
complicated - we could do that at a later stage if it's needed.

Huw.
