From: Petr Vandrovec <vandrove@vc.cvut.cz>
Subject: Re: af_packet & CHECKSUM_HW
Date: Tue, 18 Nov 2003 14:21:37 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031118132137.GA23732@vana.vc.cvut.cz>
References: <20031115024434.GA12276@gondor.apana.org.au> <Xine.LNX.4.44.0311160841500.31201-100000@thoron.boston.redhat.com> <20031116205146.GA8477@gondor.apana.org.au> <20031117194452.GB18448@vana.vc.cvut.cz> <20031117123047.55377d3a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031117123047.55377d3a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 17, 2003 at 12:30:47PM -0800, David S. Miller wrote:
> On Mon, 17 Nov 2003 20:44:52 +0100
> Petr Vandrovec <vandrove@vc.cvut.cz> wrote:
> 
> > It would be nice if at least kernel did not stomp on skb2->h.raw so
> > ptype callback could cope with situation and report to userspace where
> > to put checksum. I already discussed it here two or so months ago, and

3 months ago.

> > only solution I was able to find is that VMware's vmnet have to parse
> > itself network headers to find where to put checksum. Nothing for IPv6
> > users...
> 
> Remind me again why the vmnet driver can't just run skb_checksum()
> on packets that have CHECKSUM_HW set?

Because vmnet driver (for bridged networking) is hooked through dev_add_pack.
Place where to put checksum is defined as skb->h.raw + skb->csum, and what 
to checksum as skb->h.raw ... skb->data + skb->len. But unfortunately
dev_queue_xmit_nit replaces skb2->h.raw with skb2->nh.raw - and so hook
has to look at the packet contents to compute h.raw from packet data and
protocol type.

When I was complaining about this assignment, you told me that AF_PACKET
requires skb->h.raw pointing to same place as skb->nh.raw. And I was not able
to find place you were referring to, and thread died.

Unfortunately I was not able to find netdev public archive, so below are two 
messages I sent on this subject in august. As far as I know, there was no reply
on my second message.

Currently vmnet does fixup below at the start of hook. Fortunately
no 'Unknown EII protocol' message was reported from the users yet
(and we compute checksum while doing copy_to_user, so there is almost
no slowdown).

/*
 *----------------------------------------------------------------------
 *
 * VNetBridgeComputeHeaderPos --
 *
 *      Compute correct position for UDP/TCP header.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      skb->h.raw updated to point to the tcp/udp header.
 *
 *----------------------------------------------------------------------
 */

static INLINE_SINGLE_CALLER void
VNetBridgeComputeHeaderPos(struct sk_buff *skb)
{
   /* Maybe some kernel gets it right... */
   if (skb->h.raw != skb->nh.raw) {
      return;
   }
   switch (be16_to_cpu(skb->protocol)) {
      case ETH_P_IP:
         skb->h.raw = skb->nh.raw + (skb->nh.raw[0] & 0x0F) * 4;
         return;
      default:
         printk(KERN_DEBUG "Unknown EII protocol %04X: csum at %d\n", be16_to_cpu(skb->protocol), skb->csum);
         break;
   }
   return;
}



						Thanks,
							Petr Vandrovec



------
Date: Mon, 18 Aug 2003 05:37:11 +0200
From: Petr Vandrovec <vandrove@vc.cvut.cz>
To: davem@redhat.com
Cc: netdev@oss.sgi.com
Subject: dev_add_pack and hardware checksumming
Message-ID: <20030818033711.GA21360@vana.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.4i
Status: RO
Content-Length: 992
Lines: 23

Hi Dave,
  VMware uses dev_add_pack() for capturing ethernet traffic generated
by the host and forwarding it to the guest.

  Unfortunately skb at the packet filter input is still in CHECKSUM_HW
state, while skb->csum is relative to the skb->h.raw and
dev_queue_xmit_nit overwrites skb->h.raw with skb->nh.raw. Due to this
I have to peek at packet body to detect protocol & its header length,
reinitialize skb->h.raw with this knowledge and then finally do
skb_checksum_help().

  For me it would be best if dev_queue_xmit_nit could just leave
skb->h.raw alone, usable for skb_checksum_help(), but I assume that it
is not possible due to backward compatibility? Other choice is doing
checksumming in dev_queue_xmit_nit itself, before passing skb down to
the registered packet handlers.

  BTW, it looks to me like that an uninitialized value is leaked in UDP's
checksum field to the packets tcpdump on the host can capture...

                                        Thanks,
                                                Petr Vandrovec
                                                vandrove@vc.cvut.cz


-------
Date: Mon, 18 Aug 2003 20:27:27 +0200
From: Petr Vandrovec <vandrove@vc.cvut.cz>
To: "David S. Miller" <davem@redhat.com>
Cc: netdev@oss.sgi.com
Subject: Re: dev_add_pack and hardware checksumming
Message-ID: <20030818182727.GD999@vana.vc.cvut.cz>
References: <20030818033711.GA21360@vana.vc.cvut.cz> <20030817223851.5185bdee.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030817223851.5185bdee.davem@redhat.com>
User-Agent: Mutt/1.5.4i
Status: RO
Content-Length: 1103
Lines: 29

On Sun, Aug 17, 2003 at 10:38:51PM -0700, David S. Miller wrote:
> On Mon, 18 Aug 2003 05:37:11 +0200
> Petr Vandrovec <vandrove@vc.cvut.cz> wrote:
>
> >   For me it would be best if dev_queue_xmit_nit could just leave
> > skb->h.raw alone,
>
> The AF_PACKET layer depends upon skb->h.raw being set a certain
> way.  Have a look at the dev_add_pack() registered hooks that
> net/packet/af_packet.c uses.

Well, I do not see skb->h.raw used in any way in AF_PACKET hooks...
Probably I missed some deeply nested generic function which accesses
it...

> > Other choice is doing checksumming in dev_queue_xmit_nit itself,
> > before passing skb down to the registered packet handlers.
>
> This is not an option either.  We're specifically not going to
> undo checksum offloading just because tcpdump or some other
> kind of tap is installed.

And what's left, then? I can happilly offload checksum to some
other place down in the chain, but for doing that I must know
where I should put checksum, and currently this information is
unavailable to the packet hook.
                                Best regards,
                                        Petr Vandrovec
