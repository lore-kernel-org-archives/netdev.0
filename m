From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2] marvell sky2 driver: fix so it works without
 unaligned accesses
Date: Wed, 4 Apr 2012 11:42:53 -0700
Message-ID: <20120404114253.5f84d4c8@s6510.linuxnetplumber.net>
References: <20120403.174610.2089715131687430500.davem@davemloft.net>
	<1333469916.18626.284.camel@edumazet-glaptop>
	<201204031527.q33FR04i031747@farm-0027.internal.tilera.com>
	<201204041419.q34EJ49H025297@farm-0012.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201204041419.q34EJ49H025297@farm-0012.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Apr 2012 10:13:32 -0400
Chris Metcalf <cmetcalf@tilera.com> wrote:

> The driver uses a receive_new() routine that ends up requiring unaligned
> accesses in IP header processing.  If the architecture doesn't support
> efficient unaligned accesses, and SKY2_HW_RAM_BUFFER is set,
> just copy all ingress packets to the bounce buffers instead.
> Thanks to Eric Dumazet for pointing out the SKY2_HW_RAM_BUFFER issue.
> 
> This allows the driver to be used on the Tilera TILEmpower-Gx, since
> the tile architecture doesn't currently handle kernel unaligned accesses,
> just userspace.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> ---
>  drivers/net/ethernet/marvell/sky2.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)

What about the following (compile tested only)
--- a/drivers/net/ethernet/marvell/sky2.c	2012-04-04 08:49:05.954853108 -0700
+++ b/drivers/net/ethernet/marvell/sky2.c	2012-04-04 11:30:54.201432707 -0700
@@ -2468,6 +2468,17 @@ static int sky2_change_mtu(struct net_de
 	return err;
 }
 
+static inline bool needs_copy(const struct rx_ring_info *re,
+			      unsigned length)
+{
+#ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+	/* Some architectures need the IP header to be aligned */
+	if (!IS_ALIGNED(re->data_addr + ETH_HLEN, sizeof(u32)))
+		return 1;
+#endif
+	return length < copybreak;
+}
+
 /* For small just reuse existing skb for next receive */
 static struct sk_buff *receive_copy(struct sky2_port *sky2,
 				    const struct rx_ring_info *re,
@@ -2605,7 +2616,7 @@ static struct sk_buff *sky2_receive(stru
 		goto error;
 
 okay:
-	if (length < copybreak)
+	if (needs_copy(re, length))
 		skb = receive_copy(sky2, re, length);
 	else
 		skb = receive_new(sky2, re, length);
