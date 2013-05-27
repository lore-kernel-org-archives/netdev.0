From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [RFC] l2tp: avoid checksum offload for fragmented packets
Date: Mon, 27 May 2013 14:58:29 -0400
Message-ID: <20130527185829.GO1942@kvack.org>
References: <1368723860-22749-1-git-send-email-tparkin@katalix.com> <1368723860-22749-2-git-send-email-tparkin@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:51387 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751398Ab3E0TEr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 15:04:47 -0400
Content-Disposition: inline
In-Reply-To: <1368723860-22749-2-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 16, 2013 at 06:04:20PM +0100, Tom Parkin wrote:
> Hardware offload for UDP datagram checksum calculation doesn't work with
> fragmented IP packets -- the device will note the fragmentation and leave the
> UDP checksum well alone.

> As such, if we expect the L2TP packet to be fragmented by the IP layer we need
> to perform the UDP checksum ourselves in software (ref: net/ipv4/udp.c).

Hrm, indeed.

> This change modifies the L2TP xmit path to fallback to software checksum
> calculation if the L2TP packet + IP header exceeds the tunnel device MTU.
> Since we don't know what the IP header length will be a priori, we assume the
> worst-case of 60b.  This will likely result in unnecessary software
> checksumming when packet sizes approach the MTU since it's probably not common
> to be using the full IP header.

Using the worst case value of 60 is a poor choice for many users of L2TP --
plenty of the wholesale ISP services in the world using PPPoE transport 
sessions to ISPs using frame with headers of ethernet(14) + IP(20) + UDP(8) + 
L2TP(6) = 48 (this setup is used by a number of large telcos here in Canada).  
This will results in spurious use of software checksumming over links that 
are provisioned with the minimum usable MTU (which is common with this kind 
of link).  Please make the code calculate the correct size of the added 
headers to avoid uexpected CPU overhead.

> An alternative approach is to mimic UDP and use socket corking to allow us to
> pass the skb to the IP layer prior to finally pushing the button on xmit.
> This lets IP do his fragmentation before we authorise the packet send,
> allowing us to check whether the packet was actually fragmented by IP or not.

That is probably undesirable from a CPU usage point of view.  Ideally, the 
kernel's L2TP stack should generate ICMP frag needed messages for such 
frames to avoid the fragmentation overhead (ipip is one such tunnelling 
protocol that does this; there are others).

> Signed-off-by: Tom Parkin <tparkin@katalix.com>

Nacked-by: Benamin LaHaise at least until the IPv6 issue (see blow) is fixed 
at the bare minimum.

> ---
>  net/l2tp/l2tp_core.c |   53 ++++++++++++++++++++++++++++++--------------------
>  1 file changed, 32 insertions(+), 21 deletions(-)
> 
> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index 6984c3a..bc10658 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c

...

> @@ -1197,30 +1224,14 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
>  		uh->check = 0;
>  
>  		/* Calculate UDP checksum if configured to do so */
> +		if (sk->sk_no_check == UDP_CSUM_NOXMIT)
> +			skb->ip_summed = CHECKSUM_NONE;
>  #if IS_ENABLED(CONFIG_IPV6)
> -		if (sk->sk_family == PF_INET6)
> +		else if (sk->sk_family == PF_INET6)
>  			l2tp_xmit_ipv6_csum(sk, skb, udp_len);
> -		else
...

The last time I checked, for IPv6 UDP packets, the checksum MUST always be 
calculated (RFC 2460).  If this has changed, you'll also need to update the 
IPv6 UDP receive path to allow rx packets with a zero checksum, as I believe 
they are noisily dropped at present.

		-ben
-- 
"Thought is the essence of where you are now."
