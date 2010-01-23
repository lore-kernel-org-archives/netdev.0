From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] e1000: Fix DMA mapping error handling on TX
Date: Fri, 22 Jan 2010 19:40:48 -0800
Message-ID: <9929d2391001221940r4482dde4k8e5409bc7933bc21@mail.gmail.com>
References: <20100121114244.GC32259@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Yi Zou <yi.zou@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f190.google.com ([209.85.222.190]:56442 "EHLO
	mail-pz0-f190.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085Ab0AWDkt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 22:40:49 -0500
Received: by pzk28 with SMTP id 28so537983pzk.4
        for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 19:40:48 -0800 (PST)
In-Reply-To: <20100121114244.GC32259@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 21, 2010 at 03:42, Anton Blanchard <anton@samba.org> wrote:
>
> There were a few issues in the DMA mapping error handling in e1000_tx=
_map
> which I found via fault injection.
>
> If we fail to map the first descriptor count will end up as -1 but th=
e
> check of (count >=3D 0) will still be true since count is unsigned. I=
nstead
> of changing count to be signed, just simplify the logic.
>
> Secondly, when we wrap the tx ring we rely on i to go negative, but i=
t
> was unsigned.
>
> Signed-off-by: Anton Blanchard <anton@samba.org>
> ---
>
> Index: linux.trees.git/drivers/net/e1000/e1000_main.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.trees.git.orig/drivers/net/e1000/e1000_main.c 2010-01-21 11=
:10:00.000000000 +1100
> +++ linux.trees.git/drivers/net/e1000/e1000_main.c =C2=A0 =C2=A0 =C2=A0=
2010-01-21 11:12:52.000000000 +1100
> @@ -2693,8 +2693,9 @@ static int e1000_tx_map(struct e1000_ada
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct pci_dev *pdev =3D adapter->pdev;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct e1000_buffer *buffer_info;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int len =3D skb_headlen(skb);
> - =C2=A0 =C2=A0 =C2=A0 unsigned int offset =3D 0, size, count =3D 0, =
i;
> + =C2=A0 =C2=A0 =C2=A0 unsigned int offset =3D 0, size, count =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int f;
> + =C2=A0 =C2=A0 =C2=A0 int i;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0i =3D tx_ring->next_to_use;
>
> @@ -2802,10 +2803,8 @@ static int e1000_tx_map(struct e1000_ada
> =C2=A0dma_error:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev_err(&pdev->dev, "TX DMA map failed\n")=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0buffer_info->dma =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 count--;
>
> - =C2=A0 =C2=A0 =C2=A0 while (count >=3D 0) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 count--;
> + =C2=A0 =C2=A0 =C2=A0 while (count--) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0i--;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (i < 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0i +=3D tx_ring->count;

This patch does not apply to the current e1000 driver in net-2.6, much
of this patch has already been corrected (applied) by Roel Kluin
recent patch.

--=20
Cheers,
Jeff
