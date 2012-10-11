From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: amd64, v3.6.0: Kernel panic + BUG at
 net/netfilter/nf_conntrack_core.c:220!
Date: Fri, 12 Oct 2012 01:32:06 +0200
Message-ID: <20121011233206.GA10370@1984>
References: <CAEcaRjj-xBqEAz_6UHbTZWrvjHB7QUvUUmEvmtuyPJU+iudxkQ@mail.gmail.com>
 <20121011212733.GB26025@liondog.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Borislav Petkov <bp@alien8.de>, Ian Applegate <ia@cloudflare.com>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121011212733.GB26025@liondog.tnic>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 11, 2012 at 11:27:33PM +0200, Borislav Petkov wrote:
> On Thu, Oct 11, 2012 at 12:13:33PM -0700, Ian Applegate wrote:
> > On machines serving mainly http traffic we are seeing the following
> > panic, which is not yet reproducible.
> 
> Must be this BUG_ON:
> 
> 	if (!nf_ct_is_confirmed(ct)) {
> 		BUG_ON(hlist_nulls_unhashed(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode));
> 		hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
> 	}

At quick glance, I think we're hitting a memory corruption, I don't
see by now any sane code path to reach that bugtrap.

More comments below:

> Spamming some more lists and leaving the rest for reference.
> 
> > 
> > 
> > [180926.566743] ------------[ cut here ]------------
> > [180926.572034] kernel BUG at net/netfilter/nf_conntrack_core.c:220!
> > [180926.578873] invalid opcode: 0000 [#1] SMP
> > [180926.583594] Modules linked in: xfs exportfs ipmi_devintf ipmi_si
> > ipmi_msghandler dm_mod md_mod nf_conntr
> > ack_ipv6 nf_defrag_ipv6 ip6table_filter ip6table_raw ip6_tables
> > nf_conntrack_ipv4 nf_defrag_ipv4 xt_tcpudp x
> > t_conntrack xt_multiport iptable_filter xt_NOTRACK nf_conntrack
> > iptable_raw ip_tables x_tables nfsv4 auth_rp
> > cgss fuse nfsv3 nfs_acl nfs fscache lockd sunrpc sfc mtd i2c_algo_bit
> > i2c_core mdio igb dca uhci_hcd coretem
> > p acpi_cpufreq kvm_intel kvm crc32c_intel aesni_intel ablk_helper
> > cryptd aes_x86_64 aes_generic evdev sd_mod
> >  crc_t10dif mperf snd_pcm ahci snd_timer tpm_tis microcode snd tpm
> > libahci tpm_bios soundcore libata snd_pag
> > e_alloc pcspkr ehci_hcd lpc_ich usbcore mfd_core hpsa scsi_mod
> > usb_common button processor thermal_sys
> > [180926.657762] CPU 12
> > [180926.660008] Pid: 5948, comm: nginx-fl Not tainted 3.6.0-cloudflare
> > #1 HP ProLiant DL180 G6
> > [180926.669820] RIP: 0010:[<ffffffffa02ccdd1>]  [<ffffffffa02ccdd1>]
> > destroy_conntrack+0x55/0xa9 [nf_conntrack]
> > [180926.680871] RSP: 0018:ffff8805bd73fbb8  EFLAGS: 00010246
> > [180926.686930] RAX: 0000000000000000 RBX: ffff8806b6f56c30 RCX:
> > ffff8805bd73fc48
> > [180926.695055] RDX: 0000000000000000 RSI: 0000000000000006 RDI:
> > ffff8806b6f56c30
> > [180926.703179] RBP: ffffffff81651780 R08: 00000000000172e0 R09:
> > ffffffff812cef91
> > [180926.711304] R10: dead000000200200 R11: dead000000100100 R12:
> > ffff8806b6f56c30
> > [180926.727451] R13: 0000000000000000 R14: ffffffffa02d6030 R15:
> > 0000000000000000
> > [180926.735575] FS:  00007f382cdb2710(0000) GS:ffff880627cc0000(0000)
> > knlGS:0000000000000000
> > [180926.744766] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [180926.751312] CR2: ffffffffff600400 CR3: 00000005bd8d3000 CR4:
> > 00000000000007e0
> > [180926.759436] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> > 0000000000000000
> > [180926.767560] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> > 0000000000000400
> > [180926.775686] Process nginx-fl (pid: 5948, threadinfo
> > ffff8805bd73e000, task ffff8805c9755960)
> > [180926.785265] Stack:
> > [180926.787634]  0000000000000000 ffffffff81651780 ffff8802720c2900
> > ffffffffa02cde78
> > [180926.796087]  ffffffff81651ec0 ffffffffa02d6030 00000000bff0efab
> > ffff8805ffffffff
> > [180926.804532]  0002880500000002 0000000300000014 0000001400000003
> > 06ff880600000002
> > [180926.812985] Call Trace:
> > [180926.815845]  [<ffffffffa02cde78>] ? nf_conntrack_in+0x4ed/0x5bc
> > [nf_conntrack]

Here below the trace shows the output path to close a tcp socket. But
the line above refers to a conntrack function that is called in the
input path.

If this process is just acting as plain http server, this backtrace
doesn't seem consistent to me.

> > [180926.824069]  [<ffffffff812ac195>] ? nf_iterate+0x41/0x77
> > [180926.830131]  [<ffffffff812b3820>] ? ip_options_echo+0x2ed/0x2ed
> > [180926.836873]  [<ffffffff812ac2ee>] ? nf_hook_slow+0x68/0xfd
> > [180926.843127]  [<ffffffff812b3820>] ? ip_options_echo+0x2ed/0x2ed
> > [180926.849866]  [<ffffffff812b55a8>] ? __ip_local_out+0x98/0x9d
> > [180926.856315]  [<ffffffff812b55b6>] ? ip_local_out+0x9/0x19
> > [180926.862465]  [<ffffffff812c7582>] ? tcp_transmit_skb+0x7ae/0x7f1
> > [180926.869305]  [<ffffffff810fff4c>] ? virt_to_head_page+0x9/0x2c
> > [180926.875949]  [<ffffffff812c78a6>] ? tcp_send_active_reset+0xd5/0x101
> > [180926.883175]  [<ffffffff812bc38f>] ? tcp_close+0x118/0x354
> > [180926.889334]  [<ffffffff812dbdc2>] ? inet_release+0x75/0x7b
> > [180926.895591]  [<ffffffff81278bff>] ? sock_release+0x19/0x73
> > [180926.901845]  [<ffffffff81278c7b>] ? sock_close+0x22/0x27
> > [180926.907906]  [<ffffffff81109de8>] ? __fput+0xe9/0x1ae
> > [180926.913677]  [<ffffffff81057157>] ? task_work_run+0x53/0x67
> > [180926.920031]  [<ffffffff8100e50c>] ? do_notify_resume+0x79/0x8d
> > [180926.926673]  [<ffffffff8134e5b2>] ? int_signal+0x12/0x17
> > [180926.932732] Code: 05 48 89 df ff d0 48 c7 c7 30 66 2d a0 e8 11 b0
> > 07 e1 48 89 df e8 72 25 00 00 48 8b 43
> >  78 a8 08 75 2a 48 8b 53 10 48 85 d2 75 04 <0f> 0b eb fe 48 8b 43 08
> > 48 89 02 a8 01 75 04 48 89 50 08 48 be
> > [180926.954788] RIP  [<ffffffffa02ccdd1>] destroy_conntrack+0x55/0xa9
> > [nf_conntrack]
> > [180926.963217]  RSP <ffff8805bd73fbb8>
> > [180926.967700] ---[ end trace 54a660a52afd5820 ]---
> > [180926.973038] Kernel panic - not syncing: Fatal exception in interrupt
> > 
> > ---
> > Ian Applegate
> > CloudFlare
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> 
> -- 
> Regards/Gruss,
>     Boris.
