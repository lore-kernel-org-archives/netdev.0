From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH] mlx4_en: fix transmit of packages when blue frame is
 enabled
Date: Wed, 5 Oct 2011 10:15:02 +0200
Message-ID: <20111005081502.GB2681@mtldesk30>
References: <1317388995-411-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <953B660C027164448AE903364AC447D2235D9A8C@MTLDAG02.mtl.com>
 <20111003143721.GA3596@oc1711230544.ibm.com>
 <953B660C027164448AE903364AC447D2235DAA9D@MTLDAG02.mtl.com>
 <20111003205358.GB3596@oc1711230544.ibm.com>
 <1317708132.29415.213.camel@pasglop>
 <20111004202620.GA3455@oc1711230544.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eli Cohen <eli@mellanox.co.il>, linuxppc-dev@lists.ozlabs.org
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40742 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757988Ab1JEIPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 04:15:09 -0400
Received: by eya28 with SMTP id 28so1318723eya.19
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2011 01:15:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20111004202620.GA3455@oc1711230544.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 04, 2011 at 05:26:20PM -0300, Thadeu Lima de Souza Cascardo wrote:

I believe we have an endianess problem here. The source buffer is in
big endian - in x86 archs, it will rich the pci device unswapped since
both x86 and pci are little endian. In ppc, it wil be swapped by the
chipset so it will reach the device in little endian which is wrong.
So, in mlx4_bf_copy, you could loop over the buffer and swap32 the all
the dwords before the call to __iowrite64_copy. Of course which should
fix this in an arch independent manner. Let me know this works for
you.

> On Tue, Oct 04, 2011 at 08:02:12AM +0200, Benjamin Herrenschmidt wrote:
> > On Mon, 2011-10-03 at 17:53 -0300, Thadeu Lima de Souza Cascardo wrote:
> > 
> >  .../...
> > 
> > > > Can you also send me the output of ethtool -i?
> > > > It seems that there is a problem with write combining on Power processors, we will check this issue.
> > > > 
> > > > Yevgeny
> > > 
> > > Hello, Yevgeny.
> > > 
> > > You will find the output of ethtool -i below.
> > > 
> > > I am copying Ben and powerpc list, in case this is an issue with Power
> > > processors. They can provide us some more insight into this.
> > 
> > May I get some background please ? :-)
> > 
> > I'm not aware of a specific issue with write combining but I'd need to
> > know more about what you are doing and the code to do it to comment on
> > whether it should work or not.
> > 
> > Cheers,
> > Ben.
> > 
> > 
> 
> Hello, Ben.
> 
> Sorry for that. I am testing mlx4_en driver on a POWER. Yevgeny has
> added blue frame support, that does not require writing to the device
> memory to indicate a new packet (the doorbell register as it is called).
> 
> Well, the ring is getting full with no interrupt or packets transmitted.
> I simply added a write to the doorbell register and it works for me.
> Yevgeny says this is not the right fix, claiming there is a problem with
> write combining on POWER. The code uses memory barriers, so I don't know
> why there is any problem.
> 
> I am posting the code here to show better what the situation is.
> Yevgeny can tell more about the device and the driver.
> 
> The code below is the driver as of now, including a diff with what I
> changed and had resulted OK for me. Before the blue frame support, the
> only code executed was the else part. I can't tell much what the device
> should be seeing and doing after the blue frame part of the code is
> executed. But it does send the packet if I write to the doorbell
> register.
> 
> Yevgeny, can you tell us what the device should be doing and why you
> think this is a problem on POWER? Is it possible that this is simply a
> problem with the firmware version?
> 
> Thanks,
> Cascardo.
> 
> ---
>         if (ring->bf_enabled && desc_size <= MAX_BF && !bounce &&
> !vlan_tag) {
>                 *(u32 *) (&tx_desc->ctrl.vlan_tag) |=
> ring->doorbell_qpn;
>                 op_own |= htonl((bf_index & 0xffff) << 8);
>                 /* Ensure new descirptor hits memory
>                 * before setting ownership of this descriptor to HW */
>                 wmb();
>                 tx_desc->ctrl.owner_opcode = op_own;
> 
>                 wmb();
> 
>                 mlx4_bf_copy(ring->bf.reg + ring->bf.offset, (unsigned
> long *) &tx_desc->ctrl,
>                      desc_size);
> 
>                 wmb();
> 
>                 ring->bf.offset ^= ring->bf.buf_size;
>         } else {
>                 /* Ensure new descirptor hits memory
>                 * before setting ownership of this descriptor to HW */
>                 wmb();
>                 tx_desc->ctrl.owner_opcode = op_own;
> -               wmb();
> -               writel(ring->doorbell_qpn, ring->bf.uar->map +
> MLX4_SEND_DOORBELL);
>         }
> 
> +       wmb();
> +       writel(ring->doorbell_qpn, ring->bf.uar->map +
> MLX4_SEND_DOORBELL);
> +
> ---
