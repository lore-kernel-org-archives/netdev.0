From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: udev can't name PS3's network devices correctly
Date: Mon, 14 Apr 2008 14:16:12 +0100
Message-ID: <1208178972.31695.90.camel@pmac.infradead.org>
References: <ftdb3v$tls$1@ger.gmane.org>
	 <20080407143805.GA9492@bongo.bofh.it>
	 <1208167737.31695.32.camel@pmac.infradead.org>
	 <3ae72650804140503g73f8c281w438defb1c6477ba9@mail.gmail.com>
	 <1208175549.31695.67.camel@pmac.infradead.org>
	 <1208177531.2572.26.camel@lov.site>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marco d'Itri <md@linux.it>, Harald Hoyer <harald@redhat.com>,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:44480 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753780AbYDNNQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 09:16:59 -0400
In-Reply-To: <1208177531.2572.26.camel@lov.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-04-14 at 14:52 +0200, Kay Sievers wrote:
> On Mon, 2008-04-14 at 13:19 +0100, David Woodhouse wrote:
> > On Mon, 2008-04-14 at 14:03 +0200, Kay Sievers wrote:
> > > 
> > > >  One thing I don't understand: Don't we already emit a KERNEL== criterion
> > > >  in the case where there is already a udev rule 'reserving' the name that
> > > >  the kernel used for the current device? Why is that one OK, and why only
> > > >  in that case? This patch just makes it consistent.
> > > 
> > > Yes, we do that in the recent udev versions. We only make sure we keep
> > > the enumeration across the same basename, not across different device
> > > names.
> > 
> > Right, but you _only_ do that when you're asked to create a rule for a
> > device where the kernel's name matches a pre-existing rule.
> 
> We do it for all new rules, regardless of pre-existing rules with that
> name. It just does not add KERNEL, if some external tool tried to
> overwrite the kernel name, we write a rule for.

Ah, yes -- that's an improvement on the version in udev-120, which would
only write it if $INTERFACE_NAME wasn't set _AND_ the current interface
name is already reserved by an existing rule.

> Not sure why Fedora rules are mangling INTERFACE_NAME here:
>   https://bugzilla.redhat.com/show_bug.cgi?id=440568#c4

It's for compatibility with older configuration. Before udev, the Fedora
network configuration used to allow you to set a MAC address for each
configured interface, and would rename interfaces accordingly. This
preserves that functionality, automatically converting it to udev rules.

If we were to include the KERNEL== criterion even when $INTERFACE_NAME
is set, that would solve the problem for now.

> > You don't do it consistently --
> 
> Right, we will do that, if there are no other issues coming up with the
> general approach of adding KERNEL matches.

That would be good. :)

> > We probably also want to do the dev_id thing, but maybe not for PS3 and
> > Libertas (since it affects their IPv6 addressing too).
> 
> It can just be in all rules, like the ATTR{type} match, right?

I think so, yes. The only problem I can foresee is if you write rules
with a new kernel (with the patch I just posted), and then boot into an
older kernel. Since the dev_id attribute will no longer exist, your rule
won't match... and you'll get a new rule without the dev_id.

I'm not sure how much we care about that case -- perhaps the latter rule
should have a 'TEST!="dev_id"' criterion? And/or maybe when we generate
rules where dev_id==0x0, we should make it a special case which accepts
either 0x0, or no dev_id attribute at all?

-- 
dwmw2

