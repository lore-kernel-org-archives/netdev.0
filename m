From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: route: fix inet_rtm_getroute induced crash
Date: Mon, 14 Aug 2017 11:09:36 -0700 (PDT)
Message-ID: <20170814.110936.90630312617848721.davem@davemloft.net>
References: <20170813225258.16001-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        dsahern@gmail.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38578 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752390AbdHNSJh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 14:09:37 -0400
In-Reply-To: <20170813225258.16001-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 14 Aug 2017 00:52:58 +0200

> "ip route get $daddr iif eth0 from $saddr" causes:
>  BUG: KASAN: use-after-free in ip_route_input_rcu+0x1535/0x1b50
>  Call Trace:
>   ip_route_input_rcu+0x1535/0x1b50
>   ip_route_input_noref+0xf9/0x190
>   tcp_v4_early_demux+0x1a4/0x2b0
>   ip_rcv+0xbcb/0xc05
>   __netif_receive_skb+0x9c/0xd0
>   netif_receive_skb_internal+0x5a8/0x890
> 
> Problem is that inet_rtm_getroute calls either ip_route_input_rcu (if an
> iif was provided) or ip_route_output_key_hash_rcu.
> 
> But ip_route_input_rcu, unlike ip_route_output_key_hash_rcu, already
> associates the dst_entry with the skb.  This clears the SKB_DST_NOREF
> bit (i.e. skb_dst_drop will release/free the entry while it should not).
> 
> Thus only set the dst if we called ip_route_output_key_hash_rcu().
> 
> I tested this patch by running:
>  while true;do ip r get 10.0.1.2;done > /dev/null &
>  while true;do ip r get 10.0.1.2 iif eth0  from 10.0.1.1;done > /dev/null &
> ... and saw no crash or memory leak.
> 
> Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
> Cc: David Ahern <dsahern@gmail.com>
> Fixes: ba52d61e0ff ("ipv4: route: restore skb_dst_set in inet_rtm_getroute")
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks Florian.
