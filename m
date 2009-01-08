From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: Re: IP LRO
Date: Thu, 08 Jan 2009 12:35:00 +0200
Message-ID: <4965D6D4.3010000@mellanox.co.il>
References: <4965BF43.1060801@mellanox.co.il> <20090108091755.GA23458@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.co.il>,
	Tziporet Koren <tziporet@mellanox.co.il>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:37418 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751865AbZAHKgB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 05:36:01 -0500
In-Reply-To: <20090108091755.GA23458@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Thanks for your comments

>> We have recently implemented a reassembly of fragmented IP packets in
>> mlx4_en driver. This offload gives a performance boost in case of incoming
>> traffic with fragmented packets (such as UDP traffic with message size larger
>> then MTU). The attached patch contains this offload. I believe that we can make
>> this code generic, maybe part of inet_lro.
>> Please review and comment.
> 
> Frankly from the patch it is quite hard to tell if it is suitable or not
> for the generic usage. For example no structure access or lookup are
> guarded with some locks, likely they are somewhere in the driver itself,
> so at least it should be documented. Fragment structure can be
> rearranged to better fit the alignment rules of the platform (there are
> gaps even on 32bit). Please provide higher-level description on how it
> operates compared to existing GRO/LRO (except that it is one layer lower),
> how strcutres are operated, what are the lifetime rules for them and
> appropriate skbs, what are the usage case. How will it live with
> GRO/LRO, i.e. who will steal the skb if it matches both subsystems.
> 

The patch that I sent is suitable for our driver only. Naturally, to make
the code generic, changes are required. The structures protection is done
in the driver's receive flow. The sessions are per RX ring, and for each ring we
handle the skbs sequentially.
This feature only handles packets that are not eligible for LRO. The skb should be
IPv4 and IP fragmented. We currently only work with skb_frags, but there should not
be a problem to add skb mode.
Packet is flushed in the following cases:
	1. The last fragment of the IP packet arrived.
	2. Received an "out of order" fragment (its offset doesn't fit what we are expecting)
	   In this case all the aggregated fragments are flushed, and we start a new session.
	3. Finished completion handle, we don't want to delay the packets for a long time.

Yevgeny
