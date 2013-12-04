From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH v2] macvlan: Support creating macvtaps from macvlans
Date: Wed, 4 Dec 2013 15:23:14 +0100
Message-ID: <20131204142314.GB28692@unicorn.suse.cz>
References: <1386043991-4372-1-git-send-email-kevin@pentabarf.net>
 <1386068122-12039-1-git-send-email-kevin@pentabarf.net>
 <529E0421.2090504@gmail.com>
 <20131203194707.GA32367@lion.mk-sys.cz>
 <529F3539.2070305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kevin Wallace <kevin@pentabarf.net>, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51024 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753994Ab3LDOXQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Dec 2013 09:23:16 -0500
Content-Disposition: inline
In-Reply-To: <529F3539.2070305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 04, 2013 at 08:59:21AM -0500, Vlad Yasevich wrote:
> On 12/03/2013 02:47 PM, Michal Kubecek wrote:
> > On Tue, Dec 03, 2013 at 11:17:37AM -0500, Vlad Yasevich wrote:
> >>
> >> the other question is should this be done in a loop?  What happens if
> >> you have nested namespaces?
> > 
> > Nested namespaces are not a problem, what would be a problem, would be
> > having a macvlan (macvtap) device on top of another macvlan. But the
> > purpose of this particular code is to prevent it and use the underlying
> > "real" device instead. That's why unlike vlan_dev_real_dev(),
> > macvlan_dev_real_dev() doesn't need to recurse.
> 
> Wait,  so you have a namespace that uses macvlan to access the net.
> That macvlan is configured on top of another macvlan, so you need to
> get to the lower level device.  I understand that.  What I am asking
> is that what happens if you have a namespace within a namespace with
> the same network access restrictions.  The code as is, will think that
> the first level macvlan is the real device.  Is this setup practical...

My understanding is this:

We have eth0, a real ethernet device in init_net. We create a macvlan
device mv1 on top of it and put it into a namespace, say ns1. Inside
ns1, we can't see eth0 so that we cannot do

  ip link add mv2 link eth0 type macvlan mode bridge

The purpose of this code is to allow

  ip link add mv2 link mv1 type macvlan mode bridge

but to use eth0 as lowerdev of mv2 instead. If we then put mv2 into
another namespace ns2, there is still no problem because its lowerdev is
also eth0 (even if we cannot see it inside ns2) so that

  ip link add mv3 link mv2 type macvlan mode bridge

in fact creates mv3 with lowerdev eth0 again.

However, what I'm not sure about is whether there is something to
prevent building e.g. a macvlan on top of a (802.1q) VLAN on top of
a macvlan.

                                                     Michal Kubecek
