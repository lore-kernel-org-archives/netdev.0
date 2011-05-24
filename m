From: Krishna Kumar2 <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv2 10/14] virtio_net: limit xmit polling
Date: Tue, 24 May 2011 18:20:35 +0530
Message-ID: <OF2D4A7890.FFA91132-ON6525789A.0043E0AC-6525789A.00464690@in.ibm.com>
References: <cover.1305846412.git.mst@redhat.com>
	<aced8619c07018b5495f9ceb2c02d4fbf897a098.1305846412.git.mst@redhat.com>
	<877h9kvlps.fsf@rustcorp.com.au>
	<20110522121008.GA12155@redhat.com>
	<87boyutbjg.fsf@rustcorp.com.au>
	<20110523111900.GB27212@redhat.com>
	<OFEED174CD.D3C9A726-ON6525789A.002661D5-6525789A.002B26ED@in.ibm.com>
	<20110524091255.GB16886@redhat.com>
	<OF69E520FD.340352AC-ON6525789A.003308A2-6525789A.0033F2DF@in.ibm.com>
	<20110524112901.GB17087@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20110524112901.GB17087-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote on 05/24/2011 04:59:39 PM:

> > > > Maybe Rusty means it is a simpler model to free the amount
> > > > of space that this xmit needs. We will still fail anyway
> > > > at some time but it is unlikely, since earlier iteration
> > > > freed up atleast the space that it was going to use.
> > >
> > > Not sure I nderstand.  We can't know space is freed in the previous
> > > iteration as buffers might not have been used by then.
> >
> > Yes, the first few iterations may not have freed up space, but
> > later ones should. The amount of free space should increase
> > from then on, especially since we try to free double of what
> > we consume.
>
> Hmm. This is only an upper limit on the # of entries in the queue.
> Assume that vq size is 4 and we transmit 4 enties without
> getting anything in the used ring. The next transmit will fail.
>
> So I don't really see why it's unlikely that we reach the packet
> drop code with your patch.

I was assuming 256 entries :) I will try to get some
numbers to see how often it is true tomorrow.

> > I am not sure of why it was changed, since returning TX_BUSY
> > seems more efficient IMHO.
> > qdisc_restart() handles requeue'd
> > packets much better than a stopped queue, as a significant
> > part of this code is skipped if gso_skb is present
>
> I think this is the argument:
> http://www.mail-archive.com/virtualization-cunTk1MwBs/ROKNJybVBZg@public.gmane.org
> foundation.org/msg06364.html

Thanks for digging up that thread! Yes, that one skb would get
sent first ahead of possibly higher priority skbs. However,
from a performance point, TX_BUSY code skips a lot of checks
and code for all subsequent packets till the device is
restarted. I can test performance with both cases and report
what I find (the requeue code has become very simple and clean
from "horribly complex", thanks to Herbert and Dave).

> > (qdisc
> > will eventually start dropping packets when tx_queue_len is
>
> tx_queue_len is a pretty large buffer so maybe no.

I remember seeing tons of drops (pfifo_fast_enqueue) when
xmit returns TX_BUSY.

> I think the packet drops from the scheduler queue can also be
> done intelligently (e.g. with CHOKe) which should
> work better than dropping a random packet?

I am not sure of that - choke_enqueue checks against a random
skb to drop current skb, and also during congestion. But for
my "sample driver xmit", returning TX_BUSY could still allow
to be used with CHOKe.

thanks,

- KK
