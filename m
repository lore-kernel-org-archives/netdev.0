From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v3] net: Do not include padding in TCP GRO checksum
Date: Sat, 16 Nov 2013 09:02:34 -0800
Message-ID: <5287A52A.2060802@gmail.com>
References: <20131115225856.6988.69733.stgit@ahduyck-fpga.jf.intel.com> <20131116004738.GA1491@gondor.apana.org.au> <20131116015301.GA1999@gondor.apana.org.au> <5286F018.8060801@gmail.com> <20131116064611.GA12146@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, edumazet@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:62816 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267Ab3KPRCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 12:02:37 -0500
Received: by mail-pd0-f178.google.com with SMTP id p10so4771472pdj.37
        for <netdev@vger.kernel.org>; Sat, 16 Nov 2013 09:02:36 -0800 (PST)
In-Reply-To: <20131116064611.GA12146@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2013 10:46 PM, Herbert Xu wrote:
> On Fri, Nov 15, 2013 at 08:10:00PM -0800, Alexander Duyck wrote:
>> The case I am addressing is padding added by the remote side. 
>> Specifically in my case I was seeing TCP frames without options that
>> were padded up to 60 bytes from a netperf TCP_RR test.  I messed up the
>> padding/checksum logic so it was making the same mistake in the Tx
>> checksum logic in the driver that I caught here in GRO.  As a result I
>> was seeing checksum errors errors in wireshark, but noticed they were
>> being accepted by the stack as valid.
> OK great.  So this isn't normal data that we expect to aggregate.

Sorry, I thought that was obvious.  The check in the IPv4/IPv6 GRO
functions always make it so that we flush any frames that contain padding.

> In that case the simplest solution is to skip the checksum check
> altogether.  We only require it if the packet is going to be merged.
>
> So how about something like this?
>
> gro: Only verify TCP checksums for candidates
>
> In some cases we may receive IP packets that are longer than
> their stated lengths.  Such packets are never merged in GRO.
> However, we may end up computing their checksums incorrectly
> and end up allowing packets with a bogus checksum enter our
> stack with the checksum status set as verified.
>
> Since such packets are rare and not performance-critical, this
> patch simply skips the checksum verification for them.
>
> Reported-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
> index a2b68a1..55aeec9 100644
> --- a/net/ipv4/tcp_offload.c
> +++ b/net/ipv4/tcp_offload.c
> @@ -276,6 +276,10 @@ static struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *
>  	__wsum wsum;
>  	__sum16 sum;
>  
> +	/* Don't bother verifying checksum if we're going to flush anyway. */
> +	if (NAPI_GRO_CB(skb)->flush)
> +		goto skip_csum;
> +
>  	switch (skb->ip_summed) {
>  	case CHECKSUM_COMPLETE:
>  		if (!tcp_v4_check(skb_gro_len(skb), iph->saddr, iph->daddr,
> @@ -301,6 +305,7 @@ flush:
>  		break;
>  	}
>  
> +skip_csum:
>  	return tcp_gro_receive(head, skb);
>  }
>  
> diff --git a/net/ipv6/tcpv6_offload.c b/net/ipv6/tcpv6_offload.c
> index c1097c7..71923d1 100644
> --- a/net/ipv6/tcpv6_offload.c
> +++ b/net/ipv6/tcpv6_offload.c
> @@ -39,6 +39,10 @@ static struct sk_buff **tcp6_gro_receive(struct sk_buff **head,
>  	__wsum wsum;
>  	__sum16 sum;
>  
> +	/* Don't bother verifying checksum if we're going to flush anyway. */
> +	if (NAPI_GRO_CB(skb)->flush)
> +		goto skip_csum;
> +
>  	switch (skb->ip_summed) {
>  	case CHECKSUM_COMPLETE:
>  		if (!tcp_v6_check(skb_gro_len(skb), &iph->saddr, &iph->daddr,
> @@ -65,6 +69,7 @@ flush:
>  		break;
>  	}
>  
> +skip_csum:
>  	return tcp_gro_receive(head, skb);
>  }
>
> Thanks,

This should work.  I was just playing it safe in the patches I was
submitting by trying not to alter the behaviour.  As long as it is safe
to push something with a bad checksum and the flush bit I am fine with this.

That being the case though, why don't we set the flush flag on detecting
a bad checksum and hand it off to tcp_gro_receive instead of returning
NULL?  It seems like it would be in our interest to flush the flow and
then report the bad checksum instead of keeping the flow and handing off
the bad checksum to the stack.

Thanks,

Alex
