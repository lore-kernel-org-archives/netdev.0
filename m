From: Joe Perches <joe@perches.com>
Subject: Re: [PATCHv2] Refactor update of IPv6 flow destination address for
 srcrt (RH) option
Date: Tue, 01 Jun 2010 13:08:45 -0700
Message-ID: <1275422925.19372.114.camel@Joe-Laptop.home>
References: <87wruid8rx.fsf@small.ssi.corp>  <8739x6d0ky.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2540 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752981Ab0FAUIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jun 2010 16:08:47 -0400
In-Reply-To: <8739x6d0ky.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-01 at 21:17 +0200, Arnaud Ebalard wrote:
> I received a comment (privately) about the fact that the transform isn't
> equivalent as its sets final_p in all cases now, and asked if it matters?
> 
> It does not: in current code, final_p is always initialized to NULL when
> it is declared. I also verified it is not used by anything between the
> declaration and the code I replace by the helper.
> 
> In fact, one additional thing which can be done is to remove the
> initialization final_p to NULL when it is declared. The updated version
> below does that.
> 
> Patch is against net-2.6. Tested on 2.6.34.
[]
> +static inline struct in6_addr *srcrt_dst_flow_update(struct in6_addr *final,
> +						     struct in6_addr *fl6dst,
> +						     const struct ipv6_txoptions *opt)
> +{
> +	if (opt && opt->srcrt) {
> +		const struct rt0_hdr *rt0 = (struct rt0_hdr *)opt->srcrt;
> +		ipv6_addr_copy(final, fl6dst);
> +		ipv6_addr_copy(fl6dst, rt0->addr);
> +		return final;
> +	}
> +	return NULL;
> +}
> +

Should this be inline?  Maybe it'd be better moved to exthdrs.c

Perhaps this is clearer as something like:

/**
 * fl6_update_dst - update flow destination address
 *
 * @fl: flowlabel fl_dst to update
 * @opt: struct ipv6_txoptions
 * @orig: original fl_dst if modified
 *
 * Returns NULL if no txoptions or no srcrt, otherwise
 * returns orig and initial value of fl->fl6_dst set in orig
 */
struct in6_addr *fl6_update_dst(struct ip6_flowlabel *fl,
				const struct ipv6_txoptions *opt,
				struct in6_addr *orig)
{
	if (!opt || !opt->srcrt)
		return NULL;

	ipv6_addr_copy(orig, &fl->fl6_dst);
	ipv6_addr_copy(&fl->fl6_dst, ((struct rt0_hdr *)opt->srcrt)->addr);
	return orig;
}


