From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [netlink] WARNING: at mm/vmalloc.c:1487 __vunmap()
Date: Thu, 27 Jun 2013 10:22:38 +0200
Message-ID: <20130627082238.GA6346@localhost>
References: <20130614220119.GA12954@localhost>
 <20130617200938.GA14567@localhost>
 <1372250558.3301.194.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1372250558.3301.194.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

Thanks for looking into this.

On Wed, Jun 26, 2013 at 05:42:38AM -0700, Eric Dumazet wrote:
[...]
> Nope there are several issues :
> 
> 1) bug in netlink_alloc_large_skb() because it doesn't account
> for sizeof(struct skb_shared_info) overhead and initialization.

Indeed, I can send a fix for this.

> 2) Also, skb_clone() on such skb should be forbidden.
> 
>    Example, nl_fib_input() does a nskb = skb_clone(skb)
>
> If skb is freed before nskb, then nskb wont know skb->head must be freed
> by vfree()
> 
> I don't know...
> 
> 3) Do we really need this vmalloc stuff, because it sounds like we are
> going to add yet another test in fast path (in skb_free_head())

We want to send atomic rule-set updates via netlink in one single
batch message to kernel space. Without vmalloc, I can send up to
~20000 rule updates in one single batch.

We considered splitting the updates in smaller batches to make netlink
happy, but then a process has to own the rule-set base until it has
finished the update to avoid any interference. However, a broken
user-space program may (ab)use such ownership to prevents others from
updating the rule-set.

> 4) Or we must track all skb_clone() netlink calls to attach a destructor
> to properly to the vfree()

Perhaps we can add a new specific function for this, netlink_skb_clone?

I'll be fine to track skb_clone in existing netlink families and
replace it by such call in case you don't find this solution too
hackish.

Let me know. Thanks.

> [1]
>  BUG: unable to handle kernel paging request at ffffc90018a39001
>  IP: [<ffffffff814cdeef>] skb_clone+0x1f/0xb0
>  PGD c7f40f067 PUD 67f81b067 PMD 65de02067 PTE 0
>  Oops: 0000 [#1] [ 1931.190995] scsi_nl_rcv_msg: discarding partial skb
>  gsmi: Log Shutdown Reason 0x03
>  CPU: 1 PID: 4157 Comm: trinity-child1 Tainted: G        W    3.10.0-smp-DEV #148
>  task: ffff880c5fb647f0 ti: ffff880c5ff6c000 task.ti: ffff880c5ff6c000
>  RIP: 0010:[<ffffffff814cdeef>]  [<ffffffff814cdeef>] skb_clone+0x1f/0xb0
>  RSP: 0018:ffff880c5ff6db18  EFLAGS: 00010282
>  RAX: 0000000000002000 RBX: ffff88065fed8ec0 RCX: 0000000060fd8cb3
>  RDX: ffffc90018a37000 RSI: 00000000000000d0 RDI: ffff88065fed8ec0
>  RBP: ffff880c5ff6db28 R08: ffffc90018a39000 R09: 0000000000000001
>  R10: ffffc90018a38fff R11: 0000000000000000 R12: 00000000000000d0
>  R13: ffff880c266a0000 R14: ffff88065fed8ec0 R15: 0000000000000000
>  FS:  000000000264d880(0063) GS:ffff88067fc20000(0000) knlGS:0000000000000000
>  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>  CR2: ffffc90018a39001 CR3: 0000000c5b8af000 CR4: 00000000000007e0
>  Call Trace:
>  [<ffffffff8154b086>] nl_fib_input+0x46/0x140
>  [<ffffffff815057ed>] netlink_unicast+0x13d/0x1f0
>  [<ffffffff81505b95>] netlink_sendmsg+0x2f5/0x3f0
>  [<ffffffff814c366e>] sock_aio_write+0x15e/0x180
>  [<ffffffff81193743>] do_sync_readv_writev+0x73/0xb0
>  [<ffffffff81194e5b>] do_readv_writev+0xdb/0x2c0
