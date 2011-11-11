From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [RFC] [ver3 PATCH 0/6] Implement multiqueue virtio-net
Date: Sat, 12 Nov 2011 00:02:04 +0200
Message-ID: <1321048924.1952.3.camel@lappy>
References: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi,

I'm seeing this BUG() sometimes when running it using a small patch I
did for KVM tool:

[    1.280766] BUG: unable to handle kernel NULL pointer dereference at
0000000000000010
[    1.281531] IP: [<ffffffff810b3ac7>] free_percpu+0x9a/0x104
[    1.281531] PGD 0 
[    1.281531] Oops: 0000 [#1] PREEMPT SMP 
[    1.281531] CPU 0 
[    1.281531] Pid: 1, comm: swapper Not tainted
3.1.0-sasha-19665-gef3d2b7 #39  
[    1.281531] RIP: 0010:[<ffffffff810b3ac7>]  [<ffffffff810b3ac7>]
free_percpu+0x9a/0x104
[    1.281531] RSP: 0018:ffff88001383fd50  EFLAGS: 00010046
[    1.281531] RAX: 0000000000000000 RBX: 0000000000000282 RCX:
00000000000f4400
[    1.281531] RDX: 00003ffffffff000 RSI: ffff880000000240 RDI:
0000000001c06063
[    1.281531] RBP: ffff880013fcb7c0 R08: ffffea00004e30c0 R09:
ffffffff8138ba64
[    1.281531] R10: 0000000000001880 R11: 0000000000001880 R12:
ffff881213c00000
[    1.281531] R13: ffff8800138c0e00 R14: 0000000000000010 R15:
ffff8800138c0d00
[    1.281531] FS:  0000000000000000(0000) GS:ffff880013c00000(0000)
knlGS:0000000000000000
[    1.281531] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    1.281531] CR2: 0000000000000010 CR3: 0000000001c05000 CR4:
00000000000406f0
[    1.281531] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[    1.281531] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[    1.281531] Process swapper (pid: 1, threadinfo ffff88001383e000,
task ffff880013848000)
[    1.281531] Stack:
[    1.281531]  ffff880013846ec0 0000000000000000 0000000000000000
ffffffff8138a0e5
[    1.281531]  ffff880013846ec0 ffff880013846800 ffff880013b6c000
ffffffff8138bb63
[    1.281531]  0000000000000011 000000000000000f ffff8800fffffff0
0000000181239bcd
[    1.281531] Call Trace:
[    1.281531]  [<ffffffff8138a0e5>] ? free_rq_sq+0x2c/0xce
[    1.281531]  [<ffffffff8138bb63>] ? virtnet_probe+0x81c/0x855
[    1.281531]  [<ffffffff8129c9e7>] ? virtio_dev_probe+0xa7/0xc6
[    1.281531]  [<ffffffff8134d2c3>] ? driver_probe_device+0xb2/0x142
[    1.281531]  [<ffffffff8134d3a2>] ? __driver_attach+0x4f/0x6f
[    1.281531]  [<ffffffff8134d353>] ? driver_probe_device+0x142/0x142
[    1.281531]  [<ffffffff8134c3ab>] ? bus_for_each_dev+0x47/0x72
[    1.281531]  [<ffffffff8134c90d>] ? bus_add_driver+0xa2/0x1e6
[    1.281531]  [<ffffffff81cc1b36>] ? tun_init+0x89/0x89
[    1.281531]  [<ffffffff8134db59>] ? driver_register+0x8d/0xf8
[    1.281531]  [<ffffffff81cc1b36>] ? tun_init+0x89/0x89
[    1.281531]  [<ffffffff81c98ac1>] ? do_one_initcall+0x78/0x130
[    1.281531]  [<ffffffff81c98c0e>] ? kernel_init+0x95/0x113
[    1.281531]  [<ffffffff81658274>] ? kernel_thread_helper+0x4/0x10
[    1.281531]  [<ffffffff81c98b79>] ? do_one_initcall+0x130/0x130
[    1.281531]  [<ffffffff81658270>] ? gs_change+0x13/0x13
[    1.281531] Code: c2 85 d2 48 0f 45 2d d1 39 ce 00 eb 22 65 8b 14 25
90 cc 00 00 48 8b 05 f0 a6 bc 00 48 63 d2 4c 89 e7 48 03 3c d0 e8 83 dd
00 00 
[    1.281531]  8b 68 10 44 89 e6 48 89 ef 2b 75 18 e8 e4 f1 ff ff 8b 05
fd 
[    1.281531] RIP  [<ffffffff810b3ac7>] free_percpu+0x9a/0x104
[    1.281531]  RSP <ffff88001383fd50>
[    1.281531] CR2: 0000000000000010
[    1.281531] ---[ end trace 68cbc23dfe2fe62a ]---

