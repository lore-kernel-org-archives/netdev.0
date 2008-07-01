From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: MD5 SG fix
Date: Tue, 1 Jul 2008 14:39:43 -0700
Message-ID: <20080701143943.426c9f24@extreme>
References: <396556a20805301217k293e5718h6bbf02bfe0683151@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Adam Langley" <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:45324 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751190AbYGAVju (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2008 17:39:50 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe0683151@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Jul 2008 14:16:34 -0700
"Adam Langley" <agl@imperialviolet.org> wrote:

> I believe this patch fixes MD5 in the face of SG interfaces for IPv4. Stephen,
> could you test this because I don't get non-linear packets in my test network?
> The patch includes a debugging function which can be uncommented if you have
> issues.
> 
> If this works for you, I'll clean it up and perform the same fix for IPv6
> before submiting.
> 
> Sadly, I couldn't just pass in the SKB to the md5_hash function because there
> are several places where we don't have an SKB to hand (generating ACKs and
> RSTs, for example).
> 
> This patch is, obviously, semantically incongruent with [1] and [1] should be
> backed out before applying.
> 
> Cheers,
> 
> 
> AGL
> 
> 
> [1] http://marc.info/?l=linux-netdev&m=121459157816964&w=2
> 
> ---
> 
>  include/net/tcp.h     |   11 +++--
>  net/ipv4/tcp_ipv4.c   |  113 +++++++++++++++++++++++++++++++++++++------------
>  net/ipv4/tcp_output.c |   14 ++++--
>  3 files changed, 101 insertions(+), 37 deletions(-)
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 633147c..4213379 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1110,6 +1110,7 @@ union tcp_md5sum_block {
>  struct tcp_md5sig_pool {
>  	struct hash_desc	md5_desc;
>  	union tcp_md5sum_block	md5_blk;
> +	struct scatterlist sg[MAX_SKB_FRAGS + 3];
>  };
>  

I would rather see the pool used less and the stack used more.
Global context is more like FORTRAN common blocks.

My suggestion would be to have two hash functions, one that takes a block
for the cases of TCP SYN, etc. and another that takes an skb for data packets.

You still need to have some of the places that reset sk_route_caps otherwise
you will get TSO/GSO packets because of the resetting of route_caps after the SYN/ACK.


