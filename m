From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Oops in nf_nat_core.c:find_appropriate_src(), kernel 2.6.25.4
Date: Wed, 11 Jun 2008 08:45:20 -0700
Message-ID: <20080611154520.GA9384@linux.vnet.ibm.com>
References: <484A9E75.8000601@redhat.com> <484AA276.9090407@trash.net> <484AA5D5.10404@trash.net> <Pine.LNX.4.64.0806071742180.13503@bizon.gios.gov.pl> <484E4343.5090606@trash.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Ebbert <cebbert@redhat.com>, Krzysztof Oledzki <ole@ans.pl>,
	Netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <484E4343.5090606@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 10, 2008 at 11:02:59AM +0200, Patrick McHardy wrote:
> Krzysztof Oledzki wrote:
> >On Sat, 7 Jun 2008, Patrick McHardy wrote:
> >
> >>Patrick McHardy wrote:
> >>>Chuck Ebbert wrote:
> >>>>Reported at https://bugzilla.redhat.com/show_bug.cgi?id=449315
> >>>>
> >>>>In find_appropriate_src():
> >>>>
> >>>>        hlist_for_each_entry_rcu(nat, n, &bysource[h], bysource) {
> >>>>                ct = nat->ct;
> >>>>                if (same_src(ct, tuple)) {
> >>>>
> >>>>Dereference of ct in same_src() causes the oops. This only seems to
> >>>>happen on heavily loaded firewall machines. Kernel 2.6.24.7 works.
> >>>>
> >>>>The reporter identifies commit 4d354c5782dc352cec187845d17eedc2c2bfcf67
> >>>>("[NETFILTER]: nf_nat: use RCU for bysource hash") as a possible cause
> >>>>of the problem.
> >>>
> >>>We have a similar looking report, but that one also affects 2.6.24:
> >>>
> >>>http://bugzilla.kernel.org/show_bug.cgi?id=10875
> 
> 
> We found the reason for that crash and I've queued these two
> patches. Please let me know whether they also fix the problem
> from the redhat bugzilla.
> 

> netfilter: nf_conntrack: fix ctnetlink related crash in nf_nat_setup_info()
> 
> When creation of a new conntrack entry in ctnetlink fails after having
> set up the NAT mappings, the conntrack has an extension area allocated
> that is not getting properly destroyed when freeing the conntrack again.
> This means the NAT extension is still in the bysource hash, causing a
> crash when walking over the hash chain the next time:
> 
> BUG: unable to handle kernel paging request at 00120fbd
> IP: [<c03d394b>] nf_nat_setup_info+0x221/0x58a
> *pde = 00000000
> Oops: 0000 [#1] PREEMPT SMP
> 
> Pid: 2795, comm: conntrackd Not tainted (2.6.26-rc5 #1)
> EIP: 0060:[<c03d394b>] EFLAGS: 00010206 CPU: 1
> EIP is at nf_nat_setup_info+0x221/0x58a
> EAX: 00120fbd EBX: 00120fbd ECX: 00000001 EDX: 00000000
> ESI: 0000019e EDI: e853bbb4 EBP: e853bbc8 ESP: e853bb78
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Process conntrackd (pid: 2795, ti=e853a000 task=f7de10f0 task.ti=e853a000)
> Stack: 00000000 e853bc2c e85672ec 00000008 c0561084 63c1db4a 00000000 00000000
>        00000000 0002e109 61d2b1c3 00000000 00000000 00000000 01114e22 61d2b1c3
>        00000000 00000000 f7444674 e853bc04 00000008 c038e728 0000000a f7444674
> Call Trace:
>  [<c038e728>] nla_parse+0x5c/0xb0
>  [<c0397c1b>] ctnetlink_change_status+0x190/0x1c6
>  [<c0397eec>] ctnetlink_new_conntrack+0x189/0x61f
>  [<c0119aee>] update_curr+0x3d/0x52
>  [<c03902d1>] nfnetlink_rcv_msg+0xc1/0xd8
>  [<c0390228>] nfnetlink_rcv_msg+0x18/0xd8
>  [<c0390210>] nfnetlink_rcv_msg+0x0/0xd8
>  [<c038d2ce>] netlink_rcv_skb+0x2d/0x71
>  [<c0390205>] nfnetlink_rcv+0x19/0x24
>  [<c038d0f5>] netlink_unicast+0x1b3/0x216
>  ...
> 
> Move invocation of the extension destructors to nf_conntrack_free()
> to fix this problem.
> 
> Fixes http://bugzilla.kernel.org/show_bug.cgi?id=10875
> 
> Reported-and-Tested-by: Krzysztof Piotr Oledzki <ole@ans.pl>
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> ---
> commit 8a3d245effe6e699e587133a3f8ea700bd47842d
> tree 38676f126c592455747598b6d56bccf9550d0214
> parent 21fa91adce646ad0449e898a64edaa828ca131e7
> author Patrick McHardy <kaber@trash.net> Tue, 10 Jun 2008 10:56:29 +0200
> committer Patrick McHardy <kaber@trash.net> Tue, 10 Jun 2008 10:56:29 +0200
> 
>  net/netfilter/nf_conntrack_core.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index c4b1799..662c1cc 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -196,8 +196,6 @@ destroy_conntrack(struct nf_conntrack *nfct)
>  	if (l4proto && l4proto->destroy)
>  		l4proto->destroy(ct);
> 
> -	nf_ct_ext_destroy(ct);
> -
>  	rcu_read_unlock();
> 
>  	spin_lock_bh(&nf_conntrack_lock);
> @@ -520,6 +518,7 @@ static void nf_conntrack_free_rcu(struct rcu_head *head)
> 
>  void nf_conntrack_free(struct nf_conn *ct)
>  {
> +	nf_ct_ext_destroy(ct);
>  	call_rcu(&ct->rcu, nf_conntrack_free_rcu);
>  }
>  EXPORT_SYMBOL_GPL(nf_conntrack_free);

> netfilter: nf_nat: fix RCU races
> 
> Fix three ct_extend/NAT extension related races:
> 
> - When cleaning up the extension area and removing it from the bysource hash,
>   the nat->ct pointer must not be set to NULL since it may still be used in
>   a RCU read side
> 
> - When replacing a NAT extension area in the bysource hash, the nat->ct
>   pointer must be assigned before performing the replacement
> 
> - When reallocating extension storage in ct_extend, the old memory must
>   not be freed immediately since it may still be used by a RCU read side
> 
> Possibly fixes https://bugzilla.redhat.com/show_bug.cgi?id=449315
> and/or http://bugzilla.kernel.org/show_bug.cgi?id=10875

One question and one nit below.

							Thanx, Paul

> Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> ---
> commit f4efed322f3d3a30df1bb5fc33403e84aca66d8e
> tree 72d463aa289ab27850f40c76b68a24e91af7a6b0
> parent 8a3d245effe6e699e587133a3f8ea700bd47842d
> author Patrick McHardy <kaber@trash.net> Tue, 10 Jun 2008 11:00:35 +0200
> committer Patrick McHardy <kaber@trash.net> Tue, 10 Jun 2008 11:00:35 +0200
> 
>  include/net/netfilter/nf_conntrack_extend.h |    1 +
>  net/ipv4/netfilter/nf_nat_core.c            |    3 +--
>  net/netfilter/nf_conntrack_extend.c         |    9 ++++++++-
>  3 files changed, 10 insertions(+), 3 deletions(-)
> 
> diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
> index f736e84..f80c0ed 100644
> --- a/include/net/netfilter/nf_conntrack_extend.h
> +++ b/include/net/netfilter/nf_conntrack_extend.h
> @@ -15,6 +15,7 @@ enum nf_ct_ext_id
> 
>  /* Extensions: optional stuff which isn't permanently in struct. */
>  struct nf_ct_ext {
> +	struct rcu_head rcu;
>  	u8 offset[NF_CT_EXT_NUM];
>  	u8 len;
>  	char data[0];
> diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
> index 0457859..d2a887f 100644
> --- a/net/ipv4/netfilter/nf_nat_core.c
> +++ b/net/ipv4/netfilter/nf_nat_core.c
> @@ -556,7 +556,6 @@ static void nf_nat_cleanup_conntrack(struct nf_conn *ct)
> 
>  	spin_lock_bh(&nf_nat_lock);
>  	hlist_del_rcu(&nat->bysource);
> -	nat->ct = NULL;
>  	spin_unlock_bh(&nf_nat_lock);
>  }
> 
> @@ -570,8 +569,8 @@ static void nf_nat_move_storage(void *new, void *old)
>  		return;
> 
>  	spin_lock_bh(&nf_nat_lock);
> -	hlist_replace_rcu(&old_nat->bysource, &new_nat->bysource);
>  	new_nat->ct = ct;
> +	hlist_replace_rcu(&old_nat->bysource, &new_nat->bysource);

The intent is to ensure that new_nat->ct is initialized before any
readers can find new_nat, right?  If so, OK.

>  	spin_unlock_bh(&nf_nat_lock);
>  }
> 
> diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
> index bcc19fa..8a3f8b3 100644
> --- a/net/netfilter/nf_conntrack_extend.c
> +++ b/net/netfilter/nf_conntrack_extend.c
> @@ -59,12 +59,19 @@ nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id, gfp_t gfp)
>  	if (!*ext)
>  		return NULL;
> 
> +	INIT_RCU_HEAD(&(*ext)->rcu);

Nit: the above is unnecessary.

>  	(*ext)->offset[id] = off;
>  	(*ext)->len = len;
> 
>  	return (void *)(*ext) + off;
>  }
> 
> +static void __nf_ct_ext_free_rcu(struct rcu_head *head)
> +{
> +	struct nf_ct_ext *ext = container_of(head, struct nf_ct_ext, rcu);
> +	kfree(ext);
> +}
> +
>  void *__nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
>  {
>  	struct nf_ct_ext *new;
> @@ -106,7 +113,7 @@ void *__nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
>  					(void *)ct->ext + ct->ext->offset[i]);
>  			rcu_read_unlock();
>  		}
> -		kfree(ct->ext);
> +		call_rcu(&ct->ext->rcu, __nf_ct_ext_free_rcu);
>  		ct->ext = new;
>  	}
> 

