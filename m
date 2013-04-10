From: Florian Westphal <fw@strlen.de>
Subject: Re: [BUG] Fatal exception in interrupt - nf_nat_cleanup_conntrack
 during IPv6 tests
Date: Wed, 10 Apr 2013 11:01:59 +0200
Message-ID: <20130410090158.GF3013@breakpoint.cc>
References: <605030311.1990960.1365563720663.JavaMail.root@redhat.com>
 <1089062823.1991307.1365563878922.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	netfilter-devel@breakpoint.cc
To: CAI Qian <caiqian@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1089062823.1991307.1365563878922.JavaMail.root@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CAI Qian <caiqian@redhat.com> wrote:

[ CC'd nf-devel ]

> Just hit this very often during IPv6 tests in both the latest stable
> and mainline kernel.
> 
> [ 3597.206166] Modules linked in:
[..]
> nf_nat_ipv4(F-)
[..]

> [ 3597.804861] RIP: 0010:[<ffffffffa03227f2>]  [<ffffffffa03227f2>] nf_nat_cleanup_conntrack+0x42/0x70 [nf_nat] 
> [ 3597.855207] RSP: 0018:ffff880202c63d40  EFLAGS: 00010246 
> [ 3597.881350] RAX: 0000000000000000 RBX: ffff8801ac7bec28 RCX: ffff8801d0eedbe0 
> [ 3597.917226] RDX: dead000000200200 RSI: 0000000000000011 RDI: ffffffffa03265b8 
[..]

> [ 3598.421036]  <IRQ>  
> [ 3598.430467]  [<ffffffffa0305bb4>] __nf_ct_ext_destroy+0x44/0x60 [nf_conntrack] 
> [ 3598.499191]  [<ffffffffa02fd3fe>] nf_conntrack_free+0x2e/0x70 [nf_conntrack] 
> [ 3598.534121]  [<ffffffffa02febed>] destroy_conntrack+0xbd/0x110 [nf_conntrack] 
> [ 3598.569981]  [<ffffffff81532187>] nf_conntrack_destroy+0x17/0x20 
> [ 3598.599579]  [<ffffffffa02fe77c>] death_by_timeout+0xdc/0x1b0 [nf_conntrack]
[..]
> [ 3599.241868] Code: 83 ec 08 0f b6 58 11 84 db 74 43 48 01 c3 48 83 7b 20 00 74 39 48 c7 c7 b8 65 32 a0 e8 98 fc 2e e1 48 8b 03 48 8b 53 08 48 85 c0 <48> 89 02 74 04 48 89 50 08 48 ba 00 02 20 00 00 00 ad de 48 c7  
> [ 3599.337037] RIP  [<ffffffffa03227f2>] nf_nat_cleanup_conntrack+0x42/0x70 [nf_nat] 

Looks like we tried to remove bysource hash twice (rdx is
LIST_POISON_2).

I wonder if this would explain it:

static void nf_nat_l4proto_clean(u8 l3proto, u8 l4proto)
{
[..]
      /* Step 1 - remove from bysource hash */
      clean.hash = true;
      for_each_net(net)
                nf_ct_iterate_cleanup(net, nf_nat_proto_clean, &clean);

A nfct->timer fires and a conntrack is free'd before step 2 memsets the
nat extension.  In that case, we would try to delete nat->bysource
again?
