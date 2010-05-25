From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 0/2] fixes to arp_notify for virtual machine migration
 use case
Date: Tue, 25 May 2010 10:20:01 +0100
Message-ID: <1274779201.24218.7164.camel@zakaz.uk.xensource.com>
References: <1273671554.7572.11190.camel@zakaz.uk.xensource.com>
	 <20100523.233722.232536798.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	Jeremy Fitzhardinge <Jeremy.Fitzhardinge@citrix.com>,
	"stable@kernel.org" <stable@kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:9914 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752310Ab0EYJUH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 May 2010 05:20:07 -0400
In-Reply-To: <20100523.233722.232536798.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-05-24 at 07:37 +0100, David Miller wrote:
> From: Ian Campbell <Ian.Campbell@citrix.com>
> Date: Wed, 12 May 2010 14:39:14 +0100
> 
> > Ian Campbell (2):
> >       arp_notify: generate broadcast ARP reply not request.
> >       arp_notify: generate arp_notify event on NETDEV_CHANGE too
> 
> I don't agree with these changes.
> 
> For the first one, I think the documentation is just wrong and the
> code is what expresses the intent.  The idea is not to spam the
> world with a broadcast, only interested parties.

OK. So what is currently sent is a gratuitous ARP request which I hadn't
realised was a valid/normal thing to send but a bit of research shows
that it is.

In terms of MAC learning tables (which is what is interesting in the VM
migration case) I think the gratuitous ARP request and reply are
equivalent.

I guess the difference is that an ARP request doesn't cause everyone to
add an entry to their ARP cache, whereas a bcast ARP reply would cause
an ARP cache entry to appear even on hosts which may never talk to the
VM. Is that what you meant by spamming the world?

Anyway, I'll patch the docs instead in my next submission.

> Patch #2 I have major issues with, carriers flapping occaisionally is
> very common.  I have several interfaces which do this even on lightly
> loaded networks.  Iff we decide to do something like this (big "if")
> it would need to be rate limited so that it doesn't trigger due to
> normal flapping.

FWIW arp_notify is an option which is disabled by default.

> If you want your VM networking devices to trigger this event maybe
> the best thing to do is to create a special notification which
> allows us to prevent from doing this ARP notify for spurious physical
> network device carrier flaps.

I actually started down this path before I figured out how to make the
existing notifications work for my use cases.

Anyway, assuming the fact that arp_notify is disabled by default hasn't
changed your mind, would adding NETDEV_NOTIFY_PEERS triggered by
netif_notify_peers() be appropriate or would it be preferable to simply
add netif_notify_peers() which generates the existing NETDEV_CHANGEADDR?

I don't think there's any need for a new sysctl so I'll gate the new
option on the existing arp_notify one.

Ian.



