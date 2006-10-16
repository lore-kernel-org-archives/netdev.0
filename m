From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: [PATCH] NET : Suspicious locking in reqsk_queue_hash_req()
Date: Mon, 16 Oct 2006 14:16:43 -0200
Message-ID: <39e6f6c70610160916x36c86453pa128950896cfc17d@mail.gmail.com>
References: <20061010.191547.83619974.davem@davemloft.net>
	 <200610111511.19028.dada1@cosmosbay.com>
	 <200610161100.22549.dada1@cosmosbay.com>
	 <200610161107.19771.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:26920 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1422640AbWJPQQn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 12:16:43 -0400
Received: by wx-out-0506.google.com with SMTP id s14so1585961wxc
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2006 09:16:43 -0700 (PDT)
To: "Eric Dumazet" <dada1@cosmosbay.com>
In-Reply-To: <200610161107.19771.dada1@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/06, Eric Dumazet <dada1@cosmosbay.com> wrote:
> (Sorry, patch inlined this time)
>
> Hi David
>
> While browsing include/net/request_sock.h I found this suspicious locking
> protecting the SYN table hash table. I think this patch is necessary.
>
> Thank you

Interesting, just checked and it was there before I moved this out of tcp land:

http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=0e87506fcc734647c7b2497eee4eb81e785c857a

@@ -898,18 +898,10 @@ static struct request_sock *tcp_v4_searc
static void tcp_v4_synq_add(struct sock *sk, struct request_sock *req)
{
          struct tcp_sock *tp = tcp_sk(sk);
-        struct tcp_listen_opt *lopt = tp->listen_opt;
+       struct tcp_listen_opt *lopt = tp->accept_queue.listen_opt;
         u32 h = tcp_v4_synq_hash(inet_rsk(req)->rmt_addr,
inet_rsk(req)->rmt_port, lopt->hash_rnd);
-        req->expires = jiffies + TCP_TIMEOUT_INIT;
-        req->retrans = 0;
-        req->sk = NULL;
-        req->dl_next = lopt->syn_table[h];
-
-        write_lock(&tp->syn_wait_lock);
-        lopt->syn_table[h] = req;
-        write_unlock(&tp->syn_wait_lock);
-
+        reqsk_queue_hash_req(&tp->accept_queue, h, req, TCP_TIMEOUT_INIT);
          tcp_synq_added(sk);
}


> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>
>
> --- linux-2.6.18/include/net/request_sock.h.orig        2006-10-16 10:53:11.000000000 +0200
> +++ linux-2.6.18-ed/include/net/request_sock.h  2006-10-16 10:53:24.000000000 +0200
> @@ -251,9 +251,9 @@
>         req->expires = jiffies + timeout;
>         req->retrans = 0;
>         req->sk = NULL;
> -       req->dl_next = lopt->syn_table[hash];
>
>         write_lock(&queue->syn_wait_lock);
> +       req->dl_next = lopt->syn_table[hash];
>         lopt->syn_table[hash] = req;
>         write_unlock(&queue->syn_wait_lock);
>  }
