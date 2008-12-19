From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user space data
Date: Sat, 20 Dec 2008 01:33:15 +0300
Message-ID: <20081219223314.GA2736@ioremap.net>
References: <494009D7.4020602@vlnb.net> <494012C4.7090304@vlnb.net> <494C0255.8010208@goop.org> <20081219220452.GB704@ioremap.net> <494C1E5E.7070809@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vladislav Bolkhovitin <vst@vlnb.net>, linux-scsi@vger.kernel.org,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Jeff Garzik <jeff@garzik.org>,
	Boaz Harrosh <bharrosh@panasas.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net,
	Bart Van Assche <bart.vanassche@gmail.com>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <494C1E5E.7070809@goop.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 19, 2008 at 02:21:18PM -0800, Jeremy Fitzhardinge (jeremy@goop.org) wrote:
> >There maybe a problem though, if iscsi will run over xen network, but in
> >this case xen may copy the data, or iscsi may do that after determining
> >that underlying network device does not allow shared info destructor
> >(vis device/route flag for example).
> >  
> 
> Xen only needs the callback in the case of traffic originating in 
> another Xen domain.  If iscsi is involved, it will be running in the 
> other domain, and so all its callbacks and so on will happen there.  
> There's no conflict.

That's good news.

> >>Wouldn't you only need to do the lookup on the last put?
> >>
> >>An external lookup table might well for for us, if the net_put_page() 
> >>change is acceptable to the network folk.
> >>    
> >
> >That sounds like the best solution for this problem.
> >  
> 
> An external lookup would just need to change put_page -> net_put_page, I 
> think.

It is not needed I think, having skb shared info destructor has access
to the all pages in that skb.

> >David, will you accept shared info destructor?
> >  
> 
> I'm not very familiar with the network stack, but am I right in assuming 
> that the shared_info destructor would be called when the network stack 
> has finished with all the pages it refers to?  And those pages could be 
> the combination of pages separately submitted in different skbs?

Shared info is freed when there are no skbs referring to the shared info
in question. Skb holds all pages in shared info in the fraglist array,
so when it is about to be freed, it means that network stack does not
use it (particulary it will putpage every page in fraglist). Usually
there are two skbs in the network stack per packet in TCP (allocated at
once though via fastclone mechanims): one is provided to the device
(and will be freed there) and another one is placed into retransmit
queue, where it will be located and freed when ack has been received.

There may be another layers which may clone skb, but its shared info
structure (shared between the clones) will only be freed when all users
freed appropriate cloned skbs.

-- 
	Evgeniy Polyakov
