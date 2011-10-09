From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] mlx4_en: fix transmit of packages when blue frame is
 enabled
Date: Sun, 09 Oct 2011 09:21:55 +0200
Message-ID: <1318144915.29415.368.camel@pasglop>
References: <1317388995-411-1-git-send-email-cascardo@linux.vnet.ibm.com>
	 <953B660C027164448AE903364AC447D2235D9A8C@MTLDAG02.mtl.com>
	 <20111003143721.GA3596@oc1711230544.ibm.com>
	 <953B660C027164448AE903364AC447D2235DAA9D@MTLDAG02.mtl.com>
	 <20111003205358.GB3596@oc1711230544.ibm.com>
	 <1317708132.29415.213.camel@pasglop>
	 <20111004202620.GA3455@oc1711230544.ibm.com>
	 <20111005081502.GB2681@mtldesk30>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eli Cohen <eli@mellanox.co.il>, linuxppc-dev@lists.ozlabs.org
To: Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:49778 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750984Ab1JIHWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Oct 2011 03:22:13 -0400
In-Reply-To: <20111005081502.GB2681@mtldesk30>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-05 at 10:15 +0200, Eli Cohen wrote:
> On Tue, Oct 04, 2011 at 05:26:20PM -0300, Thadeu Lima de Souza Cascardo wrote:
> 
> I believe we have an endianess problem here. The source buffer is in
> big endian - in x86 archs, it will rich the pci device unswapped since
> both x86 and pci are little endian. In ppc, it wil be swapped by the
> chipset 
  ^^^^^^^ ugh ?

> so it will reach the device in little endian which is wrong.
> So, in mlx4_bf_copy, you could loop over the buffer and swap32 the all
> the dwords before the call to __iowrite64_copy. Of course which should
> fix this in an arch independent manner. Let me know this works for
> you.

That's generally the wrong way to handle endian (to swap32 a whole
buffer).

But I need to know more about the structure of those descriptors etc...
to judge properly.

Cheers,
Ben.

> > On Tue, Oct 04, 2011 at 08:02:12AM +0200, Benjamin Herrenschmidt wrote:
> > > On Mon, 2011-10-03 at 17:53 -0300, Thadeu Lima de Souza Cascardo wrote:
> > > 
> > >  .../...
> > > 
> > > > > Can you also send me the output of ethtool -i?
> > > > > It seems that there is a problem with write combining on Power processors, we will check this issue.
> > > > > 
> > > > > Yevgeny
> > > > 
> > > > Hello, Yevgeny.
> > > > 
> > > > You will find the output of ethtool -i below.
> > > > 
> > > > I am copying Ben and powerpc list, in case this is an issue with Power
> > > > processors. They can provide us some more insight into this.
> > > 
> > > May I get some background please ? :-)
> > > 
> > > I'm not aware of a specific issue with write combining but I'd need to
> > > know more about what you are doing and the code to do it to comment on
> > > whether it should work or not.
> > > 
> > > Cheers,
> > > Ben.
> > > 
> > > 
> > 
> > Hello, Ben.
> > 
> > Sorry for that. I am testing mlx4_en driver on a POWER. Yevgeny has
> > added blue frame support, that does not require writing to the device
> > memory to indicate a new packet (the doorbell register as it is called).
> > 
> > Well, the ring is getting full with no interrupt or packets transmitted.
> > I simply added a write to the doorbell register and it works for me.
> > Yevgeny says this is not the right fix, claiming there is a problem with
> > write combining on POWER. The code uses memory barriers, so I don't know
> > why there is any problem.
> > 
> > I am posting the code here to show better what the situation is.
> > Yevgeny can tell more about the device and the driver.
> > 
> > The code below is the driver as of now, including a diff with what I
> > changed and had resulted OK for me. Before the blue frame support, the
> > only code executed was the else part. I can't tell much what the device
> > should be seeing and doing after the blue frame part of the code is
> > executed. But it does send the packet if I write to the doorbell
> > register.
> > 
> > Yevgeny, can you tell us what the device should be doing and why you
> > think this is a problem on POWER? Is it possible that this is simply a
> > problem with the firmware version?
> > 
> > Thanks,
> > Cascardo.
> > 
> > ---
> >         if (ring->bf_enabled && desc_size <= MAX_BF && !bounce &&
> > !vlan_tag) {
> >                 *(u32 *) (&tx_desc->ctrl.vlan_tag) |=
> > ring->doorbell_qpn;
> >                 op_own |= htonl((bf_index & 0xffff) << 8);
> >                 /* Ensure new descirptor hits memory
> >                 * before setting ownership of this descriptor to HW */
> >                 wmb();
> >                 tx_desc->ctrl.owner_opcode = op_own;
> > 
> >                 wmb();
> > 
> >                 mlx4_bf_copy(ring->bf.reg + ring->bf.offset, (unsigned
> > long *) &tx_desc->ctrl,
> >                      desc_size);
> > 
> >                 wmb();
> > 
> >                 ring->bf.offset ^= ring->bf.buf_size;
> >         } else {
> >                 /* Ensure new descirptor hits memory
> >                 * before setting ownership of this descriptor to HW */
> >                 wmb();
> >                 tx_desc->ctrl.owner_opcode = op_own;
> > -               wmb();
> > -               writel(ring->doorbell_qpn, ring->bf.uar->map +
> > MLX4_SEND_DOORBELL);
> >         }
> > 
> > +       wmb();
> > +       writel(ring->doorbell_qpn, ring->bf.uar->map +
> > MLX4_SEND_DOORBELL);
> > +
> > ---
