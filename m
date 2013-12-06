From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 1/2] virtio-net: determine type of bufs correctly
Date: Fri, 06 Dec 2013 11:20:02 +0800
Message-ID: <52A14262.6080407@redhat.com>
References: <1386254181-17257-1-git-send-email-avagin@openvz.org>
	<1386254181-17257-2-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	linux-kernel@vger.kernel.org, Michael Dalton <mwdalton@google.com>
To: Andrey Vagin <avagin@openvz.org>, virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1386254181-17257-2-git-send-email-avagin@openvz.org>
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

On 12/05/2013 10:36 PM, Andrey Vagin wrote:
> free_unused_bufs must check vi->mergeable_rx_bufs before
> vi->big_packets, because we use this sequence in other places.
> Otherwise we allocate buffer of one type, then free it as another
> type.
>
> general protection fault: 0000 [#1] SMP
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables pcspkr virtio_balloon virtio_net(-) i2c_pii
> CPU: 0 PID: 400 Comm: rmmod Not tainted 3.13.0-rc2+ #170
> Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> task: ffff8800b6d2a210 ti: ffff8800aed32000 task.ti: ffff8800aed32000
> RIP: 0010:[<ffffffffa00345f3>]  [<ffffffffa00345f3>] free_unused_bufs+0xc3/0x190 [virtio_net]
> RSP: 0018:ffff8800aed33dd8  EFLAGS: 00010202
> RAX: ffff8800b1fe2c00 RBX: ffff8800b66a7240 RCX: 6b6b6b6b6b6b6b6b
> RDX: 6b6b6b6b6b6b6b6b RSI: ffff8800b8419a68 RDI: ffff8800b66a1148
> RBP: ffff8800aed33e00 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000000
> R13: ffff8800b66a1148 R14: 0000000000000000 R15: 000077ff80000000
> FS:  00007fc4f9c4e740(0000) GS:ffff8800bfa00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007f63f432f000 CR3: 00000000b6538000 CR4: 00000000000006f0
> Stack:
>  ffff8800b66a7240 ffff8800b66a7380 ffff8800377bd3f0 0000000000000000
>  00000000023302f0 ffff8800aed33e18 ffffffffa00346e2 ffff8800b66a7240
>  ffff8800aed33e38 ffffffffa003474d ffff8800377bd388 ffff8800377bd390
> Call Trace:
>  [<ffffffffa00346e2>] remove_vq_common+0x22/0x40 [virtio_net]
>  [<ffffffffa003474d>] virtnet_remove+0x4d/0x90 [virtio_net]
>  [<ffffffff813ae303>] virtio_dev_remove+0x23/0x80
>  [<ffffffff813f62cf>] __device_release_driver+0x7f/0xf0
>  [<ffffffff813f6c80>] driver_detach+0xc0/0xd0
>  [<ffffffff813f5f08>] bus_remove_driver+0x58/0xd0
>  [<ffffffff813f72cc>] driver_unregister+0x2c/0x50
>  [<ffffffff813ae63e>] unregister_virtio_driver+0xe/0x10
>  [<ffffffffa0036852>] virtio_net_driver_exit+0x10/0x7be [virtio_net]
>  [<ffffffff810d7cf2>] SyS_delete_module+0x172/0x220
>  [<ffffffff810a732d>] ? trace_hardirqs_on+0xd/0x10
>  [<ffffffff810f5d4c>] ? __audit_syscall_entry+0x9c/0xf0
>  [<ffffffff81677f69>] system_call_fastpath+0x16/0x1b
> Code: c0 74 55 0f 1f 44 00 00 80 7b 30 00 74 7a 48 8b 50 30 4c 89 e6 48 03 73 20 48 85 d2 0f 84 bb 00 00 00 66 0f
> RIP  [<ffffffffa00345f3>] free_unused_bufs+0xc3/0x190 [virtio_net]
>  RSP <ffff8800aed33dd8>
> ---[ end trace edb570ea923cce9c ]---
>
> Fixes: 2613af0ed18a (virtio_net: migrate mergeable rx buffers to page frag allocators)
> Cc: Michael Dalton <mwdalton@google.com>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>
> ---
>  drivers/net/virtio_net.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 916241d..930039a 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1396,10 +1396,10 @@ static void free_unused_bufs(struct virtnet_info *vi)
>  		struct virtqueue *vq = vi->rq[i].vq;
>  
>  		while ((buf = virtqueue_detach_unused_buf(vq)) != NULL) {
> -			if (vi->big_packets)
> -				give_pages(&vi->rq[i], buf);
> -			else if (vi->mergeable_rx_bufs)
> +			if (vi->mergeable_rx_bufs)
>  				put_page(virt_to_head_page(buf));
> +			else if (vi->big_packets)
> +				give_pages(&vi->rq[i], buf);
>  			else
>  				dev_kfree_skb(buf);
>  			--vi->rq[i].num;

Acked-by: Jason Wang <jasowang@redhat.com>
