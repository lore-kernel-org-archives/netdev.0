From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net] ipv4: Avoid crashing in ip_error
Date: Fri, 22 May 2015 04:58:12 -0500
Message-ID: <87zj4x6iiz.fsf_-_@x220.int.ebiederm.org>
References: <2b6d6ab2d8c35af3be55c82e507f5376@vittgam.net>
	<20150520025428.GA23304@kroah.com>
	<b5abf7328b22373e4ec18bd6da479431@vittgam.net>
	<06f5f10e9ee831f5a839c6ea24b94f64@vittgam.net>
	<d146b8b8a69462ced89a384e6be85b28@vittgam.net>
	<4cb068397127c2b2baee1f021b014b11@vittgam.net>
	<da006bc9072931406270f0fdda06045d@vittgam.net>
	<6056363be65a2c129551518da94bff20@vittgam.net>
	<87a8wx97er.fsf@x220.int.ebiederm.org>
	<ff82713d6862786de9784bd3c9c06bfa@vittgam.net>
	<20150522040453.GC8530@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	"Vittorio G \(VittGam\)" <linuxbugs@vittgam.net>,
	security@kernel.org, Greg KH <greg@kroah.com>, luto@amacapital.net,
	Willy Tarreau <w@1wt.eu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:44819 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755795AbbEVKD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 06:03:28 -0400
In-Reply-To: <20150522040453.GC8530@1wt.eu> (Willy Tarreau's message of "Fri,
	22 May 2015 06:04:53 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


ip_error does not check if in_dev is NULL before dereferencing it.

IThe following sequence of calls is possible:
CPU A                          CPU B
ip_rcv_finish
    ip_route_input_noref()
        ip_route_input_slow()
                               inetdev_destroy()
    dst_input()

With the result that a network device can be destroyed while processing
an input packet.

A crash was triggered with only unicast packets in flight, and
forwarding enabled on the only network device.   The error condition
was created by the removal of the network device.

As such it is likely the that error code was -EHOSTUNREACH, and the
action taken by ip_error (if in_dev had been accessible) would have
been to not increment any counters and to have tried and likely failed
to send an icmp error as the network device is going away.

Therefore handle this weird case by just dropping the packet if
!in_dev.  It will result in dropping the packet sooner, and will not
result in an actual change of behavior.

Fixes: 251da4130115b ("ipv4: Cache ip_error() routes even when not forwarding.")
Reported-by: "Vittorio G (VittGam)" <linuxbugs@vittgam.net>
Tested-by: "Vittorio G (VittGam)" <linuxbugs@vittgam.net>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/route.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9e15f5ca4495..f6055984c307 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -900,6 +900,10 @@ static int ip_error(struct sk_buff *skb)
 	bool send;
 	int code;
 
+	/* IP on this device is disabled. */
+	if (!in_dev)
+		goto out;
+
 	net = dev_net(rt->dst.dev);
 	if (!IN_DEV_FORWARD(in_dev)) {
 		switch (rt->dst.error) {
-- 
2.2.1
