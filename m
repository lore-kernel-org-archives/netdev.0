From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/5 2.6.21-rc4] l2tp: pppol2tp core
Date: Sat, 24 Mar 2007 15:03:44 +0100
Message-ID: <46052FC0.8080804@trash.net>
References: <200703232307.l2NN7Rtg010808@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54198 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917AbXCXODs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2007 10:03:48 -0400
In-Reply-To: <200703232307.l2NN7Rtg010808@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman wrote:
> [PPPOL2TP]: Add PPP-over-L2TP driver core.
> 
> This driver handles only L2TP data frames; control frames are handled
> by a userspace application. The dfriver implements L2TP using the
> PPPoX socket family. Data is sent or received using regular socket
> sendmsg() / recvmsg() calls. Kernel parameters of the socket can be
> read or modified using ioctl() or [gs]etsockopt() calls.


The interaction with UDP sockets looks pretty horrible IMO. On the
send side I don't see why you can't simply build the UDP header
yourself instead of doing these set_fs + sendmsgs hacks. On the
receive side I it would be nice if you could use the encapsulation
socket stuff thats also used by IPsec.

A couple of random comments:

- your list locking is broken
- list_for_each_entry_safe is only needed if you remove something
  while iterating, its no replacement for locking
- SOCK_2_SESSION/SOCK_2_TUNNEL are terribly ugly and should
  probably be inline functions that use BUG_ON in case of an
  invalid magic
- You should use skb_queue_walk for queue walking
- You should use endian-annotated types
- pppol2tp_fget: why do you want to open sockets for other processes?
  I hope this can go together with the sendmsg hacks

