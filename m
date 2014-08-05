From: Alexander Aring <alex.aring@gmail.com>
Subject: IPv6 over IEEE 802.15.4 aka 6LoWPAN - Neighbor discovery issue
Date: Tue, 5 Aug 2014 14:15:18 +0200
Message-ID: <20140805121516.GB14196@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org, linux-wpan@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:41561 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048AbaHEMPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 08:15:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The IEEE 802.15.4 is a WPAN PHY/MAC layer. On top of this Layer we can use
6LoWPAN as upper layer. 6LoWPAN is an adaption layer for IPv6 over IEEE
802.15.4.

Because 6LoWPAN is an adaption we should not change anything in net/ipv6, but
there exist an issue with the 802.15.4 mac addresses and neighbor discovery.

The 802.15.4 has two kinds of mac addresses with a different length.

These are:

Short addresses are 16 bit long and contain some special addresses like
0xffff (broadcast) and 0xfffe (difficult to explain, it's simple not
available).

Extended addresses are 64 bit long and have no special address ranges. It's an
EUI-64 which should not be 00..00 or ff..ff [0].                           
                                                                           
There exist no mapping between extended and short addresses. The global problem
that the neighbor discovery cache handle the address length with a static addr_len
value from net_device, this value should not be changed during runtime.


To handle 6LoWPAN over IEEE 802.15.4 correctly we need to indicate that the neighbor
discovery stores an extended or short address.

We need this information at two places. The first is the daddr pointer of
create callback of header_ops. The other place is creating of ICMPv6 neighbor
discovery ICMPv6 messages.
The source/target link-layer addresses headers for extended and short addresses should
follow description of [1].            
                                      
The second place is:                  
In the create callback of header_ops, we replace the IPv6 header with the 6LoWPAN
header, that's why we need this information in the create callback also. We need this
information also for generating MAC header. For the sending part.
                                                           
                                                           
Furthermore there exists a neighbor discovery "optimization" which do a separate
handling for extended and short addresses also. I don't take a closer look but
it introduce new option types [3] and maybe we can do all 6LoWPAN stuff there.
                                                                       
For now, we don't want to use rfc6775 and simple use the normal IPv6 neighbor
discovery. This need nd messages like [1].                             

I currently searching for a good solution that the neighbor discovery cache can
handle short and extended addresses WITHOUT touching net/ipv6 branch. 


My idea:

Let addr_len to extended_address_length + 1. In the last byte we have a bit which
indicate that is it a short address. If this bit isn't set we have an extended
address. 

If we do that, we need some conversions about generating the ICMPv6 messages according
to [1]. We can solve that with some hooks in net/ipv6/ndisc.c like the ndisc_mc_map
function for mapping mac multicast addresses.

Another idea to avoid hooks in net/ipv6/ndisc.c  is to parse and rebuild the ICMPv6
header while replacing IPv6 with the 6LoWPAN header.


Please I need help and I need a solution which is also acceptable for mainline.

- Alex

[0] http://standards.ieee.org/develop/regauth/tut/eui64.pdf
[1] http://tools.ietf.org/html/rfc4944#section-8
[2] http://tools.ietf.org/html/rfc6775
[3] http://tools.ietf.org/html/rfc6775#section-12
