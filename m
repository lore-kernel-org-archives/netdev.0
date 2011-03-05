From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Possible regression in __netif_receive_skb() between 2.6.38-rc7 and
 net-next-2.6
Date: Sat, 05 Mar 2011 22:30:33 +0100
Message-ID: <4D72AB79.3000605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Patrick Mc Hardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55253 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669Ab1CEVah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 16:30:37 -0500
Received: by wwb22 with SMTP id 22so3861439wwb.1
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2011 13:30:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Comparing __netif_receive_skb() between 2.6.38-rc7 and net-next-2.6, I noticed an important 
difference: The ptype_base loop used to deliver to orig_dev and this is not true anymore.

[Note that this is unrelated to Jiri's today's patch that remove the orig_dev parameter to protocol 
handler].

Imagine the following simple setup:

eth0 -> bond0

- A packet handler registered on eth0, with ptype->type == NULL will receive the packet, because it 
will be delivered in the ptype_all loop, which is inside the another_round loop.
- The same packet handler, registered on eth0, but with ptype->type != NULL won't receive the 
packet, because the ptype_base loop doesn't deliver to orig_dev anymore.

I think this can lead to a regression for user space: an application using af_packet to listen to 
eth0 will receive the packet flow if the registered protocol is NULL, but won't receive anything if 
the registered protocol is not NULL.

Can someone confirm?

	Nicolas.
