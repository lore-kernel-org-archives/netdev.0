From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [Security] TIPC security issues
Date: Wed, 27 Oct 2010 14:26:19 -0400
Message-ID: <1288203979.1836.2.camel@dan>
References: <AANLkTi=V93A660+YS8C2TvC13kGUcJpFgjPHUvONd_WW@mail.gmail.com>
	 <20101027.102940.112580564.davem@davemloft.net>
	 <AANLkTinHVXDJbgJ0zBVRnr8R4sx=NtZCaFgbFC+8DE+q@mail.gmail.com>
	 <20101027.105047.183059900.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, netdev@vger.kernel.org,
	security@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:53844 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755038Ab0J0S0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 14:26:24 -0400
In-Reply-To: <20101027.105047.183059900.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The proposed fix is a start, but it's not sufficient to completely fix
the problem.  What if the total of the iovecs wraps around back to 0?
The total size will be returned as a small number, but large amounts of
data will be copied into the allocated buffer since the individual
iovecs can have arbitrary sizes.

-Dan

On Wed, 2010-10-27 at 10:50 -0700, David Miller wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Wed, 27 Oct 2010 10:37:46 -0700
> 
> > If you _really_ care deeply, then some packet-oriented protocol can
> > just have its own private packet size limit (which would be way less
> > than 2GB), and then just look at the total size and say "oh, the total
> > size is bigger than my limit, so I'll just error out". Then, the fact
> > that verify_iovec() may have truncated the message to 2GB-1 doesn't
> > matter at all.
> > 
> > (Practically speaking, I bet all packet-oriented protocols already
> > have a limit that is enforced by simply allocation patterns, so I
> > don't think it's actually a problem even now)
> 
> This is, as it turns out, effectively what the TIPC socket layer
> already does.
> 
> Most of the send calls that propagate down to this code adding up the
> iov_len lengths gets passed a maximum packet size.
> 
> Anyways, here is what I came up with to kill this specific bug in
> TIPC:
> 
> From 39dc17049a5ed989bab8997945a048ffddf48387 Mon Sep 17 00:00:00 2001
> From: David S. Miller <davem@davemloft.net>
> Date: Wed, 27 Oct 2010 10:46:59 -0700
> Subject: [PATCH] tipc: Fix iov_len handling in message send path.
> 
> Use size_t to add together iov_len's from the iovec, error
> out with -EMSGSIZE if total is greater than INT_MAX.
> 
> Reported-by: Dan Rosenberg <drosenberg@vsecurity.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/tipc/msg.c |   13 ++++++++++---
>  1 files changed, 10 insertions(+), 3 deletions(-)
> 
> diff --git a/net/tipc/msg.c b/net/tipc/msg.c
> index ecb532f..b29eb8b 100644
> --- a/net/tipc/msg.c
> +++ b/net/tipc/msg.c
> @@ -76,11 +76,15 @@ void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type,
>  
>  int tipc_msg_calc_data_size(struct iovec const *msg_sect, u32 num_sect)
>  {
> -	int dsz = 0;
> +	size_t dsz = 0;
>  	int i;
>  
>  	for (i = 0; i < num_sect; i++)
>  		dsz += msg_sect[i].iov_len;
> +
> +	if (dsz > INT_MAX)
> +		return -EMSGSIZE;
> +
>  	return dsz;
>  }
>  
> @@ -93,12 +97,15 @@ int tipc_msg_calc_data_size(struct iovec const *msg_sect, u32 num_sect)
>   */
>  
>  int tipc_msg_build(struct tipc_msg *hdr,
> -			    struct iovec const *msg_sect, u32 num_sect,
> -			    int max_size, int usrmem, struct sk_buff** buf)
> +		      struct iovec const *msg_sect, u32 num_sect,
> +		      int max_size, int usrmem, struct sk_buff** buf)
>  {
>  	int dsz, sz, hsz, pos, res, cnt;
>  
>  	dsz = tipc_msg_calc_data_size(msg_sect, num_sect);
> +	if (dsz < 0)
> +		return dsz;
> +
>  	if (unlikely(dsz > TIPC_MAX_USER_MSG_SIZE)) {
>  		*buf = NULL;
>  		return -EINVAL;
> -- 
> 1.7.3.2


