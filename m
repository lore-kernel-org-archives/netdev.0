From: Florian Westphal <fw@strlen.de>
Subject: Re: [net-next fragmenation icmp v2 1/2] bridge_netfilter: No ICMP
 packet on IPv4 defragmentation timeout
Date: Thu, 7 May 2015 04:07:19 +0200
Message-ID: <20150507020719.GG21713@breakpoint.cc>
References: <1430962033-16141-1-git-send-email-azhou@nicira.com>
 <1430962033-16141-2-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:53792 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751162AbbEGCHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 22:07:22 -0400
Content-Disposition: inline
In-Reply-To: <1430962033-16141-2-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Zhou <azhou@nicira.com> wrote:
> Currently, on defragmentation timeout error, ICMP error message
> will be generated. This is fine when they are used in a routing context,
> but does not make sense in the context of bridging netfilter.
> 
> This patch adds a bit (IPSKB_NO_FRAG_ICMP) in IPCB to control
> whether ICMP error message should be generated. br_netfiler sets
> this bit.

Why not use qp->user to make this decision for bridge too?

> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
> index cc1da6d..447d9ec 100644
> --- a/net/ipv4/ip_fragment.c
> +++ b/net/ipv4/ip_fragment.c
> @@ -217,7 +217,8 @@ static void ip_expire(unsigned long arg)
>  		/* Only an end host needs to send an ICMP
>  		 * "Fragment Reassembly Timeout" message, per RFC792.
>  		 */
> -		if (qp->user == IP_DEFRAG_AF_PACKET ||
>  		    ((qp->user >= IP_DEFRAG_CONNTRACK_IN) &&
>  		     (qp->user <= __IP_DEFRAG_CONNTRACK_IN_END) ||

  		    ((qp->user >= IP_DEFRAG_CONNTRACK_BRIDGE_IN) &&
  		     (qp->user <= __IP_DEFRAG_CONNTRACK_BRIDGE_IN) &&


[ This if cascade is getting silly, might make sense to add
 'static bool should_send_icmp(enum ip_defrag_users users)', move if
 tests there and then just

if (should_send_icmp(qp->user) && skb_rtable( ...)
