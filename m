From: =?ISO-8859-1?Q?S=E9guier_R=E9gis?= <rseguier@e-teleport.net>
Subject: Re: [PATCH] net: via-velocity.c fix sleep-with-spinlock bug during
 MTU change
Date: Wed, 18 Jun 2008 18:56:21 +0200
Message-ID: <48593E35.1010409@e-teleport.net>
References: <20080531184615.350bac00@infradead.org> <20080603134019.df2f51d4.akpm@linux-foundation.org> <20080603215155.GA9712@electric-eye.fr.zoreil.com> <20080604215909.GA17446@electric-eye.fr.zoreil.com> <20080614212341.GA12976@electric-eye.fr.zoreil.com> <4856DA62.7080803@e-teleport.net> <20080617214538.GA6388@electric-eye.fr.zoreil.com> <48584AA4.8040801@e-teleport.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Arjan van de Ven <arjan@infradead.org>, alan@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.e-teleport.net ([213.190.83.68]:55909 "EHLO
	mail.imsnet.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751661AbYFRQ4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 12:56:24 -0400
In-Reply-To: <48584AA4.8040801@e-teleport.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

S=E9guier R=E9gis a =E9crit :
> Francois Romieu a =E9crit :
>> S=E9guier R=E9gis <rseguier@e-teleport.net> :
>> [...]
>> =20
>>> The mtu change doesn't work :
>>>
>>> Jun 16 23:22:34 apollo kernel: ------------[ cut here ]------------
>>> Jun 16 23:22:34 apollo kernel: WARNING: at=20
>>> arch/x86/kernel/pci-dma.c:482 dma_free_coherent+0x3a/0x9c()
>>> Jun 16 23:22:34 apollo kernel: Pid: 1527, comm: ip Tainted: G      =
 =20
>>> W 2.6.26-rc6EPIA_SN_VB7001 #3
>>> Jun 16 23:22:34 apollo kernel:  [<c0115fe5>] warn_on_slowpath+0x3b/=
0x5f
>>> Jun 16 23:22:34 apollo kernel:  [<c0133940>]=20
>>> get_page_from_freelist+0x24a/0x36f
>>> Jun 16 23:22:34 apollo kernel:  [<c012d86b>] handle_IRQ_event+0x1a/=
0x3f
>>> Jun 16 23:22:34 apollo kernel:  [<c0241193>]=20
>>> velocity_free_rd_ring+0xa5/0xb6
>>> Jun 16 23:22:34 apollo kernel:  [<c0144752>] kfree+0x6a/0x72
>>> Jun 16 23:22:34 apollo kernel:  [<c0241193>]=20
>>> velocity_free_rd_ring+0xa5/0xb6
>>> Jun 16 23:22:34 apollo kernel:  [<c0105816>]=20
>>> dma_free_coherent+0x3a/0x9c
>>> Jun 16 23:22:34 apollo kernel:  [<c02411eb>]=20
>>> velocity_free_dma_rings+0x47/0x4d
>>> Jun 16 23:22:34 apollo kernel:  [<c024225b>]=20
>>> velocity_change_mtu+0xf6/0x157
>>> Jun 16 23:22:34 apollo kernel:  [<c02856c4>] dev_set_mtu+0x2a/0x4f
>>> Jun 16 23:22:34 apollo kernel:  [<c0286642>] dev_ioctl+0x4ab/0x530
>>> Jun 16 23:22:34 apollo kernel:  [<c012e4cb>]=20
>>> handle_fasteoi_irq+0x74/0x77
>>> Jun 16 23:22:34 apollo kernel:  [<c010479b>] do_IRQ+0x50/0x60
>>> Jun 16 23:22:34 apollo kernel:  [<c027d785>] sock_ioctl+0x0/0x177
>>>    =20
>>
>> Does the patch below make a difference ?
>>
>> diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
>> index 71a5133..fa303da 100644
>> --- a/drivers/net/via-velocity.c
>> +++ b/drivers/net/via-velocity.c
>> @@ -1274,7 +1274,7 @@ static void velocity_free_rd_ring(struct=20
>> velocity_info *vptr)
>>                   PCI_DMA_FROMDEVICE);
>>          rd_info->skb_dma =3D (dma_addr_t) NULL;
>> =20
>> -        dev_kfree_skb(rd_info->skb);
>> +        dev_kfree_skb_any(rd_info->skb);
>>          rd_info->skb =3D NULL;
>>      }
>> =20
>> @@ -1336,7 +1336,7 @@ static void velocity_free_td_ring_entry(struct=
=20
>> velocity_info *vptr,
>>                  td_info->skb_dma[i] =3D (dma_addr_t) NULL;
>>              }
>>          }
>> -        dev_kfree_skb(td_info->skb);
>> +        dev_kfree_skb_any(td_info->skb);
>>          td_info->skb =3D NULL;
>>      }
>>  }
>>  =20
> Idem.
>
> Jun 18 01:30:15 apollo kernel: ------------[ cut here ]------------
> Jun 18 01:30:15 apollo kernel: WARNING: at=20
> arch/x86/kernel/pci-dma.c:482 dma_free_coherent+0x3a/0x9c()
> Jun 18 01:30:15 apollo kernel: Pid: 1401, comm: ip Not tainted=20
> 2.6.26-rc6EPIA_SN_VB7001 #4
> Jun 18 01:30:15 apollo kernel:  [<c0115fe5>] warn_on_slowpath+0x3b/0x=
5f
> Jun 18 01:30:15 apollo kernel:  [<c0133b19>]=20
> __alloc_pages_internal+0xb4/0x349
> Jun 18 01:30:15 apollo kernel:  [<c0112bfd>] hrtick_start_fair+0x67/0=
xfd
> Jun 18 01:30:15 apollo kernel:  [<c011414f>]=20
> check_preempt_wakeup+0x9d/0xbb
> Jun 18 01:30:15 apollo kernel:  [<c0144752>] kfree+0x6a/0x72
> Jun 18 01:30:15 apollo kernel:  [<c0241193>]=20
> velocity_free_rd_ring+0xa5/0xb6
> Jun 18 01:30:15 apollo kernel:  [<c0105816>] dma_free_coherent+0x3a/0=
x9c
> Jun 18 01:30:15 apollo kernel:  [<c02411eb>]=20
> velocity_free_dma_rings+0x47/0x4d
> Jun 18 01:30:15 apollo kernel:  [<c024225b>]=20
> velocity_change_mtu+0xf6/0x157
> Jun 18 01:30:15 apollo kernel:  [<c02856c4>] dev_set_mtu+0x2a/0x4f
> Jun 18 01:30:15 apollo kernel:  [<c0286642>] dev_ioctl+0x4ab/0x530
> Jun 18 01:30:15 apollo kernel:  [<c013964a>] __do_fault+0x256/0x28e
> Jun 18 01:30:15 apollo kernel:  [<c027d8d7>] sock_ioctl+0x152/0x177
> Jun 18 01:30:15 apollo kernel:  [<c027d785>] sock_ioctl+0x0/0x177
> Jun 18 01:30:15 apollo kernel:  [<c0150b4a>] vfs_ioctl+0x16/0x48
> Jun 18 01:30:15 apollo kernel:  [<c0150d5a>] do_vfs_ioctl+0x1de/0x1f1
> Jun 18 01:30:15 apollo kernel:  [<c0150dae>] sys_ioctl+0x41/0x5b
> Jun 18 01:30:15 apollo kernel:  [<c010291d>] sysenter_past_esp+0x6a/0=
x91
> Jun 18 01:30:15 apollo kernel:  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Jun 18 01:30:15 apollo kernel: ---[ end trace abc2c54f7fac91dc ]---
>
This correction seems to work.

