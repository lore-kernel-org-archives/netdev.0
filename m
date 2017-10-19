From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] strparser: Generalize strparser
Date: Thu, 19 Oct 2017 10:42:17 -0700
Message-ID: <1508434937.30291.1.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170728232243.3040-1-tom@quantonium.net>
         <20170728232243.3040-4-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rohit@quantonium.net,
        john.fastabend@gmail.com
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:46423 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752830AbdJSRmT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 13:42:19 -0400
Received: by mail-io0-f196.google.com with SMTP id 101so10668585ioj.3
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 10:42:19 -0700 (PDT)
In-Reply-To: <20170728232243.3040-4-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-07-28 at 16:22 -0700, Tom Herbert wrote:
> Generalize strparser from more than just being used in conjunction
> with read_sock. strparser will also be used in the send path with
> zero proxy. The primary change is to create strp_process function
> that performs the critical processing on skbs. The documentation
> is also updated to reflect the new uses.
> 
> Signed-off-by: Tom Herbert <tom@quantonium.net>
> ---
>  Documentation/networking/strparser.txt | 207 +++++++++++++++-------
>  include/net/strparser.h                | 119 +++++++------
>  net/kcm/kcmproc.c                      |  34 ++--
>  net/kcm/kcmsock.c                      |  38 ++--
>  net/strparser/strparser.c              | 313 ++++++++++++++++++++-------------
>  5 files changed, 424 insertions(+), 287 deletions(-)

Just found this gem :

static void strp_msg_timeout(unsigned long arg)
{
        struct strparser *strp = (struct strparser *)arg;

        /* Message assembly timed out */
        STRP_STATS_INCR(strp->stats.msg_timeouts);
        strp->cb.lock(strp);
        strp->cb.abort_parser(strp, ETIMEDOUT);
        strp->cb.unlock(strp);
}

static void strp_sock_lock(struct strparser *strp)
{
        lock_sock(strp->sk);
}

static void strp_sock_unlock(struct strparser *strp)
{
        release_sock(strp->sk);
}


A timer runs from BH, and from this interrupt context it is absolutely
illegal to call lock_sock() ( and release_sock() )

Please fix, thanks !
