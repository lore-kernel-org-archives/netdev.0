From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/2] [PCI] Check that MWI bit really did get set
Date: Sun, 15 Oct 2006 16:18:34 -0700
Message-ID: <20061015161834.f96a0761.akpm@osdl.org>
References: <1160161519800-git-send-email-matthew@wil.cx>
	<20061015191631.DE49D19FEC8@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
	<20061015123432.4c6b7f15.akpm@osdl.org>
	<200610151545.59477.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, matthew@wil.cx,
	val_henson@linux.intel.com, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org,
	gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:25268 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751250AbWJOXWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2006 19:22:00 -0400
To: David Brownell <david-b@pacbell.net>
In-Reply-To: <200610151545.59477.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 15 Oct 2006 15:45:58 -0700
David Brownell <david-b@pacbell.net> wrote:

> > In that case its interface is misdesigned, because it doesn't discriminate
> > between "yes-it-does/no-it-doesn't" (which we don't want to report, because
> > either is expected and legitimate) and "something screwed up", which we do
> > want to report, because it is always unexpected.
> 
> You mis-understand.  It's completely legit for the driver not to care.
> 
> I agree that set_mwo() should set MWI if possible, and fail cleanly
> if it couldn't (for whatever reason).  Thing is, choosing to treat
> that as an error must be the _driver's_ choice ... it'd be wrong to force
> that policy into the _interface_ by forcing must_check etc.

No.  If pci_set_mwi() detects an unexpected error then the driver should
take some action: report it, recover from it, fail to load, etc.  If the
driver fails to do any of this then it's a buggy driver.

You, the driver author _do not know_ what pci_set_mwi() does at present, on
all platforms, nor do you know what it does in the future.  For you the
driver author to make assumptions about what's happening inside
pci_set_mwi() is a layering violation.  Maybe the bridge got hot-unplugged.
 Maybe the attempt to set MWI caused some synchronous PCI error.  For
example, take a look at the various implementations of pci_ops.read()
around the place - various of them can fail for various reasons.  

Now it could be that an appropriate solution is to make pci_set_mwi()
return only 0 or 1, and to generate a warning from within pci_set_mwi()
if some unexpected error happens.  In which case it is legitimate for
callers to not check for errors.

This is not a terribly important issue, and it is far from the worst case
of missed error-checking which we have in there. 
