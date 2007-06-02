From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Sat, 2 Jun 2007 19:11:48 -0300
Message-ID: <39e6f6c70706021511i42a70099lf5415adf51215b27@mail.gmail.com>
References: <E1HubUt-0004Hb-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Miklos Szeredi" <miklos@szeredi.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:23517 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759659AbXFBWLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2007 18:11:50 -0400
Received: by ug-out-1314.google.com with SMTP id j3so469377ugf
        for <netdev@vger.kernel.org>; Sat, 02 Jun 2007 15:11:49 -0700 (PDT)
In-Reply-To: <E1HubUt-0004Hb-00@dorka.pomaz.szeredi.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/2/07, Miklos Szeredi <miklos@szeredi.hu> wrote:
> From: Miklos Szeredi <mszeredi@suse.cz>
>
> A recv() on an AF_UNIX, SOCK_STREAM socket can race with a
> send()+close() on the peer, causing recv() to return zero, even though
> the sent data should be received.
>
> This happens if the send() and the close() is performed between
> skb_dequeue() and checking sk->sk_shutdown in unix_stream_recvmsg():
>
> process A  skb_dequeue() returns NULL, there's no data in the socket queue
> process B  new data is inserted onto the queue by unix_stream_sendmsg()
> process B  sk->sk_shutdown is set to SHUTDOWN_MASK by unix_release_sock()
> process A  sk->sk_shutdown is checked, unix_release_sock() returns zero
>
> I'm surprised nobody noticed this, it's not hard to trigger.  Maybe
> it's just (un)luck with the timing.
>
> It's possible to work around this bug in userspace, by retrying the
> recv() once in case of a zero return value.
>
> Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> ---
>
> Index: linux-2.6.22-rc2/net/unix/af_unix.c
> ===================================================================
> --- linux-2.6.22-rc2.orig/net/unix/af_unix.c    2007-06-02 23:45:47.000000000 +0200
> +++ linux-2.6.22-rc2/net/unix/af_unix.c 2007-06-02 23:45:49.000000000 +0200
> @@ -1711,20 +1711,23 @@ static int unix_stream_recvmsg(struct ki
>                 int chunk;
>                 struct sk_buff *skb;
>
> +               unix_state_rlock(sk);

this function doesn't exist anymore, see:

http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=e97b6936b03dd0a62991f361c048cca38ac00198

There is also another AF_UNIX patch, also related to a race.

- Arnaldo
