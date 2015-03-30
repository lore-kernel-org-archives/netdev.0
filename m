From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 2/2] ipvlan: always allow the broadcast MAC address
Date: Mon, 30 Mar 2015 09:37:10 -0500
Message-ID: <1427726230.1913.9.camel@redhat.com>
References: <1427409698.18540.11.camel@redhat.com>
	 <1427409822.18540.13.camel@redhat.com>
	 <CAF2d9jjxoKFoX7bvJ7+cA685iBT9fPgjvjTKe8ppE_J3oWJgrQ@mail.gmail.com>
	 <CAF2d9jh_-DxxUMcTjFK3TUAJhC=B9ORrmH0=tVH1KBiWsYPpLg@mail.gmail.com>
	 <20150328193254.6c79784d@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>,
	linux-netdev <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42113 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752735AbbC3Ogw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 10:36:52 -0400
In-Reply-To: <20150328193254.6c79784d@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-03-28 at 19:32 +0100, Jiri Benc wrote:
> On Fri, 27 Mar 2015 22:56:15 -0700, Mahesh Bandewar wrote:
> > The current logic disables broadcast by default and enables only when
> > an IPv4 address is added. If this is inverted and -
> > enables broadcast by default but disables it when only IPv6
> > address(es) is / are added. These links can have multiple addresses
> > and hence have to be careful if any one of those is IPv4 then
> > broadcast bit has to be set.
> 
> You'd have to be careful and ignore IPv6 link local addresses.
> Those are added automatically whenever IPv6 is enabled and their
> presence does not mean the network is not IPv4 only.
> 
> But I don't like such magic behavior. It would lead to DHCP sometimes
> working and sometimes not in mixed v4/v6 environment depending on
> whether DHCPv4 or SLAAC was faster.
> 
> Could we perhaps add a flag when creating ipvlan interface stating
> whether IPv4 broadcast should be always enabled? Or, rather, the other
> way round - whether it should be disabled by default. Call it "nodhcp"
> or so.
> 
> Btw, speaking about IPv6 link local addresses, these actually do not
> work with ipvlan correctly. I'm getting DAD failures if I have more
> than one ipvlan interface, which is no wonder. This means that ipvlan
> cannot work with IPv6 reliably by default (unless you take care of ll
> address assignment and ensure all ipvlan interfaces get a different
> one).

ipvlan doesn't set dev_id.  Once dev_id is set the kernel's IPv6LL
address generation code will assign a different LL address to each
ipvlan interface created from the same physical interface, despite that
they have the same MAC address.

But of course you'd have to be careful to assign a *different* dev_id
than any of that physical interface's non-ipvlan children too, and I
have no idea how that would work since dev_id is currently done
per-driver.  eg, if you have a physical interface with dev_id=1 which
you then create an ipvlan from, that ipvlan must not use dev_id=1 or it
will be assigned the same IPv6LL address as the parent.

Dan
