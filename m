From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [v2 PATCH 13/13] crypto: algif_aead - Switch to new AEAD interface
Date: Sun, 24 May 2015 12:52:02 +0200
Message-ID: <3847514.ujeNcPGtgS@tachyon.chronox.de>
References: <20150522082708.GA3507@gondor.apana.org.au> <1969904.xZlo35YxmK@tachyon.chronox.de> <20150524033420.GC20656@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150524033420.GC20656@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Sonntag, 24. Mai 2015, 11:34:20 schrieb Herbert Xu:

Hi Herbert,

> On Sat, May 23, 2015 at 08:04:19PM +0200, Stephan Mueller wrote:
> > Am Freitag, 22. Mai 2015, 16:31:04 schrieb Herbert Xu:
> > 
> > Hi Herbert,
> > 
> > > This patch makes use of the new AEAD interface which uses a single
> > > SG list instead of separate lists for the AD and plain text.
> > 
> > After applying your additional patch, the "normal" AEAD operation works.
> > 
> > But with long messages (16 filled pages), I get the following. To test,
> > simply use [1], cd libkcapi/test, compile and execute ./kcapi -y
> 
> Thanks for testing!
> 
> Does this patch help?

Yes and no. Executing the test with 16 pages once passes. Executing it again 
(same test, same vectors) causes:

[   29.653113] BUG: unable to handle kernel NULL pointer dereference at 
000000000000000c
[   29.653118] IP: [<ffffffff812b6d78>] scatterwalk_ffwd+0x28/0xd0
[   29.653123] PGD 7b775067 PUD 7b699067 PMD 0 
[   29.653125] Oops: 0000 [#1] SMP 
[   29.653128] Modules linked in: crypto_user ccm algif_aead af_alg 
nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ip6t_REJECT 
nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 
nf_defrag_ipv4 xt_conntrack nf_conntrack cfg80211 ebtable_nat ebtable_broute 
bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_security 
ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_security 
iptable_raw crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel 
aesni_intel aes_x86_64 glue_helper ablk_helper virtio_balloon microcode joydev 
pcspkr serio_raw i2c_piix4 acpi_cpufreq virtio_net virtio_blk qxl 
drm_kms_helper ttm drm virtio_pci virtio_ring virtio
[   29.653151] CPU: 1 PID: 1759 Comm: kcapi Not tainted 4.0.0+ #220
[   29.653153] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 
1.7.5-20140709_153950- 04/01/2014
[   29.653154] task: ffff88007b798880 ti: ffff88007a434000 task.ti: 
ffff88007a434000
[   29.653156] RIP: 0010:[<ffffffff812b6d78>]  [<ffffffff812b6d78>] 
scatterwalk_ffwd+0x28/0xd0
[   29.653158] RSP: 0018:ffff88007a437a98  EFLAGS: 00010202
[   29.653160] RAX: 0000000000000000 RBX: 0000000000006fe0 RCX: 
ffffea0001eef580
[   29.653161] RDX: 0000000000001000 RSI: ffff88007a437b38 RDI: 
ffff88007a437c18
[   29.653162] RBP: ffff88007a437aa8 R08: 0000000000000000 R09: 
ffff88007a437cf8
[   29.653163] R10: 0000000000000000 R11: 0000000000000000 R12: 
ffff88007b1fed90
[   29.653164] R13: ffff88007c0d7ac0 R14: ffff88007b1fed50 R15: 
ffff88007b1fc000
[   29.653165] FS:  00007fb3d7ace700(0000) GS:ffff88007fd00000(0000) 
knlGS:0000000000000000
[   29.653167] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   29.653168] CR2: 000000000000000c CR3: 000000007b779000 CR4: 
00000000000407e0
[   29.653171] Stack:
[   29.653172]  ffff88007b1fecf0 ffffffffa02a0380 ffff88007a437ad8 
ffffffff812b7b40
[   29.653175]  ffff88007b1fecb0 ffff88007a437cf8 0000000000000000 
ffff8800798bf400
[   29.653177]  ffff88007a437ae8 ffffffff812b7c0d ffff88007a437d88 
ffffffffa029a246
[   29.653179] Call Trace:
[   29.653182]  [<ffffffffa02a0380>] ? crypto_ccm_decrypt+0x350/0x350 [ccm]
[   29.653185]  [<ffffffff812b7b40>] old_crypt+0x50/0xe0
[   29.653187]  [<ffffffff812b7c0d>] old_encrypt+0x1d/0x20
[   29.653189]  [<ffffffffa029a246>] aead_recvmsg+0x6f6/0x860 [algif_aead]
[   29.653192]  [<ffffffff8114a672>] ? __alloc_pages_nodemask+0x1a2/0x9d0
[   29.653195]  [<ffffffff81687b7a>] ? _raw_spin_unlock_bh+0x1a/0x20
[   29.653197]  [<ffffffffa0299849>] ? aead_sendmsg+0x429/0x4c0 [algif_aead]
[   29.653201]  [<ffffffff81561528>] sock_recvmsg+0x38/0x50
[   29.653203]  [<ffffffff815615c8>] sock_read_iter+0x88/0xd0
[   29.653205]  [<ffffffff811a9990>] __vfs_read+0x90/0xc0
[   29.653207]  [<ffffffff811aa12a>] vfs_read+0x8a/0x140
[   29.653209]  [<ffffffff811aab56>] SyS_read+0x46/0xb0
[   29.653210]  [<ffffffff8168812e>] system_call_fastpath+0x12/0x71
[   29.653211] Code: 0f 1f 00 66 66 66 66 90 55 85 d2 48 89 f0 48 89 e5 41 54 
53 89 d3 74 28 8b 56 0c 49 89 fc 39 d3 73 10 eb 27 0f 1f 80 00 00 00 00 <8b> 
50 0c 39 da 77 19 29 d3 48 89 c7 e8 87 a9 05 00 85 db 75 eb 
[   29.653233] RIP  [<ffffffff812b6d78>] scatterwalk_ffwd+0x28/0xd0
[   29.653235]  RSP <ffff88007a437a98>
[   29.653236] CR2: 000000000000000c
[   29.653238] ---[ end trace b579ecce490b2e88 ]---
-- 
Ciao
Stephan
