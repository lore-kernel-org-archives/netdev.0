From: Chris Friesen <chris.friesen@genband.com>
Subject: [BUG]  behaviour mismatch between ipv4 and ipv6 in UDP rx path
Date: Wed, 16 Feb 2011 14:18:48 -0600
Message-ID: <4D5C3128.4080101@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og116.obsmtp.com ([64.18.2.219]:58674 "EHLO
	exprod7og116.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123Ab1BPUVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 15:21:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I sent this out a week ago but didn't see a reply, so I'm sending it out
again.

One of our guys is seeing occasional dropped ipv4 packets coming in on
an ipv6 udp socket obtained via socket(AF_INET6,  SOCK_DGRAM, IPPROTO_UDP).

Here's what he says:


"The problem happens when release_sock() goes down an interesting code
path.  If (sk->sk_backlog.tail) is non-NULL then release_sock() invokes
__release_sock() which loops over all queue packets and invokes the
socket's backlog receive function for each previously queued packet.

Now for the interesting part.  The UDPv6 backlog receive function (in
net/ipv6/udp.c, udpv6_queue_rcv_skb()) invokes xfrm6_policy_check() to
confirm that the packet is allowed, but the problem is that it calls
this function regardless of whether the packet is IPv4 or IPv6.  The
xfrm6_policy_check() function then assumes that it is an IPv6 packet and
tries to match a policy based on its packet header... but that clearly
won't work because the addresses that it finds when it decodes the skb
are completely bogus."


Looking at the ipv4 code, git commit 9382177 split __udp_queue_rcv_skb()
out of udp_queue_rcv_skb().  It was done for locking purposes, but it
also means that backlog_rcv is bound to __udp_queue_rcv_skb(), which
doesn't call xfrm4_policy_check().


Should a new function __udpv6_queue_rcv_skb() be split out from
udpv6_queue_rcv_skb() and bound to backlog_rcv to resolve the xfrm
issue?  What about the locking that was the reason for the split in the
ipv4 case--is there a similar problem with ipv6?

Thanks,
Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
