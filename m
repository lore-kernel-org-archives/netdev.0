From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: RE: [Xen-devel] [RFC PATCH 3/6] netback: switch to NAPI + kthread
 model
Date: Mon, 16 Jan 2012 11:09:33 +0000
Message-ID: <1326712173.17210.412.camel@zakaz.uk.xensource.com>
References: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com>
	 <1326473949-22389-4-git-send-email-wei.liu2@citrix.com>
	 <4F107625.7090601@citrix.com> <1326706394.5285.5.camel@liuw-desktop>
	 <1326710711.17210.411.camel@zakaz.uk.xensource.com>
	 <291EDFCB1E9E224A99088639C4762022B5991BEC4D@LONPMAILBOX01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	David Vrabel <david.vrabel@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:27886 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228Ab2APLJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 06:09:34 -0500
In-Reply-To: <291EDFCB1E9E224A99088639C4762022B5991BEC4D@LONPMAILBOX01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-01-16 at 10:56 +0000, Paul Durrant wrote:
> > -----Original Message-----
> > From: xen-devel-bounces@lists.xensource.com [mailto:xen-devel-
> > bounces@lists.xensource.com] On Behalf Of Ian Campbell
> > Sent: 16 January 2012 10:45
> > To: Wei Liu (Intern)
> > Cc: netdev@vger.kernel.org; xen-devel@lists.xensource.com; David Vrabel;
> > konrad.wilk@oracle.com
> > Subject: Re: [Xen-devel] [RFC PATCH 3/6] netback: switch to NAPI + kthread
> > model
> > 
> > On Mon, 2012-01-16 at 09:33 +0000, Wei Liu (Intern) wrote:
> > > On Fri, 2012-01-13 at 18:21 +0000, David Vrabel wrote:
> > > > On 13/01/12 16:59, Wei Liu wrote:
> > > > > This patch implements 1:1 model netback. We utilizes NAPI and
> > > > > kthread to do the weight-lifting job:
> > > > >
> > > > >   - NAPI is used for guest side TX (host side RX)
> > > > >   - kthread is used for guest side RX (host side TX)
> > > > >
> > > > > This model provides better scheduling fairness among vifs. It also
> > > > > lays the foundation for future work.
> > > > >
> > > > > The major defect for the current implementation is that in the
> > > > > NAPI poll handler we don't actually disable interrupt. Xen stuff
> > > > > is different from real hardware, it requires some other tuning of
> > > > > ring macros.
> > > >
> > > > RING_FINAL_CHECK_FOR_REQUESTS() looks it does the correct thing to
> > me.
> > > >
> > > > David
> > >
> > > I need to stop the other end from generating events, so
> > > RING_FINAL_CHECK_FOR_REQUESTS is not the right answer I think.
> > 
> > What you need is a variant which sets req_event some large distance into
> > the future instead of to just req_cons + 1. Or possibly it should be set to just
> > in the past (e.g. req_cons - 1). Call it something like
> > RING_POLL_FOR_REQUESTS().
> > 
> 
> Can you just simply avoid calling RING_FINAL_CHECK_FOR_REQUESTS()
> unless you actually want to re-enable 'interrupts'? All it does is
> manipulate the event pointer and tell you whether there are still
> unconsumed requests.

Perhaps but I think you'd want to keep moving the event pointer to
handle wrap around, i.e. by keeping it always either far enough away or
right behind. (I think "req_cons - 1" is probably the correct option
BTW).

Ian.
