From: Andrew Vagin <avagin@parallels.com>
Subject: Re: [PATCH] [RFC] netfilter: ct: flush net_gre->keymap_list only in
 nf_conntrack_proto_gre
Date: Tue, 8 Apr 2014 10:56:00 +0400
Message-ID: <20140408065600.GA15309@paralelels.com>
References: <1396275258-19015-1-git-send-email-avagin@openvz.org>
 <20140407145158.GA25974@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Cc: Andrey Vagin <avagin@openvz.org>, <linux-kernel@vger.kernel.org>,
	<netfilter-devel@vger.kernel.org>, <netfilter@vger.kernel.org>,
	<coreteam@netfilter.org>, <netdev@vger.kernel.org>,
	<vvs@parallels.com>, Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140407145158.GA25974@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 07, 2014 at 04:51:58PM +0200, Pablo Neira Ayuso wrote:
> On Mon, Mar 31, 2014 at 06:14:18PM +0400, Andrey Vagin wrote:
> > nf_ct_gre_keymap_flush() removes a nf_ct_gre_keymap object from
> > net_gre->keymap_list and frees the object. But it doesn't clean
> > a reference on this object from ct_pptp_info->keymap[dir].
> > Then nf_ct_gre_keymap_destroy() may release the same object again.
> > 
> > So nf_ct_gre_keymap_flush() can be called only when we are sure that
> > when nf_ct_gre_keymap_destroy will not be called.
> > 
> > nf_ct_gre_keymap is created by nf_ct_gre_keymap_add() and the right way
> > to destroy it is to call nf_ct_gre_keymap_destroy().
> 
> I think you use call nf_ct_iterate_cleanup() to get rid of all GRE
> conntrack entries that have a ct->master, which means that they were
> created by PPTP. That implicitly calls gre_destroy, which releases the
> keymap object.

I'm not sure that I understand your comment. Currently I change nothing
about nf_ct_iterate_cleanup(). In this sentence I point to the right
procedure of destroying a gre conntrack.

nf_ct_iterate_cleanup() is called from nf_ct_l4proto_pernet_unregister().

[ 1858.693250]   <idle>-0       1..s. 118795582us : nf_ct_gre_keymap_add <-exp_gre
[ 1858.693250]   <idle>-0       1..s. 118795598us : nf_ct_gre_keymap_add <-exp_gre
[ 1858.693250]   <idle>-0       1..s. 118795652us : nf_ct_gre_keymap_add <-exp_gre
[ 1858.693250]   <idle>-0       1..s. 118795683us : nf_ct_gre_keymap_add <-exp_gre
[ 1858.693250] kworker/-44      1.... 133620272us : nf_conntrack_pptp_net_exit <-ops_exit_list.isra.1
[ 1858.693250] kworker/-44      1.... 133620274us : nf_ct_gre_keymap_flush <-nf_conntrack_pptp_net_exit
[ 1858.693250] kworker/-44      1.... 133621145us : proto_gre_net_exit <-ops_exit_list.isra.1
[ 1858.693250] kworker/-44      1.... 133621145us : nf_ct_l4proto_pernet_unregister <-proto_gre_net_exit
[ 1858.693250] kworker/-44      1.... 133621146us : nf_ct_iterate_cleanup <-nf_ct_l4proto_pernet_unregister
[ 1858.693250] kworker/-44      1.... 133621187us : nf_ct_gre_keymap_destroy <-gre_destroy

> 
> > This patch marks nf_ct_gre_keymap_flush() as static, so this patch can
> > break compilation of third party modules, which use
> > nf_ct_gre_keymap_flush. I'm not sure this is the right way to deprecate
> > this function.
> 
> No problem with that, we don't mind about out of tree modules. With
> the approach I'm proposing I think you will also need to make this
> function static as it won't be used by PPTP anymore.

I have made this function static. If you don't have other comment, could
you take this patch?

Thanks,
Andrey
