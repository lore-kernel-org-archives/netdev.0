From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] sctp: assign assoc_id earlier in __sctp_connect
Date: Fri, 4 Nov 2016 09:28:53 -0400
Message-ID: <20161104132852.GB13691@hmsreliant.think-freely.org>
References: <9df38dcd0323ad92386eb6851a60dc128dd00b4e.1478199530.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        Vlad Yasevich <vyasevich@gmail.com>,
        syzkaller@googlegroups.com, kcc@google.com, glider@google.com,
        edumazet@google.com, dvyukov@google.com, andreyknvl@google.com
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47507 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761557AbcKDN3Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 09:29:16 -0400
Content-Disposition: inline
In-Reply-To: <9df38dcd0323ad92386eb6851a60dc128dd00b4e.1478199530.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 03, 2016 at 05:03:41PM -0200, Marcelo Ricardo Leitner wrote:
> sctp_wait_for_connect() currently already holds the asoc to keep it
> alive during the sleep, in case another thread release it. But Andrey
> Konovalov and Dmitry Vyukov reported an use-after-free in such
> situation.
> 
> Problem is that __sctp_connect() doesn't get a ref on the asoc and will
> do a read on the asoc after calling sctp_wait_for_connect(), but by then
> another thread may have closed it and the _put on sctp_wait_for_connect
> will actually release it, causing the use-after-free.
> 
> Fix is, instead of doing the read after waiting for the connect, do it
> before so, and avoid this issue as the socket is still locked by then.
> There should be no issue on returning the asoc id in case of failure as
> the application shouldn't trust on that number in such situations
> anyway.
> 
> This issue doesn't exist in sctp_sendmsg() path.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
>  net/sctp/socket.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 6cdc61c21438aa9b6dbdad93e70759071a4d6789..be1d9bb98230c9d77f676949db773b2dacd801a4 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -1214,9 +1214,12 @@ static int __sctp_connect(struct sock *sk,
>  
>  	timeo = sock_sndtimeo(sk, f_flags & O_NONBLOCK);
>  
> -	err = sctp_wait_for_connect(asoc, &timeo);
> -	if ((err == 0 || err == -EINPROGRESS) && assoc_id)
> +	if (assoc_id)
>  		*assoc_id = asoc->assoc_id;
> +	err = sctp_wait_for_connect(asoc, &timeo);
> +	/* Note: the asoc may be freed after the return of
> +	 * sctp_wait_for_connect.
> +	 */
>  
>  	/* Don't free association on exit. */
>  	asoc = NULL;
> -- 
> 2.7.4
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
