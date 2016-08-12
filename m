From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RESEND] net/sctp: always initialise
 sctp_ht_iter::start_fail
Date: Fri, 12 Aug 2016 09:38:56 -0400
Message-ID: <20160812133856.GA8682@hmsreliant.think-freely.org>
References: <1470988251-18792-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Xin Long <lucien.xin@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	stable@vger.kernel.org
To: Vegard Nossum <vegard.nossum@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53342 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbcHLNj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 09:39:28 -0400
Content-Disposition: inline
In-Reply-To: <1470988251-18792-1-git-send-email-vegard.nossum@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 12, 2016 at 09:50:51AM +0200, Vegard Nossum wrote:
> sctp_transport_seq_start() does not currently clear iter->start_fail on
> success, but relies on it being zero when it is allocated (by
> seq_open_net()).
> 
> This can be a problem in the following sequence:
> 
>     open() // allocates iter (and implicitly sets iter->start_fail = 0)
>     read()
>      - iter->start() // fails and sets iter->start_fail = 1
>      - iter->stop() // doesn't call sctp_transport_walk_stop() (correct)
>     read() again
>      - iter->start() // succeeds, but doesn't change iter->start_fail
>      - iter->stop() // doesn't call sctp_transport_walk_stop() (wrong)
> 
> We should initialize sctp_ht_iter::start_fail to zero if ->start()
> succeeds, otherwise it's possible that we leave an old value of 1 there,
> which will cause ->stop() to not call sctp_transport_walk_stop(), which
> causes all sorts of problems like not calling rcu_read_unlock() (and
> preempt_enable()), eventually leading to more warnings like this:
> 
>     BUG: sleeping function called from invalid context at mm/slab.h:388
>     in_atomic(): 0, irqs_disabled(): 0, pid: 16551, name: trinity-c2
>     Preemption disabled at:[<ffffffff819bceb6>] rhashtable_walk_start+0x46/0x150
> 
>      [<ffffffff81149abb>] preempt_count_add+0x1fb/0x280
>      [<ffffffff83295892>] _raw_spin_lock+0x12/0x40
>      [<ffffffff819bceb6>] rhashtable_walk_start+0x46/0x150
>      [<ffffffff82ec665f>] sctp_transport_walk_start+0x2f/0x60
>      [<ffffffff82edda1d>] sctp_transport_seq_start+0x4d/0x150
>      [<ffffffff81439e50>] traverse+0x170/0x850
>      [<ffffffff8143aeec>] seq_read+0x7cc/0x1180
>      [<ffffffff814f996c>] proc_reg_read+0xbc/0x180
>      [<ffffffff813d0384>] do_loop_readv_writev+0x134/0x210
>      [<ffffffff813d2a95>] do_readv_writev+0x565/0x660
>      [<ffffffff813d6857>] vfs_readv+0x67/0xa0
>      [<ffffffff813d6c16>] do_preadv+0x126/0x170
>      [<ffffffff813d710c>] SyS_preadv+0xc/0x10
>      [<ffffffff8100334c>] do_syscall_64+0x19c/0x410
>      [<ffffffff83296225>] return_from_SYSCALL_64+0x0/0x6a
>      [<ffffffffffffffff>] 0xffffffffffffffff
> 
> Notice that this is a subtly different stacktrace from the one in commit
> 5fc382d875 ("net/sctp: terminate rhashtable walk correctly").
> 
> Cc: Xin Long <lucien.xin@gmail.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Cc: stable@vger.kernel.org
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
> ---
>  net/sctp/proc.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/sctp/proc.c b/net/sctp/proc.c
> index 4cb5aed..ef8ba77 100644
> --- a/net/sctp/proc.c
> +++ b/net/sctp/proc.c
> @@ -293,6 +293,7 @@ static void *sctp_transport_seq_start(struct seq_file *seq, loff_t *pos)
>  		return ERR_PTR(err);
>  	}
>  
> +	iter->start_fail = 0;
>  	return sctp_transport_get_idx(seq_file_net(seq), &iter->hti, *pos);
>  }
>  
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-By: Neil Horman <nhorman@tuxdriver.com>
