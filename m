From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: xfrm: warning on negative dst refcount
Date: Fri, 4 Jun 2010 12:40:12 +0200
Message-ID: <20100604104012.GA13408@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51014 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753915Ab0FDKkr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jun 2010 06:40:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I see the warning below frequently when I'm running iperf on a IPsec
connection. It seems that dst_pop() drops a refcount on a noref
dst_entry. I was able to fix this by changing dst_pop() to a new
function skb_dst_pop() which uses skb_dst_drop(skb) instead of
dst_release(dst) to drop the reference if necessary. I'll send the
patch that fixed the issue for me in repy to this mail.
I don't know that much about the noref work, so I'm not sure whether
this is the right fix, but I got rid of the warning at least.

Steffen

Jun  4 10:21:24 mainline kernel: [ 1334.203913] WARNING: at /home/secunet/git/linux-sinafe-2.6/net/core/dst.c:276 xfrm_output_resume+0x2d3/0x35e()
Jun  4 10:21:24 mainline kernel: [ 1334.203915] Hardware name:         
Jun  4 10:21:24 mainline kernel: [ 1334.203916] Modules linked in: authenc esp4 xfrm4_mode_tunnel aes_x86_64 aes_generic cbc sha1_generic xfrm_user ipv6 acpi_cpufreq mperf cpufreq_userspace cpufreq_stats cpufreq_ondemand freq_table cpufreq_conservative cpufreq_powersave container fan video output sbs sbshc battery af_packet ac fuse loop option usb_wwan usbserial sr_mod cdrom iTCO_wdt ehci_hcd thermal uhci_hcd serio_raw psmouse tpm_tis tpm tpm_bios iTCO_vendor_support pcspkr processor thermal_sys evdev usbcore button ata_generic
Jun  4 10:21:24 mainline kernel: [ 1334.203944] Pid: 3337, comm: dd Tainted: G        W   2.6.35-rc1+ #276
Jun  4 10:21:24 mainline kernel: [ 1334.203946] Call Trace:
Jun  4 10:21:24 mainline kernel: [ 1334.203947]  <IRQ>  [<ffffffff81261fbb>] ? xfrm_output_resume+0x2d3/0x35e
Jun  4 10:21:24 mainline kernel: [ 1334.203952]  [<ffffffff81261fbb>] ? xfrm_output_resume+0x2d3/0x35e
Jun  4 10:21:24 mainline kernel: [ 1334.203955]  [<ffffffff8102700d>] ? warn_slowpath_common+0x78/0x8d
Jun  4 10:21:24 mainline kernel: [ 1334.203958]  [<ffffffff81261fbb>] ? xfrm_output_resume+0x2d3/0x35e
Jun  4 10:21:24 mainline kernel: [ 1334.203961]  [<ffffffff8122bbe0>] ? ip_queue_xmit+0x2bc/0x304
Jun  4 10:21:24 mainline kernel: [ 1334.203964]  [<ffffffff8123b2db>] ? tcp_transmit_skb+0x6d2/0x701
Jun  4 10:21:24 mainline kernel: [ 1334.203967]  [<ffffffff81233df9>] ? tcp_cong_avoid+0xe/0x1d
Jun  4 10:21:24 mainline kernel: [ 1334.203970]  [<ffffffff81235bdf>] ? tcp_fin+0x74/0x17c
Jun  4 10:21:24 mainline kernel: [ 1334.203972]  [<ffffffff81236796>] ? tcp_data_queue+0x2fc/0xb64
Jun  4 10:21:24 mainline kernel: [ 1334.203975]  [<ffffffff81239d61>] ? tcp_rcv_state_process+0x927/0x99b
Jun  4 10:21:24 mainline kernel: [ 1334.203978]  [<ffffffff8123f563>] ? tcp_v4_do_rcv+0x18b/0x1d0
Jun  4 10:21:24 mainline kernel: [ 1334.203981]  [<ffffffff81241160>] ? tcp_v4_rcv+0x485/0x721
Jun  4 10:21:24 mainline kernel: [ 1334.203985]  [<ffffffff81227154>] ? ip_local_deliver+0xda/0x165
Jun  4 10:21:24 mainline kernel: [ 1334.203988]  [<ffffffff812276f4>] ? ip_rcv+0x515/0x53d
Jun  4 10:21:24 mainline kernel: [ 1334.203991]  [<ffffffff81209192>] ? process_backlog+0x99/0x174
Jun  4 10:21:24 mainline kernel: [ 1334.203994]  [<ffffffff81208e41>] ? net_rx_action+0xab/0x153
Jun  4 10:21:24 mainline kernel: [ 1334.203997]  [<ffffffff8102b8f5>] ? __do_softirq+0x8d/0x107
Jun  4 10:21:24 mainline kernel: [ 1334.204000]  [<ffffffff81002aec>] ? call_softirq+0x1c/0x28
Jun  4 10:21:24 mainline kernel: [ 1334.204003]  [<ffffffff810043a5>] ? do_softirq+0x31/0x64
Jun  4 10:21:24 mainline kernel: [ 1334.204005]  [<ffffffff8102b826>] ? irq_exit+0x36/0x78
Jun  4 10:21:24 mainline kernel: [ 1334.204008]  [<ffffffff81003c4f>] ? do_IRQ+0xa7/0xbd
Jun  4 10:21:24 mainline kernel: [ 1334.204011]  [<ffffffff8127dad3>] ? ret_from_intr+0x0/0xa
Jun  4 10:21:24 mainline kernel: [ 1334.204012]  <EOI>  [<ffffffff8127d810>] ? _raw_spin_unlock_irqrestore+0x4/0x5
Jun  4 10:21:24 mainline kernel: [ 1334.204018]  [<ffffffff8108e618>] ? pipe_write+0x413/0x447
Jun  4 10:21:24 mainline kernel: [ 1334.204021]  [<ffffffff81087aab>] ? do_sync_write+0xb3/0xf7
Jun  4 10:21:24 mainline kernel: [ 1334.204024]  [<ffffffff810c7007>] ? kmsg_read+0x44/0x4e
Jun  4 10:21:24 mainline kernel: [ 1334.204027]  [<ffffffff8127c26c>] ? schedule+0x525/0x5db
Jun  4 10:21:24 mainline kernel: [ 1334.204030]  [<ffffffff81088120>] ? vfs_write+0xad/0x149
Jun  4 10:21:24 mainline kernel: [ 1334.204033]  [<ffffffff81088669>] ? sys_write+0x45/0x6e
Jun  4 10:21:24 mainline kernel: [ 1334.204035]  [<ffffffff81001ceb>] ? system_call_fastpath+0x16/0x1b
Jun  4 10:21:24 mainline kernel: [ 1334.204037] ---[ end trace ab41f96596a62e77 ]---

