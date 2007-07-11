From: Joel Becker <Joel.Becker@oracle.com>
Subject: Re: [PATCH][RFC] network splice receive v3
Date: Wed, 11 Jul 2007 11:17:58 -0700
Message-ID: <20070711181758.GX1011@tasint.org>
References: <20070711091927.GQ4587@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	olaf.kirch@oracle.com, johnpol@2ka.mipt.ru
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:43857 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758473AbXGKSSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 14:18:12 -0400
Content-Disposition: inline
In-Reply-To: <20070711091927.GQ4587@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 11, 2007 at 11:19:27AM +0200, Jens Axboe wrote:
> Subject: [PATCH] splice: don't assume regular pages in splice_to_pipe()
> 
> Allow caller to pass in a release function, there might be
> other resources that need releasing as well. Needed for
> network receive.
> 
> diff --git a/fs/splice.c b/fs/splice.c
> index 3160951..4b4b501 100644
> --- a/fs/splice.c
> +++ b/fs/splice.c
> @@ -254,11 +254,16 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
>  	}
>  
>  	while (page_nr < spd_pages)
> -		page_cache_release(spd->pages[page_nr++]);
> +		spd->spd_release(spd, page_nr++);

	Rather than requiring the caller set this, shouldn't we just
allow it?  Especially given there is only one non-page user?

  	while (page_nr < spd_pages)
 -		page_cache_release(spd->pages[page_nr++]);
 +		if (spd->spd_release)
 +			spd->spd_release(spd, page_nr++);
 +		else
 +			page_cache_release(spd->pages[page_nr++]);

Joel

-- 

"Any man who is under 30, and is not a liberal, has not heart;
 and any man who is over 30, and is not a conservative, has no brains."
         - Sir Winston Churchill 

Joel Becker
Principal Software Developer
Oracle
E-mail: joel.becker@oracle.com
Phone: (650) 506-8127
