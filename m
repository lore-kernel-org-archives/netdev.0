From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] xen-netfront: reduce gso_max_size to account for
 ethernet header
Date: Mon, 25 Mar 2013 12:59:49 -0400 (EDT)
Message-ID: <20130325.125949.1046297562456662826.davem@davemloft.net>
References: <1364209702-12437-3-git-send-email-wei.liu2@citrix.com>
	<20130325.121809.2023305728304341952.davem@davemloft.net>
	<1364230472.29473.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, xen-devel@lists.xen.org,
	netdev@vger.kernel.org, ian.campbell@citrix.com,
	annie.li@oracle.com, konrad.wilk@oracle.com,
	david.vrabel@citrix.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758086Ab3CYQ7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 12:59:55 -0400
In-Reply-To: <1364230472.29473.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Mar 2013 09:54:32 -0700

> On Mon, 2013-03-25 at 12:18 -0400, David Miller wrote:
> 
>> 
>> This is effectively the default already, you don't need to change this
>> value explicitly.
>> 
>> ->gso_max_size is set by default to 65536 and then TCP performs this
>> calculation:
>> 
>>                 xmit_size_goal = ((sk->sk_gso_max_size - 1) -                          
>>                                   inet_csk(sk)->icsk_af_ops->net_header_len -          
>>                                   inet_csk(sk)->icsk_ext_hdr_len -                     
>>                                   tp->tcp_header_len);                                 
>> 
>> thereby making it adhere to your limits just fine.
> 
> For locally generated TCP traffic this is the case.

Right, and also any other piece of code that is not interpreting the
gso_max_size value the same way (as "(x - 1) - sizeof_headers") would
need to be fixed.

> However, GRO can build packets up to 65535 bytes, not including the
> Ethernet header.

If this GRO packet ends up being transmitted, the gso limit should be
applied, otherwise we would be violating the device's advertised GSO
limit value.

Assume that this kind of check is performed (it must), then I don't
see how GRO can cause any problems for Xen.