I don't have time today to dig into it, sorry.

On Fri, 2011-11-11 at 18:32 +0530, Krishna Kumar wrote:
> This patch series resurrects the earlier multiple TX/RX queues
> functionality for virtio_net, and addresses the issues pointed
> out.  It also includes an API to share irq's, f.e.  amongst the
> TX vqs. 
> 
> I plan to run TCP/UDP STREAM and RR tests for local->host and
> local->remote, and send the results in the next couple of days.
> 
> 
> patch #1: Introduce VIRTIO_NET_F_MULTIQUEUE
> patch #2: Move 'num_queues' to virtqueue
> patch #3: virtio_net driver changes
> patch #4: vhost_net changes
> patch #5: Implement find_vqs_irq()
> patch #6: Convert virtio_net driver to use find_vqs_irq()
> 
> 
> 		Changes from rev2:
> Michael:
> -------
> 1. Added functions to handle setting RX/TX/CTRL vq's.
> 2. num_queue_pairs instead of numtxqs.
> 3. Experimental support for fewer irq's in find_vqs.
> 
> Rusty:
> ------
> 4. Cleaned up some existing "while (1)".
> 5. rvq/svq and rx_sg/tx_sg changed to vq and sg respectively.
> 6. Cleaned up some "#if 1" code.
> 
> 
> Issue when using patch5:
> -------------------------
> 
> The new API is designed to minimize code duplication.  E.g.
> vp_find_vqs() is implemented as:
> 
> static int vp_find_vqs(...)
> {
> 	return vp_find_vqs_irq(vdev, nvqs, vqs, callbacks, names, NULL);
> }
> 
> In my testing, when multiple tx/rx is used with multiple netperf
> sessions, all the device tx queues stops a few thousand times and
> subsequently woken up by skb_xmit_done.  But after some 40K-50K
> iterations of stop/wake, some of the txq's stop and no wake
> interrupt comes. (modprobe -r followed by modprobe solves this, so
> it is not a system hang).  At the time of the hang (#txqs=#rxqs=4):
> 
> # egrep "CPU|virtio0" /proc/interrupts | grep -v config
>        CPU0     CPU1     CPU2    CPU3
> 41:    49057    49262    48828   49421  PCI-MSI-edge    virtio0-input.0
> 42:    5066     5213     5221    5109   PCI-MSI-edge    virtio0-output.0
> 43:    43380    43770    43007   43148  PCI-MSI-edge    virtio0-input.1
> 44:    41433    41727    42101   41175  PCI-MSI-edge    virtio0-input.2
> 45:    38465    37629    38468   38768  PCI-MSI-edge    virtio0-input.3
> 
> # tc -s qdisc show dev eth0
> qdisc mq 0: root      
> 	Sent 393196939897 bytes 271191624 pkt (dropped 59897,
> 	overlimits 0 requeues 67156) backlog 25375720b 1601p
> 	requeues 67156  
> 
> I am not sure if patch #5 is responsible for the hang.  Also, without
> patch #5/patch #6, I changed vp_find_vqs() to:
> static int vp_find_vqs(...)
> {
> 	return vp_try_to_find_vqs(vdev, nvqs, vqs, callbacks, names,
> 				  false, false);
> }
> No packets were getting TX'd with this change when #txqs>1.  This is
> with the MQ-only patch that doesn't touch drivers/virtio/ directory.
> 
> Also, the MQ patch works reasonably well with 2 vectors - with
> use_msix=1 and per_vq_vectors=0 in vp_find_vqs().
> 
> Patch against net-next - please review.
> 
> Signed-off-by: krkumar2@in.ibm.com
> ---
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 

Sasha.
