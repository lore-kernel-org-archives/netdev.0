From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: possible kernel oops from user MSS
Date: Thu, 11 Nov 2010 13:15:01 +0800
Message-ID: <4CDB7BD5.6030204@cn.fujitsu.com>
References: <AANLkTimMDMb74-3E9vhFxZ5Dgeuk3HMzPZVjwCj+yFEJ@mail.gmail.com> <20101110.124119.102563803.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: schen@mvista.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55280 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750942Ab0KKFPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Nov 2010 00:15:49 -0500
In-Reply-To: <20101110.124119.102563803.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, at 11/11/2010 04:41 AM:
> From: Steve Chen <schen@mvista.com>
> Date: Wed, 10 Nov 2010 07:24:51 -0600
> 
>> With commit f5fff5dc8a7a3f395b0525c02ba92c95d42b7390, a user program
>> can pass in TCP_MAXSEG of 12 (or TCPOLEN_TSTAMP_ALIGNED), and cause
>> kernel oops with division by 0
>>  in tcp_select_initial_window.  One way to prevent it is to change the
>> minimum value for TCP_MAXSEG in do_tcp_setsockopt from 8 to some value
>> over 12.  Two questions.
>>
>> 1.  Is this the right solution?
>> 2.  If it is, what is a good minimum value?
> 
> Thanks Steve, I'll fix this like so:
> 
> --------------------
> tcp: Increase TCP_MAXSEG socket option minimum.
> 
> As noted by Steve Chen, since commit
> f5fff5dc8a7a3f395b0525c02ba92c95d42b7390 ("tcp: advertise MSS
> requested by user") we can end up with a situation where
> tcp_select_initial_window() does a divide by a zero (or
> even negative) mss value.
> 
> The problem is that sometimes we subtract TCPOLEN_TSTAMP_ALIGNED
> from the mss.
> 
> Fix this by increasing the minimum from 8 to 8 plus the value
> of TCPOLEN_TSTATMP_ALIGNED.

In tcp_connect_init(), if tcp_header_len includes TCPOLEN_TSTAMP_ALIGNED(12 bytes)
and TCPOLEN_MD5SIG_ALIGNED(20 bytes).

This fix is still not perfect.

The minimum value of TCP_MAXSEG is 20 tytes, tcp_select_initial_window() still be 
called with negative mss value.

-- 
Best Regards
-----
Shan Wei


> Reported-by: Steve Chen <schen@mvista.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/tcp.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 245603c..6b0eb4d 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2246,7 +2246,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>  		/* Values greater than interface MTU won't take effect. However
>  		 * at the point when this call is done we typically don't yet
>  		 * know which interface is going to be used */
> -		if (val < 8 || val > MAX_TCP_WINDOW) {
> +		if (val < TCPOLEN_TSTAMP_ALIGNED + 8 || val > MAX_TCP_WINDOW) {
>  			err = -EINVAL;
>  			break;
>  		}


