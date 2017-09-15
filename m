From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] sctp: fix an use-after-free issue in sctp_sock_dump
Date: Fri, 15 Sep 2017 08:57:27 -0400
Message-ID: <20170915125727.GA6031@hmswarspite.think-freely.org>
References: <9de7bef8f4f8c0f369361118f6d2daee5d188467.1505444541.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        pabeni@redhat.com
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52586 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751207AbdIOM5s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 08:57:48 -0400
Content-Disposition: inline
In-Reply-To: <9de7bef8f4f8c0f369361118f6d2daee5d188467.1505444541.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 15, 2017 at 11:02:21AM +0800, Xin Long wrote:
> Commit 86fdb3448cc1 ("sctp: ensure ep is not destroyed before doing the
> dump") tried to fix an use-after-free issue by checking !sctp_sk(sk)->ep
> with holding sock and sock lock.
> 
> But Paolo noticed that endpoint could be destroyed in sctp_rcv without
> sock lock protection. It means the use-after-free issue still could be
> triggered when sctp_rcv put and destroy ep after sctp_sock_dump checks
> !ep, although it's pretty hard to reproduce.
> 
> I could reproduce it by mdelay in sctp_rcv while msleep in sctp_close
> and sctp_sock_dump long time.
> 
> This patch is to add another param cb_done to sctp_for_each_transport
> and dump ep->assocs with holding tsp after jumping out of transport's
> traversal in it to avoid this issue.
> 
> It can also improve sctp diag dump to make it run faster, as no need
> to save sk into cb->args[5] and keep calling sctp_for_each_transport
> any more.
> 
> This patch is also to use int * instead of int for the pos argument
> in sctp_for_each_transport, which could make postion increment only
> in sctp_for_each_transport and no need to keep changing cb->args[2]
> in sctp_sock_filter and sctp_sock_dump any more.
> 
> Fixes: 86fdb3448cc1 ("sctp: ensure ep is not destroyed before doing the dump")
> Reported-by: Paolo Abeni <pabeni@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  include/net/sctp/sctp.h |  3 ++-
>  net/sctp/sctp_diag.c    | 32 +++++++++-----------------------
>  net/sctp/socket.c       | 40 +++++++++++++++++++++++++---------------
>  3 files changed, 36 insertions(+), 39 deletions(-)
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
