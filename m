From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] virtio_net: fix virtnet_open and virtnet_probe competing
 for try_fill_recv
Date: Thu, 26 May 2016 09:40:37 +0800
Message-ID: <57465415.3020801@redhat.com>
References: <57459BB0.2000108@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: wangyunjian <wangyunjian@huawei.com>, davem@davemloft.net,
	netdev@vger.kernel.org, mst@redhat.com, liuyongan@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52754 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752275AbcEZBko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 May 2016 21:40:44 -0400
In-Reply-To: <57459BB0.2000108@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016=E5=B9=B405=E6=9C=8825=E6=97=A5 20:33, wangyunjian wrote:
> In function virtnet_open() and virtnet_probe(), func try_fill_recv() =
will be executed at the same time. VQ in virtqueue_add() is not protect=
ed well and BUG_ON will be triggered when virito_net.ko being removed.
>
> Test Script:
> for (( i=3D0; i<5000000; i=3Di+1 )); do
> 	rmmod virtio_net
> 	modprobe virtio_net
> 	ifconfig eth0 up
> done
>
> [  302.336996] ------------[ cut here ]------------
> [  302.338794] kernel BUG at virtio_ring.c:750!
> [  302.340013] invalid opcode: 0000 [#1] SMP
> [  302.340013] last sysfs file: /sys/devices/pci0000:00/0000:00:03.0/=
virtio0/device
> [  302.340013] CPU 0
> [  302.340013] Modules linked in: virtio_balloon virtio_net(-) virtio=
_pci virtio_ring virtio ipv6 af_packet microcode acpiphp pci_hotplug fu=
se loop dm_mod rtc_cmos tpm_tis rtc_core tpm i2c_piix4 rtc_lib containe=
r button floppy pcspkr tpm_bios i2c_core joydev sg usbhid hid uhci_hcd =
ehci_hcd usbcore edd ext3 mbcache jbd fan processor ide_pci_generic pii=
x ide_core ata_generic at a_piix libata thermal thermal_sys hwmon sd_mo=
d crc_t10dif kvm_ivshmem(N) scsi_mod pv_channel(N) [last unloaded: virt=
io]
> [  302.340013] Supported: Yes
> [  302.340013] Pid: 8410, comm: rmmod Tainted: GN  2.6.32.12-0.7-defa=
ult #1 Standard PC (i440FX + PIIX, 1996)
> [  302.340013] RIP: 0010:[<ffffffffa0323419>]  [<ffffffffa0323419>] v=
irtqueue_detach_unused_buf+0xb9/0xc0 [virtio_ring]
> [  302.340013] RSP: 0018:ffff88000c7a9e08  EFLAGS: 00010283
> [  302.340013] RAX: 00000000000000f4 RBX: 0000000000000100 RCX: 00000=
00000004d8e
> [  302.340013] RDX: ffff880001e00000 RSI: 0000000000000046 RDI: fffff=
fff81a71570
> [  302.340013] RBP: ffff88000c987000 R08: 0000000000000000 R09: 00000=
0000000000a
> [  302.340013] R10: 0000000000000000 R11: 0000000000000000 R12: 00000=
00000000400
> [  302.340013] R13: 0000000000000000 R14: 00007fff92bc1758 R15: 00000=
00000000001
> [  302.340013] FS:  00007f8b3995d700(0000) GS:ffff880001e00000(0000) =
knlGS:0000000000000000
> [  302.340013] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  302.340013] CR2: 00007fff196433e0 CR3: 000000000d07e000 CR4: 00000=
000000006f0
> [  302.340013] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000=
00000000000
> [  302.340013] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000=
00000000400
> [  302.340013] Process rmmod (pid: 8410, threadinfo ffff88000c7a8000,=
 task ffff88000c7aa200)
> [  302.340013] Stack:
> [  302.340013]  ffff88000fbb3780 0000000000000000 ffff88000c987000 ff=
ffffffa034b178
> [  302.340013] <0> ffff88000fbb3850 ffff88000fbb3780 ffffffffa034efc0=
 ffff88000fbb3850
> [  302.340013] <0> 0000000000000000 ffffffffa034b299 ffff88000fbb3780=
 ffffffffa034b406
> [  302.340013] Call Trace:
> [  302.340013]  [<ffffffffa034b178>] free_unused_bufs+0x88/0x120 [vir=
tio_net]
> [  302.340013]  [<ffffffffa034b299>] remove_vq_common+0x19/0x30 [virt=
io_net]
> [  302.340013]  [<ffffffffa034b406>] virtnet_remove+0x46/0x80 [virtio=
_net]
> [  302.340013]  [<ffffffffa0219245>] virtio_dev_remove+0x15/0x60 [vir=
tio]
> [  302.340013]  [<ffffffff81294551>] __device_release_driver+0x91/0x1=
10
> [  302.340013]  [<ffffffff81294678>] driver_detach+0xa8/0xb0
> [  302.340013]  [<ffffffff81293562>] bus_remove_driver+0x82/0x110
> [  302.340013]  [<ffffffff8107aea4>] sys_delete_module+0x1c4/0x290
> [  302.340013]  [<ffffffff81002f7b>] system_call_fastpath+0x16/0x1b
> [  302.340013]  [<00007f8b394c7de7>] 0x7f8b394c7de7
> [  302.340013] Code: c3 01 49 83 c4 04 e8 30 10 07 e1 8b 55 38 39 da =
77 d0 8b 75 2c 31 c0 48 c7 c7 ba 4b 32 a0 e8 18 10 07 e1 8b 45 2c 3b 45=
 38 74 82 <0f> 0b eb fe 0f 1f 00 48 83 ec 28 48 89 6c 24 08 48 89 1c 24=
 48
> [  302.340013] RIP  [<ffffffffa0323419>] virtqueue_detach_unused_buf+=
0xb9/0xc0 [virtio_ring]
> [  302.340013]  RSP <ffff88000c7a9e08>
> [  302.438579] ---[ end trace 1e583bdb5b2644f1 ]---
>
>
> Signed-off-by: Yunjian Wang <wangyunjian@huawei.com>
> ---
>   drivers/net/virtio_net.c | 4 ----
>   1 file changed, 4 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 49d84e5..4528ef8 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -818,10 +818,6 @@ static int virtnet_open(struct net_device *dev)
>          int i;
>
>          for (i =3D 0; i < vi->max_queue_pairs; i++) {
> -               if (i < vi->curr_queue_pairs)
> -                       /* Make sure we have some buffers: if oom use=
 wq. */
> -                       if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL=
))
> -                               schedule_delayed_work(&vi->refill, 0)=
;
>                  virtnet_napi_enable(&vi->rq[i]);
>          }
>
> --
> 1.7.12.4
>

Thanks a lot for spotting the issue.

But the fix looks questionable, what if we increase the number of queue=
s=20
before we open it? I can thin two solutions:

- since ndo_open() is protected by rtnl_lock, how about protect the=20
refill in virtnet_probe() with rtnl_lock?
- or looks like we can remove the refills in virtnet_probe() since we=20
will do it in .ndo_open() ?

Btw, we usually use net or net-next prefix in the patch. For the patch=20
like this, it should have something like "PATCH net" as a prefix. And=20
since it needs go to -stable, better add a short descriptor after "---"=
=20
for letting David to know about this.
