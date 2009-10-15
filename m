From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] virtio_net: use dev_kfree_skb_any() in free_old_xmit_skbs()
Date: Thu, 15 Oct 2009 02:36:43 +0200
Message-ID: <4AD66E9B.2020803@gmail.com>
References: <zJ_pXHNwoHC.A.akB.Aal0KB@chimera>	<r-4Wjt4coy.A.CwC.Wal0KB@chimera> <20091012.034224.64980795.davem@davemloft.net> <4AD44435.3050703@navynet.it> <4AD45447.7030705@gmail.com> <4AD455E4.2070105@navynet.it> <4AD62626.6010709@navynet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Massimo Cetra <ctrixk-BBpJ+9iBSNKonA0d6jMUrA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, rjw-KKrjLPT3xs0@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Massimo Cetra <mcetra-BBpJ+9iBSNKonA0d6jMUrA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4AD62626.6010709-BBpJ+9iBSNKonA0d6jMUrA@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Massimo Cetra a =E9crit :
> Eric,
> thanks for the patch.
> The problem didn't arise again and i haven't seen any warning like th=
at
> on both servers where that problem was happening more frequently.
>=20
> I would say that it's fixed and if it's not, i'll let you know as soo=
n
> as it happens again.
>=20

Thanks Massimo, I think patch is reasonably safe and should be taken as=
 is :


[PATCH] virtio_net: use dev_kfree_skb_any() in free_old_xmit_skbs()

Because netpoll can call netdevice start_xmit() method with
irqs disabled, drivers should not call kfree_skb() from
their start_xmit(), but use dev_kfree_skb_any() instead.

Oct  8 11:16:52 172.30.1.31 [113074.791813] ------------[ cut here ]---=
---------
Oct  8 11:16:52 172.30.1.31 [113074.791813] WARNING: at net/core/skbuff=
=2Ec:398 \
                skb_release_head_state+0x64/0xc8()
Oct  8 11:16:52 172.30.1.31 [113074.791813] Hardware name:=20
Oct  8 11:16:52 172.30.1.31 [113074.791813] Modules linked in: netconso=
le ocfs2 jbd2 quota_tree \
ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglu=
e configfs crc32c drbd cn loop \
serio_raw psmouse snd_pcm snd_timer snd soundcore snd_page_alloc virtio=
_net pcspkr parport_pc parport \
i2c_piix4 i2c_core button processor evdev ext3 jbd mbcache dm_mirror dm=
_region_hash dm_log dm_snapshot \
dm_mod ide_cd_mod cdrom ata_generic ata_piix virtio_blk libata scsi_mod=
 piix ide_pci_generic ide_core \
                virtio_pci virtio_ring virtio floppy thermal fan therma=
l_sys [last unloaded: netconsole]
Oct  8 11:16:52 172.30.1.31 [113074.791813] Pid: 11132, comm: php5-cgi =
Tainted: G        W  \
                2.6.31.2-vserver #1
Oct  8 11:16:52 172.30.1.31 [113074.791813] Call Trace:
Oct  8 11:16:52 172.30.1.31 [113074.791813] <IRQ>  [<ffffffff81253cd5>]=
 ? \
                skb_release_head_state+0x64/0xc8
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffff81253cd5>] ? skb_=
release_head_state+0x64/0xc8
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffff81049ae1>] ? warn=
_slowpath_common+0x77/0xa3
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffff81253cd5>] ? skb_=
release_head_state+0x64/0xc8
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffff81253a1a>] ? __kf=
ree_skb+0x9/0x7d
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffffa01cb139>] ? free=
_old_xmit_skbs+0x51/0x6e \
                [virtio_net]
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffffa01cbc85>] ? star=
t_xmit+0x26/0xf2 [virtio_net]
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffff8126934f>] ? netp=
oll_send_skb+0xd2/0x205
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffffa0429216>] ? writ=
e_msg+0x90/0xeb [netconsole]
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffff81049f06>] ? __ca=
ll_console_drivers+0x5e/0x6f
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffff8102b49d>] ? kvm_=
clock_read+0x4d/0x52
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffff8104a082>] ? rele=
ase_console_sem+0x115/0x1ba
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffff8104a632>] ? vpri=
ntk+0x2f2/0x34b
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffff8106b142>] ? vx_u=
pdate_load+0x18/0x13e
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffff81308309>] ? prin=
tk+0x4e/0x5d
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffff8102b49d>] ? kvm_=
clock_read+0x4d/0x52
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffff81070b62>] ? getn=
stimeofday+0x55/0xaf
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffff81062683>] ? ktim=
e_get_ts+0x21/0x49
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffff810626b7>] ? ktim=
e_get+0xc/0x41
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffff81062788>] ? hrti=
mer_interrupt+0x9c/0x146
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffff81024a4b>] ? smp_=
apic_timer_interrupt+0x80/0x93
Oct  8 11:16:52 172.30.1.31 [113074.791813] [<ffffffff81011663>] ? apic=
_timer_interrupt+0x13/0x20
Oct  8 11:16:52 172.30.1.31 [113074.791813] <EOI>  [<ffffffff8130a9eb>]=
 ? _spin_unlock_irq+0xd/0x31

Reported-and-tested-by: Massimo Cetra <mcetra-BBpJ+9iBSNKonA0d6jMUrA@public.gmane.org>
Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Bug-Entry: http://bugzilla.kernel.org/show_bug.cgi?id=3D14378
---

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 8d00976..54bf091 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -454,7 +454,7 @@ static unsigned int free_old_xmit_skbs(struct virtn=
et_info *vi)
 		vi->dev->stats.tx_bytes +=3D skb->len;
 		vi->dev->stats.tx_packets++;
 		tot_sgs +=3D skb_vnet_hdr(skb)->num_sg;
-		kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 	}
 	return tot_sgs;
 }
