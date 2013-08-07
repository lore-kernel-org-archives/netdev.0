From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: Add low-latency/polling support for
 UDP multicast
Date: Wed, 07 Aug 2013 13:22:26 -0700
Message-ID: <1375906946.4004.45.camel@edumazet-glaptop>
References: <5200A203.2090306@linux.intel.com>
	 <1375818663-12318-1-git-send-email-sbohrer@rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eliezer.tamir@linux.intel.com,
	netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	tomk@rgmadvisors.com
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:54977 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757107Ab3HGUW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 16:22:28 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so1793124pdi.27
        for <netdev@vger.kernel.org>; Wed, 07 Aug 2013 13:22:27 -0700 (PDT)
In-Reply-To: <1375818663-12318-1-git-send-email-sbohrer@rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-06 at 14:51 -0500, Shawn Bohrer wrote:
> Set the napi id for each socket in the multicast path to enable
> low-latency/polling support.
> 
> Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> ---
> v2 include ipv6 support

This might help your workload, but I doubt it is generic enough.

One UDP socket is supposed to receive traffic from many endpoints,
so we have no guarantee all the received traffic will end on a single RX
queue on the NIC.

That's the same logic than RFS here.

sk_mark_napi_id() in UDP are wrong IMHO.

It should be guarded by the following test in  
__udp_queue_rcv_skb()

if (inet_sk(sk)->inet_daddr) {
    sock_rps_save_rxhash(sk, skb);
    sk_mark_napi_id(sk, skb);
}

(To occur only for connected UDP sockets, where we are 100% sure all
packets will use this same rxhash/rx queue)
