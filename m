From: Anthony Liguori <aliguori@us.ibm.com>
Subject: Re: [PATCH] virtio_net: Fix oops on early interrupts - introduced
 by virtio reset code
Date: Mon, 11 Feb 2008 09:29:36 -0600
Message-ID: <47B069E0.9040905@us.ibm.com>
References: <200802111411.15745.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@qumranet.com>, dor.laor@qumranet.com,
	kvm-devel <kvm-devel@lists.sourceforge.net>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:51864 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753205AbYBKP3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 10:29:38 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1BFTatl015855
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 10:29:36 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1BFTa5Z249462
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 10:29:36 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1BFTZBp014461
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 10:29:36 -0500
In-Reply-To: <200802111411.15745.borntraeger@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christian Borntraeger wrote:
> Avi,
> this fixes a problem that was introduced by the virtio_reset patches. 
> Can you apply that fix to kvm.git as a bugfix,  as the virtio_reset
> infrastructure is not on Linus upstream yet?
>   

The reset support is in Linus's tree so we should try to push it for -rc2.

> Anthony, Dor,
> are you ok with that change?
>   

Yes.

Acked-by: Anthony Liguori <aliguori@us.ibm.com>

Regards,

Anthony Liguori

> --
>
> With the latest virtio_reset patches I got the following oops:
>
> Unable to handle kernel pointer dereference at virtual kernel address 0000000000000000
> Oops: 0004 [#1] PREEMPT SMP
> Modules linked in:
> CPU: 1 Not tainted 2.6.24zlive-guest-10577-g63f5307-dirty #168
> Process swapper (pid: 0, task: 000000000f866040, ksp: 000000000f86fd78)
> Krnl PSW : 0404100180000000 000000000047598a (skb_recv_done+0x52/0x98)
>            R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:0 CC:1 PM:0 EA:3
> Krnl GPRS: 0000000000000001 0000000000000000 000000000efd0e60 0000000000000001
>            0000000000000000 000000000f866040 0000000000000000 0000000000000000
>            00000000008de4c8 0000000000001237 0000000000001237 000000000f977dd8
>            0000000000000020 00000000001132bc 000000000f977e08 000000000f977dd8
> Krnl Code: 000000000047597c: e31040300004       lg      %r1,48(%r4)
>            0000000000475982: b9040001           lgr     %r0,%r1
>            0000000000475986: b9810003           ogr     %r0,%r3
>           >000000000047598a: eb1040300030       csg     %r1,%r0,48(%r4)
>            0000000000475990: a744fff9           brc     4,475982
>            0000000000475994: a7110001           tmll    %r1,1
>            0000000000475998: a7840009           brc     8,4759aa
>            000000000047599c: e340b0b80004       lg      %r4,184(%r11)
> Call Trace:
> ([<000001500f978000>] 0x1500f978000)
>  [<00000000004779a6>] vring_interrupt+0x72/0x88
>  [<0000000000491d9c>] kvm_extint_handler+0x34/0x44
>  [<000000000010d2d4>] do_extint+0xc0/0xfc
>  [<0000000000113b5a>] ext_no_vtime+0x1c/0x20
>  [<000000000010a0b6>] cpu_idle+0x21a/0x230
>
>
> We must initialize vdev->priv before we use the notify hypercall as 
> vdev->priv is used in skb_recv_done. So lets move the assignment of 
> vdev->priv before we call try_fill_recv.
>
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> ---
>  drivers/net/virtio_net.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> Index: kvm/drivers/net/virtio_net.c
> ===================================================================
> --- kvm.orig/drivers/net/virtio_net.c
> +++ kvm/drivers/net/virtio_net.c
> @@ -361,6 +361,7 @@ static int virtnet_probe(struct virtio_d
>  	netif_napi_add(dev, &vi->napi, virtnet_poll, napi_weight);
>  	vi->dev = dev;
>  	vi->vdev = vdev;
> +	vdev->priv = vi;
>
>  	/* We expect two virtqueues, receive then send. */
>  	vi->rvq = vdev->config->find_vq(vdev, 0, skb_recv_done);
> @@ -395,7 +396,6 @@ static int virtnet_probe(struct virtio_d
>  	}
>
>  	pr_debug("virtnet: registered device %s\n", dev->name);
> -	vdev->priv = vi;
>  	return 0;
>
>  unregister:
>   

