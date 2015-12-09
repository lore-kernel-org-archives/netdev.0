From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] nftables: use list_for_each_entry_safe_reverse to
 traversal commit_list in nf_tables_abort
Date: Wed, 9 Dec 2015 15:03:30 +0100
Message-ID: <20151209140330.GA1695@salvia>
References: <15bcb964221e1a9498e901417d020609cd5aac65.1449485287.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net, fw@strlen.de
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <15bcb964221e1a9498e901417d020609cd5aac65.1449485287.git.lucien.xin@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 07, 2015 at 06:48:07PM +0800, Xin Long wrote:
> when we use 'nft -f' to sumbit rules, it will build multiple rules into
> one netlink skb to send to kernel, kernel will process them one by one.
> meanwhile, it add the trans into commit_list to record every commit.
> if one of them's return value is -EAGAIN, status |= NFNL_BATCH_REPLAY
> will be marked. after all the process is done. it will roll back all the
> commits.
> 
> now kernel use list_add_tail to add trans to commit, and use
> list_for_each_entry_safe to roll back. which means the order of adding
> and rollback is the same. that will cause some cases cannot work well,
> even trigger call trace, like:
> 
> 1. add a set into table foo  [return -EAGAIN]:
>    commit_list = 'add set trans'
> 2. del foo:
>    commit_list = 'add set trans' -> 'del set trans' -> 'del tab trans'
> then nf_tables_abort will be called to roll back:
> firstly process 'add set trans':
>                    case NFT_MSG_NEWSET:
>                         trans->ctx.table->use--;
>                         list_del_rcu(&nft_trans_set(trans)->list);
> 
>   it will del the set from the table foo, but it has removed when del
>   table foo [step 2], then the kernel will panic.
> 
> the right order of rollback should be:
>   'del tab trans' -> 'del set trans' -> 'add set trans'.
> which is opposite with commit_list order.
> 
> so fix it by rolling back commits with reverse order in nf_tables_abort.


You're reporting a kernel panic.

Could you please provide a sequence of commands to reproduce it with
the existing code?

Thanks.
