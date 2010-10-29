From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] net: Limit socket I/O iovec total length to INT_MAX.
Date: Fri, 29 Oct 2010 17:45:32 +0100
Message-ID: <20101029164532.GV19804@ZenIV.linux.org.uk>
References: <20101028.112231.232747062.davem@davemloft.net>
 <AANLkTinAzvfrRHwW-w-Ppdu7LWd7nGTa4EWP=e6pKV2F@mail.gmail.com>
 <1288360820.2092.34.camel@dan>
 <AANLkTikeaXncdUohUiGF2EkhujYETK5dtyOJASffz2qR@mail.gmail.com>
 <AANLkTi=sUDRzGnkp57OCQUi9APHWLYLShhiTVHLyq1eV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, allan.stephens@windriver.com,
	Dan Rosenberg <drosenberg@vsecurity.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:58442 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758009Ab0J2Qpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 12:45:38 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTi=sUDRzGnkp57OCQUi9APHWLYLShhiTVHLyq1eV@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 29, 2010 at 09:21:16AM -0700, Linus Torvalds wrote:
>  	ret = -EINVAL;
>  	for (seg = 0; seg < nr_segs; seg++) {
> -		compat_ssize_t tmp = tot_len;
>  		compat_uptr_t buf;
>  		compat_ssize_t len;
>  
> @@ -624,13 +624,13 @@ ssize_t compat_rw_copy_check_uvector(int type,
>  		}
>  		if (len < 0)	/* size_t not fitting in compat_ssize_t .. */
>  			goto out;
> -		tot_len += len;
> -		if (tot_len < tmp) /* maths overflow on the compat_ssize_t */
> -			goto out;
>  		if (!access_ok(vrfy_dir(type), compat_ptr(buf), len)) {
>  			ret = -EFAULT;
>  			goto out;
>  		}
> +		if (len > MAX_RW_COUNT - tot_len)
> +			len = MAX_RW_COUNT - tot_len;
> +		tot_len += len;
>  		iov->iov_base = compat_ptr(buf);
>  		iov->iov_len = (compat_size_t) len;
>  		uvector++;

Interesting...  Had anybody tested vectors with 0 iov_len in the end and/or
middle?  Looks like something rarely hit in practice...

I don't see anything obviously broken (and we obviously have allowed
iov_len == 0 cases all along, so if anything, breakage won't be new).
However, I wonder if things like sendmsg() for datagrams have warranties
against silent truncation.  Davem?
