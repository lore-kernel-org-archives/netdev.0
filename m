From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] icmp: don't fail on fragment reassembly time
 exceeded
Date: Sat, 14 Oct 2017 11:05:50 -0700 (PDT)
Message-ID: <20171014.110550.1916274794729423457.davem@davemloft.net>
References: <20171012141237.2209-1-mcroce@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mcroce@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34150 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750907AbdJNSF7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 14:05:59 -0400
In-Reply-To: <20171012141237.2209-1-mcroce@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matteo Croce <mcroce@redhat.com>
Date: Thu, 12 Oct 2017 16:12:37 +0200

> The ICMP implementation currently replies to an ICMP time exceeded message
> (type 11) with an ICMP host unreachable message (type 3, code 1).
> 
> However, time exceeded messages can either represent "time to live exceeded
> in transit" (code 0) or "fragment reassembly time exceeded" (code 1).
> 
> Unconditionally replying to "fragment reassembly time exceeded" with
> host unreachable messages might cause unjustified connection resets
> which are now easily triggered as UFO has been removed, because, in turn,
> sending large buffers triggers IP fragmentation.
> 
> The issue can be easily reproduced by running a lot of UDP streams
> which is likely to trigger IP fragmentation:
> 
>   # start netserver in the test namespace
>   ip netns add test
>   ip netns exec test netserver
> 
>   # create a VETH pair
>   ip link add name veth0 type veth peer name veth0 netns test
>   ip link set veth0 up
>   ip -n test link set veth0 up
> 
>   for i in $(seq 20 29); do
>       # assign addresses to both ends
>       ip addr add dev veth0 192.168.$i.1/24
>       ip -n test addr add dev veth0 192.168.$i.2/24
> 
>       # start the traffic
>       netperf -L 192.168.$i.1 -H 192.168.$i.2 -t UDP_STREAM -l 0 &
>   done
> 
>   # wait
>   send_data: data send error: No route to host (errno 113)
>   netperf: send_omni: send_data failed: No route to host
> 
> We need to differentiate instead: if fragment reassembly time exceeded
> is reported, we need to silently drop the packet,
> if time to live exceeded is reported, maintain the current behaviour.
> In both cases increment the related error count "icmpInTimeExcds".
> 
> While at it, fix a typo in a comment, and convert the if statement
> into a switch to mate it more readable.
> 
> Signed-off-by: Matteo Croce <mcroce@redhat.com>

Looks good, applied, thank you!
