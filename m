From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 00/19] IPv6 NDISC Updates
Date: Tue, 22 Jan 2013 01:47:40 +0900
Message-ID: <50FD712C.1050703@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50327 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751610Ab3AUQro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:47:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of changes basically clean up NDISC logic,
especially on sender side.

We originally do For NS/NA/RS:
 1) build temporary ICMPv6 header
 2) ndisc_build_skb() with temporary ICMPv6 header and rather
    criptic arguments.
    - Calculate total length and allocate sk_buff
    - Build IPv6 header.
    - copy ICMPv6 header, additional data and ND options.
    - Fill-in ICMPv6 checksum.
    Here, structures defined for message format was not used
    at all, it is difficult to understand what is being sent,
    and it was not generic.
 3) __ndisc_send()
    - Allocate temporary dst.
    - Send it.

Several issues:
- We could not defer decision if we should/can send some ND
  option.
- It is hard to see the packet format at a glance.
- ICMPv6 header was built as temporary variable, and then
  copied to the buffer.
- Some code path for Redirect was not shared.

With these patches, we do:
 1) Calculate (or estimate) message length and option length.
 2) Allocate skb (via new ndisc_skb_alloc()).
 3) Fill-in ICMPv6 message directly using compound literals.
 4) Fill-in ICMPv6 checksum
 5) Build IPv6 header (including length)
 6) Send the packet (via ndisc_send_skb()).
    - allocate temporary dst and send it.

- We can defer calculating real length of the packet.
  For example, we can give up filling some option at when
  filling in.
- Message is built directly without temporary buffer.
- Structures defined for message format is easier to understand
  what is being built.
- NS/NA/RS/Redirect share same logic.
- Reduced code/data size:
	   text	   data	    bss	    dec	    hex	filename
	 265407	  14133	   3488	 283028	  45194	old/net/ipv6/ipv6.o
	 264955	  14109	   3488	 282552	  44fb8	new/net/ipv6/ipv6.o

YOSHIFUJI Hideaki (19):
  ndisc: Reduce number of arguments for ndisc_fill_addr_option().
  ndisc: Move ndisc_opt_addr_space() to include/net/ndisc.h.
  ndisc: Use skb_linearize() instead of pskb_may_pull(skb, skb->len).
  ndisc: Introduce ndisc_fill_redirect_hdr_option().
  ndisc: Introduce ndisc_alloc_skb() helper.
  ipv6: Unshare ip6_nd_hdr() and change return type to void.
  ndisc: Simplify arguments for ip6_nd_hdr().
  ndisc: Set skb->dev and skb->protocol inside ndisc_alloc_skb().
  ndisc: Remove dev argument for ndisc_send_skb().
  ndisc: Defer building IPv6 header.
  ndisc: Reset skb->trasport_headner inside ndisc_alloc_send_skb().
  ndisc: Calculate message body length and option length separately.
  ndisc: Make ndisc_fill_xxx_option() for sk_buff.
  ndisc: Remove icmp6h argument from ndisc_send_skb().
  ndisc: Use ndisc_send_skb() for redirect.
  ndisc: Fill in ICMPv6 checksum and IPv6 header in ndisc_send_skb().
  ndisc: Break down __ndisc_send().
  ndisc: Break down ndisc_build_skb() and build message directly.
  ndisc: Use compound literals to build redirect message.

 include/net/ipv6.h    |    7 --
 include/net/ndisc.h   |    8 +-
 net/ipv6/ip6_output.c |   33 -----
 net/ipv6/mcast.c      |   29 ++++-
 net/ipv6/ndisc.c      |  331 +++++++++++++++++++++++++------------------------
 5 files changed, 203 insertions(+), 205 deletions(-)

-- 
1.7.9.5
