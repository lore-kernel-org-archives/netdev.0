From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: [PATCH v3 0/6] skb paged fragment destructors
Date: Wed, 25 Jan 2012 12:26:29 +0000
Message-ID: <1327494389.24561.316.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	<Ian.Campbell@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:42172 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753034Ab2AYM0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 07:26:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series makes use of the skb fragment API (which is in 3.2)
to add a per-paged-fragment destructor callback. This can be used by
creators of skbs who are interested in the lifecycle of the pages
included in that skb after they have handed it off to the network stack.
I think these have all been posted before, but have been backed up
behind the skb fragment API.

The mail at [0] contains some more background and rationale but
basically the completed series will allow entities which inject pages
into the networking stack to receive a notification when the stack has
really finished with those pages (i.e. including retransmissions,
clones, pull-ups etc) and not just when the original skb is finished
with, which is beneficial to many subsystems which wish to inject pages
into the network stack without giving up full ownership of those page's
lifecycle. It implements something broadly along the lines of what was
described in [1].

I have also included a patch to the RPC subsystem which uses this API to
fix the bug which I describe at [2].

Since last time I have removed the unnecessary void *data from the
destructor struct and made do_tcp_sendpages take only a single
destructor instead of an array.

More importantly I have also played with the shinfo alignment and member
ordering to ensure that the frequently used fields (including at least
one frag) are all within the same 64 byte cache line. In order to do
this I had to evict destructor_arg from the hot cache line -- however I
believe this is not actually a hot field and so this is acceptable.

Cheers,
Ian.

[0] http://marc.info/?l=linux-netdev&m=131072801125521&w=2
[1] http://marc.info/?l=linux-netdev&m=130925719513084&w=2
[2] http://marc.info/?l=linux-nfs&m=122424132729720&w=2
