From: David Miller <davem@davemloft.net>
Subject: Re: BSD 4.2 style TCP keepalives
Date: Wed, 06 Jan 2010 19:21:31 -0800 (PST)
Message-ID: <20100106.192131.193700514.davem@davemloft.net>
References: <20100106.002328.141253811.davem@davemloft.net>
	<20100106.150453.186399201.davem@davemloft.net>
	<20100106.161454.193705075.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, ilpo.jarvinen@helsinki.fi
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56157
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756331Ab0AGDVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 22:21:25 -0500
In-Reply-To: <20100106.161454.193705075.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 06 Jan 2010 16:14:54 -0800 (PST)

> +#if 1
> +	/* Construct BSD 4.2 style zero-window probe with one
> +	 * out-of-window garbage data byte.
> +	 *
> +	 * XXX this does the wrong thing when 'urgent' is true
> +	 */
> +	{
> +		unsigned char *garbage_byte = skb_put(skb, 1);
> +
> +		*garbage_byte = 0xff;
> +		TCP_SKB_CB(skb)->end_seq++;
> +	}
> +#endif

This doesn't work so well, because the checksum will be wrong.
The patch at the end of this email should work better.

And maybe that's a clue, because with this upstream Linux does ACK the
probe.  So I wonder if the Windows 2000 systems don't calculate the
checksum correctly?

More mysterious by the minute :-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 383ce23..ce0ae32 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2727,6 +2727,20 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent)
 	 * send it.
 	 */
 	tcp_init_nondata_skb(skb, tp->snd_una - !urgent, TCPCB_FLAG_ACK);
+#if 1
+	/* Construct BSD 4.2 style zero-window probe with one
+	 * out-of-window garbage data byte.
+	 *
+	 * XXX this does the wrong thing when 'urgent' is true
+	 */
+	{
+		unsigned char *garbage_byte = skb_put(skb, 1);
+
+		*garbage_byte = 0xff;
+		TCP_SKB_CB(skb)->end_seq++;
+		skb->ip_summed = CHECKSUM_PARTIAL;
+	}
+#endif
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
 	return tcp_transmit_skb(sk, skb, 0, GFP_ATOMIC);
 }
