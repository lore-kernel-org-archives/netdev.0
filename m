From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] net: Discard and warn about LRO'd skbs received for forwarding
Date: Thu, 19 Jun 2008 23:42:51 +0100
Message-ID: <20080619224246.GA29360@solarflare.com>
References: <cover.1213898165.git.bhutchings@solarflare.com> <20080619180833.GU5350@solarflare.com> <20080619145015.3ec2307c@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	Kieran Mansley <kmansley@solarflare.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.mbr-roch.zen.net.uk ([212.23.3.142]:44414 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753392AbYFSWm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 18:42:58 -0400
Content-Disposition: inline
In-Reply-To: <20080619145015.3ec2307c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Thu, 19 Jun 2008 19:08:34 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> > Add skb_warn_if_lro() to test whether an skb was received with LRO and
> > warn if so.
> > 
> > Change br_forward(), ip_forward() and ip6_forward() to call it) and
> > discard the skb if it returns true.
> 
> Actually shouldn't ip forwarding work because of refragmentation?

At the moment, LRO'd skbs have gso_size != 0 and ip_summed ==
CHECKSUM_UNNECESSARY (typically), and this results in taking the
GSO path on output and hitting a BUG() or WARN() in skb_segment_gso().
If you want to avoid this without dropping packets, you can avoid the
condition by either:

- setting gso_size = 0 - should result in fragmentation
- setting ip_summed = CHECKSUM_NONE - should result in GSO
  (maybe skb_forward_csum() could do that)

But I didn't try either of these because I think it's fundamentally
dodgy to apply LRO to forwarded packets.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
