From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Who/What is supposed to remove IPv6 address from interface when moving from one network to another ?
Date: Mon, 18 Mar 2013 19:58:08 +0100
Message-ID: <20130318185808.GB2740@order.stressinduktion.org>
References: <CAF6-1L4=xACZdqvJ6AZL4XkY17N0pC9PnPfNfK9Tk7QB47c1tw@mail.gmail.com> <CAF6-1L5cxguK8tHxjMACZJ8xNmAXLLXwP086eF4_SEctZdiZ3g@mail.gmail.com> <1363290495.1643.29.camel@dcbw.foobar.com> <CAKD1Yr1=1kfcSmRYgnrYQBhNPPc=nquB2c1jLbopbvqz848cxQ@mail.gmail.com> <20130318183407.GA2740@order.stressinduktion.org> <CAKD1Yr37t2RJm-fmz=mVYcYWerM5Bu1O1cJMLEqSh=ogvxMrGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Dan Williams <dcbw@redhat.com>,
	Sylvain Munaut <s.munaut@whatever-company.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42612 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753484Ab3CRS6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 14:58:09 -0400
Content-Disposition: inline
In-Reply-To: <CAKD1Yr37t2RJm-fmz=mVYcYWerM5Bu1O1cJMLEqSh=ogvxMrGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 18, 2013 at 11:39:02AM -0700, Lorenzo Colitti wrote:
> On Mon, Mar 18, 2013 at 11:34 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> >> Actually, it *does* trigger events on carrier change: it creates the
> >> addresses when you connect. It just doesn't delete them when you
> >> disconnect. So you can get addresses without a userspace daemon, but
> >> you can never delete them without a userspace daemon.
> >
> > Not directly related, but I wonder if we should treat the change of the
> > mac address as a carrier change in ipv6 to create a new ll address. I
> > did not find any satisfying answer yet.
> 
> Yes, we should - because if we're attaching to a new link, there might
> be someone with a duplicate IPv6 address on it, so we'd need to
> perform DAD.

I think there is a misunderstanding:

I was thinking just about the case where we change the mac address of
some interface without changing anything else (not changing link status):

# ip l a type dummy
# ip l s up dev dummy0
# ip l l dev dummy0
|	14: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT 
|	    link/ether ca:eb:dd:14:ad:15 brd ff:ff:ff:ff:ff:ff
# ip -6 a l dev dummy0
|	14: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 
|	    inet6 fe80::c8eb:ddff:fe14:ad15/64 scope link 
|	       valid_lft forever preferred_lft forever
# ip l s a ca:eb:dd:14:ad:16 dev dummy0
# ip l l dev dummy0
|	14: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT 
|	    link/ether ca:eb:dd:14:ad:16 brd ff:ff:ff:ff:ff:ff
# ip -6 a l dev dummy0
|	14: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 
|	    inet6 fe80::c8eb:ddff:fe14:ad15/64 scope link 
|	       valid_lft forever preferred_lft forever

Currently we don't generate any new ll address. I wondered if this is
correct.  This e.g. happens if creating bridges with libvirt. It could
also be just a acceptable circumstance, I currently don't know. If people
depend on the mapping from mac address to ipv6 ll address perhaps this
is something that should be addressed.
