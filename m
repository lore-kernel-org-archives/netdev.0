From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: tun packet accounting and guest to guest traffic
Date: Wed, 22 Dec 2010 18:10:53 +0200
Message-ID: <20101222161053.GB8019@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61539 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753954Ab0LVQLU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Dec 2010 11:11:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

If enough packets are forwarded from tun device A to tun devices B, C, D
which don't consume any packets, A will get blocked and will be unable
to communicate to any other device.

This was supposed to get fixed in a comment for
0110d6f22f392f976e84ab49da1b42f85b64a3c5, however I missed the fact that
packets can get queued in qdisc when the queue is stopped: and with tun,
it can stay stopped indefinitely.

The amount of packets queued for each device is limited by tx queue
length but however small we make it, with enough slow guests they will
add up.

Thoughts on how to fix this? Some ideas below:


----

I am not sure how to solve this properly, while still preserving the
feature, introduced by 33dccbb050bbe35b88ca8cf1228dcf3e4d4b3554 that in
a virt seeting with a guest using one tun device each, guest UDP packets
destined to other guests on the same host are never dropped.

Maybe we should just educate the users that they need to select one:
reliable local UDP with well-behaved guests on the same host, or
reliable networking with misbehaving guests on the same host?


If we do, and if thus more people will start running with sndbuf set to
INT_MAX, it might be a good idea to optimize that path a bit:
sock_alloc_send_pskb does some atomics which we don't need if we are not
interested in packet accounting, and forces similar atomic ops when skb
is freed (potentially on another CPU and/or when that cache line is
cold).

I also have this vague idea that maybe accounting only UDP skbs might be
a useful option for some users.  This decision could be made in the
guest with an 'accounting enabled' flag per packet, or in the host tun
driver.

More thoughts?

-- 
MST
