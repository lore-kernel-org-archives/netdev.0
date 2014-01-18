From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv5 net-next 0/6] xfrm: Add ESN support for AH
Date: Sat, 18 Jan 2014 09:54:22 +0800
Message-ID: <1390010068-15715-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63060 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848AbaARByd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 20:54:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is initial Extended Sequence Number support for AH based on IPv4/6.
The rationale is totally by the RFC 4302, which states:

3.3.3.2.2.  Implicit Packet Padding and ESN

   If the ESN option is elected for an SA, then the high-order 32 bits
   of the ESN must be included in the ICV computation.  For purposes of
   ICV computation, these bits are appended (implicitly) immediately
   after the end of the payload, and before any implicit packet padding.

So we attach the high-order 32bits as a scatterlist right after the packet
payload to compute ICV value. 

Test:
I add a knob in iproute2/ip/xfrm_state.c to enable esn when setting SA,
which make it possible to test with-esn and without-esn scenarios, both
cases works ok with ping using packetsize(-s) from default to 32768. 

v2:
  - Patch3/5 and Patch4/5 add IPv6 part as requested by Steffen.
  - Patch5/5 restrict ESN feature only to ESP and AH.
v3:
  - Fix double parens spotted by Sergei, and thanks for reporting.
v4:
  - Incorperate feedbacks from Steffen by simplify the code flow.
  - Add Patch1/6 to introduce skb_to_sgvec_nomark
  - Patch2/6 remove rebundant inclusion crypto/scatterwalk.h
v5:
  - Before calling type 'input' method, XFRM_SKB_CB(skb)->seq.input.hi
    has already been set in network byte order in xfrm_input, so no
    need to change the byte once in type 'input' method. So fix
    Patch3/6 and Patch5/6.


Fan Du (6):
  skbuff: Introduce skb_to_sgvec_nomark to map skb without mark new end
  {IPv4,xfrm} Add ESN support for AH egress part
  {IPv4,xfrm} Add ESN support for AH ingress part
  {IPv6,xfrm} Add ESN support for AH egress part
  {IPv6,xfrm} Add ESN support for AH ingress part
  xfrm: Don't prohibit AH from using ESN feature

 include/linux/skbuff.h |    2 ++
 net/core/skbuff.c      |   26 ++++++++++++++++++++++
 net/ipv4/ah4.c         |   53 +++++++++++++++++++++++++++++++++++----------
 net/ipv6/ah6.c         |   56 ++++++++++++++++++++++++++++++++++++++----------
 net/xfrm/xfrm_user.c   |    3 ++-
 5 files changed, 117 insertions(+), 23 deletions(-)

-- 
1.7.9.5
