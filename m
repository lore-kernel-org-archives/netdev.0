From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: query: bnx2 and tg3 don't check tcp and/or ip header length validity?
Date: Wed, 14 Oct 2009 11:50:11 -0400
Message-ID: <4AD5F333.3040002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:37939 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934682AbZJNPwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 11:52:03 -0400
Received: by fg-out-1718.google.com with SMTP id 16so1450199fgg.1
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 08:50:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My question is whether it would be OK to add a simple test, and set it to
zero in case of bad values?

In both cases, they get a number that could be negative (in the case of a
badly formed header), and mash it into a flag vector of some sort.

No comments/documentation explaining purpose.

===

bnx2.c:
		u32 tcp_opt_len;
(ipv6 variant)
			vlan_tag_flags |= ((tcp_opt_len >> 2) << 8) |
					  TX_BD_FLAGS_SW_FLAGS;
(ipv4 variant)
			if (tcp_opt_len || (iph->ihl > 5)) {
				vlan_tag_flags |= ((iph->ihl - 5) +
						   (tcp_opt_len >> 2)) << 8;
			}

At least in the latter case, it bothers to check the IP header validity....

These are transmit-only, I cannot find where they use them on receive?

===

tg3.c:
		int tcp_opt_len, ip_tcp_len;

			tcp_opt_len = tcp_optlen(skb);
			ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);

			iph->check = 0;
			iph->tot_len = htons(mss + ip_tcp_len + tcp_opt_len);
			hdrlen = ip_tcp_len + tcp_opt_len;

...

		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
			mss |= (hdrlen & 0xc) << 12;
			if (hdrlen & 0x10)
				base_flags |= 0x00000010;
			base_flags |= (hdrlen & 0x3e0) << 5;
		} else
			mss |= hdrlen << 9;

Likewise, transmit-only.  With completely different code later, in a dma
bug fix function.  But that's the overall picture....

Anybody have any idea what's going on here?
