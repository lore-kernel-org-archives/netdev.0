From: David Miller <davem@davemloft.net>
Subject: Re: Warning in net/ipv4/af_inet.c:154
Date: Wed, 26 May 2010 00:56:34 -0700 (PDT)
Message-ID: <20100526.005634.48509140.davem@davemloft.net>
References: <20100525115813.GA28063@kryten>
	<1274801229.5020.80.camel@edumazet-laptop>
	<20100526031943.GA28295@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50428
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750868Ab0EZH4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 03:56:24 -0400
In-Reply-To: <20100526031943.GA28295@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Wed, 26 May 2010 13:19:43 +1000

> I notice we update sk_forward_alloc in sk_mem_charge and sk_mem_uncharge.
> Since it isn't an atomic variable I went looking for a lock somewhere in
> the call chain (first thought was the socket lock). I couldn't find
> anything, but I could easily be missing something.

We take the lock properly for all of the skb_queue_rcv_skb() cases
but this rule isn't followed properly for skb_queue_err_skb().

Eric, look at even things like skb_tstamp_tx().  Nothing locks the
socket in those cases, yet we dip down into sock_queue_err_skb() and
thus invoke skb_set_owner_r which goes into sk_mem_charge() and does
the non-atomic update on ->sk_forward_alloc.

I am sure there are other cases with this problem involving
sock_queue_err_skb()...  ip_icmp_error() (via __udp4_lib_err()),
ipv6_icmp_error(), etc.
