From: Pablo Neira Ayuso <pablo@gnumonks.org>
Subject: Re: Oops with latest (netfilter) nf-next tree, when unloading
 iptable_nat
Date: Thu, 20 Sep 2012 12:08:59 +0200
Message-ID: <20120920100859.GB20828@1984>
References: <1347357081.3928.32.camel@localhost>
 <20120912213627.GJ14750@breakpoint.cc>
 <20120914120750.GA5764@1984>
 <Pine.GSO.4.63.1209141511020.11622@stinky-local.trash.net>
 <1348058791.2761.94.camel@localhost>
 <Pine.GSO.4.63.1209200855500.8409@stinky-local.trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, yongjun_wei@trendmicro.com.cn
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.63.1209200855500.8409@stinky-local.trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 20, 2012 at 08:57:04AM +0200, Patrick McHardy wrote:
> On Wed, 19 Sep 2012, Jesper Dangaard Brouer wrote:
> 
> >On Fri, 2012-09-14 at 15:15 +0200, Patrick McHardy wrote:
> >>On Fri, 14 Sep 2012, Pablo Neira Ayuso wrote:
> >>
> >[...cut...]
> >>>>Patrick, any other idea?
> >>>
> >[...cut...]
> >>>>
> >>>We can add nf_nat_iterate_cleanup that can iterate over the NAT
> >>>hashtable to replace current usage of nf_ct_iterate_cleanup.
> >>
> >>Lets just bail out when IPS_SRC_NAT_DONE is not set, that should also fix
> >>it. Could you try this patch please?
> >
> >On Fri, 2012-09-14 at 15:15 +0200, Patrick McHardy wrote:
> >diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
> >>index 29d4452..8b5d220 100644
> >>--- a/net/netfilter/nf_nat_core.c
> >>+++ b/net/netfilter/nf_nat_core.c
> >>@@ -481,6 +481,8 @@ static int nf_nat_proto_clean(struct nf_conn *i,
> >void *data)
> >>
> >>        if (!nat)
> >>                return 0;
> >>+       if (!(i->status & IPS_SRC_NAT_DONE))
> >>+               return 0;
> >>        if ((clean->l3proto && nf_ct_l3num(i) != clean->l3proto) ||
> >>            (clean->l4proto && nf_ct_protonum(i) != clean->l4proto))
> >>                return 0;
> >>
> >
> >No it does not work :-(
> 
> Ok I think I understand the problem now, we're invoking the NAT cleanup
> callback twice with clean->hash = true, once for each direction of the
> conntrack.
> 
> Does this patch fix the problem?

> commit 6c46a3bfb2776ca098565daf7e872a3283d14e0d
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Thu Sep 20 08:43:02 2012 +0200
> 
>     netfilter: nf_nat: fix oops when unloading protocol modules
>     
>     When unloading a protocol module nf_ct_iterate_cleanup() is used to
>     remove all conntracks using the protocol from the bysource hash and
>     clean their NAT sections. Since the conntrack isn't actually killed,
>     the NAT callback is invoked twice, once for each direction, which
>     causes an oops when trying to delete it from the bysource hash for
>     the second time.
>     
>     The same oops can also happen when removing both an L3 and L4 protocol
>     since the cleanup function doesn't check whether the conntrack has
>     already been cleaned up.
>     
>     Pid: 4052, comm: modprobe Not tainted 3.6.0-rc3-test-nat-unload-fix+ #32 Red Hat KVM
>     RIP: 0010:[<ffffffffa002c303>]  [<ffffffffa002c303>] nf_nat_proto_clean+0x73/0xd0 [nf_nat]
>     RSP: 0018:ffff88007808fe18  EFLAGS: 00010246
>     RAX: 0000000000000000 RBX: ffff8800728550c0 RCX: ffff8800756288b0
>     RDX: dead000000200200 RSI: ffff88007808fe88 RDI: ffffffffa002f208
>     RBP: ffff88007808fe28 R08: ffff88007808e000 R09: 0000000000000000
>     R10: dead000000200200 R11: dead000000100100 R12: ffffffff81c6dc00
>     R13: ffff8800787582b8 R14: ffff880078758278 R15: ffff88007808fe88
>     FS:  00007f515985d700(0000) GS:ffff88007cd00000(0000) knlGS:0000000000000000
>     CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>     CR2: 00007f515986a000 CR3: 000000007867a000 CR4: 00000000000006e0
>     DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>     DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>     Process modprobe (pid: 4052, threadinfo ffff88007808e000, task ffff8800756288b0)
>     Stack:
>      ffff88007808fe68 ffffffffa002c290 ffff88007808fe78 ffffffff815614e3
>      ffffffff00000000 00000aeb00000246 ffff88007808fe68 ffffffff81c6dc00
>      ffff88007808fe88 ffffffffa00358a0 0000000000000000 000000000040f5b0
>     Call Trace:
>      [<ffffffffa002c290>] ? nf_nat_net_exit+0x50/0x50 [nf_nat]
>      [<ffffffff815614e3>] nf_ct_iterate_cleanup+0xc3/0x170
>      [<ffffffffa002c55a>] nf_nat_l3proto_unregister+0x8a/0x100 [nf_nat]
>      [<ffffffff812a0303>] ? compat_prepare_timeout+0x13/0xb0
>      [<ffffffffa0035848>] nf_nat_l3proto_ipv4_exit+0x10/0x23 [nf_nat_ipv4]
>      ...
>     
>     To fix this,
>     
>     - check whether the conntrack has already been cleaned up in
>       nf_nat_proto_clean
>     
>     - change nf_ct_iterate_cleanup() to only invoke the callback function
>       once for each conntrack (IP_CT_DIR_ORIGINAL).
>     
>     The second change doesn't affect other callers since when conntracks are
>     actually killed, both directions are removed from the hash immediately
>     and the callback is already only invoked once. If it is not killed, the
>     second callback invocation will always return the same decision not to
>     kill it.
>     
>     Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index dcb2791..0f241be 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -1224,6 +1224,8 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
>  	spin_lock_bh(&nf_conntrack_lock);
>  	for (; *bucket < net->ct.htable_size; (*bucket)++) {
>  		hlist_nulls_for_each_entry(h, n, &net->ct.hash[*bucket], hnnode) {
> +			if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
> +				continue;

I think this will make the deletion of entries via `conntrack -F'
slowier as we'll have to iterate over more entries (we won't delete
entries for the reply tuple).

I think I prefer Florian's patch, it's fairly small and it does not
change the current nf_ct_iterate behaviour or adding some
nf_nat_iterate cleanup.

>  			ct = nf_ct_tuplehash_to_ctrack(h);
>  			if (iter(ct, data))
>  				goto found;
> diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
> index 1816ad3..65cf694 100644
> --- a/net/netfilter/nf_nat_core.c
> +++ b/net/netfilter/nf_nat_core.c
> @@ -481,6 +481,8 @@ static int nf_nat_proto_clean(struct nf_conn *i, void *data)
>  
>  	if (!nat)
>  		return 0;
> +	if (!(i->status & IPS_SRC_NAT_DONE))
> +		return 0;
>  	if ((clean->l3proto && nf_ct_l3num(i) != clean->l3proto) ||
>  	    (clean->l4proto && nf_ct_protonum(i) != clean->l4proto))
>  		return 0;

