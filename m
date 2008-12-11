From: Vladislav Bolkhovitin <vst@vlnb.net>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user
 space data
Date: Thu, 11 Dec 2008 21:16:47 +0300
Message-ID: <4941590F.3070705@vlnb.net>
References: <494009D7.4020602@vlnb.net> <494012C4.7090304@vlnb.net> <20081210214500.GA24212@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-scsi@vger.kernel.org,
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
	netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:52286 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755258AbYLKSRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 13:17:01 -0500
In-Reply-To: <20081210214500.GA24212@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

Evgeniy Polyakov wrote:
> Hi Vladislav.
> 
> On Wed, Dec 10, 2008 at 10:04:36PM +0300, Vladislav Bolkhovitin (vst@vlnb.net) wrote:
>> In the chosen approach new optional field void *net_priv was added to 
>> struct page. It is enclosed by
> 
> There is a huge no-no in networking land on increasing skb.
> Reason is simple every skb will carry potentially unneded data as long
> as given option is enabled, and most of the time it will.
> To break this barrier one has to have (I wanted to write ego, but then
> decided to replace it with mojo) so huge reason to do this, that it is
> almost impossible to have.
> 
> Something tells me that increasing page structure with 8 bytes because
> of zero-copy iscsi transfer is not that great idea, since basically every
> user out there will have it enabled in the distro config and will waste
> noticeble amount of ram.

The waste will be only 0.2% of RAM or 2MB per 1GB. Not much. Perhaps, 
not noticeable for an average user of distro kernels at all. Embedded 
people, who count each byte, almost always don't need iSCSI, so won't 
have any problems to disable 
TCP_ZERO_COPY_TRANSFER_COMPLETION_NOTIFICATION option.

Also, as I wrote, iSCSI-SCST can work without this patch or with 
TCP_ZERO_COPY_TRANSFER_COMPLETION_NOTIFICATION option disabled, but with 
user space device handlers it will work considerably worse. Only few 
distro kernels users need an iSCSI target and only few among such users 
need to use a user space device handler. So, option 
TCP_ZERO_COPY_TRANSFER_COMPLETION_NOTIFICATION can be safely disabled in 
default configs of distro kernels. People who need both iSCSI target 
*and* fast working user space device handler would simply enable that 
option and rebuild the kernel. Rejecting this patch provides much worse 
alternative: those people would also have to *patch* the kernel at 
first, only then enable that option, then rebuild the kernel.

> The same problem of not sending any kind of notification to the user
> when his pages are 'acked' by receiving some packet or freeing the data
> exists long ago and was tried to be fixed several times.
> 
> The most applicable to your case maybe DST experience. DST is a block
> layer device and all its pages starting from quite recent kernels are
> not allowed to be slab ones (xfs was the last one who provided slab
> pages in the bios), so each page has two 'unused' pointers in lru list
> entry, which you may reuse. If scsi layer may have slab pages from some
> place (although this does not sound like a good idea, ->sendpage() will
> bug on on them anyway), this hack will not work, otherwise you only need
> to have net_page_get/put stuff in and do not mess with increasing page.
> And this was tested 3-4 kernel releases ago, so things may be changed.

I've just rechecked if any of struct page fields can be shared with 
net_priv field. Unfortunately, it looks like none among the mandatory 
fields:

  - Transmitting pages can be mapped in some user space, so sharing in 
unions with _mapcount, mapping and index fields isn't possible

  - Transmitting pages can be in the page cache, so sharing lru field 
isn't possible as well

It might, however, be shared with field "virtual", since SCST allocates 
only lowmem pages, but on non-HIGHMEM kernels and most HIGHMEM kernels 
WANT_PAGE_VIRTUAL isn't defined, so it will change basically nothing.

> Another appropach is to increase skb's shared data (at the end of the
> skb->data), and this approach was not frowned upon too much either, but
> it requires to mess with skb->destructor, which may not be appropriate
> in some cases. If iscsi does not use sockets (it does iirc), things are
> much simpler.

As I wrote, approach to use net_priv on the skb level was examined, but 
rejected as unpractical. Simply too many places should be modified to 
prevent merging skb's with different net_priv-like labels and those 
places are too inobvious. Implementation of this approach and, 
especially, maintenance it would be just a nightmare.

Thanks,
Vlad

