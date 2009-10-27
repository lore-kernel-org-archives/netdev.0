From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: allow VLAN ID 0 to be used
Date: Mon, 26 Oct 2009 17:32:32 -0700 (PDT)
Message-ID: <20091026.173232.33817336.davem@davemloft.net>
References: <m34opmr2fz.fsf@ursa.amorsen.dk>
	<4AE563C7.5070702@gmail.com>
	<4AE5CAC6.4000604@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benny+usenet@amorsen.dk, gertjan_hofman@yahoo.com,
	mcarlson@broadcom.com, netdev@vger.kernel.org, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53768
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754910AbZJ0AcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 20:32:08 -0400
In-Reply-To: <4AE5CAC6.4000604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 26 Oct 2009 17:13:58 +0100

> [PATCH] vlan: allow VLAN ID 0 to be used
> 
> We currently use a 16 bit field (vlan_tci) to store VLAN ID on a skb.
> 
> 0 value is used a special value, meaning VLAN ID not set.
> This forbids use of VLAN ID 0
> 
> As VLAN ID is 12 bits, we can use high order bit as a flag, and
> allow VLAN ID 0
> 
> Reported-by: Gertjan Hofman <gertjan_hofman@yahoo.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

This is going to need some more work.

IXGBE is already using the higher bits of ->vlan_tci internally,
your change breaks that.

QLGE explicitly initializes skb->vlan_tci to zero, you'll need to make
sure that's OK.

There is an explicit "if (skb->vlan_tci" (ie. zero vs. non-zero) test
in net/core/dev.c:netif_receive_skb()

net/core/skbuff.c:__copy_skb_header() does a straight copy, you'll
need to make sure that's still OK.

net/packet/af_packet.c:tpacket_rcv() and packet_recvmsg() report the
skb->vlan_tci value to userspace, that's broken now as userspace
doesn't expect that new bit to be there.
