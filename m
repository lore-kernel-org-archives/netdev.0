From: Ansis Atteka <ansisatteka@gmail.com>
Subject: Re: [PATCH net] xfrm: calculate L4 checksums also for GSO case before
 encrypting packets
Date: Fri, 21 Apr 2017 14:45:17 -0700
Message-ID: <CAMQa7Bgn58eWhwH-tOJcoNoF7ATs5yBpAyu1rR4JN5=8pBdaMA@mail.gmail.com>
References: <1491849727-32008-1-git-send-email-aatteka@ovn.org>
 <20170411070755.GW5092@secunet.com> <CAMQa7Biajree5Kc1fOWQN42R1UDDGp7ZevZZRtUMZOKDWTk-Vw@mail.gmail.com>
 <20170418090919.GD30104@secunet.com> <CAMQa7Bimd378QJgsv6yBP0ULH+__C9gjjcXa39wx1z7p_9mT=g@mail.gmail.com>
 <20170420094743.GI2649@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ansis Atteka <aatteka@ovn.org>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35731 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1037537AbdDUVpS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 17:45:18 -0400
Received: by mail-io0-f196.google.com with SMTP id d203so34715560iof.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 14:45:18 -0700 (PDT)
In-Reply-To: <20170420094743.GI2649@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20 April 2017 at 02:47, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Tue, Apr 18, 2017 at 07:10:03PM -0700, Ansis Atteka wrote:
>>
>> However, after taking pointers from your patch I came up with this one
>> that may solve this problem once and for all (note, that I was seeing
>> this bug only with ixgbe NIC that supports tx csum offloads). I hope
>> it does not break any other IPsec tests that you have.
>>
>> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
>> index b2be1d9..7812501 100644
>> --- a/net/ipv4/udp_offload.c
>> +++ b/net/ipv4/udp_offload.c
>> @@ -29,6 +29,7 @@ static struct sk_buff
>> *__skb_udp_tunnel_segment(struct sk_buff *skb,
>>         u16 mac_len = skb->mac_len;
>>         int udp_offset, outer_hlen;
>>         __wsum partial;
>> +       bool need_ipsec;
>>
>>         if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
>>                 goto out;
>> @@ -62,8 +63,10 @@ static struct sk_buff
>> *__skb_udp_tunnel_segment(struct sk_buff *skb,
>>
>>         ufo = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP);
>>
>> +       need_ipsec = skb_dst(skb) && dst_xfrm(skb_dst(skb));
>>         /* Try to offload checksum if possible */
>>         offload_csum = !!(need_csum &&
>> +                         !need_ipsec &&
>>                           (skb->dev->features &
>>                            (is_ipv6 ? (NETIF_F_HW_CSUM | NETIF_F_IPV6_CSUM) :
>>                                       (NETIF_F_HW_CSUM | NETIF_F_IP_CSUM))));
>
> This looks good, but we should fix udp4_ufo_fragment() too.
>
> Thanks!

I removed Geneve tunneling from equation and tried to run a simple
iperf underlay UDP test while IPsec was still enabled to observe
issues with the udp4_ufo_fragment() case.

Unfortunately, as can be seen from kernel tracer output below, I was
unable to come up with a test case where udp4_ufo_fragment function
would ever be invoked while IPsec is enabled:

admin1@ubuntu1:~/xfrm_test/net$ ifconfig em2.4001 | grep "inet addr"
          inet addr:192.168.1.1  Bcast:192.168.1.255  Mask:255.255.255.0
admin1@ubuntu1:~/xfrm_test/net$ ethtool -k em2.4001 | grep
udp-fragmentation-offload
udp-fragmentation-offload: on
admin1@ubuntu1:~/xfrm_test/net$ sudo trace-cmd record -p
function_graph -c -F iperf -c 192.168.1.2 -u -l20000
admin1@ubuntu1:~/xfrm_test/net$ trace-cmd report | grep udp4
admin1@ubuntu1:~/xfrm_test/net$


Nevertheless, after disabling IPsec and leaving everything else the
same, I start to see that udp4_ufo_fragment() gets invoked:

admin1@ubuntu1:~/xfrm_test/net$ trace-cmd report | grep udp4
           iperf-25466 [004] 242431.203307: funcgraph_entry:
0.113 us   |                  udp4_hwcsum();
           iperf-25466 [004] 242431.203360: funcgraph_entry:
        |
udp4_ufo_fragment() {
           iperf-25466 [004] 242431.508436: funcgraph_entry:
0.080 us   |                  udp4_hwcsum();
           iperf-25466 [004] 242431.508542: funcgraph_entry:
        |
udp4_ufo_fragment() {


However, non-IPsec case really does not have this ESP packet
corruption problem, because then the packets are in plain and can
utilize checksum offloads. Do we really have a problem there for
IPsec? I did not have time yet to look into the code to understand why
exactly udp4_ufo_fragment() is not called for IPsec case, but since I
can't come up with a real life test case, then for now I will simply
resubmit the previous patch as-is to netdev mailinglist to solve the
problem I encountered previously for Geneve tunneling case.

If you could drop more hints on how to come up with an IPsec test case
where udp4_ufo_fragment() is still invoked and packets get corrupted,
then I can later send another patch for that.
