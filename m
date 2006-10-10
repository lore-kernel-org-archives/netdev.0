From: David Miller <davem@davemloft.net>
Subject: Re: [BUG 2.6.18] unaligned access in ipvv6_rcv, nf_ip6_checksum,
 tcp_error, __ipv6_addr_type, fib6_lookup_1
Date: Tue, 10 Oct 2006 15:27:29 -0700 (PDT)
Message-ID: <20061010.152729.85819882.davem@davemloft.net>
References: <20060930202040.GF1083@sunbeam.de.gnumonks.org>
	<20061009.184743.112621206.davem@davemloft.net>
	<20061010162803.GG6663@(none)>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36549
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030597AbWJJW1d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 18:27:33 -0400
To: laforge@gnumonks.org
In-Reply-To: <20061010162803.GG6663@(none)>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Harald Welte <laforge@gnumonks.org>
Date: Tue, 10 Oct 2006 18:28:03 +0200

> The NIC in use is a tulip:
> eth1: Digital DS21143 Tulip rev 65 at 000001ff00002000, 00:40:C7:97:6B:0D, IRQ 15.
> 
> Since there is no other tulip nic (only 3c59x and sunhme) in that box,
> it might be a tulip driver bug.

I don't see anything interesting in the tulip driver
after scanning it's RX buffer handling code.

Let's at least see if my theory is at least correct.
Can you run the following little debug patch?

It will print about 40 messages indicating the pointer
value for the ipv6 header in ipv6_rcv().  This way
we can see if it's really misaligned.

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 6b8e6d7..f08e5cd 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -90,6 +90,14 @@ int ipv6_rcv(struct sk_buff *skb, struct
 		goto err;
 
 	hdr = skb->nh.ipv6h;
+#if 1
+	{
+		static int times = 0;
+
+		if (++times < 40)
+			printk("DEBUG: ipv6 header [%p]\n", hdr);
+	}
+#endif
 
 	if (hdr->version != 6)
 		goto err;
