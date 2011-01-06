From: Simon Horman <horms@verge.net.au>
Subject: Flow Control and Port Mirroring Revisited
Date: Thu, 6 Jan 2011 18:33:12 +0900
Message-ID: <20110106093312.GA1564@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.linux-foundation.org,
	Jesse Gross <jesse@nicira.com>, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:41217 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319Ab1AFJdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 04:33:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Back in October I reported that I noticed a problem whereby flow control
breaks down when openvswitch is configured to mirror a port[1].

I have (finally) looked into this further and the problem appears to relate
to cloning of skbs, as Jesse Gross originally suspected.

More specifically, in do_execute_actions[2] the first n-1 times that an skb
needs to be transmitted it is cloned first and the final time the original
skb is used.

In the case that there is only one action, which is the normal case, then
the original skb will be used. But in the case of mirroring the cloning
comes into effect. And in my case the cloned skb seems to go to the (slow)
eth1 interface while the original skb goes to the (fast) dummy0 interface
that I set up to be a mirror. The result is that dummy0 "paces" the flow,
and its a cracking pace at that.

As an experiment I hacked do_execute_actions() to use the original skb
for the first action instead of the last one.  In my case the result was
that eth1 "paces" the flow, and things work reasonably nicely.

Well, sort of. Things work well for non-GSO skbs but extremely poorly for
GSO skbs where only 3 (yes 3, not 3%) end up at the remote host running
netserv. I'm unsure why, but I digress.

It seems to me that my hack illustrates the point that the flow ends up
being "paced" by one interface. However I think that what would be
desirable is that the flow is "paced" by the slowest link. Unfortunately
I'm unsure how to achieve that.

One idea that I had was to skb_get() the original skb each time it is
cloned - that is easy enough. But unfortunately it seems to me that
approach would require some sort of callback mechanism in kfree_skb() so
that the cloned skbs can kfree_skb() the original skb.

Ideas would be greatly appreciated.

[1] http://openvswitch.org/pipermail/dev_openvswitch.org/2010-October/003806.html
[2] http://openvswitch.org/cgi-bin/gitweb.cgi?p=openvswitch;a=blob;f=datapath/actions.c;h=5e16143ca402f7da0ee8fc18ee5eb16c3b7598e6;hb=HEAD
