From: Kozlov Dmitry <xeb@mail.ru>
Subject: [PATCH 0/1] l2tp: avoid to use synchronize_rcu in tunnel free function
Date: Fri, 24 Aug 2012 15:07:34 +0400
Message-ID: <2209419.JYrho4ME2S@dima>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: kleptog@svana.org, jchapman@katalix.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp20.mail.ru ([94.100.176.173]:59768 "EHLO smtp20.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753110Ab2HXLHm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2012 07:07:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid to use synchronize_rcu in l2tp_tunnel_free because context may be 
atomic.

This fixes following condition:
[   71.773006] BUG: scheduling while atomic: swapper/0/0/0x00000100
[   71.775593] Modules linked in: authenc rmd160 crypto_null l2tp_ppp 
l2tp_core pptp pppox gre camellia_generic cast6 cast5 deflate zlib_deflate cts 
ctr gcm ccm serpent_sse2_i586 lrw serpent_generic xts gf128mul 
blowfish_generic blowfish_common twofish_generic twofish_i586 twofish_common 
xcbc sha512_generic des_generic geode_aes xfrm_user ah4 esp4 xfrm4_mode_beet 
xfrm4_tunnel tunnel4 xfrm4_mode_tunnel xfrm4_mode_transport ipcomp xfrm_ipcomp 
tunnel6 af_key xfrm_algo coretemp kvm_intel kvm aesni_intel cryptd mgag200 ttm 
drm_kms_helper drm aes_i586 i2c_algo_bit sysimgblt sysfillrect syscopyarea 
dcdbas lpc_ich microcode mac_hid lp parport usb_storage uas hid_generic usbhid 
hid mpt2sas scsi_transport_sas raid_class bnx2
[   71.775627] Pid: 0, comm: swapper/0 Not tainted 3.5.0-11-generic #11-Ubuntu
[   71.775628] Call Trace:
[   71.775632]  [<c15bf650>] __schedule_bug+0x52/0x5e
[   71.775635]  [<c15c7ede>] __schedule+0x75e/0x770
[   71.775639]  [<c152e797>] ? udp_rcv+0x17/0x20
[   71.775642]  [<c1506179>] ? ip_local_deliver_finish+0xa9/0x260
[   71.775644]  [<c150647c>] ? ip_local_deliver+0x3c/0x80
[   71.775646]  [<c15c8193>] schedule+0x23/0x60
[   71.775647]  [<c15c69a5>] schedule_timeout+0x215/0x280
[   71.775650]  [<c12c80af>] ? cpumask_next_and+0x1f/0x40
[   71.775653]  [<c107c4ed>] ? update_sd_lb_stats+0xcd/0x4b0
[   71.775655]  [<c15c8011>] wait_for_common+0xa1/0x120
[   71.775657]  [<c1075f50>] ? try_to_wake_up+0x230/0x230
[   71.775661]  [<c10cbc50>] ? call_rcu_bh+0x20/0x20
[   71.775662]  [<c15c8167>] wait_for_completion+0x17/0x20
[   71.775665]  [<c10627b9>] wait_rcu_gp+0x39/0x40
[   71.775667]  [<c10627c0>] ? wait_rcu_gp+0x40/0x40
[   71.775669]  [<c10cad82>] synchronize_sched+0x32/0x40
[   71.775672]  [<f8c93a47>] l2tp_tunnel_free+0x87/0xd0 [l2tp_core]
[   71.775674]  [<f8c93c25>] l2tp_tunnel_destruct+0x195/0x210 [l2tp_core]
[   71.775676]  [<c14cb649>] __sk_free+0x19/0x120
[   71.775678]  [<c14cb782>] sock_wfree+0x32/0x60
[   71.775680]  [<c14ceed3>] skb_release_head_state+0x43/0xc0
[   71.775682]  [<c14cecd0>] __kfree_skb+0x10/0x90
[   71.775684]  [<c14cf11c>] consume_skb+0x2c/0x80
[   71.775689]  [<f848b951>] bnx2_poll_work+0x1f1/0x3b0 [bnx2]
[   71.775692]  [<f848bb39>] bnx2_poll_msix+0x29/0xa0 [bnx2]
[   71.775695]  [<c14daca5>] net_rx_action+0xf5/0x1d0
[   71.775698]  [<c104cac7>] __do_softirq+0x87/0x180
[   71.775700]  [<c104ca40>] ? local_bh_enable_ip+0x90/0x90
[   71.775701]  <IRQ>  [<c104ce15>] ? irq_exit+0x95/0xa0
[   71.775705]  [<c15d04db>] ? do_IRQ+0x4b/0xc0
[   71.775707]  [<c15d0330>] ? common_interrupt+0x30/0x38
[   71.775710]  [<c10400e0>] ? virt_efi_get_variable+0x10/0x40
[   71.775712]  [<c1326c43>] ? intel_idle+0xc3/0x120
