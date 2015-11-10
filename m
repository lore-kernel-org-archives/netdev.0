From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] af-unix: fix use-after-free with concurrent
 readers while splicing
Date: Tue, 10 Nov 2015 07:18:44 -0800
Message-ID: <1447168724.17135.73.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447166859-11766-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34176 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071AbbKJPSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 10:18:47 -0500
Received: by padhx2 with SMTP id hx2so228568600pad.1
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 07:18:47 -0800 (PST)
In-Reply-To: <1447166859-11766-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-10 at 15:47 +0100, Hannes Frederic Sowa wrote:
> During splicing an af-unix socket to a pipe we have to drop all
> af-unix socket locks. While doing so we allow another reader to enter
> unix_stream_read_generic which can read, copy and finally free another
> skb. If exactly this skb is just in process of being spliced we get a
> use-after-free report by kasan.
> 
> First, we must make sure to not have a free while the skb is used during
> the splice operation. We simply increment its use counter before unlocking
> the reader lock.
> 
> Stream sockets have the nice characteristic that we don't care about
> zero length writes and they never reach the peer socket's queue. That
> said, we can take the UNIXCB.consumed field as the indicator if the
> skb was already freed from the socket's receive queue. If the skb was
> fully consumed after we locked the reader side again we know it has been
> dropped by a second reader. We indicate a short read to user space and
> abort the current splice operation.
> 
> This bug has been found with syzkaller
> (http://github.com/google/syzkaller) by Dmitry Vyukov.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Please Hannes include the Fixes: tag.

As you might already know, patchwork does not catch it later

Fixes: 2b514574f7e8 ("net: af_unix: implement splice for stream af_unix sockets")
Acked-by: Eric Dumazet <edumazet@google.com>

Also I would prefer skb_get() being on a separate line, to ease future
understanding of the code.

Thanks.
