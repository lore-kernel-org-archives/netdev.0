From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 44/44] [XFRM] IPV6: Support Mobile IPv6 extension headers
 sorting.
Date: Fri, 25 Aug 2006 19:06:40 +0900
Message-ID: <44EECBB0.7070001@linux-ipv6.org>
References: <20060824.150442.44820672.yoshfuji@linux-ipv6.org>	<20060823.235404.108743952.davem@davemloft.net>	<44ED4FC3.9060005@linux-ipv6.org> <20060824.045850.74749237.davem@davemloft.net> <44EE4ABC.6050604@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:25820 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1751423AbWHYKGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 06:06:20 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <44EE4ABC.6050604@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Masahide NAKAMURA wrote:
 > David Miller wrote:
 >> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
 >> Date: Thu, 24 Aug 2006 16:05:39 +0900
 >>
 >>> David Miller wrote:
 >>>> In the mean time, I will work on porting my XFRM hashing changes
 >>>> for the current net-2.6.19 tree.
 >>> FYI, your work will not have any conflict with the left of MIPv6 patches
 >>> which I will describe later since they are almost out of XFRM.
 >>
 >> Great.
 >>
 >> I just finished the port and pushed all of that work to net-2.6.19,
 >> can folks please take a look?
 >>
 >> I tested IPSEC as best as I could with XFRM_SUB_POLICY enabled, but I
 >> have no way currently to test sub-policies or MIPV6 cases.
 >
 > OK, I will review it and also start my XFRM test with net-2.6.19
 > as I've done with my tree.

I've found a problem about MIPv6 CN with the patch below.

commit 02b0fa84daaa70f035767c9a5a0d539667249e60
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Thu Aug 24 04:45:07 2006 -0700

     [XFRM]: Hash policies when non-prefixed.


It seems that the policy hashing is not always used with selector protocol.
It may conflict with MIPL daemon thought.

Let me explain the detail:
MIPv6 specification says that all mobility header(MH) must be
sent without routing header type 2(RT2) / home address option,
except [*1].
To satisfy it MIPL daemon uses some bypass policies.

For CN outbound example(ip command output):

(a)MIPL daemon adds MH bypass policy when it starts to run:

src ::/0 dst ::/0 proto 135
         dir out priority 12 ptype sub


(b)After binding is accepted, it also adds route optimization
policy to send user traffic with RT2:

src 3ffe:501:ffff:100::XXXX/128 dst 3ffe:501:ffff:101::YYYY/128
         dir out priority 16 ptype sub
         tmpl src :: dst ::
                 proto route2 reqid 0 mode ro
                 level use

When the daemon added both policy we expected that
all MH was used (a) otherwise (b) because of priority order.
But the kernel used (b) when the daemon sent MH from
3ffe:501:ffff:100::XXXX to 3ffe:501:ffff:101::YYYY.

Note: such bypasses are also required for ICMPv6 error and
neighbor discovery.

(*1:
  Binding update(BU) can be sent with home address option
  and binding ack(BA) can be sent with RT2.)

Do you have any ideas?

Thanks,

-- 
Masahide NAKAMURA
