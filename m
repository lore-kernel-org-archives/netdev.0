From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/4] net: bridge: rearrange flood vs unicast receive paths
Date: Fri, 15 Jul 2016 10:37:54 -0700
Message-ID: <FE62FD91-E4D1-44B6-A4D7-66E86C09A5FA@cumulusnetworks.com>
References: <1468465802-4571-1-git-send-email-nikolay@cumulusnetworks.com> <1468465802-4571-3-git-send-email-nikolay@cumulusnetworks.com> <CAM_iQpXXoprcz48c-AYgOridkQWSv+5+7v4V5pT1rUu4_FoXMQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	bridge@lists.linux-foundation.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34549 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbcGORh4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 13:37:56 -0400
Received: by mail-pf0-f171.google.com with SMTP id p64so9558797pfb.1
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 10:37:56 -0700 (PDT)
In-Reply-To: <CAM_iQpXXoprcz48c-AYgOridkQWSv+5+7v4V5pT1rUu4_FoXMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jul 15, 2016, at 10:35 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> 
> On Wed, Jul 13, 2016 at 8:10 PM, Nikolay Aleksandrov
> <nikolay@cumulusnetworks.com> wrote:
>> This patch removes one conditional from the unicast path by using the fact
>> that skb is NULL only when the packet is multicast or is local.
>> 
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> ---
>> net/bridge/br_input.c | 29 ++++++++++++++---------------
>> 1 file changed, 14 insertions(+), 15 deletions(-)
>> 
>> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
>> index 0b6d32619468..c20c5be6fc22 100644
>> --- a/net/bridge/br_input.c
>> +++ b/net/bridge/br_input.c
>> @@ -134,10 +134,10 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
>>        struct net_bridge_port *p = br_port_get_rcu(skb->dev);
>>        const unsigned char *dest = eth_hdr(skb)->h_dest;
>>        struct net_bridge_fdb_entry *dst = NULL;
>> +       bool mcast_hit = false, unicast = true;
>>        struct net_bridge_mdb_entry *mdst;
>>        struct net_bridge *br;
>>        struct sk_buff *skb2;
>> -       bool unicast = true;
>>        u16 vid = 0;
>> 
>>        if (!p || p->state == BR_STATE_DISABLED)
>> @@ -177,30 +177,29 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
>>                if ((mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) &&
>>                    br_multicast_querier_exists(br, eth_hdr(skb))) {
>>                        if ((mdst && mdst->mglist) ||
>> -                           br_multicast_is_router(br))
>> +                           br_multicast_is_router(br)) {
>>                                skb2 = skb;
>> -                       br_multicast_forward(mdst, skb, skb2);
>> -                       skb = NULL;
>> -                       if (!skb2)
>> -                               goto out;
>> +                               br->dev->stats.multicast++;
>> +                       }
>> +                       mcast_hit = true;
>>                } else {
>>                        skb2 = skb;
>> +                       br->dev->stats.multicast++;
>>                }
>>                unicast = false;
>> -               br->dev->stats.multicast++;
> 
> 
> Looks like you change the unconditional increment of this counter,
> is this intended?

Oops +CC all, mixed the reply list.

Yes, this counter must increment only when the packet is going to be locally received as you can see before
there was an unconditional jump if the packet was not going to be locally received (if !skb2, goto).
This is exactly one of the confusing cases trying to avoid with these skb0/skb2 variables..

Cheers,
Nik
