From: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: use-after-free in usbnet
Date: Fri, 20 Apr 2012 22:56:48 +0800
Message-ID: <CA+v9cxZWtGbz6uCSysVbAc1hT27rCiuJXzcvSiTxH-zuQYnrZw@mail.gmail.com>
References: <CACVXFVP+U1k7JFTmbabF-k8F3bO9zc58c3tLG6=1nQPcrR9p1g@mail.gmail.com>
	<Pine.LNX.4.44L0.1203211201560.1369-100000@iolanthe.rowland.org>
	<CACVXFVOVjnWjqpKxbU98DAyUC_OSb8ZL-3WcyYuFXgPJn5UyuA@mail.gmail.com>
	<201203221008.46882.oneukum@suse.de>
	<CACVXFVODFvtF1DRyWJmnYCByw7sr9QDv_+Taxo5maVaUauDNtg@mail.gmail.com>
	<CA+v9cxawVwKakF6c_RpAw2XUGWcbqd8M+ZJqyq76Au9rmNosmQ@mail.gmail.com>
	<CACVXFVM5YBJkDZddeGi1_MPY7EqEV_wtoFy-NtBHYA6rxez0jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Fedora Kernel Team <kernel-team-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVM5YBJkDZddeGi1_MPY7EqEV_wtoFy-NtBHYA6rxez0jg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 20, 2012 at 10:22 PM, Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrot=
e:
> On Fri, Apr 20, 2012 at 9:37 PM, Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> =
wrote:
>>
>> Above patch has already been integrated to mainline. However, maybe
>> there still exists another potentail use-after-free issue, here is a
>> case:
>> =A0 =A0 =A0After release the lock in unlink_urbs(), defer_bh() may m=
ove
>> current skb from rxq/txq to dev->done queue, even cause the skb be
>> released. Then in next loop cycle, it can't refer to expected skb, a=
nd
>> may Oops again.
>
> Could you explain in a bit detail? Why can't the expected skb be refe=
red
> to in next loop?


      unlink_urbs()                                           complete =
handler
--------------------------------------
-------------------------------------------------
     spin_unlock_irqrestore()
                                                                  rx_co=
mplete()
                                                                  derve=
r_bh()

 __skb_unlink()

 __skb_queue_tail(&dev->done, skb)   =3D=3D=3D=3D=3D=3D=3D> skb is move=
d to
dev->done, and can be freed by usbnet_bh()
      skb_queue_walk_safe()
                      tmp =3D skb->next   =3D=3D=3D> refer to freed skb

>
>>
>> To easily reproduce it, in unlink_urbs(), you can delay a short time
>> after usb_put_urb(urb), then disconnect your device while transferri=
ng
>> data, and repeat it times you will find errors on your screen.
>
> Could you post out the error log?

