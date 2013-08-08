From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v2 net-next] net: Add low-latency/polling support for
 UDP multicast
Date: Thu, 08 Aug 2013 11:46:17 +0300
Message-ID: <52035AD9.30703@linux.intel.com>
References: <5200A203.2090306@linux.intel.com>  <1375818663-12318-1-git-send-email-sbohrer@rgmadvisors.com> <1375906946.4004.45.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	tomk@rgmadvisors.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:52074 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933813Ab3HHIqV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Aug 2013 04:46:21 -0400
In-Reply-To: <1375906946.4004.45.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 07/08/2013 23:22, Eric Dumazet wrote:
> On Tue, 2013-08-06 at 14:51 -0500, Shawn Bohrer wrote:
>> Set the napi id for each socket in the multicast path to enable
>> low-latency/polling support.
>>
>> Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
>> ---
>> v2 include ipv6 support
> 
> This might help your workload, but I doubt it is generic enough.
> 
> One UDP socket is supposed to receive traffic from many endpoints,
> so we have no guarantee all the received traffic will end on a single RX
> queue on the NIC.
> 
> That's the same logic than RFS here.
> 
> sk_mark_napi_id() in UDP are wrong IMHO.
> 
> It should be guarded by the following test in  
> __udp_queue_rcv_skb()
> 
> if (inet_sk(sk)->inet_daddr) {
>     sock_rps_save_rxhash(sk, skb);
>     sk_mark_napi_id(sk, skb);
> }
> 
> (To occur only for connected UDP sockets, where we are 100% sure all
> packets will use this same rxhash/rx queue)

This would also be safe if there is only one NIC and said NIC was
programmed to always place this socket's data on the same queue.

I don't have a good suggestion on how to detect this.
