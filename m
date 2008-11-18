From: Patrick Ohly <patrick.ohly@intel.com>
Subject: route and device for received packets
Date: Tue, 18 Nov 2008 14:06:17 +0100
Message-ID: <1227013577.31699.198.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@linux.intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54486 "EHLO mga02.intel.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752141AbYKRNGa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2008 08:06:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

As mentioned in the "hardware time stamping + igb example
implementation" I'm currently rewriting the patch so that it adds the
raw hardware time stamp to sk_buff. Conversion from hardware time stamp
to system time base is done at the socket level, if the owner of the
socket asked for it.

This conversion requires access to the net_device which generated the
hardware time stamp. Currently I am following this chain of pointers to
find the device and the new callback:

int skb_hwtstamp_transformed(const struct sk_buff *skb, struct timespec *ts)
{
	struct rtable *rt;
	struct in_device *idev;
	struct net_device *netdev;

        if (skb_hwtstamp_available(skb) &&
		(rt = skb->rtable) != NULL &&
		(idev = rt->idev) != NULL &&
		(netdev = idev->dev) != NULL  &&
		netdev->hwtstamp_raw2sys) {
		ktime_t hwtstamp_sys =
			netdev->hwtstamp_raw2sys(netdev,
						skb->hwtstamp.hwtstamp);

The problem is that incoming packets have a route pointer which leads to
the lo device instead of the real hardware which received the packet.
The rt->rt_iif however is correct.

For outgoing packets that were bounced via skb_clone() and
sock_queue_err_skb(sk, skb) the code above works.

Any suggestions how the right net_device could be found (perhaps via
rt->rt_iif)? How about locking?

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