I read somewhere pci_free_consistent (in velocity_free_dma_rings)=20
couldn't be use in a spin_lock.
When I move velocity_free_rings outside the spin_lock, error desappeare=
=20
but data transfert doesn't work after the mtu change.
When I add velocity_give_many_rx_descs all work.

I will make some more tests.


--- drivers/net/via-velocity.c  2008-06-18 20:17:18.000000000 +0200
+++ ../linux-2.6.26-rc6-mtu/drivers/net/via-velocity.c  2008-06-18=20
20:28:14.000000000 +0200
@@ -1968,6 +1968,8 @@ static int velocity_change_mtu(struct ne
        if (dev->mtu !=3D new_mtu) {
                struct velocity_info *tmp_vptr;
                unsigned long flags;
+               struct tx_info tx;
+               struct rx_info rx;

                tmp_vptr =3D kzalloc(sizeof(*tmp_vptr), GFP_KERNEL);
                if (!tmp_vptr) {
@@ -1989,13 +1991,16 @@ static int velocity_change_mtu(struct ne
                netif_stop_queue(dev);
                velocity_shutdown(vptr);

-               velocity_free_rings(vptr);
-
+               rx=3Dvptr->rx;
+               tx=3Dvptr->tx;
                vptr->rx =3D tmp_vptr->rx;
                vptr->tx =3D tmp_vptr->tx;
+               tmp_vptr->rx=3Drx;
+               tmp_vptr->tx=3Dtx;

                dev->mtu =3D new_mtu;

+               velocity_give_many_rx_descs(vptr);
                velocity_init_registers(vptr, VELOCITY_INIT_COLD);

                mac_enable_int(vptr->mac_regs);
@@ -2003,6 +2008,7 @@ static int velocity_change_mtu(struct ne

                spin_unlock_irqrestore(&vptr->lock, flags);

+               velocity_free_rings(tmp_vptr);
 out_free_tmp_vptr_1:
                kfree(tmp_vptr);
        }


--=20
R=E9gis
