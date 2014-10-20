From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v4 13/25] virtio_console: enable VQs early
Date: Mon, 20 Oct 2014 13:07:50 +0100
Message-ID: <20141020120750.GA18561@casper.infradead.org>
References: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
 <1413114332-626-14-git-send-email-mst-v4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	linux-scsi@vger.kernel.org, linux-s390@vger.kernel.org,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	kvm@vger.kernel.org, Amit Shah <amit.shah@redhat.com>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1413114332-626-14-git-send-email-mst-v4@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/13/14 at 10:50am, Michael S. Tsirkin wrote:
> virtio spec requires drivers to set DRIVER_OK before using VQs.
> This is set automatically after probe returns, virtio console violated this
> rule by adding inbufs, which causes the VQ to be used directly within
> probe.
> 
> To fix, call virtio_device_ready before using VQs.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/char/virtio_console.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/char/virtio_console.c b/drivers/char/virtio_console.c
> index b585b47..6ebe8f6 100644
> --- a/drivers/char/virtio_console.c
> +++ b/drivers/char/virtio_console.c
> @@ -1449,6 +1449,8 @@ static int add_port(struct ports_device *portdev, u32 id)
>  	spin_lock_init(&port->outvq_lock);
>  	init_waitqueue_head(&port->waitqueue);
>  
> +	virtio_device_ready(portdev->vdev);
> +
>  	/* Fill the in_vq with buffers so the host can send us data. */
>  	nr_added_bufs = fill_queue(port->in_vq, &port->inbuf_lock);
>  	if (!nr_added_bufs) {

Seems like probe and add_port() now both set VIRTIO_CONFIG_S_DRIVER_OK

    1.839658] kernel BUG at include/linux/virtio_config.h:125!
[    1.839995] invalid opcode: 0000 [#1] SMP 
[    1.840169] Modules linked in: serio_raw virtio_balloon pcspkr virtio_net virtio_console soundcore parport_pc floppy pvpanic parport i2c_piix4 nfsd auth_rpcgss nfs_acl lockd grace sunrpc qxl drm_kms_helper ttm drm virtio_blk i2c_core virtio_pci ata_generic virtio_ring virtio pata_acpi
[    1.840169] CPU: 2 PID: 266 Comm: kworker/2:2 Not tainted 3.17.0+ #1
[    1.840169] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    1.840169] Workqueue: events control_work_handler [virtio_console]
[    1.840169] task: ffff8800364bc840 ti: ffff880078490000 task.ti: ffff880078490000
[    1.840169] RIP: 0010:[<ffffffffa01d92c6>]  [<ffffffffa01d92c6>] virtio_device_ready.part.12+0x4/0x6 [virtio_console]
[    1.840169] RSP: 0018:ffff880078493c78  EFLAGS: 00010202
[    1.840169] RAX: 0000000000000007 RBX: ffff880036406200 RCX: 0000000000006e39
[    1.840169] RDX: 000000000000c0b2 RSI: 0000000000000000 RDI: 000000000001c0b2
[    1.840169] RBP: ffff880078493c78 R08: ffffffff81d2c6f8 R09: 0000000000000000
[    1.840169] R10: 0000000000000001 R11: ffff8800364bd000 R12: ffff880036618400
[    1.840169] R13: 0000000000000001 R14: ffff8800368c6800 R15: ffff880036406220
[    1.840169] FS:  0000000000000000(0000) GS:ffff88007fd00000(0000) knlGS:0000000000000000
[    1.840169] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    1.840169] CR2: 00007f1c31c90000 CR3: 0000000001c14000 CR4: 00000000000006e0
[    1.840169] Stack:
[    1.840169]  ffff880078493ce8 ffffffffa01d886a ffff880000000001 ffffffff810e20cd
[    1.840169]  ffff880078493cb8 0000000000000282 0000000000000000 0000000087f90194
[    1.840169]  ffff880078493ce8 ffff88007ab1d4e0 ffff880036618498 ffff880036618410
[    1.840169] Call Trace:
[    1.840169]  [<ffffffffa01d886a>] add_port+0x40a/0x440 [virtio_console]
[    1.840169]  [<ffffffff810e20cd>] ? trace_hardirqs_on+0xd/0x10
[    1.840169]  [<ffffffffa01d8c6a>] control_work_handler+0x3ca/0x420 [virtio_console]
[    1.840169]  [<ffffffff810b0e7b>] ? process_one_work+0x15b/0x530
[    1.840169]  [<ffffffff810b0ef4>] process_one_work+0x1d4/0x530
[    1.840169]  [<ffffffff810b0e7b>] ? process_one_work+0x15b/0x530
[    1.840169]  [<ffffffff810b136b>] worker_thread+0x11b/0x490
[    1.840169]  [<ffffffff810b1250>] ? process_one_work+0x530/0x530
[    1.840169]  [<ffffffff810b67c3>] kthread+0xf3/0x110
[    1.840169]  [<ffffffff81788f00>] ? _raw_spin_unlock_irq+0x30/0x50
[    1.840169]  [<ffffffff810b66d0>] ? kthread_create_on_node+0x240/0x240
[    1.840169]  [<ffffffff81789a7c>] ret_from_fork+0x7c/0xb0
[    1.840169]  [<ffffffff810b66d0>] ? kthread_create_on_node+0x240/0x240
[    1.840169] Code: ff 49 89 c4 4d 85 e4 0f 8f 25 ff ff ff eb ad 48 c7 c0 f4 ff ff ff e9 17 ff ff ff e8 f5 cd eb e0 90 55 48 89 e5 0f 0b 55 48 89 e5 <0f> 0b 55 48 89 e5 0f 0b 55 48 89 e5 e8 99 e2 ff ff 48 c7 c7 c0 
[    1.840169] RIP  [<ffffffffa01d92c6>] virtio_device_ready.part.12+0x4/0x6 [virtio_console]
[    1.840169]  RSP <ffff880078493c78>
