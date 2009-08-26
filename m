From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Wed, 26 Aug 2009 10:50:40 -0700
Message-ID: <1251309040.10599.34.camel@w-sridhar.beaverton.ibm.com>
References: <OFB18AD855.24C5AC71-ON8825761D.00687D5E-8825761D.0068BB9C@us.ibm.com>
	 <alpine.DEB.1.10.0908251514190.17963@gentwo.org>
	 <1251239734.3169.65.camel@w-sridhar.beaverton.ibm.com>
	 <alpine.DEB.1.10.0908261223210.9933@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	niv@linux.vnet.ibm.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:37318 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbZHZRuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 13:50:52 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7QHfbkd011637
	for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 11:41:37 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7QHoiYf204254
	for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 11:50:45 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7QHog9u023495
	for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 11:50:44 -0600
In-Reply-To: <alpine.DEB.1.10.0908261223210.9933@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-26 at 12:29 -0400, Christoph Lameter wrote:
> On Tue, 25 Aug 2009, Sridhar Samudrala wrote:
> 
> > Could you check if the UDP packet losses you are seeing are accounted for in
> > qdisc drops with this patch. But i am not completely positive on this as this
> > case happens only if qdisc is deactivated.
> 
> This does not work. qdisc drops are still not reported.

OK. So the drops are not happening in dev_queue_xmit().

>  They are reported for IP and UDP.
Not clear what you meant by this.

> Test tool crashes on first TX overrun:
> 
> clameter@rd-strategy3-deb64:~$ ./mcast -n1 -r400000
> Receiver: Listening to control channel 239.0.192.1
> Receiver: Subscribing to 0 MC addresses 239.0.192-254.2-254 offset 0
> origin 10.2.36.123
> Sender: Sending 400000 msgs/ch/sec on 1 channels. Probe interval=0.001-1
> sec.
> sendto: No buffer space available
> Socket Send error
> 
> netstat reports exactly one packet loss:
> 
> 
> clameter@rd-strategy3-deb64:~$ netstat -su
> IcmpMsg:
>     InType3: 1
>     OutType3: 1
> Udp:
>     298 packets received
>     0 packets to unknown port received.
>     0 packet receive errors
>     7232136 packets sent
>     SndbufErrors: 1
> 
> root@rd-strategy3-deb64:/home/clameter#tc -s qdisc show
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1
> 1 1 1 1
>  Sent 6208 bytes 64 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0

Even the Sent count seems to be too low. Are you looking at the right
device?

So based on the current analysis, the packets are getting dropped after
the call to ip_local_out() in ip_push_pending_frames(). ip_local_out()
is failing with NET_XMIT_DROP. But we are not sure where they are
getting dropped. Is that right?

I think we need to figure out where they are getting dropped and then
decide on the appropriate counter to be incremented.

Thanks
Sridhar

