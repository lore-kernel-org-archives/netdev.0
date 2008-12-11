From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user
	space data
Date: Thu, 11 Dec 2008 13:12:14 -0600
Message-ID: <1229022734.3266.67.camel@localhost.localdomain>
References: <494009D7.4020602@vlnb.net> <494012C4.7090304@vlnb.net>
	 <20081210214500.GA24212@ioremap.net>  <4941590F.3070705@vlnb.net>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from accolon.hansenpartnership.com ([76.243.235.52]:52529 "EHLO
	accolon.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751542AbYLKTMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 14:12:12 -0500
In-Reply-To: <4941590F.3070705@vlnb.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-12-11 at 21:16 +0300, Vladislav Bolkhovitin wrote:
> Hi Evgeniy,
> 
> Evgeniy Polyakov wrote:
> > Hi Vladislav.
> > 
> > On Wed, Dec 10, 2008 at 10:04:36PM +0300, Vladislav Bolkhovitin (vst@vlnb.net) wrote:
> >> In the chosen approach new optional field void *net_priv was added to 
> >> struct page. It is enclosed by
> > 
> > There is a huge no-no in networking land on increasing skb.
> > Reason is simple every skb will carry potentially unneded data as long
> > as given option is enabled, and most of the time it will.
> > To break this barrier one has to have (I wanted to write ego, but then
> > decided to replace it with mojo) so huge reason to do this, that it is
> > almost impossible to have.
> > 
> > Something tells me that increasing page structure with 8 bytes because
> > of zero-copy iscsi transfer is not that great idea, since basically every
> > user out there will have it enabled in the distro config and will waste
> > noticeble amount of ram.
> 
> The waste will be only 0.2% of RAM or 2MB per 1GB. Not much. Perhaps, 
> not noticeable for an average user of distro kernels at all. Embedded 
> people, who count each byte, almost always don't need iSCSI, so won't 
> have any problems to disable 
> TCP_ZERO_COPY_TRANSFER_COMPLETION_NOTIFICATION option.

Actually, there are several other considerations:

     1. struct page is a lowmem structure, so increasing its size
        becomes problematic on x86 PAE systems.
     2. The current 64 bit struct page seems to be exactly pushing a
        cacheline boundary.  Increasing it so it spills over will have a
        performance impact

It's the performance problems that will be most critical, I suspect, so
you'll need mm people buy in for doing this.

One thing that leaps immediately to mind is that you could isolate this
to the net layer by putting it in skb_frag_struct.  However, such a move
would require a proper API for this in net ... right now it looks like
you're using the struct page addition to carry this information from
SCSI to net, which is a bit of a layering violation.

James


