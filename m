From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC net-next 3/3] rcv path changes for vrf traffic
Date: Mon, 08 Jun 2015 18:36:03 -0600
Message-ID: <557634F3.4070700@gmail.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com>	 <87eae7a7a03708bda5560a5ea43b0fcac705c80d.1433561681.git.shm@cumulusnetworks.com> <1433793517.4616.4.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, ebiederm@xmission.com,
	hadi@mojatatu.com, davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:35930 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956AbbFIAgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 20:36:14 -0400
Received: by ieclw1 with SMTP id lw1so4527698iec.3
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 17:36:13 -0700 (PDT)
In-Reply-To: <1433793517.4616.4.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/8/15 1:58 PM, Hannes Frederic Sowa wrote:
> Hi Shrijeet,
>
> On Mo, 2015-06-08 at 11:35 -0700, Shrijeet Mukherjee wrote:
>> From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
>>
>> Incoming frames for IP protocol stacks need the IIF to be changed
>> from the actual interface to the VRF device. This allows the IIF
>> rule to be used to select tables (or do regular PBR)
>>
>> This change selects the iif to be the VRF device if it exists and
>> the incoming iif is enslaved to the VRF device.
>>
>> Since VRF aware sockets are always bound to the VRF device this
>> system allows return traffic to find the socket of origin.
>>
>> changes are in the arp_rcv, icmp_rcv and ip_rcv paths
>>
>> Question : I did not wrap the rcv modifications, in CONFIG_NET_VRF
>> as it would create code variations and the vrf_ptr check is there
>> I can make that whole thing modular.
>
>  From an architectural level I think the output path looks good. For the
> input path I would also to propose my (I think) more flexible solution:
>

Something is still not right on the output path. e.g., I see the wrong 
source address showing up on ping -I vrf0:

# ping -I vrf0 1.1.1.254
ping: Warning: source address might be selected on device other than vrf0.
PING 1.1.1.254 (1.1.1.254) from 172.16.1.52 vrf0: 56(84) bytes of data.
64 bytes from 1.1.1.254: icmp_seq=1 ttl=64 time=0.215 ms
...

The reason is because the datagram connect function fails to look up the 
outbound route in the vrf and falls back to the main table. (As an aside 
the fallback to other tables is something that should not be happening 
for VRFs; you want to use the table specific to the VRF.)

The route lookup fails because it passes in oif = vrf device (this VRF 
design relies on bind to device which sets oif in the flow). That is 
good for selecting the table to use for the lookups, but not good for 
selecting the route within the table.

This is one way to fix the connect problem:

diff --git a/include/net/route.h b/include/net/route.h
index fe22d03afb6a..a18798caec25 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -245,11 +245,18 @@ static inline void ip_route_connect_init(struct 
flowi4 *fl4, __be32 dst, __be32
                      __be16 sport, __be16 dport,
                      struct sock *sk)
  {
+   struct net_device *dev = dev_get_by_index(sock_net(sk), oif);
     __u8 flow_flags = 0;

     if (inet_sk(sk)->transparent)
         flow_flags |= FLOWI_FLAG_ANYSRC;

+   if (dev) {
+       if (netif_is_vrf(dev))
+           flow_flags |= FLOWI_FLAG_VRFSRC;
+       dev_put(dev);
+   }
+
     flowi4_init_output(fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
                protocol, flow_flags, dst, src, dport, sport);
  }


which essentially tells fib_table_lookup to drop the OIF comparison 
after selecting the table per this change made in the patch Shrijeet posted:

                         if (!(flp->flowi4_flags & FLOWI_FLAG_VRFSRC)) {
                                 if (flp->flowi4_oif &&
                                     flp->flowi4_oif != nh->nh_oif)
                                         continue;
                         }
