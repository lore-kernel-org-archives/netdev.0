From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] sctp: Fix mangled IPv4 addresses on a IPv6 listening
 socket
Date: Wed, 27 May 2015 10:11:16 +0200
Message-ID: <55657C24.1010601@iogearbox.net>
References: <20150526233017.GB22391@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43994 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752369AbbE0ILd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 04:11:33 -0400
In-Reply-To: <20150526233017.GB22391@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/2015 01:30 AM, Jason Gunthorpe wrote:
> sctp_v4_map_v6 was subtly writing and reading from members
> of a union in a way the clobbered data it needed to read before

s/the/that/

> it read it.
>
> Zeroing the v6 flowinfo overwrites the v4 sin_addr with 0, meaning
> that every place that calls sctp_v4_map_v6 gets ::ffff:0.0.0.0 as the
> result.
>
> Reorder things to guarantee correct behaviour no matter what the
> union layout is.
>
> This impacts user space clients that open an IPv6 SCTP socket and
> receive IPv4 connections. Prior to 299ee user space would see a
> sockaddr with AF_INET and a correct address, after 299ee the sockaddr
> is AF_INET6, but the address is wrong.
>
> Fixes: 299ee123e198 (sctp: Fixup v4mapped behaviour to comply with Sock API)
> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> ---
>   include/net/sctp/sctp.h | 7 +++++--
>   1 file changed, 5 insertions(+), 2 deletions(-)
>
> This bugfix should be a candidate for -stable
>
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index 856f01cb51dd..230775f5952a 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -571,11 +571,14 @@ static inline void sctp_v6_map_v4(union sctp_addr *addr)
>   /* Map v4 address to v4-mapped v6 address */
>   static inline void sctp_v4_map_v6(union sctp_addr *addr)
>   {
> +	__be16 port;
> +
> +	port = addr->v4.sin_port;
> +	addr->v6.sin6_addr.s6_addr32[3] = addr->v4.sin_addr.s_addr;
> +	addr->v6.sin6_port = port;
>   	addr->v6.sin6_family = AF_INET6;
>   	addr->v6.sin6_flowinfo = 0;
>   	addr->v6.sin6_scope_id = 0;
> -	addr->v6.sin6_port = addr->v4.sin_port;
> -	addr->v6.sin6_addr.s6_addr32[3] = addr->v4.sin_addr.s_addr;

Change looks good to me. You actually would only need to address
the issue where the v4.sin_addr is copied before you overwrite/zero
the flowinfo as only these two overlap in the union. Given that
sockaddr_in and sockaddr_in6 are exported to uapi, they are immutable,
but I see the point that union sctp_addr is kernel private - bad
things happen if v4/v6 don't overlap the way anymore as they'd do
now. ;)

Anyways:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

>   	addr->v6.sin6_addr.s6_addr32[0] = 0;
>   	addr->v6.sin6_addr.s6_addr32[1] = 0;
>   	addr->v6.sin6_addr.s6_addr32[2] = htonl(0x0000ffff);
>
