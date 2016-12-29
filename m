From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] sctp: do not loose window information if in rwnd_over
Date: Thu, 29 Dec 2016 10:42:45 -0500
Message-ID: <20161229154245.GA31194@neilslaptop.think-freely.org>
References: <14d1eef1c9da4fcebc53d428a59ecaefab439b2c.1482510284.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        Vlad Yasevich <vyasevich@gmail.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41567 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752905AbcL2Pnk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 10:43:40 -0500
Content-Disposition: inline
In-Reply-To: <14d1eef1c9da4fcebc53d428a59ecaefab439b2c.1482510284.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 23, 2016 at 02:29:02PM -0200, Marcelo Ricardo Leitner wrote:
> It's possible that we receive a packet that is larger than current
> window. If it's the first packet in this way, it will cause it to
> increase rwnd_over. Then, if we receive another data chunk (specially as
> SCTP allows you to have one data chunk in flight even during 0 window),
> rwnd_over will be overwritten instead of added to.
> 
> In the long run, this could cause the window to grow bigger than its
> initial size, as rwnd_over would be charged only for the last received
> data chunk while the code will try open the window for all packets that
> were received and had its value in rwnd_over overwritten. This, then,
> can lead to the worsening of payload/buffer ratio and cause rwnd_press
> to kick in more often.
> 
> The fix is to sum it too, same as is done for rwnd_press, so that if we
> receive 3 chunks after closing the window, we still have to release that
> same amount before re-opening it.
> 
> Log snippet from sctp_test exhibiting the issue:
> [  146.209232] sctp: sctp_assoc_rwnd_decrease: asoc:ffff88013928e000
> rwnd decreased by 1 to (0, 1, 114221)
> [  146.209232] sctp: sctp_assoc_rwnd_decrease:
> association:ffff88013928e000 has asoc->rwnd:0, asoc->rwnd_over:1!
> [  146.209232] sctp: sctp_assoc_rwnd_decrease: asoc:ffff88013928e000
> rwnd decreased by 1 to (0, 1, 114221)
> [  146.209232] sctp: sctp_assoc_rwnd_decrease:
> association:ffff88013928e000 has asoc->rwnd:0, asoc->rwnd_over:1!
> [  146.209232] sctp: sctp_assoc_rwnd_decrease: asoc:ffff88013928e000
> rwnd decreased by 1 to (0, 1, 114221)
> [  146.209232] sctp: sctp_assoc_rwnd_decrease:
> association:ffff88013928e000 has asoc->rwnd:0, asoc->rwnd_over:1!
> [  146.209232] sctp: sctp_assoc_rwnd_decrease: asoc:ffff88013928e000
> rwnd decreased by 1 to (0, 1, 114221)
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
>  net/sctp/associola.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 68428e1f71810fbe65b7f86c750c3ad61f0266ec..56ddcfaeb4f64235b54b0daa915fabf0cc0170a9 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -1539,7 +1539,7 @@ void sctp_assoc_rwnd_decrease(struct sctp_association *asoc, unsigned int len)
>  			asoc->rwnd = 0;
>  		}
>  	} else {
> -		asoc->rwnd_over = len - asoc->rwnd;
> +		asoc->rwnd_over += len - asoc->rwnd;
>  		asoc->rwnd = 0;
>  	}
>  
> -- 
> 2.9.3
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
