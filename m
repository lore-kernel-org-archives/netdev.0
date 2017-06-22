From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: BUG: KASAN: use-after-free in free_old_xmit_skbs
Date: Thu, 22 Jun 2017 21:53:03 +0300
Message-ID: <20170622215125-mutt-send-email-mst@kernel.org>
References: <d2e8cf65-ea3d-7db2-9382-a063daf1168a@gmail.com>
 <20170605050423-mutt-send-email-mst@kernel.org>
 <20170606024211-mutt-send-email-mst@kernel.org>
 <CAOTcU=u_HSMQiwDF3Snv5P8mT-b_Aepeb=Z9gbLd1j=2P+Yy+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com,
        John Fastabend <john.fastabend@gmail.com>,
        virtualization@lists.linux-foundation.org, qemu-devel@nongnu.org
To: jean-philippe menil <jpmenil@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42932 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752669AbdFVSxF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 14:53:05 -0400
Content-Disposition: inline
In-Reply-To: <CAOTcU=u_HSMQiwDF3Snv5P8mT-b_Aepeb=Z9gbLd1j=2P+Yy+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 22, 2017 at 08:15:58AM +0200, jean-philippe menil wrote:
> 2017-06-06 1:52 GMT+02:00 Michael S. Tsirkin <mst@redhat.com>:
> 
>     On Mon, Jun 05, 2017 at 05:08:25AM +0300, Michael S. Tsirkin wrote:
>     > On Mon, Jun 05, 2017 at 12:48:53AM +0200, Jean-Philippe Menil wrote:
>     > > Hi,
>     > >
>     > > while playing with xdp and ebpf, i'm hitting the following:
>     > >
>     > > [  309.993136]
>     > > ==================================================================
>     > > [  309.994735] BUG: KASAN: use-after-free in
>     > > free_old_xmit_skbs.isra.29+0x2b7/0x2e0 [virtio_net]
>     > > [  309.998396] Read of size 8 at addr ffff88006aa64220 by task sshd/323
>     > > [  310.000650]
>     > > [  310.002305] CPU: 1 PID: 323 Comm: sshd Not tainted 4.12.0-rc3+ #2
>     > > [  310.004018] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
>     BIOS
>     > > 1.10.2-20170228_101828-anatol 04/01/2014

...

>     >
>     > Since commit 680557cf79f82623e2c4fd42733077d60a843513
>     >     virtio_net: rework mergeable buffer handling
>     >
>     > we no longer must do the resets, we now have enough space
>     > to store a bit saying whether a buffer is xdp one or not.
>     >
>     > And that's probably a cleaner way to fix these issues than
>     > try to find and fix the race condition.
>     >
>     > John?
>     >
>     > --
>     > MST
> 
> 
>     I think I see the source of the race. virtio net calls
>     netif_device_detach and assumes no packets will be sent after
>     this point. However, all it does is stop all queues so
>     no new packets will be transmitted.
> 
>     Try locking with HARD_TX_LOCK?
>    
> 
>     --
>     MST
> 
> 
> Hi Michael,
> 
> from what i see, the race appear when we hit virtnet_reset in virtnet_xdp_set.
> virtnet_reset
>   _remove_vq_common
>     virtnet_del_vqs
>       virtnet_free_queues
>         kfree(vi->sq)
> when the xdp program (with two instances of the program to trigger it faster)
> is added or removed.
> 
> It's easily repeatable, with 2 cpus and 4 queues on the qemu command line,
> running the xdp_ttl tool from Jesper.
> 
> For now, i'm able to continue my qualification, testing if xdp_qp is not null,
> but do not seem to be a sustainable trick.
> if (xdp_qp && vi->xdp_queues_pairs != xdp_qp)
> 
> Maybe it will be more clear to you with theses informations.
> 
> Best regards.
> 
> Jean-Philippe


I'm pretty clear about the issue here, I was trying to figure out a fix.
Jason, any thoughts?


-- 
MST
