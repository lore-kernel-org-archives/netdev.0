From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v4 10/25] virtio: add API to enable VQs early
Date: Tue, 11 Nov 2014 08:15:29 +0200
Message-ID: <20141111061529.GA17897@redhat.com>
References: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
	<1413114332-626-11-git-send-email-mst-v4@redhat.com>
	<54615C15.6060400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-s390@vger.kernel.org, kvm@vger.kernel.org, linux-scsi@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>, Amit Shah <amit.shah@redhat.com>,
	v9fs-developer@lists.sourceforge.net,
	"David S. Miller" <davem@davemloft.net>
To: Andy Grover <agrover@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <54615C15.6060400@redhat.com>
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

On Mon, Nov 10, 2014 at 04:45:09PM -0800, Andy Grover wrote:
> On 10/13/2014 12:50 AM, Michael S. Tsirkin wrote:
> >virtio spec 0.9.X requires DRIVER_OK to be set before
> >VQs are used, but some drivers use VQs before probe
> >function returns.
> >Since DRIVER_OK is set after probe, this violates the spec.
> >
> >Even though under virtio 1.0 transitional devices support this
> >behaviour, we want to make it possible for those early callers to become
> >spec compliant and eventually support non-transitional devices.
> >
> >Add API for drivers to call before using VQs.
> >
> >Sets DRIVER_OK internally.
> >
> >Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> >Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
> >---
> >  include/linux/virtio_config.h | 17 +++++++++++++++++
> >  1 file changed, 17 insertions(+)
> >
> >diff --git a/include/linux/virtio_config.h b/include/linux/virtio_config.h
> >index e8f8f71..e36403b 100644
> >--- a/include/linux/virtio_config.h
> >+++ b/include/linux/virtio_config.h
> >@@ -109,6 +109,23 @@ struct virtqueue *virtio_find_single_vq(struct virtio_device *vdev,
> >  	return vq;
> >  }
> >
> >+/**
> >+ * virtio_device_ready - enable vq use in probe function
> >+ * @vdev: the device
> >+ *
> >+ * Driver must call this to use vqs in the probe function.
> >+ *
> >+ * Note: vqs are enabled automatically after probe returns.
> >+ */
> >+static inline
> >+void virtio_device_ready(struct virtio_device *dev)
> >+{
> >+	unsigned status = dev->config->get_status(dev);
> >+
> >+	BUG_ON(status & VIRTIO_CONFIG_S_DRIVER_OK);
> >+	dev->config->set_status(dev, status | VIRTIO_CONFIG_S_DRIVER_OK);
> >+}
> 
> Getting a BUG when booting via KVM, host Fedora 20, guest Fedora 20.
> 
> my config is at:
> 
> https://fedorapeople.org/~grover/config-20141110
> 

The fix is here:
http://article.gmane.org/gmane.linux.kernel.virtualization/23324/raw

I'm surprised it's not merged yet.

Rusty, could you pick it up please?


> 
> [    0.828494] ------------[ cut here ]------------
> [    0.829039] kernel BUG at
> /home/agrover/git/kernel/include/linux/virtio_config.h:125!
> [    0.831266] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
> [    0.831266] Modules linked in:
> [    0.831266] CPU: 1 PID: 30 Comm: kworker/1:1 Not tainted 3.18.0-rc4 #120
> [    0.831266] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [    0.831266] Workqueue: events control_work_handler
> [    0.831266] task: ffff88003cd98000 ti: ffff88003cd94000 task.ti:
> ffff88003cd94000
> [    0.831266] RIP: 0010:[<ffffffff81445004>]  [<ffffffff81445004>]
> add_port+0x264/0x410
> [    0.831266] RSP: 0000:ffff88003cd97c78  EFLAGS: 00010202
> [    0.831266] RAX: 0000000000000007 RBX: ffff88003c58c400 RCX:
> 0000000000000001
> [    0.831266] RDX: 000000000000c132 RSI: ffffffff81a955e9 RDI:
> 000000000001c132
> [    0.831266] RBP: ffff88003cd97cc8 R08: 0000000000000000 R09:
> 0000000000000000
> [    0.831266] R10: 0000000000000001 R11: 0000000000000000 R12:
> ffff88003c58be00
> [    0.831266] R13: 0000000000000001 R14: ffff8800395ca800 R15:
> ffff88003c58c420
> [    0.831266] FS:  0000000000000000(0000) GS:ffff88003fa00000(0000)
> knlGS:0000000000000000
> [    0.831266] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [    0.831266] CR2: 0000000000000000 CR3: 0000000001c11000 CR4:
> 00000000000006e0
> [    0.831266] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [    0.831266] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:
> 0000000000000400
> [    0.831266] Stack:
> [    0.831266]  ffff880000000001 0000000000000292 0000000000000000
> 0000000000000001
> [    0.831266]  ffff88003cd97cc8 ffff88003dfa8a20 ffff88003c58beb8
> ffff88003c58be10
> [    0.831266]  ffff8800395a2000 0000000000000000 ffff88003cd97d38
> ffffffff8144531a
> [    0.831266] Call Trace:
> [    0.831266]  [<ffffffff8144531a>] control_work_handler+0x16a/0x3c0
> [    0.831266]  [<ffffffff8108b0c8>] ? process_one_work+0x208/0x500
> [    0.831266]  [<ffffffff8108b16c>] process_one_work+0x2ac/0x500
> [    0.831266]  [<ffffffff8108b0c8>] ? process_one_work+0x208/0x500
> [    0.831266]  [<ffffffff8108b68e>] worker_thread+0x2ce/0x4e0
> [    0.831266]  [<ffffffff8108b3c0>] ? process_one_work+0x500/0x500
> [    0.831266]  [<ffffffff81090b28>] kthread+0xf8/0x100
> [    0.831266]  [<ffffffff810bad7d>] ? trace_hardirqs_on+0xd/0x10
> [    0.831266]  [<ffffffff81090a30>] ? kthread_stop+0x140/0x140
> [    0.831266]  [<ffffffff816ea92c>] ret_from_fork+0x7c/0xb0
> [    0.831266]  [<ffffffff81090a30>] ? kthread_stop+0x140/0x140
> [    0.831266] Code: c7 c2 48 31 01 83 48 c7 c6 e9 55 a9 81 e8 55 b4 c6 ff
> 4d 8b b4 24 58 01 00 00 49 8b 86 e8 04 00 00 4c 89 f7 ff 50 10 a8 04 74 0c
> <0f> 0b 66 2e 0f 1f 84 00 00 00 00 00 49 8b 96 e8 04 00 00 83 c8
> [    0.831266] RIP  [<ffffffff81445004>] add_port+0x264/0x410
> [    0.831266]  RSP <ffff88003cd97c78>
> [    0.878202] ---[ end trace f98fbb172cc7bbf4 ]---
> 
> Thanks -- Andy
