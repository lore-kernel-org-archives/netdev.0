From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] net/hsr: Add support for IEC 62439-3 High-availability
 Seamless Redundancy
Date: Wed, 4 Apr 2012 16:55:59 -0700
Message-ID: <20120404165559.5223ab95@s6510.linuxnetplumber.net>
References: <4F71BEAD.5080605@enea.com>
	<20120403113751.21fd0b17@s6510.linuxnetplumber.net>
	<4F7CD4BC.4000006@enea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Bruno Ferreira <balferreira@googlemail.com>,
	Arvid Brodin <arvid.brodin@xdin.com>
To: Arvid Brodin <arvid.brodin@enea.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58872 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753799Ab2DDX4H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 19:56:07 -0400
In-Reply-To: <4F7CD4BC.4000006@enea.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 5 Apr 2012 01:09:48 +0200
Arvid Brodin <arvid.brodin@enea.com> wrote:

> Stephen Hemminger wrote:
> > On Tue, 27 Mar 2012 15:20:45 +0200
> > Arvid Brodin <arvid.brodin@enea.com> wrote:
> > 
> >> +config NONSTANDARD_HSR
> >> +	bool "HSR: Use efficient tag (breaks HSR standard, read help!)"
> >> +	depends on HSR
> >> +	---help---
> >> +	  The HSR standard specifies a 6-byte HSR tag to be inserted into the
> >> +	  transmitted network frames. This breaks the 32-bit alignment that the
> >> +	  Linux network stack relies on, and would cause kernel panics on
> >> +	  certain architectures. To avoid this, the whole frame payload is
> >> +	  memmoved 2 bytes on reception on these architectures - which is very
> >> +	  inefficient!
> > 
> > This option won't fly. Don't do it.
> > If you need to copy/realign packets on some architecture the stack
> > should be changed to handle it.
> 
> Ok. The problems are in net/ipv4/icmp.c. The below patch seems to do
> the trick for me - does it look OK (and if so, should I resend it as
> a normal patch instead of a reply or is this enough)?
> 
> Note that I've only triggered this problem in icmp_echo(), but I
> noticed that icmp_timestamp() does the same thing, so I made the change
> there too.
> 
> 
> [PATCH] net/ipv4/icmp: Fix kernel panic due to unaligned access with HSR on AVR32
> 
> icmp_echo() and icmp_timestamp() requires the icmphdr struct to be
> 32-bit aligned. This causes a kernel panic on AVR32 when HSR is used,
> since the HSR protocol inserts a 6-byte "HSR tag" into Ethernet frame
> headers, thus changing the alignment.
> 
> HSR = IEC 62439-3 High-availability Seamless Redundancy.
> 
> Signed-off-by: Arvid Brodin <arvid.brodin@xdin.com>
> ---
>  net/ipv4/icmp.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> index 2cb2bf8..fdd8097 100644
> --- a/net/ipv4/icmp.c
> +++ b/net/ipv4/icmp.c
> @@ -818,7 +818,8 @@ static void icmp_echo(struct sk_buff *skb)
>  	if (!net->ipv4.sysctl_icmp_echo_ignore_all) {
>  		struct icmp_bxm icmp_param;
>  
> -		icmp_param.data.icmph	   = *icmp_hdr(skb);
> +		memcpy(&icmp_param.data.icmph, icmp_hdr(skb),
> +						sizeof(icmp_param.data.icmph));
>  		icmp_param.data.icmph.type = ICMP_ECHOREPLY;
>  		icmp_param.skb		   = skb;
>  		icmp_param.offset	   = 0;
> @@ -854,7 +855,8 @@ static void icmp_timestamp(struct sk_buff *skb)
>  	icmp_param.data.times[2] = icmp_param.data.times[1];
>  	if (skb_copy_bits(skb, 0, &icmp_param.data.times[0], 4))
>  		BUG();
> -	icmp_param.data.icmph	   = *icmp_hdr(skb);
> +	memcpy(&icmp_param.data.icmph, icmp_hdr(skb),
> +						sizeof(icmp_param.data.icmph));
>  	icmp_param.data.icmph.type = ICMP_TIMESTAMPREPLY;
>  	icmp_param.data.icmph.code = 0;
>  	icmp_param.skb		   = skb;

That isn't so bad, doing a memcpy versus a structure copy.
