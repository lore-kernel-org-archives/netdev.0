From: Petr Vandrovec <vandrove@vc.cvut.cz>
Subject: Re: af_packet & CHECKSUM_HW
Date: Wed, 19 Nov 2003 13:35:35 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031119123535.GA11108@vana.vc.cvut.cz>
References: <20031115024434.GA12276@gondor.apana.org.au> <Xine.LNX.4.44.0311160841500.31201-100000@thoron.boston.redhat.com> <20031116205146.GA8477@gondor.apana.org.au> <20031117194452.GB18448@vana.vc.cvut.cz> <20031117123047.55377d3a.davem@redhat.com> <20031118132137.GA23732@vana.vc.cvut.cz> <20031118174612.48c0854e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031118174612.48c0854e.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Nov 18, 2003 at 05:46:12PM -0800, David S. Miller wrote:
> On Tue, 18 Nov 2003 14:21:37 +0100
> Petr Vandrovec <vandrove@vc.cvut.cz> wrote:
> 
> > On Mon, Nov 17, 2003 at 12:30:47PM -0800, David S. Miller wrote:
> > > Remind me again why the vmnet driver can't just run skb_checksum()
> > > on packets that have CHECKSUM_HW set?
> > 
> > Because vmnet driver (for bridged networking) is hooked through dev_add_pack.
> > Place where to put checksum is defined as skb->h.raw + skb->csum, and what 
> > to checksum as skb->h.raw ... skb->data + skb->len. But unfortunately
> > dev_queue_xmit_nit replaces skb2->h.raw with skb2->nh.raw - and so hook
> > has to look at the packet contents to compute h.raw from packet data and
> > protocol type.
> 
> Thanks so much for reminding me.
> 
> I'd like to resolve this.  One solution is evident, let me know
> what you think about the following idea.
> 
> How about we add a flag the the packet_type structure, called
> PTYPE_FLAG_NEEDCHECKSUM.  If it is set, we run skb_checksum() on
> CHECKSUM_HW SKBs and do not mangle the skb2->h.raw etc. pointers, then
> we pass it into ptype->func().
> 
> In this way all existing ptype->func() implementations get what
> they expect.  Only if the flag is set will the new behavior occur.

I'm not sure that we should run skb_checksum() on the packet. In vmnet's
case about 95% of all packets delivered to the hook is thrown away after
checking target MAC address (they are not broadcasts & they are not for
the virtual machine), and in these cases computing checksum is just waste 
of time.

So I think that this option should be named PTYPE_FLAG_CANCHECKSUM, and it
should affect only h.raw assignment - no checksumming should happen.

For AF_PACKET needs we can create PTYPE_FLAG_NEEDCHECKSUM which would call
skb_checksum() itself. But I think that adding skb_checksum call to af_packet
hook itself is simpler.

We can leave default case (no flags) as is, so hooks which expects h.raw==nh.raw
still work, and system is not slowed down by doing checksums for hooks which
do not need it.

I see only one possible benefit from PTYPE_FLAG_NEEDCHECKSUM: we can checksum
original skb, potentially saving some cycles in drivers which use 
skb_csum_and_copy_dev (or when two or more such hooks are registered).
					Best regards,
						Petr Vandrovec
						vandrove@vc.cvut.cz
