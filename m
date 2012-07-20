From: hayeswang <hayeswang@realtek.com>
Subject: RE: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Sat, 21 Jul 2012 00:01:38 +0800
Message-ID: <A4FD513AF09D40849B8A75C371F1D431@realtek.com.tw>
References: <20120718.132840.1571938255177607234.davem@davemloft.net> <20120718214422.GA18207@electric-eye.fr.zoreil.com> <1342649136.2626.3757.camel@edumazet-glaptop> <20120718.152405.1083396282134539674.davem@davemloft.net> <EF06A7B3C1E6432BB660CDEF8E1D2A1B@realtek.com.tw> <20120720100846.GA17398@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:42711 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942Ab2GTQBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 12:01:55 -0400
In-Reply-To: <20120720100846.GA17398@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Francois Romieu [mailto:romieu@fr.zoreil.com] 

[...]
> > I find that the total length field of IP header would be 
> modified if the hw
> > checksum is enabled. Therefore, skb_padto + hw checksum 
> wouldn't work.
> 
> Ok, my patch completely ignored the fact that skb_padto does 
> not change the
> length.
> 
> However skb_padto + length adjustement + hw checksum should 
> work (at least in
> theory if not in the patch below) ?

If the hw only fills in the checksum fields of IP header, UDP header, and TCP
header, the patch would work. However, the hw would also fill in the total
length field of IP header, so it causes problems. For example, I send a packet
with ethernet header 14 bytes + IP header 20 bytes + data 20 bytes = 54 bytes.

Case 1: Software checksum + pad zeroes to 60 bytes
   Receiver gets this packet and finds the total length in IP header would be 40
bytes. Therefore, the receiver knows the data would be 40 - 20 (IP header) = 20
bytes.

Case 2: pad zeroes to 60 bytes + hw checksum
   Receiver gets this packet and would find the total length in IP header is 40
+ (60-54) = 46 bytes, not 40 bytes. Therefore, the receiver consider the data
would be 46 - 20 = 26 bytes. However, the final 6 bytes should not be the parts
of data.
 
Best Regards,
Hayes
