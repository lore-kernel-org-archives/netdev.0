From: Flavio Leitner <fleitner@redhat.com>
Subject: possible bug in IPv6 MLD retransmissions
Date: Fri, 17 May 2013 00:24:49 -0300
Message-ID: <20130517032449.GA3595@obelix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17226 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752063Ab3EQDYy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 23:24:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

A tcpdump captured while adding an IPv6 link-local address shows
two MLD reports. One with source ``::'' and another with the permanent
address.

Well, if you increase dad_retransmits from 1 to 10, for instance,
then both MLD reports are sent with source address ``::'' which
according with specs should be ignored by the routers.

* 4759.429868           :: -> ff02::16     ICMPv6 90 Multicast Listener
  Report Message v2
4759.890934           :: -> ff02::1:ffe5:a8aa ICMPv6 78 Neighbor
  Solicitation for fe80::f2de:f1ff:fee5:a8aa
4760.893868           :: -> ff02::1:ffe5:a8aa ICMPv6 78 Neighbor
  Solicitation for fe80::f2de:f1ff:fee5:a8aa
4761.895867           :: -> ff02::1:ffe5:a8aa ICMPv6 78 Neighbor
  Solicitation for fe80::f2de:f1ff:fee5:a8aa
4762.897873           :: -> ff02::1:ffe5:a8aa ICMPv6 78 Neighbor
  Solicitation for fe80::f2de:f1ff:fee5:a8aa
4763.899868           :: -> ff02::1:ffe5:a8aa ICMPv6 78 Neighbor
  Solicitation for fe80::f2de:f1ff:fee5:a8aa
* 4764.237923           :: -> ff02::16     ICMPv6 90 Multicast Listener
  Report Message v2
4764.901866           :: -> ff02::1:ffe5:a8aa ICMPv6 78 Neighbor
  Solicitation for fe80::f2de:f1ff:fee5:a8aa
4765.903878           :: -> ff02::1:ffe5:a8aa ICMPv6 78 Neighbor
  Solicitation for fe80::f2de:f1ff:fee5:a8aa
4766.905867           :: -> ff02::1:ffe5:a8aa ICMPv6 78 Neighbor
  Solicitation for fe80::f2de:f1ff:fee5:a8aa
4767.907864           :: -> ff02::1:ffe5:a8aa ICMPv6 78 Neighbor
  Solicitation for fe80::f2de:f1ff:fee5:a8aa
4768.909865           :: -> ff02::1:ffe5:a8aa ICMPv6 78 Neighbor
  Solicitation for fe80::f2de:f1ff:fee5:a8aa
4769.911919 fe80::f2de:f1ff:fee5:a8aa -> ff02::2      ICMPv6 70 Router
  Solicitation from f0:de:f1:e5:a8:a9
4773.917868 fe80::f2de:f1ff:fee5:a8aa -> ff02::2      ICMPv6 70 Router
  Solicitation from f0:de:f1:e5:a8:a9
4777.925855 fe80::f2de:f1ff:fee5:a8aa -> ff02::2      ICMPv6 70 Router
  Solicitation from f0:de:f1:e5:a8:a9

Therefore, I believe this is a bug in IPv6 MLD because it should
sent at least 2 MLD reports after DAD is completed.
The specs says:

rfc3810
5.2.13. Source Addresses for Reports

   An MLDv2 Report MUST be sent with a valid IPv6 link-local source
   address, or the unspecified address (::), if the sending interface
   has not acquired a valid link-local address yet.  Sending reports
   with the unspecified address is allowed to support the use of IP
   multicast in the Neighbor Discovery Protocol [RFC2461].  For
   stateless autoconfiguration, as defined in [RFC2462], a node is
   required to join several IPv6 multicast groups, in order to perform
   Duplicate Address Detection (DAD).  Prior to DAD, the only address
   the reporting node has for the sending interface is a tentative one,
   which cannot be used for communication.  Thus, the unspecified
   address must be used.

   On the other hand, routers MUST silently discard a message that is
   not sent with a valid link-local address, without taking any action
   on the contents of the packet.  Thus, a Report is discarded if the
   router cannot identify the source address of the packet as belonging
   to a link connected to the interface on which the packet was
   received.  A Report sent with the unspecified address is also
   discarded by the router.  This enhances security, as unidentified
   reporting nodes cannot influence the state of the MLDv2 router(s).
   Nevertheless, the reporting node has modified its listening state for
   multicast addresses that are contained in the Multicast Address
   Records of the Report message.  From now on, it will treat packets
   sent to those multicast addresses according to this new listening
   state.  ***Once a valid link-local address is available, a node
SHOULD
   generate new MLDv2 Report messages for all multicast addresses joined
   on the interface****.
...

Does that make any sense?
Thanks,
-- 
fbl
