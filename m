From: Brian Niebuhr <BNiebuhr@efjohnson.com>
Subject: RE: [Bugme-new] [Bug 16821] New: g_ether no carrier while it is
Date: Wed, 25 Aug 2010 09:42:27 -0500
Message-ID: <BA34378D1528D04CB3C865B8BAB2472B0534D0@transmx01.transcrypt.local>
References: <20100824164006.0bd7b7e8.akpm@linux-foundation.org><559294.8951.qm@web180302.mail.gq1.yahoo.com> <20100824234419.326ce966.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<bugzilla-daemon@bugzilla.kernel.org>,
	<bugme-daemon@bugzilla.kernel.org>, "Greg KH" <greg@kroah.com>,
	<public.avatar@gmail.com>
To: "Andrew Morton" <akpm@linux-foundation.org>,
	"David Brownell" <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:31385 "EHLO
	TX2EHSOBE007.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306Ab0HYOme convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 10:42:34 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <20100824234419.326ce966.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

> -----Original Message-----
> From: Andrew Morton [mailto:akpm@linux-foundation.org] 
> Sent: Wednesday, August 25, 2010 1:44 AM
> To: David Brownell
> Cc: netdev@vger.kernel.org; linux-usb@vger.kernel.org; 
> bugzilla-daemon@bugzilla.kernel.org; 
> bugme-daemon@bugzilla.kernel.org; Greg KH; 
> public.avatar@gmail.com; Brian Niebuhr
> Subject: Re: [Bugme-new] [Bug 16821] New: g_ether no carrier 
> while it is
> 
> On Tue, 24 Aug 2010 22:38:39 -0700 (PDT) David Brownell 
> <david-b@pacbell.net> wrote:
> 
> > 
> > 
> > --- On Tue, 8/24/10, Andrew Morton 
> <akpm@linux-foundation.org> wrote:
> > 
> > > From: Andrew Morton <akpm@linux-foundation.org>
> > > Subject: Re: [Bugme-new] [Bug 16821] New: g ether no 
> carrier while it is
> > > To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
> > > Cc: bugzilla-daemon@bugzilla.kernel.org, 
> bugme-daemon@bugzilla.kernel.org, "Greg KH" <greg@kroah.com>, 
> "David Brownell" <david-b@pacbell.net>, public.avatar@gmail.com
> > > Date: Tuesday, August 24, 2010, 4:40 PM
> > > 
> > > (switched to email.   Please respond via emailed
> > > reply-to-all, not via the
> > > bugzilla web interface).
> > > 
> > > On Mon, 23 Aug 2010 06:24:16 GMT
> > > bugzilla-daemon@bugzilla.kernel.org
> > > wrote:
> > > 
> > > > https://bugzilla.kernel.org/show bug.cgi?id=16821
> > > > 
> > > >                  Summary:
> > > g ether no carrier while it is
> > > >                  Product:
> > > Networking
> > > >                  Version: 2.5
> > > >         Kernel Version: 2.6.3(2 - ok,
> > > 3?, 4-6 - fail)
> > > >                  Platform:
> > > All
> > > >               OS/Version:
> > > Linux
> > > >                 
> > >       Tree: Mainline
> > > >              
> > >       Status: NEW
> > > >                  Severity:
> > > blocking
> > > >                  Priority:
> > > P1
> > > >               Component: Other
> > > >               AssignedTo: acme@ghostprotocols.net
> > > >               ReportedBy: public.avatar@gmail.com
> > > >               Regression: Yes
> > > > 
> > > > 
> > > > After successfully loaded g ether module (with
> > > use eem=0) usb device appears.
> > > > If I configure it at host as ifconfig usb0 blah bah,
> > > than network present, all
> > > > ok. 
> > > > In windows (with RNDIS config), and in linux with
> > > bridge it looks to CARRIER
> > > > state. I get in ip addr state DOWN, NO-CARRIER. That's
> > > why g ether usb device
> > > > in bridge and windows don't work at all.
> > > 
> > > So g ether broke after 2.6.32?
> > > 
> > > Nobody really seems to do much with that USB driver.
> > 
> > That's changed then.  There used to be boxes that
> > relied on it for their network connectivity...
> 
> I meant not much development happens there.
> 
> > Adding EEM support was something... I think the
> > issue might be driver changes since last it was
> > seriously tested in bridge configs (for which
> > the link state, such as carrier, matters LOTS.)
> 
> Thanks.  Let's cc Brian.

It is possible that I broke something.  Most of the changes for EEM were
isolated, but I did make a couple of changes to the core ethernet code
to make wrap() and unwrap() work correctly for EEM.  I don't fully
understand the issue being described here, but when I originally
submitted the patch I had a couple of concerns I noted that might be
related.  I'll quote them here:

Issue 1.  I changed the semantics of the wrap/unwrap callbacks in struct
gether as follows.  This change necessitated a modification of the rndis
gadget.

    wrap():
	old semantics: Always copies the sk_buff.   Caller is
responsible
	    for freeing original sk_buff.
	new semantics: Only copies if necessary.  For EEM it will often
not
	    be necessary since the 2-byte EEM header should fit within
the
	    reserved space.  wrap() is responsible for freeing the
original
	    sk_buff, if necessary.

    unwrap():
	old semantics: sk_buff that comes out is the same is the one
that
	    went in, only with extra protocol trimmed off.
	new semantics: An sk_buff list is returned since one USB request
	    could have multiple ethernet frames.  The sk_buff that was
	    passed in is consumed by unwrap() (or placed on the queue).

Issue 2.  The wrap/unwrap callbacks now use port_usb from struct
eth_dev, so the appropriate spinlock is held with irqs disabled for the
duration of the wrap() or unwrap() callback.  I'm thinking that might
not be the best idea.

Related to the above issues, there are a couple pieces of code in my
patch that may have caused the bug:

- The problem could be in rndis_add_header or rndis_rm_hdr, but I really
doubt it.  These functions didn't functionally change in any way - the
only thing that changed was how the sk_buffs were passed and who was
responsible for cleaning them up.  

- The most likely source of the issue is in rx_complete() or
eth_start_xmit() in u_ether.c where I made the change to use the new
wrap/unwrap semantics that were required for EEM.  However since I don't
totally understand the bug being reported, I'm not sure exactly what the
problem could be.  I'm willing to help out in any way, but many of you
have more experience with this code than I do and may be able to spot
some issue that I missed.  


> > 
> > > I wonder if some
> > > changes in core networking could have triggered this?
> > 
> > Wouldn't be my first thought; but might be.
> > 
> > ISTR getting link/carrier state to behave in
> > the first place (with just CDC and RNDIS) was
> > complex.  If it wasn't carefully re-tested after
> > EEM was added, breakage may have been overlooked.

I did not test that particular case, so it is quite possible that I
broke something.


