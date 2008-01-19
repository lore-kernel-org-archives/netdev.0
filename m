From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] mv643xx: fix byte order when checksum offload is enabled
Date: Sat, 19 Jan 2008 20:09:01 +0000
Message-ID: <20080119200900.GE27894@ZenIV.linux.org.uk>
References: <1200770858-11456-1-git-send-email-byron.bbradley@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hvr@gnu.org, akpm@linux-foundation.org,
	Dale Farnsworth <dale@farnsworth.org>,
	Manish Lachwani <mlachwani@mvista.com>,
	Tzachi Perelstein <tzachi@marvell.com>
To: Byron Bradley <byron.bbradley@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:44234 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658AbYASUJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2008 15:09:05 -0500
Content-Disposition: inline
In-Reply-To: <1200770858-11456-1-git-send-email-byron.bbradley@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 19, 2008 at 07:27:38PM +0000, Byron Bradley wrote:
>  		case IPPROTO_UDP:
>  			cmd_sts |= ETH_UDP_FRAME;
> -			desc->l4i_chk = udp_hdr(skb)->check;
> +			desc->l4i_chk = htons(udp_hdr(skb)->check);
>  			break;
>  		case IPPROTO_TCP:
> -			desc->l4i_chk = tcp_hdr(skb)->check;
> +			desc->l4i_chk = htons(tcp_hdr(skb)->check);
>  			break;

The first part was OK, but this one...  AFAICS, the sucker byteswaps
64bit words in descriptors wholesale, right?  Then the right way to spell
that would be ntohs((__force __be16)....->check).

What's happening here is that we take a fixed-endian (checksum) and then
correct for conversion done in hardware - i.e. we store it in something
that expects a _host_-endian value and would convert that to fixed-endian.
So we need to counter that correction and that's where the damn thing is
coming from.

It's not particulary rare - drivers that do hardware byteswap tend to need
it.  For now I'd suggest explicit form (with force-cast from __csum to
__be16 and ntohs() on top of it); if anybody has good ideas for helper
names, though...  csum_as_le() and csum_as_be(), perhaps?  Interpret
__csum (fixed-endian) and another fixed-endian type, with proper checks;
i.e. something along the lines of
static inline __be16 csum_as_be(__csum sum)
{
	return (__force __be16)sum;
}
and this stuff becoming ntohs(csum_as_be(udp_hdr(skb)->check)), etc.
