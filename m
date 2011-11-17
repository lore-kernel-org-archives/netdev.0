From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 5/5] tcp: skip cwnd moderation in TCP_CA_Open in
 tcp_try_to_open
Date: Thu, 17 Nov 2011 07:14:15 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1111170706330.23028@melkinpaasi.cs.helsinki.fi>
References: <1321469885-10885-1-git-send-email-ncardwell@google.com> <1321469885-10885-5-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43938 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160Ab1KQFOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 00:14:17 -0500
In-Reply-To: <1321469885-10885-5-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Nov 2011, Neal Cardwell wrote:

> The problem: Senders were overriding cwnd values picked during an undo
> by calling tcp_moderate_cwnd() in tcp_try_to_open().

I think it's intentional. Because of receiver lying bandwidth cheats all 
unlimited undos are bit dangerous.

> The fix: Don't moderate cwnd in tcp_try_to_open() if we're in
> TCP_CA_Open, since doing so is generally unnecessary and specifically
> would override a DSACK-based undo of a cwnd reduction made in fast
> recovery.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---
>  net/ipv4/tcp_input.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index a4efdd7..78dd38c 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2881,7 +2881,8 @@ static void tcp_try_to_open(struct sock *sk, int flag)
>  
>  	if (inet_csk(sk)->icsk_ca_state != TCP_CA_CWR) {
>  		tcp_try_keep_open(sk);
> -		tcp_moderate_cwnd(tp);
> +		if (inet_csk(sk)->icsk_ca_state != TCP_CA_Open)
> +			tcp_moderate_cwnd(tp);
>  	} else {
>  		tcp_cwnd_down(sk, flag);
>  	}

Wouldn't it be enough if tcp max burst is increased to match IW (iirc we 
had 3 still there as a magic number)?


-- 
 i.
