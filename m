From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user
	space data
Date: Fri, 12 Dec 2008 13:37:53 -0600
Message-ID: <1229110673.3262.94.camel@localhost.localdomain>
References: <494009D7.4020602@vlnb.net> <494012C4.7090304@vlnb.net>
	 <20081210214500.GA24212@ioremap.net>  <4941590F.3070705@vlnb.net>
	 <1229022734.3266.67.camel@localhost.localdomain>
	 <4942BAB8.4050007@vlnb.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>, linux-scsi@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Jeff Garzik <jeff@garzik.org>,
	Boaz Harrosh <bharrosh@panasas.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net,
	Bart Van Assche <bart.vanassche@gmail.com>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	netdev@vger.kernel.org
To: Vladislav Bolkhovitin <vst@vlnb.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <4942BAB8.4050007@vlnb.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2008-12-12 at 22:25 +0300, Vladislav Bolkhovitin wrote:
> > One thing that leaps immediately to mind is that you could isolate this
> > to the net layer by putting it in skb_frag_struct.  However, such a move
> > would require a proper API for this in net ...
> 
> To have net_priv analog in skb was the first idea I was tried. But I 
> quickly gave up, because it would required that all the pages in each 
> skb_frag_struct be from the same originator, i.e. with the same 
> net_priv. It is unpractical to change all the operations with skb's to 
> forbid merging them, if they have different net_priv. There are too many 
> such places in very not obvious code pieces.

Actually, I said carry in skb_frag_struct not skb ... that allows for
merging of skbs with different page sources.  The API changes would have
to allow setting at this level.

> > right now it looks like
> > you're using the struct page addition to carry this information from
> > SCSI to net, which is a bit of a layering violation.
> 
> I don't think there is any layering violation here. Just lower layer 
> notifies upper layer that transmission of a page has finished. It's done 
> a bit not straightforward, but still basically the same as, for 
> instance, on_free_cmd() callbacks which SCST core uses to notify target 
> drivers and dev handlers that the corresponding command is about to be 
> freed, so they can free associated with it data as well.

The way you transmit the information you want notification is done by a
private tag in struct page, so you're carrying the information on an
object that belongs to neither layer ... that's the violation.  It's
essentially an extension of the net API that goes via the mm layer.

James


