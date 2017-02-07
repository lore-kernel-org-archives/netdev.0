From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: avoid BUG_ON on sctp_wait_for_sndbuf
Date: Tue, 7 Feb 2017 21:02:46 +0800
Message-ID: <CADvbK_c8u=Ot7rmqKQ37ExKD4Gn9acxVNbTJJF=o2EHWWy4QBQ@mail.gmail.com>
References: <90df61dca0e882ccc175bcec200b341b171b7406.1486411622.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Alexander Popov <alex.popov@linux.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:36761 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755135AbdBGNCs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 08:02:48 -0500
In-Reply-To: <90df61dca0e882ccc175bcec200b341b171b7406.1486411622.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 7, 2017 at 4:10 AM, Marcelo Ricardo Leitner
<marcelo.leitner@gmail.com> wrote:
> Alexander Popov reported that an application may trigger a BUG_ON in
> sctp_wait_for_sndbuf if the socket tx buffer is full, a thread is
> waiting on it to queue more data and meanwhile another thread peels off
> the association being used by the first thread.
>
> This patch replaces the BUG_ON call with a proper error handling. It
> will return -EPIPE to the original sendmsg call, similarly to what would
> have been done if the association wasn't found in the first place.
>
> Acked-by: Alexander Popov <alex.popov@linux.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
> Please consider this to -stable. Thanks
>
Reviewed-by: Xin Long <lucien.xin@gmail.com>

>  net/sctp/socket.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 37eeab7899fc235a56bd2f4ccdb3e6c338a8d48e..e214d2e7e9a30c02847daf354668c42eeaffd0d6 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -7426,7 +7426,8 @@ static int sctp_wait_for_sndbuf(struct sctp_association *asoc, long *timeo_p,
>                  */
>                 release_sock(sk);
>                 current_timeo = schedule_timeout(current_timeo);
> -               BUG_ON(sk != asoc->base.sk);
> +               if (sk != asoc->base.sk)
> +                       goto do_error;
>                 lock_sock(sk);
>
>                 *timeo_p = current_timeo;
> --
> 2.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
