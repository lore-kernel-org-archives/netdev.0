From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net: via-velocity.c fix sleep-with-spinlock bug during
	MTU change
Date: Tue, 17 Jun 2008 23:45:38 +0200
Message-ID: <20080617214538.GA6388@electric-eye.fr.zoreil.com>
References: <20080531184615.350bac00@infradead.org> <20080603134019.df2f51d4.akpm@linux-foundation.org> <20080603215155.GA9712@electric-eye.fr.zoreil.com> <20080604215909.GA17446@electric-eye.fr.zoreil.com> <20080614212341.GA12976@electric-eye.fr.zoreil.com> <4856DA62.7080803@e-teleport.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Arjan van de Ven <arjan@infradead.org>, alan@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?unknown-8bit?B?U8OpZ3VpZXIgUsOpZ2lz?= <rseguier@e-teleport.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39886 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754108AbYFQVqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 17:46:09 -0400
Content-Disposition: inline
In-Reply-To: <4856DA62.7080803@e-teleport.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

S=C3=A9guier R=C3=A9gis <rseguier@e-teleport.net> :
[...]
> The mtu change doesn't work :
>
> Jun 16 23:22:34 apollo kernel: ------------[ cut here ]------------
> Jun 16 23:22:34 apollo kernel: WARNING: at arch/x86/kernel/pci-dma.c:=
482=20
> dma_free_coherent+0x3a/0x9c()
> Jun 16 23:22:34 apollo kernel: Pid: 1527, comm: ip Tainted: G        =
W=20
> 2.6.26-rc6EPIA_SN_VB7001 #3
> Jun 16 23:22:34 apollo kernel:  [<c0115fe5>] warn_on_slowpath+0x3b/0x=
5f
> Jun 16 23:22:34 apollo kernel:  [<c0133940>]=20
> get_page_from_freelist+0x24a/0x36f
> Jun 16 23:22:34 apollo kernel:  [<c012d86b>] handle_IRQ_event+0x1a/0x=
3f
> Jun 16 23:22:34 apollo kernel:  [<c0241193>] velocity_free_rd_ring+0x=
a5/0xb6
> Jun 16 23:22:34 apollo kernel:  [<c0144752>] kfree+0x6a/0x72
> Jun 16 23:22:34 apollo kernel:  [<c0241193>] velocity_free_rd_ring+0x=
a5/0xb6
> Jun 16 23:22:34 apollo kernel:  [<c0105816>] dma_free_coherent+0x3a/0=
x9c
> Jun 16 23:22:34 apollo kernel:  [<c02411eb>]=20
> velocity_free_dma_rings+0x47/0x4d
> Jun 16 23:22:34 apollo kernel:  [<c024225b>] velocity_change_mtu+0xf6=
/0x157
> Jun 16 23:22:34 apollo kernel:  [<c02856c4>] dev_set_mtu+0x2a/0x4f
> Jun 16 23:22:34 apollo kernel:  [<c0286642>] dev_ioctl+0x4ab/0x530
> Jun 16 23:22:34 apollo kernel:  [<c012e4cb>] handle_fasteoi_irq+0x74/=
0x77
> Jun 16 23:22:34 apollo kernel:  [<c010479b>] do_IRQ+0x50/0x60
> Jun 16 23:22:34 apollo kernel:  [<c027d785>] sock_ioctl+0x0/0x177

Does the patch below make a difference ?

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 71a5133..fa303da 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1274,7 +1274,7 @@ static void velocity_free_rd_ring(struct velocity=
_info *vptr)
 				 PCI_DMA_FROMDEVICE);
 		rd_info->skb_dma =3D (dma_addr_t) NULL;
=20
-		dev_kfree_skb(rd_info->skb);
+		dev_kfree_skb_any(rd_info->skb);
 		rd_info->skb =3D NULL;
 	}
=20
@@ -1336,7 +1336,7 @@ static void velocity_free_td_ring_entry(struct ve=
locity_info *vptr,
 				td_info->skb_dma[i] =3D (dma_addr_t) NULL;
 			}
 		}
-		dev_kfree_skb(td_info->skb);
+		dev_kfree_skb_any(td_info->skb);
 		td_info->skb =3D NULL;
 	}
 }
--=20
Ueimor
