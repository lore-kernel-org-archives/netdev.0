From: Yi-Hung Wei <yihung.wei@gmail.com>
Subject: Re: [PATCH net] openvswitch: Fix ovs_flow_key_update()
Date: Thu, 30 Mar 2017 11:39:35 -0700
Message-ID: <CAG1aQhJwShZWAJO_jGEQ_5TaHxpKpfjL0rkpYQSWfn_b9Ua-yg@mail.gmail.com>
References: <1490832850-6012-1-git-send-email-yihung.wei@gmail.com> <20170330152215.7b4f9703@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Stringer <joe@ovn.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170330152215.7b4f9703@griffin>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 30, 2017 at 6:22 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Wed, 29 Mar 2017 17:14:10 -0700, Yi-Hung Wei wrote:
>> ovs_flow_key_update() is called when the flow key is invalid, and it is
>> used to update and revalidate the flow key. Commit 329f45bc4f19
>> ("openvswitch: add mac_proto field to the flow key") introduces mac_proto
>> field to flow key and use it to determine whether the flow key is valid.
>> However, the commit does not update the code path in ovs_flow_key_update()
>> to revalidate the flow key which may cause BUG_ON() on execute_recirc().
>> This patch addresses the aforementioned issue.
>
> Good catch.
>
>>  int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key)
>>  {
>> +     int res;
>> +
>> +     res = key_extract_mac_proto(skb);
>> +     if (res < 0)
>> +             return res;
>> +     key->mac_proto = res;
>> +
>>       return key_extract(skb, key);
>>  }
>
> But this should just reset the SW_FLOW_KEY_INVALID flag, there's no
> need to recompute mac_proto.
>
> Something like this:
>
>  int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key)
>  {
> -       return key_extract(skb, key);
> +       int res;
> +
> +       res = key_extract(skb, key);
> +       if (!res)
> +               key->mac_proto &= ~SW_FLOW_KEY_INVALID;
> +       return res;
>  }
Hi Jiri,

One case that I worry is that key_extract() currently relies on mac_proto to
decide whether to process the link layer.  So if we update key->mac_proto
after key_extract(), wouldn't we run into a problem like the following?

If we invalidate a flow key of a L3 packet, the flow's mac_proto is like this
(MAC_PROTO_NONE | SW_FLOW_KEY_INVALID), then key_extract() will
process the link layer of this L3 packet since mac_proto !=MAC_PROTO_NONE?

In this case, shall we update key_extract() like this
static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)

        /* Link layer. */
        clear_vlan(key);
-       if (key->mac_proto == MAC_PROTO_NONE) {
+       if (key->mac_proto & MAC_PROTO_NONE) {
                if (unlikely(eth_type_vlan(skb->protocol)))
                        return -EINVAL;

Thanks,

-Yi-Hung

>
> Thanks,
>
>  Jiri