The log like this:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[45219.230127] general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
[45219.230192] CPU 1
[45219.230208] Modules linked in: cdc_ether usbnet(O) bluetooth
dm_crypt binfmt_misc snd_hda_codec_analog snd_hda_intel snd_hda_codec
snd_hwdep snd_pcm snd_seq_midi snd_rawmidi snd_seq_midi_event hp_wmi
ppdev sparse_keymap i915 snd_seq snd_timer coretemp microcode
snd_seq_device psmouse tpm_infineon serio_raw snd soundcore
drm_kms_helper snd_page_alloc tpm_tis tpm parport_pc tpm_bios drm
i2c_algo_bit video lp parport sg ehci_hcd uhci_hcd sr_mod sd_mod
usbcore e1000e usb_common floppy
[45219.230658]
[45219.230673] Pid: 200, comm: khubd Tainted: G          IO 3.4.0-rc3
#56 Hewlett-Packard HP Compaq dc7800p Convertible Minitower/0AACh
[45219.230761] RIP: 0010:[<ffffffffa0094e7d>]  [<ffffffffa0094e7d>]
usb_get_urb+0x1d/0x70 [usbcore]
[45219.230837] RSP: 0018:ffff8800554df8e0  EFLAGS: 00010002
[45219.230874] RAX: 6b6b6b6b6b6b6b6b RBX: 6b6b6b6b6b6b6b6b RCX: 0000000=
000008760
[45219.230920] RDX: 6b6b6b6b6b6b6b6b RSI: 0000000000000202 RDI: 6b6b6b6=
b6b6b6b6b
[45219.230966] RBP: ffff8800554df8f0 R08: 0000000304b1e1be R09: 0000000=
000000001
[45219.231012] R10: 0000000000000001 R11: 0000000000000000 R12: 6b6b6b6=
b6b6b6b6b
[45219.231058] R13: ffff88000650e330 R14: ffff88000650e318 R15: 0000000=
000000001
[45219.231105] FS:  0000000000000000(0000) GS:ffff88007a400000(0000)
knlGS:0000000000000000
[45219.231158] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[45219.231196] CR2: 00007f1bd331c3e0 CR3: 000000000656b000 CR4: 0000000=
0000007e0
[45219.231243] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000=
000000000
[45219.231289] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000=
000000400
[45219.231335] Process khubd (pid: 200, threadinfo ffff8800554de000,
task ffff880055b4a410)
[45219.231387] Stack:
[45219.231405]  ffff8800567daf40 ffff88000650e330 ffff8800554df940
ffffffffa053ee1a
[45219.231469]  0000000000000202 ffff88000650e2a0 ffff8800554df940
ffff88000650e140
[45219.231534]  ffff880055b4a410 ffff88000650e318 ffff88000650e378
ffff88000650e2a0
[45219.231597] Call Trace:
[45219.231622]  [<ffffffffa053ee1a>] unlink_urbs.isra.14+0xca/0x170 [us=
bnet]
[45219.231670]  [<ffffffffa053f05b>] usbnet_terminate_urbs+0x19b/0x350 =
[usbnet]
[45219.231721]  [<ffffffff810d1700>] ? try_to_wake_up+0x580/0x580
[45219.231762]  [<ffffffff810c24ba>] ? __wake_up+0x3a/0x90
[45219.231801]  [<ffffffffa053ff90>] usbnet_stop+0x190/0x270 [usbnet]
[45219.231846]  [<ffffffff817b1226>] __dev_close_many+0xd6/0x160
[45219.231886]  [<ffffffff817b1368>] dev_close_many+0xb8/0x160
[45219.231926]  [<ffffffff817b1518>] rollback_registered_many+0x108/0x3=
90
[45219.231972]  [<ffffffff817b1874>] rollback_registered+0x44/0x70
[45219.232013]  [<ffffffff817b1920>] unregister_netdevice_queue+0x80/0x=
f0
[45219.232058]  [<ffffffff817b1ae0>] unregister_netdev+0x30/0x50
[45219.232100]  [<ffffffffa053e61a>] usbnet_disconnect+0x8a/0x170 [usbn=
et]
[45219.232155]  [<ffffffffa009adc5>] usb_unbind_interface+0x65/0x230 [u=
sbcore]
[45219.232205]  [<ffffffff8163cda7>] __device_release_driver+0x157/0x17=
0
[45219.232249]  [<ffffffff8163cdfe>] device_release_driver+0x3e/0x60
[45219.232291]  [<ffffffff8163c27f>] bus_remove_device+0x15f/0x210
[45219.232331]  [<ffffffff81637e6d>] device_del+0x1ad/0x2b0
[45219.232379]  [<ffffffffa0097970>] usb_disable_device+0x100/0x340 [us=
bcore]
[45219.232435]  [<ffffffffa008a417>] usb_disconnect+0xf7/0x220 [usbcore=
]
[45219.232487]  [<ffffffffa008e411>] hub_thread+0x1321/0x21e0 [usbcore]
[45219.232535]  [<ffffffff810b3780>] ? wake_up_bit+0x50/0x50
[45219.232581]  [<ffffffffa008d0f0>] ? usb_remote_wakeup+0xb0/0xb0 [usb=
core]
[45219.232628]  [<ffffffff810b2b9f>] kthread+0xdf/0xf0
[45219.232664]  [<ffffffff819a5574>] kernel_thread_helper+0x4/0x10
[45219.232706]  [<ffffffff819970b0>] ? retint_restore_args+0x13/0x13
[45219.232749]  [<ffffffff810b2ac0>] ? __init_kthread_worker+0x80/0x80
[45219.232791]  [<ffffffff819a5570>] ? gs_change+0x13/0x13
[45219.232826] Code: ff ff e9 d4 fb ff ff 0f 1f 80 00 00 00 00 55 48
89 e5 48 83 ec 10 66 66 66 66 90 48 83 05 2b aa 02 00 01 48 85 ff 48
89 f8 74 19 <8b> 17 48 83 05 21 aa 02 00 01 85 d2 74 0d f0 ff 00 48 83
05 2a
[45219.233184] RIP  [<ffffffffa0094e7d>] usb_get_urb+0x1d/0x70 [usbcore=
]
[45219.233240]  RSP <ffff8800554df8e0>
[45219.233268] ---[ end trace a7919e7f17c0a727 ]---
[45222.870031] usb0: no IPv6 routers present

>
>>
>> Following is a draft patch to guarantee the queue consistent, and
>> refer to expected skb in each loop cycle:
>>
>> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
>> index b7b3f5b..6da0141 100644
>> --- a/drivers/net/usb/usbnet.c
>> +++ b/drivers/net/usb/usbnet.c
>> @@ -578,16 +578,28 @@ EXPORT_SYMBOL_GPL(usbnet_purge_paused_rxq);
>> =A0static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *=
q)
>> =A0{
>> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 flags;
>> - =A0 =A0 =A0 struct sk_buff =A0 =A0 =A0 =A0 =A0*skb, *skbnext;
>> + =A0 =A0 =A0 struct sk_buff =A0 =A0 =A0 =A0 =A0*skb;
>> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count =3D=
 0;
>>
>> =A0 =A0 =A0 =A0spin_lock_irqsave (&q->lock, flags);
>> - =A0 =A0 =A0 skb_queue_walk_safe(q, skb, skbnext) {
>> + =A0 =A0 =A0 while (!skb_queue_empty(q)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct skb_data =A0 =A0 =A0 =A0 *entr=
y;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct urb =A0 =A0 =A0 =A0 =A0 =A0 =A0=
*urb;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 retval;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry =3D (struct skb_data *) skb->cb;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_queue_walk(q, skb) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry =3D (struct skb_=
data *)skb->cb;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (entry->state =3D=3D=
 rx_done ||
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry-=
>state =3D=3D tx_done ||
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry-=
>state =3D=3D rx_cleanup)
>
> Maybe it is not necessary, if the state has been changed to =A0rx_don=
e
> or tx_done or rx_cleanup, it means the URB referenced to by the skb
> has been completed, and the coming usb_unlink_urb can handle the
> case correctly.
>

If its state is x_done/tx_done/rx_cleanup, that means the the skb will
be released soon, right? If so, it should avoid calling
usb_unlink_urb().

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 contin=
ue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb =3D=3D (struct sk_buff *)(q))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0urb =3D entry->urb;
>>
>>
>> Thanks,
>> --Huajun Li
>
>
> Thanks,
> --
> Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
