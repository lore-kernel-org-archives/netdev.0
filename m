From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] AF_UNIX: Fix deadlock on connecting to shutdown socket
Date: Mon, 19 Oct 2009 11:57:13 +0000
Message-ID: <20091019115713.GB6869@ff.dom.local>
References: <4ADC010C.5070809@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alan@lxorguk.ukuu.org.uk, davem@davemloft.net,
	satoshi.oshima.fk@hitachi.com, hidehiro.kawai.ez@hitachi.com,
	hideo.aoki.tk@hitachi.com
To: Tomoki Sekiyama <tomoki.sekiyama.qu@hitachi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754683AbZJSL5R@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4ADC010C.5070809@hitachi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19-10-2009 08:02, Tomoki Sekiyama wrote:
...
> Why this happens:
>  Error checks between unix_socket_connect() and unix_wait_for_peer() are
>  inconsistent. The former calls the latter to wait until the backlog is
>  processed. Despite the latter returns without doing anything when the
>  socket is shutdown, the former doesn't check the shutdown state and
>  just retries calling the latter forever.
> 
> Patch:
>  The patch below adds shutdown check into unix_socket_connect(), so
>  connect(2) to the shutdown socket will return -ECONREFUSED.
> 
> Signed-off-by: Tomoki Sekiyama <tomoki.sekiyama.qu@hitachi.com>
> Signed-off-by: Masanori Yoshida <masanori.yoshida.tv@hitachi.com>
> ---
>  net/unix/af_unix.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 51ab497..fc820cd 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1074,6 +1074,8 @@ restart:
>  	err = -ECONNREFUSED;
>  	if (other->sk_state != TCP_LISTEN)
>  		goto out_unlock;
> +	if (other->sk_shutdown & RCV_SHUTDOWN)
> +		goto out_unlock;

Isn't the shutdown call expected to change sk_state to TCP_CLOSE?

Jarek P.
