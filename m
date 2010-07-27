From: Dimitris Michailidis <dm@chelsio.com>
Subject: Rx checksum offload for fragments
Date: Tue, 27 Jul 2010 15:56:44 -0700
Message-ID: <4C4F642C.1090901@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12277 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946Ab0G0W4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 18:56:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am looking at a problem with the cxgb4 driver related to Rx checksum 
offload and IPv6 fragments.  For IP/IPv6 fragments the device provides the 
L4 checksum without the pseudo-header, which the driver passes in skb->csum 
and sets CHECKSUM_COMPLETE.  This works for IP fragments but triggers errors 
  from netdev_rx_csum_fault for IPv6.  The errors are because of this code 
in ip6_frag_queue:

	if (skb->ip_summed == CHECKSUM_COMPLETE) {
		const unsigned char *nh = skb_network_header(skb);
		skb->csum = csum_sub(skb->csum,
			             csum_partial(nh, (u8 *)(fhdr + 1) - nh,
                                                   0));
	}

which subtracts the checksum for the L3 headers (that HW does not include in 
the first place).  AFAICS IPv4 does not make a similar adjustment to 
skb->csum for its header.  Am I missing something here or do IP and IPv6 
interpret CHECKSUM_COMPLETE differently?  And what should the driver do?
