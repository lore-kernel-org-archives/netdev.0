From: Konstantin Khlebnikov <koct9i@gmail.com>
Subject: [BUG] skb corruption and kernel panic at forwarding with fragmentation
Date: Wed, 6 Jan 2016 22:15:31 +0300
Message-ID: <CALYGNiP-0MZ-FExV2HutTvE9U-QQtkKSoE--KN=JQE5STYsjAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've got some of these:

[84408.314676] BUG: unable to handle kernel NULL pointer dereference
at           (null)
[84408.317324] IP: [<ffffffff81166e15>] put_page+0x5/0x50
[84408.319985] PGD 0
[84408.322583] Oops: 0000 [#1] SMP
[84408.325156] Modules linked in: ppp_mppe ppp_async ppp_generic slhc
8021q fuse nfsd auth_rpcgss oid_registry nfs_acl nfs lockd grace
sunrpc bridge stp llc xt_HL xt_TCPMSS xt_state w83627ehf hwmon_vid
snd_hda_codec_realtek snd_hda_codec_generic radeon snd_hda_codec_hdmi
snd_hda_intel snd_hda_controller snd_hda_codec snd_hwdep snd_pcm
snd_hda_core edac_core k10temp snd_timer snd drm_kms_helper soundcore
ath9k ttm ath9k_common ath9k_hw ath r8169 mii
[84408.336804] CPU: 3 PID: 0 Comm: swapper/3 Not tainted 4.1.15-zurg #1
[84408.339839] Hardware name: To Be Filled By O.E.M. To Be Filled By
O.E.M./RS880D, BIOS 080015  04/12/2011
[84408.342964] task: ffff880216d56f50 ti: ffff880216e04000 task.ti:
ffff880216e04000
[84408.346136] RIP: 0010:[<ffffffff81166e15>]  [<ffffffff81166e15>]
put_page+0x5/0x50
[84408.349301] RSP: 0018:ffff88021fcc37c0  EFLAGS: 00010216
[84408.352433] RAX: 0000000000000030 RBX: 0000000000000001 RCX: 0000000000000077
[84408.355602] RDX: ffff880213d8818e RSI: 0000000000000200 RDI: 0000000000000000
[84408.358765] RBP: ffff88021fcc37e8 R08: 0000000000000076 R09: ffff880216c01900
[84408.361885] R10: ffffea000859a840 R11: 0000000000000001 R12: ffff8802166a1300
[84408.364988] R13: ffff88021280d8c0 R14: ffff8802166a1300 R15: ffff88021280d410
[84408.368059] FS:  00007f9ada2de700(0000) GS:ffff88021fcc0000(0000)
knlGS:0000000000000000
[84408.371211] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[84408.374336] CR2: 0000000000000000 CR3: 0000000216575000 CR4: 00000000000006e0
[84408.377484] Stack:
[84408.380623]  ffffffff81576ac8 ffff88021fcc37e8 ffff8802166a1300
ffff8802166a1300
[84408.383843]  0000000000000000 ffff88021fcc3808 ffffffff81576b48
ffff88021fcc3808
[84408.387022]  0000000000006e00 ffff88021fcc3828 ffffffff81576cdd
0000000000006e00
[84408.390187] Call Trace:
[84408.393293]  <IRQ>
[84408.393323]  [<ffffffff81576ac8>] ? skb_release_data+0x78/0xd0
[84408.399488]  [<ffffffff81576b48>] skb_release_all+0x28/0x30
[84408.402553]  [<ffffffff81576cdd>] consume_skb+0x5d/0x80
[84408.405630]  [<ffffffff815d0d64>] ip_fragment+0x5c4/0x970
[84408.408676]  [<ffffffff815cf740>] ? ip_copy_metadata+0x160/0x160
[84408.411733]  [<ffffffff815d1711>] ip_finish_output+0x601/0x900
[84408.414788]  [<ffffffff815b6ed9>] ? nf_hook_slow+0x99/0x100
[84408.417828]  [<ffffffff815d2366>] ip_output+0x66/0xc0
[84408.420847]  [<ffffffff815d1110>] ? ip_fragment+0x970/0x970
[84408.423864]  [<ffffffff815cd683>] ip_forward_finish+0x73/0xa0
[84408.426864]  [<ffffffff815cda5f>] ip_forward+0x3af/0x490
[84408.429833]  [<ffffffff815cd610>] ? ip_frag_mem+0x50/0x50
[84408.432782]  [<ffffffff815cb701>] ip_rcv_finish+0x81/0x370
[84408.435778]  [<ffffffff815cc0b2>] ip_rcv+0x2a2/0x3c0
[84408.438780]  [<ffffffff815cb680>] ? inet_del_offload+0x40/0x40
[84408.441780]  [<ffffffff8158a623>] __netif_receive_skb_core+0x673/0x810
[84408.444785]  [<ffffffff8158a7d8>] __netif_receive_skb+0x18/0x60
[84408.447766]  [<ffffffff8158a843>] netif_receive_skb_internal+0x23/0x90
[84408.450739]  [<ffffffff8158a8cc>] netif_receive_skb_sk+0x1c/0x70
[84408.453726]  [<ffffffffa04a9e5c>] br_handle_frame_finish+0x27c/0x520 [bridge]
[84408.456774]  [<ffffffff8161dcc8>] ? ipv4_confirm+0xb8/0xe0
[84408.459787]  [<ffffffffa04aa261>] br_handle_frame+0x161/0x290 [bridge]
[84408.462803]  [<ffffffff815cbdb6>] ? ip_local_deliver+0x46/0xa0
[84408.465796]  [<ffffffff8158a2de>] __netif_receive_skb_core+0x32e/0x810
[84408.468822]  [<ffffffff8158a7d8>] __netif_receive_skb+0x18/0x60
[84408.471748]  [<ffffffff8158a843>] netif_receive_skb_internal+0x23/0x90
[84408.474615]  [<ffffffff815f6483>] ? tcp4_gro_complete+0x73/0x80
[84408.477378]  [<ffffffff8158a9bc>] napi_gro_complete+0x9c/0xe0
[84408.480045]  [<ffffffff8158b0a0>] dev_gro_receive+0x230/0x360
[84408.482675]  [<ffffffff8158b400>] napi_gro_receive+0x30/0x100
[84408.485240]  [<ffffffffa000e8d6>] rtl8169_poll+0x2c6/0x6b0 [r8169]
[84408.487766]  [<ffffffff8158ad4a>] net_rx_action+0x1fa/0x320
[84408.490241]  [<ffffffff81090a1b>] __do_softirq+0x10b/0x2d0
[84408.492672]  [<ffffffff81090db5>] irq_exit+0xd5/0xe0
[84408.495072]  [<ffffffff817452d8>] do_IRQ+0x58/0xf0
[84408.497463]  [<ffffffff8174356e>] common_interrupt+0x6e/0x6e
[84408.499879]  <EOI>
[84408.499909]  [<ffffffff8104c726>] ? native_safe_halt+0x6/0x10
[84408.504697]  [<ffffffff810f01be>] ? tick_broadcast_oneshot_control+0xbe/0x200
[84408.507126]  [<ffffffff8100e98e>] default_idle+0x1e/0xc0
[84408.509516]  [<ffffffff8100ea9e>] amd_e400_idle+0x6e/0xf0
[84408.511879]  [<ffffffff8100f51f>] arch_cpu_idle+0xf/0x20
[84408.514181]  [<ffffffff810c4c37>] cpu_startup_entry+0x327/0x3a0
[84408.516456]  [<ffffffff810eea3c>] ? clockevents_register_device+0xec/0x1d0
[84408.518760]  [<ffffffff8103ba08>] start_secondary+0x138/0x160
[84408.521066] Code: 48 89 d7 e8 2e f7 ff ff e9 a1 fe ff ff 48 89 d7
e8 51 f7 ff ff e9 94 fe ff ff 66 90 66 2e 0f 1f 84 00 00 00 00 00 66
66 66 66 90 <48> f7 07 00 c0 00 00 55 48 89 e5 75 1e 8b 47 1c 85 c0 74
27 f0
[84408.526216] RIP  [<ffffffff81166e15>] put_page+0x5/0x50
[84408.528705]  RSP <ffff88021fcc37c0>
[84408.531178] CR2: 0000000000000000

Looks like this happens because ip_options_fragment() relies on
correct ip options length in ip control block in skb. But in
ip_finish_output_gso() control block in segments is reused by
skb_gso_segment(). following ip_fragment() sees some garbage.

In my case there was no ip options but length becomes non-zero and
ip_options_fragment() picked some bytes from payload and decides to
fill huge range with IPOPT_NOOP (1). One of that ones flipped nr_frags
in skb_shared_info at the end of data =)

Here is quick hack: just make room for ip control block in gso control block.

--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3316,6 +3316,7 @@ static inline struct sec_path
*skb_sec_path(struct sk_buff *skb)
  * Keeps track of level of encapsulation of network headers.
  */
 struct skb_gso_cb {
+ char pad[32]; /* inet_skb_parm lives here */
  int mac_offset;
  int encap_level;
  __u16 csum_start;

And debug which prevents kernel crash too.

--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -215,6 +215,10 @@ void ip_options_fragment(struct sk_buff *skb)
  int  l = opt->optlen;
  int  optlen;

+ const struct iphdr *iph = ip_hdr(skb);
+ l = iph->ihl * 4 - sizeof(struct iphdr);
+ WARN(opt->optlen != l, "%s %d != %d\n", __func__, opt->optlen, l);
+
  while (l > 0) {
  switch (*optptr) {
  case IPOPT_END:
