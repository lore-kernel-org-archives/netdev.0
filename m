From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 4/4] net: diag: Support destroying TCP sockets.
Date: Tue, 01 Dec 2015 05:25:52 -0800
Message-ID: <1448976352.25582.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1448953466-132321-1-git-send-email-lorenzo@google.com>
	 <1448953466-132321-4-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	hannes@stressinduktion.org, ek@google.com, tom@herbertland.com,
	zenczykowski@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35622 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753986AbbLANZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:25:55 -0500
Received: by pacej9 with SMTP id ej9so5476301pac.2
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 05:25:54 -0800 (PST)
In-Reply-To: <1448953466-132321-4-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-01 at 16:04 +0900, Lorenzo Colitti wrote:

> +	/* Don't race with BH socket closes such as inet_csk_listen_stop. */
> +	local_bh_disable();
> +	bh_lock_sock(sk);
> +
> +	if (!sock_flag(sk, SOCK_DEAD)) {
> +		smp_wmb();  /* Be consistent with tcp_reset */

This barrier is absolutely useless here, it must be moved _after_
sk->sk_err = ECONNABORTED.

Since you copied tcp_reset() code, please do not reorder barriers.

Also, comment in tcp_reset() is better IMO

/* This barrier is coupled with smp_rmb() in tcp_poll() */



> +		sk->sk_err = ECONNABORTED;
> +		sk->sk_error_report(sk);

Why not using tcp_need_reset() here, otherwise we might send spurious
RST for some tcp states.

Ideally, packetdrill tests would be nice.

> +		tcp_send_active_reset(sk, GFP_ATOMIC);
> +		tcp_done(sk);
> +	}

Please do not send a v5 before letting other people comment on v3 & v4,
no need to flood netdev with many versions sent the same day.

Thanks.
