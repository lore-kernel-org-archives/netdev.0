From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: [PATCH 1/2] tcp-lp 2.6.18-rc6: fix tcp_lp_remote_hz_estimator() about rhz
Date: Sun, 3 Dec 2006 13:32:07 +0100
Message-ID: <20061203123207.GA17178@janus>
References: <3feffd230609040244o497070f2j7909c6268f4eb588@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:17039 "EHLO
	janus.localdomain") by vger.kernel.org with ESMTP id S1759631AbWLCMcI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 07:32:08 -0500
To: netdev <netdev@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3feffd230609040244o497070f2j7909c6268f4eb588@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 04, 2006 at 05:44:58PM +0800, Wong Edison wrote:
> pageexec report an oops for tcp_lp_owd_calculator(). This is due to
> tcp_lp_remote_hz_estimator can return 0.
> 
> This patch fix the handling of lp->flag, so will set lp->flag as FALSE
> if rhz <= 0
> 
> Signed-off-by: Wong Hoi Sing Edison <hswong3i@gmail.com>
> 
> ---
> 
> diff -urpN 2.6.18-rc6/tcp_lp.c tcp-lp/tcp_lp.c
> --- 2.6.18-rc6/tcp_lp.c	2006-09-04 16:21:00.000000000 +0800
> +++ tcp-lp/tcp_lp.c	2006-09-04 17:22:19.000000000 +0800
> @@ -153,14 +157,17 @@ static u32 tcp_lp_remote_hz_estimator(st
> 	if (m < 0)
> 		m = -m;
> 
> -	if (rhz != 0) {
> +	if (rhz > 0) {
> 		m -= rhz >> 6;	/* m is now error in remote HZ est */
> 		rhz += m;	/* 63/64 old + 1/64 new */
> 	} else
> 		rhz = m << 6;
> 
> 	/* record time for successful remote HZ calc */
> -	lp->flag |= LP_VALID_RHZ;
> +	if (rhz > 0)
> +		lp->flag |= LP_VALID_RHZ;
> +	else
> +		lp->flag &= ~LP_VALID_RHZ;
> 
>  out:
> 	/* record reference time stamp */
> 
> -- 
> VGER BF report: U 0.500057

Got bitten by this zerodivide in 2.6.18.* (every few days a panic inside
an interrupt handler) and it doesn't seem to be fixed in 2.6.19.

-- 
Frank
