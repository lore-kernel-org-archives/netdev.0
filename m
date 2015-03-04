From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] af_unix: don't poll dead peers
Date: Wed, 04 Mar 2015 12:21:42 -0800
Message-ID: <1425500502.5130.232.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425499629-15223-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Olivier Mauras <olivier@mauras.ch>,
	Rainer Weikusat <rweikusat@mssgmbh.com>,
	PaX Team <pageexec@freemail.hu>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:36052 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757923AbbCDUVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 15:21:44 -0500
Received: by igkb16 with SMTP id b16so39837366igk.1
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 12:21:44 -0800 (PST)
In-Reply-To: <1425499629-15223-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-04 at 21:07 +0100, Mathias Krause wrote:
> We need to test if the peer is still alive, before actually calling
> poll_wait() on its wait queue, as we may race with unix_release_sock()
> which may lead to a use-after-free in the epoll code, ending up in
> uninterruptable lockups in the epoll code or other badnesses.

...

> 
> This bug has been found by the PaX memory sanitize feature, reported
> here: https://forums.grsecurity.net/viewtopic.php?f=3&t=4150
> 
> Fixes: 3c73419c09a5 "af_unix: fix 'poll for write'/ connected DGRAM..."
> Signed-off-by: Mathias Krause <minipli@googlemail.com>
> Reported-by: Olivier Mauras <olivier@mauras.ch>
> Cc: Rainer Weikusat <rweikusat@mssgmbh.com>
> Cc: PaX Team <pageexec@freemail.hu>
> ---
>  net/unix/af_unix.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 526b6edab018..0da9d7eeed17 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -2233,10 +2233,14 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
>  	writable = unix_writable(sk);
>  	other = unix_peer_get(sk);
>  	if (other) {
> -		if (unix_peer(other) != sk) {
> +		unix_state_lock(other);
> +		if (!sock_flag(other, SOCK_DEAD) && unix_peer(other) != sk) {
> +			unix_state_unlock(other);
>  			sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
>  			if (unix_recvq_full(other))
>  				writable = 0;
> +		} else {
> +			unix_state_unlock(other);
>  		}
>  		sock_put(other);
>  	}


Using locks in _poll() is going to be tremendously expensive for some
applications still using poll() or select() ?

This might be find for a stable candidate, but...

It seems RCU locking might be more appropriate in this fast path.

Please take a look at struct socket" and its "struct socket_wq __rcu
*wq;"

(commit 43815482370c510c569fd18edb57afcb0fa8cab6 for details)
