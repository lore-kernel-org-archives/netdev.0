From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Tue, 14 Sep 2010 17:22:31 +0200
Message-ID: <20100914152231.GA13105@redhat.com>
References: <1284410580.13351.10.camel@localhost.localdomain>
 <4C8F3C77.7010302@redhat.com>
 <1284476719.13351.35.camel@localhost.localdomain>
 <201009141721.13202.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <mashirle@us.ibm.com>, Avi Kivity <avi@redhat.com>,
	David Miller <davem@davemloft.net>, xiaohui.xin@intel.com,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30370 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750973Ab0INP2h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Sep 2010 11:28:37 -0400
Content-Disposition: inline
In-Reply-To: <201009141721.13202.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 14, 2010 at 05:21:13PM +0200, Arnd Bergmann wrote:
> On Tuesday 14 September 2010, Shirley Ma wrote:
> > On Tue, 2010-09-14 at 11:12 +0200, Avi Kivity wrote:
> >
> > > That's what io_submit() is for.  Then io_getevents() tells you what
> > > "a 
> > > while" actually was.
> > 
> > This macvtap zero copy uses iov buffers from vhost ring, which is
> > allocated from guest kernel. In host kernel, vhost calls macvtap
> > sendmsg. macvtap sendmsg calls get_user_pages_fast to pin these buffers'
> > pages for zero copy.
> > 
> > The patch is relying on how vhost handle these buffers. I need to look
> > at vhost code (qemu) first for addressing the questions here.
> 
> I guess the best solution would be to make macvtap_aio_write return
> -EIOCBQUEUED when a packet gets passed down to the adapter, and
> call aio_complete when the adapter is done with it.
> 
> This would change the regular behavior of macvtap into a model where
> every write on the file blocks until the packet has left the machine,
> which gives us better flow control, but does slow down the traffic
> when we only put one packet at a time into the queue.
> 
> It also allows the user to call io_submit instead of write in order
> to do an asynchronous submission as Avi was suggesting.
> 
> 	Arnd

I would expect this to hurt performance significantly.
We could do this for asynchronous requests only to avoid the
slowdown.

-- 
MST
