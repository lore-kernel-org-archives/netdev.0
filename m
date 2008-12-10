From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user space data
Date: Thu, 11 Dec 2008 00:45:00 +0300
Message-ID: <20081210214500.GA24212@ioremap.net>
References: <494009D7.4020602@vlnb.net> <494012C4.7090304@vlnb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Vladislav Bolkhovitin <vst@vlnb.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <494012C4.7090304@vlnb.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vladislav.

On Wed, Dec 10, 2008 at 10:04:36PM +0300, Vladislav Bolkhovitin (vst@vlnb.net) wrote:
> In the chosen approach new optional field void *net_priv was added to 
> struct page. It is enclosed by

There is a huge no-no in networking land on increasing skb.
Reason is simple every skb will carry potentially unneded data as long
as given option is enabled, and most of the time it will.
To break this barrier one has to have (I wanted to write ego, but then
decided to replace it with mojo) so huge reason to do this, that it is
almost impossible to have.

Something tells me that increasing page structure with 8 bytes because
of zero-copy iscsi transfer is not that great idea, since basically every
user out there will have it enabled in the distro config and will waste
noticeble amount of ram.

The same problem of not sending any kind of notification to the user
when his pages are 'acked' by receiving some packet or freeing the data
exists long ago and was tried to be fixed several times.

The most applicable to your case maybe DST experience. DST is a block
layer device and all its pages starting from quite recent kernels are
not allowed to be slab ones (xfs was the last one who provided slab
pages in the bios), so each page has two 'unused' pointers in lru list
entry, which you may reuse. If scsi layer may have slab pages from some
place (although this does not sound like a good idea, ->sendpage() will
bug on on them anyway), this hack will not work, otherwise you only need
to have net_page_get/put stuff in and do not mess with increasing page.
And this was tested 3-4 kernel releases ago, so things may be changed.

Another appropach is to increase skb's shared data (at the end of the
skb->data), and this approach was not frowned upon too much either, but
it requires to mess with skb->destructor, which may not be appropriate
in some cases. If iscsi does not use sockets (it does iirc), things are
much simpler.

Hope this helps.

-- 
	Evgeniy Polyakov
