From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 3/5] net: Add helper function to compare
 inetpeer addresses
Date: Fri, 28 Aug 2015 14:03:56 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB8970A@AcuExch.aculab.com>
References: <1440710193-4824-1-git-send-email-dsa@cumulusnetworks.com>
 <1440710193-4824-4-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'David Ahern' <dsa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.194]:50015 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140AbbH1OET convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 10:04:19 -0400
In-Reply-To: <1440710193-4824-4-git-send-email-dsa@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern
> Sent: 27 August 2015 22:17
ATCH net-next 3/5] net: Add helper function to compare inetpeer addresses
> 
> tcp_metrics and inetpeer both have functions to compare inetpeer
> addresses. Consolidate into 1 version.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
...
> diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
> index f75b9e7036a2..9d9b3446731d 100644
> --- a/include/net/inetpeer.h
> +++ b/include/net/inetpeer.h
> @@ -121,6 +121,22 @@ static inline struct inet_peer *inet_getpeer_v6(struct inet_peer_base *base,
>  	return inet_getpeer(base, &daddr, create);
>  }
> 
> +static inline int inetpeer_addr_cmp(const struct inetpeer_addr *a,
> +				    const struct inetpeer_addr *b)
> +{
> +	int i, n = (a->family == AF_INET ? 1 : 4);
> +
> +	for (i = 0; i < n; i++) {
> +		if (a->addr.a6[i] == b->addr.a6[i])
> +			continue;
> +		if ((__force u32)a->addr.a6[i] < (__force u32)b->addr.a6[i])
> +			return -1;
> +		return 1;
> +	}
> +
> +	return 0;
> +}

If the performance of this matters then I'd not use the loop for IPv4
and use u64 comparisons (esp. on 64 bit systems) in an unrolled loop for IPv6.
(Might need to worry about the alignment.)

I presume nothing cares that the ordering relation is endian dependant?
With either byteswapping memory reads or a byteswapping instruction
then an endian-independant ordering should be almost as quick.

	David
