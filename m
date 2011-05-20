From: Jacek Luczak <difrost.kernel@gmail.com>
Subject: Re: linux-next: build failure after merge of the tip tree (net tree interaction)
Date: Fri, 20 May 2011 09:59:20 +0200
Message-ID: <BANLkTik=bC1beZWx5eLDMmGcOp5UZ29MUQ@mail.gmail.com>
References: <20110520141417.f49bf364.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110520141417.f49bf364.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/5/20 Stephen Rothwell <sfr@canb.auug.org.au>:
> Hi all,
>
> After merging the tip tree, today's linux-next build (x86_64 allmodco=
nfig)
> failed like this:
>
> net/sctp/bind_addr.c: In function 'sctp_bind_addr_clean':
> net/sctp/bind_addr.c:148: error: 'sctp_local_addr_free' undeclared (f=
irst use in this function)
>
> Caused by commit 1231f0baa547 ("net,rcu: convert call_rcu
> (sctp_local_addr_free) to kfree_rcu()") interacting with commit
> c182f90bc1f2 ("SCTP: fix race between sctp_bind_addr_free() and
> sctp_bind_addr_conflict()") from the net tree.
>
> I applied the following patch as a merge fix:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Fri, 20 May 2011 14:11:11 +1000
> Subject: [PATCH] net,rcu: convert another call to call_rcu(sctp_local=
_addr_free)
>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
> =A0net/sctp/bind_addr.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
> index 6338413..83e3011 100644
> --- a/net/sctp/bind_addr.c
> +++ b/net/sctp/bind_addr.c
> @@ -145,7 +145,7 @@ static void sctp_bind_addr_clean(struct sctp_bind=
_addr *bp)
> =A0 =A0 =A0 =A0/* Empty the bind address list. */
> =A0 =A0 =A0 =A0list_for_each_entry_safe(addr, temp, &bp->address_list=
, list) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_del_rcu(&addr->list);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 call_rcu(&addr->rcu, sctp_local_addr_fr=
ee);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree_rcu(addr, rcu);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SCTP_DBG_OBJCNT_DEC(addr);
> =A0 =A0 =A0 =A0}
> =A0}
> --
> 1.7.5.1
>


Hi

as this is planned to be backported down to stable/longterm, kfree_rcu
was not used here. I guess in meantime the callback has been removed
while introducing kfree_rcu in sctp  module. I have a patch ready to
send for net-next-2.6 converting to kfree_rcu in sctp, only I've been
waiting for it jumping to the tree.

This patch is of course valid.

-Jacek
