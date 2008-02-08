From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [patch 1/7] typhoon section fix
Date: Fri, 8 Feb 2008 20:03:40 +0100
Message-ID: <20080208190340.GA31072@uranus.ravnborg.org>
References: <200802081120.m18BK6cL021623@imap1.linux-foundation.org> <1202479150.4349.0.camel@obelisk.thedillows.org> <20080208095233.722d7c47.akpm@linux-foundation.org> <1202494917.5298.3.camel@lap75545.ornl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	jeff@garzik.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>,
	Jan Beulich <jbeulich@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:48777 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935217AbYBHTDf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2008 14:03:35 -0500
Content-Disposition: inline
In-Reply-To: <1202494917.5298.3.camel@lap75545.ornl.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 08, 2008 at 01:21:57PM -0500, David Dillow wrote:
> 
> On Fri, 2008-02-08 at 09:52 -0800, Andrew Morton wrote:
> > On Fri, 08 Feb 2008 08:59:10 -0500 David Dillow <dave@thedillows.org> wrote:
> > > On Fri, 2008-02-08 at 03:11 -0800, akpm@linux-foundation.org wrote:
> > > > From: Andrew Morton <akpm@linux-foundation.org>
> > > > 
> > > > gcc-3.4.4 on powerpc:
> > > > 
> > > > drivers/net/typhoon.c:137: error: version causes a section type conflict
> > > > 
> > > > Cc: Jeff Garzik <jeff@garzik.org>
> > > > Cc: Sam Ravnborg <sam@ravnborg.org>
> > > > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > > 
> > > > -static const char version[] __devinitdata =
> > > > +static char version[] __devinitdata =
> > > >      "typhoon.c: version " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
> > > 
> > > Wouldn't going to __devinitconst be better? I'll try to whip up a patch
> > > and test-compile it.
> > 
> > Sam told me that doesn't work right, that this approach is the one to use
> > and, iirc, that __devinitcont and friends will be removed.
> > 
> > I'm not sure why, actually.  I think I missed that dicussion.

After introducing dedicated sections for __devinit, __devinitdata & friends
and introducing __devinitconst for const data we started to see
section type conflict _errors_ emitted from gcc for certain architectures.
64bit powerpc and ia64 being two of them.

That was rooted down by Al to the following:
===================================================================
; cat >a.c <<'EOF'
const char foo[] __attribute__ ((__section__(".blah"))) = "";
const char * const bar __attribute__((__section__(".blah"))) = "";
EOF
; gcc -m32 -S a.c
; gcc -m64 -S a.c
a.c:2: error: bar causes a section type conflict
;
===================================================================

Which tells us that the same data in some cases are put in a readonly
section and in other cases not.
And when we force data for tow different variables where gcc thinks one is
const and the other is not const to the same section gcc errros
out with the "section type conflict" error.

And this is becoming increasingly visible when people start to constify
the data all around and do test build on x86 64bit that does not exhibit
this behaviour.

The rationale behind the increased constification of data is to get
improved use of the DEBUG_RODATA thing.
Another good reason s that this is a good way to let gcc catch accidental
writes to data that otherwise should have been read-only.

But if we advocate for constification of data than we should have
a reliable way to detect the section type conflict errors on x86
(at least 64 bit) which we do not have. Missing that will casue us to see
an increasing flood of error reports from our power pc and ia64 builders.

The rationale behind __devinitconst was to create a dedicated section
for data marked read-only by gcc and thus avoiding the
section type conflict.

But as shown by the above code snippet this is not easy.
For x86 (32 + 64bit) both variables end up in READ-ONLY section.
For Powerpc 64 bit the variable bar end up in a read-write section.
And I see no way to check this for a x86 build so we warn early and
with the most widely used tool-chain.

So do we have other options that to drop the constification and thus
dropping the __devinitconst and the other __*const annotations - I think not :-(


	Sam
