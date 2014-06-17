From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] net: fec: remove HW IP header checksum for IPV6 frame
Date: Tue, 17 Jun 2014 11:20:25 +0100
Message-ID: <20140617102024.GF23430@n2100.arm.linux.org.uk>
References: <1402993895-10955-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:60326 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752704AbaFQKUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 06:20:30 -0400
Content-Disposition: inline
In-Reply-To: <1402993895-10955-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2014 at 04:31:35PM +0800, Fugang Duan wrote:
> The commit 96c50caa5148 (net: fec: Enable IP header hardware checksum)
> enable HW IP header checksum for IPV4 and IPV6, which causes IPV6 TCP/UDP
> cannot work. (The issue is reported by Russell King)
> 
> The reason is that FEC HW IP cannot detect the transmit frame type (can
> detect received frame type), and treats all packets as IPv4, overwrites
> the point in the packet which would be the IPv4 checksum field. Since IPV6
> don't have IP header checksum, so this results in the frame being corrupted.
> 
> The patch just add software detect the current packet type, if it is IPV6
> frame, it don't enable IP header checksum.

I think it /can/ detect the packet type - the hardware showed no signs of
overwriting the checksum field with a non-zero value.  The zeroing of the
bytes seems to come purely from the driver assuming that every partial
checksummed packet is an IPv4 packet:

> @@ -330,7 +335,8 @@ fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
>  	if (unlikely(skb_cow_head(skb, 0)))
>  		return -1;
>  
> -	ip_hdr(skb)->check = 0;
> +	if (is_ipv4_pkt(skb))
> +		ip_hdr(skb)->check = 0;
>  	*(__sum16 *)(skb->head + skb->csum_start + skb->csum_offset) = 0;
>  
>  	return 0;

So, I will first test whether avoiding this resolves the issue I'm
seeing before deciding whether to test the remainder of the patch.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
