From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3] fix locking regression in ipx_sendmsg and ipx_recvmsg
Date: Wed, 19 Nov 2014 17:38:13 +0300
Message-ID: <546CAB55.7030102@cogentembedded.com>
References: <20141117013448.GA26743@midget.suse.cz> <8698539.evYG7fs8jS@wuerfel> <20141118221057.GA13473@midget.suse.cz> <1609909.1jJeqOzgZ8@wuerfel> <20141119103413.GA19092@midget.suse.cz> <20141119103814.GB19092@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jiri Bohac <jbohac@suse.cz>, Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:49396 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754004AbaKSOiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 09:38:16 -0500
Received: by mail-la0-f54.google.com with SMTP id gf13so583509lab.41
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 06:38:14 -0800 (PST)
In-Reply-To: <20141119103814.GB19092@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/19/2014 1:38 PM, Jiri Bohac wrote:

> This fixes an old regression introduced by commit
> b0d0d915 (ipx: remove the BKL).

> When a recvmsg syscall blocks waiting for new data, no data can be sent on the
> same socket with sendmsg because ipx_recvmsg() sleeps with the socket locked.

> This breaks mars-nwe (NetWare emulator):
> - the ncpserv process reads the request using recvmsg
> - ncpserv forks and spawns nwconn
> - ncpserv calls a (blocking) recvmsg and waits for new requests
> - nwconn deadlocks in sendmsg on the same socket

> Commit b0d0d915 has simply replaced BKL locking with
> lock_sock/release_sock. Unlike now, BKL got unlocked while
> sleeping, so a blocking recvmsg did not block a concurrent
> sendmsg.

> Only keep the socket locked while actually working with the socket data and
> release it prior to calling skb_recv_datagram().


> Signed-off-by: Jiri Bohac <jbohac@suse.cz>

> diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
> index a0c7536..d0725d9 100644
> --- a/net/ipx/af_ipx.c
> +++ b/net/ipx/af_ipx.c
> @@ -1764,6 +1764,7 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
>   	struct ipxhdr *ipx = NULL;
>   	struct sk_buff *skb;
>   	int copied, rc;
> +	int locked = 1;

    Why not *bool*?

[...]

WBR, Sergei
