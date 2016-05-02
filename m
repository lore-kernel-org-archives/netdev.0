From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: SOCKWQ_ASYNC_NOSPACE optimizations
Date: Mon, 02 May 2016 13:55:58 -0700
Message-ID: <1462222558.5535.279.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1462206138.5535.255.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160502191229.GA1946@nanopsycho.orion>
	 <1462220607.5535.273.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160502.163140.11281931277716285.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, edumazet@google.com, netdev@vger.kernel.org,
	eladr@mellanox.com, idosch@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36758 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754771AbcEBVEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 17:04:21 -0400
Received: by mail-pa0-f46.google.com with SMTP id bt5so89782pac.3
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 14:04:21 -0700 (PDT)
In-Reply-To: <20160502.163140.11281931277716285.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-05-02 at 16:31 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 02 May 2016 13:23:27 -0700
> 
> > It looks like net/sunrpc/xprtsock.c should set SOCK_FASYNC
> > even if it is not actually using fasync_list
> > 
> > Could you try this quick hack to check if this is the right way ?
> 
> Indeed, it tests the ASYNC bit without enabling FASYNC.
> 
> There are three other places that do this: macvtap, tun, dlm lowcomms.

Yes, although macvtap and tun have a private usage of this bit.

When the flag was moved (commit ceb5d58b217098a657f3850b7a2640f995032e62
"net: fix sock_wake_async() rcu protection"), I did not change the code
in these drivers. And apparently nobody complained (linux-4.4)

drivers/net/macvtap.c:501:          !test_and_clear_bit(SOCKWQ_ASYNC_NOSPACE, &sk->sk_socket->flags))
drivers/net/macvtap.c:588:          (!test_and_set_bit(SOCKWQ_ASYNC_NOSPACE, &q->sock.flags) &&
drivers/net/tun.c:1111:     (!test_and_set_bit(SOCKWQ_ASYNC_NOSPACE, &sk->sk_socket->flags) &&
drivers/net/tun.c:1576: if (!test_and_clear_bit(SOCKWQ_ASYNC_NOSPACE, &sk->sk_socket->flags))

fs/dlm/lowcomms.c probably needs a fix.
