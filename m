From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: reset transport header if it was not
 set before transmission
Date: Fri, 15 Mar 2013 19:10:51 -0700
Message-ID: <1363399851.29475.52.camel@edumazet-glaptop>
References: <1363333305-54398-1-git-send-email-jasowang@redhat.com>
	 <1363333305-54398-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	Eric Dumazet <edumazet@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:36988 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932272Ab3CPCK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 22:10:56 -0400
In-Reply-To: <1363333305-54398-2-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-15 at 15:41 +0800, Jason Wang wrote:
> Some drivers depends on transport_header to do packet transmission, but it was
> unset in some cases (one example is macvtap driver which build skbs from
> userspace and generate CHECKSUM_NONE packets). The driver may crash in those
> cases since the transport_header was not valid. The problem becomes more obvious
> since commit fda55eca5a33f33ffcd4192c6b2d75179714a52c (net: introduce
> skb_transport_header_was_set()) since it initializes transport_header to ~0U.
> 
> So before passing the skb to driver, this patch reset the transport_header if it
> was not set to avoid such crash such as:
> 
> hp-z800-04.qe.lab.eng.nay.redhat.com login: BUG: unable to handle kernel paging
> request at ffff8805166f760c
> IP: [<ffffffffa035a5d0>] ixgbe_xmit_frame_ring+0x220/0x5e0 [ixgbe]
> PGD 1ece067 PUD 0
> Oops: 0000 [#1] SMP
> Modules linked in: vhost_net tun nfsv3 nfs_acl nfsv4 auth_rpcgss nfs fscache
> lockd autofs4 sunrpc openvswitch ipv6 iTCO_wdt iTCO_vendor_support hp_wmi
> sparse_keymap rfkill acpi_cpufreq freq_table mperf coretemp kvm_intel kvm
> crc32c_intel ghash_clmulni_intel microcode serio_raw pcspkr sg lpc_ich mfd_core
> tg3 snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq
> snd_seq_device snd_pcm snd_timer snd soundcore snd_page_alloc i7core_edac
> edac_core ixgbe dca ptp pps_core mdio ext4(F) mbcache(F) jbd2(F) sd_mod(F)
> crc_t10dif(F) sr_mod(F) cdrom(F) firewire_ohci(F) firewire_core(F) crc_itu_t(F)
> aesni_intel(F) ablk_helper(F) cryptd(F) lrw(F) aes_x86_64(F) xts(F) gf128mul(F)
> floppy(F) mptsas(F) mptscsih(F) mptbase(F) scsi_transport_sas(F) ahci(F)
> libahci(F) nouveau(F) ttm(F) drm_kms_helper(F) drm(F) i2c_algo_bit(F)
> i2c_core(F) mxm_wmi(F) video(F) wmi(F) dm_mirror(F) dm_region_hash(F) dm_log(F)
> dm_mod(F) [last unloaded: tun]
> CPU 6
> Pid: 17337, comm: vhost-17317 Tainted: GF            3.9.0-rc1+ #7
> Hewlett-Packard HP Z800 Workstation/0AECh
> RIP: 0010:[<ffffffffa035a5d0>]  [<ffffffffa035a5d0>]
> ixgbe_xmit_frame_ring+0x220/0x5e0 [ixgbe]
> RSP: 0018:ffff880222cddb18  EFLAGS: 00010286
> RAX: 00000000ffffffff RBX: ffff880416b4b000 RCX: ffff8805166f75ff
> RDX: 0000000000000008 RSI: ffff8804166f760e RDI: 0000000000000007
> RBP: ffff880222cddb68 R08: 0000000000000008 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: ffffc90009dce120
> R13: ffff880416b4b300 R14: 0000000000000000 R15: ffff8804118f0800
> FS:  0000000000000000(0000) GS:ffff88042fc40000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: ffff8805166f760c CR3: 000000041e98c000 CR4: 00000000000027e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process vhost-17317 (pid: 17337, threadinfo ffff880222cdc000, task
> ffff8802211d4040)
> Stack:
>  00000000ffffffff 0000000000000180 ffff880222cddbb7 0000000000000180
>  ffff880222cddb48 ffff88040d5dd1c0 ffff8804118f0000 0000000000000036
>  ffff8804118f0000 ffff8804165d7a9c ffff880222cddb88 ffffffffa035a9d3
> Call Trace:
>  [<ffffffffa035a9d3>] ixgbe_xmit_frame+0x43/0x90 [ixgbe]
>  [<ffffffff8149d54a>] dev_hard_start_xmit+0x12a/0x570
>  [<ffffffff814bd8da>] sch_direct_xmit+0xfa/0x1d0
>  [<ffffffff8149db28>] dev_queue_xmit+0x198/0x4c0
>  [<ffffffff813d23fa>] macvlan_start_xmit+0x6a/0x170
>  [<ffffffff813d3974>] macvtap_get_user+0x404/0x4e0
>  [<ffffffff813d3a7b>] macvtap_sendmsg+0x2b/0x30
>  [<ffffffffa06d9efa>] handle_tx+0x34a/0x680 [vhost_net]
>  [<ffffffffa06da265>] handle_tx_kick+0x15/0x20 [vhost_net]
>  [<ffffffffa06d7dfc>] vhost_worker+0x10c/0x1c0 [vhost_net]
>  [<ffffffffa06d7cf0>] ? vhost_attach_cgroups_work+0x30/0x30 [vhost_net]
>  [<ffffffffa06d7cf0>] ? vhost_attach_cgroups_work+0x30/0x30 [vhost_net]
>  [<ffffffff8107b77e>] kthread+0xce/0xe0
>  [<ffffffff8107b6b0>] ? kthread_freezable_should_stop+0x70/0x70
>  [<ffffffff815749ec>] ret_from_fork+0x7c/0xb0
>  [<ffffffff8107b6b0>] ? kthread_freezable_should_stop+0x70/0x70
> Code: 34 31 0f 84 d3 01 00 00 66 83 fa 08 0f 85 b9 00 00 00 80 7e 09 06 0f 85 af
> 00 00 00 8b 80 cc 00 00 00 48 01 c1 0f 84 a0 00 00 00 <0f> b6 41 0d a8 01 0f 85
> 94 00 00 00 a8 02 75 0a 41 3a 7d 5c 0f
> RIP  [<ffffffffa035a5d0>] ixgbe_xmit_frame_ring+0x220/0x5e0 [ixgbe]
>  RSP <ffff880222cddb18>
> CR2: ffff8805166f760c
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  net/core/dev.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 480114d..db315a1 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2525,6 +2525,9 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  			}
>  		}
>  
> +		if (!skb_transport_header_was_set(skb))
> +			skb_reset_transport_header(skb);
> +
>  		if (!list_empty(&ptype_all))
>  			dev_queue_xmit_nit(skb, dev);
>  

Hmm... This really looks strange.

Any way we can avoid adding this to fast path, for people not using
macvtap and ixgbe ?
