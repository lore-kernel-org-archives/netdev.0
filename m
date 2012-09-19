From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Oops with latest (netfilter) nf-next tree, when unloading
 iptable_nat
Date: Wed, 19 Sep 2012 14:46:31 +0200
Message-ID: <1348058791.2761.94.camel@localhost>
References: <1347357081.3928.32.camel@localhost>
	 <20120912213627.GJ14750@breakpoint.cc> <20120914120750.GA5764@1984>
	 <Pine.GSO.4.63.1209141511020.11622@stinky-local.trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@gnumonks.org>,
	Florian Westphal <fw@strlen.de>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, yongjun_wei@trendmicro.com.cn
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.GSO.4.63.1209141511020.11622@stinky-local.trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-09-14 at 15:15 +0200, Patrick McHardy wrote:
> On Fri, 14 Sep 2012, Pablo Neira Ayuso wrote:
> 
[...cut...]
> >> Patrick, any other idea?
> >
[...cut...]
> > >
> > We can add nf_nat_iterate_cleanup that can iterate over the NAT
> > hashtable to replace current usage of nf_ct_iterate_cleanup.
> 
> Lets just bail out when IPS_SRC_NAT_DONE is not set, that should also fix
> it. Could you try this patch please?

On Fri, 2012-09-14 at 15:15 +0200, Patrick McHardy wrote:
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
> index 29d4452..8b5d220 100644
> --- a/net/netfilter/nf_nat_core.c
> +++ b/net/netfilter/nf_nat_core.c
> @@ -481,6 +481,8 @@ static int nf_nat_proto_clean(struct nf_conn *i,
void *data)
>  
>         if (!nat)
>                 return 0;
> +       if (!(i->status & IPS_SRC_NAT_DONE))
> +               return 0;
>         if ((clean->l3proto && nf_ct_l3num(i) != clean->l3proto) ||
>             (clean->l4proto && nf_ct_protonum(i) != clean->l4proto))
>                 return 0;
> 

No it does not work :-(


[ 1216.310146] general protection fault: 0000 [#1] SMP 
[ 1216.311046] Modules linked in: netconsole ip_vs_lblc ip_vs_lc ip_vs_rr ip_vs libcrc32c ipt_MASQUERADE nf_nat_ipv4(-) nf_nat iptable_mangle xt_mark ip6table_mangle xt_LOG ip6table_filter ip6_tables virtio_balloon virtio_net [last unloaded: iptable_nat]
[ 1216.311046] CPU 1 
[ 1216.311046] Pid: 4052, comm: modprobe Not tainted 3.6.0-rc3-test-nat-unload-fix+ #32 Red Hat KVM
[ 1216.311046] RIP: 0010:[<ffffffffa002c303>]  [<ffffffffa002c303>] nf_nat_proto_clean+0x73/0xd0 [nf_nat]
[ 1216.311046] RSP: 0018:ffff88007808fe18  EFLAGS: 00010246
[ 1216.311046] RAX: 0000000000000000 RBX: ffff8800728550c0 RCX: ffff8800756288b0
[ 1216.311046] RDX: dead000000200200 RSI: ffff88007808fe88 RDI: ffffffffa002f208
[ 1216.311046] RBP: ffff88007808fe28 R08: ffff88007808e000 R09: 0000000000000000
[ 1216.311046] R10: dead000000200200 R11: dead000000100100 R12: ffffffff81c6dc00
[ 1216.311046] R13: ffff8800787582b8 R14: ffff880078758278 R15: ffff88007808fe88
[ 1216.311046] FS:  00007f515985d700(0000) GS:ffff88007cd00000(0000) knlGS:0000000000000000
[ 1216.311046] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1216.311046] CR2: 00007f515986a000 CR3: 000000007867a000 CR4: 00000000000006e0
[ 1216.311046] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1216.311046] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1216.311046] Process modprobe (pid: 4052, threadinfo ffff88007808e000, task ffff8800756288b0)
[ 1216.311046] Stack:
[ 1216.311046]  ffff88007808fe68 ffffffffa002c290 ffff88007808fe78 ffffffff815614e3
[ 1216.311046]  ffffffff00000000 00000aeb00000246 ffff88007808fe68 ffffffff81c6dc00
[ 1216.311046]  ffff88007808fe88 ffffffffa00358a0 0000000000000000 000000000040f5b0
[ 1216.311046] Call Trace:
[ 1216.311046]  [<ffffffffa002c290>] ? nf_nat_net_exit+0x50/0x50 [nf_nat]
[ 1216.311046]  [<ffffffff815614e3>] nf_ct_iterate_cleanup+0xc3/0x170
[ 1216.311046]  [<ffffffffa002c55a>] nf_nat_l3proto_unregister+0x8a/0x100 [nf_nat]
[ 1216.311046]  [<ffffffff812a0303>] ? compat_prepare_timeout+0x13/0xb0
[ 1216.311046]  [<ffffffffa0035848>] nf_nat_l3proto_ipv4_exit+0x10/0x23 [nf_nat_ipv4]
[ 1216.311046]  [<ffffffff8109f4a5>] sys_delete_module+0x235/0x2b0
[ 1216.311046]  [<ffffffff810b8193>] ? __audit_syscall_entry+0x1b3/0x1f0
[ 1216.311046]  [<ffffffff810b8776>] ? __audit_syscall_exit+0x3e6/0x410
[ 1216.311046]  [<ffffffff816679e2>] system_call_fastpath+0x16/0x1b
[ 1216.311046] Code: 75 6e 0f b6 46 01 84 c0 74 05 3a 42 3e 75 61 80 7e 02 00 74 43 48 c7 c7 08 f2 02 a0 e8 37 3b 63 e1 48 8b 03 48 8b 53 08 48 85 c0 <48> 89 02 74 04 48 89 50 08 48 be 00 02 20 00 00 00 ad de 48 c7 
[ 1216.311046] RIP  [<ffffffffa002c303>] nf_nat_proto_clean+0x73/0xd0 [nf_nat]
[ 1216.311046]  RSP <ffff88007808fe18>


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


