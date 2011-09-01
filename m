From: David Lamparter <equinox@diac24.net>
Subject: Re: RFC - should network devices trim frames > soft mtu
Date: Thu, 1 Sep 2011 02:10:30 +0200
Message-ID: <20110901001030.GA1349731@jupiter.n2.diac24.net>
References: <20110831151823.23cfb7bc@nehalam.ftrdhcpuser.net>
 <1314829651.9556.37.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:39516 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752249Ab1IAAKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 20:10:39 -0400
Content-Disposition: inline
In-Reply-To: <1314829651.9556.37.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 31, 2011 at 03:27:31PM -0700, Michael Chan wrote:
> > This means that for non-VLAN tagged frames, the device drops received
> > packets if the length is greater than the MTU.  I don't see that in
> > other devices. What is the correct method? IMHO the bnx2 driver is
> > wrong here and if the policy is desired it should be enforced at
> > the next level (netif_receive_skb).  Hardcoding a protocol value is
> > kind of a giveaway that something is fishy.
> > 
> 
> I guess the reasoning is that we program the RX MTU in our chip to
> automatically discard packets bigger than the RX MTU and count them as
> over-size packets.  We add 4 bytes to the RX MTU to account for the VLAN
> tag which may be stripped or not stripped by the chip depending on
> settings.  The extra 4 bytes in the RX MTU setting will allow over-size
> packets by up to 4 bytes to get through.
> 
> I agree we should move this to the next level.

802.3ac allows both unconditionally raising the MTU to 1522 as well as
checking the protocol and only accepting 802.1Q frames at 1522 while
restricting everything else to 1518.

802.3as raises the bar to 2000 bytes, but explicitly states that the
actual payload - without encapsulation headers from 802.1Q, 1ad, 1ah,
MPLS & co. - should keep the 1500 byte limit.

I think the sensible approach would be to move the MTU check as close
as possible to the border between ethernet and the upper layer
protocols, i.e. the driver shouldn't check this at all and try to tx/rx
as much as the hardware supports. This is needed for QinQ, 802.1ah & co.


-David
