From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net-next 1/8] flow_keys: Record IP layer protocol in
 skb_flow_dissect()
Date: Tue, 10 Jun 2014 19:38:00 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1406101923050.2499@ws.cisco>
References: <1402338773-5996-1-git-send-email-_govind@gmx.com> <1402338773-5996-2-git-send-email-_govind@gmx.com> <539703F5.8030707@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Govindarajulu Varadarajan <_govind@gmx.com>, davem@davemloft.net,
	netdev@vger.kernel.org, ssujith@cisco.com, gvaradar@cisco.com,
	benve@cisco.com, eric.dumazet@gmail.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:53147 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750945AbaFJOIj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2014 10:08:39 -0400
In-Reply-To: <539703F5.8030707@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 10 Jun 2014, Daniel Borkmann wrote:
>> diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
>> index 7e64bd8..fbefdca 100644
>> --- a/include/net/flow_keys.h
>> +++ b/include/net/flow_keys.h
>> @@ -1,6 +1,19 @@
>>   #ifndef _NET_FLOW_KEYS_H
>>   #define _NET_FLOW_KEYS_H
>> 
>> +/* struct flow_keys:
>> + *	@src: source ip address in case of IPv4
>> + *	      For IPv6 it contains 32bit hash of src address
>> + *	@dst: destination ip address in case of IPv4
>> + *	      For IPv6 it contains 32bit hash of dst address
>> + *	@ports: port numbers of Transport header
>> + *		port16[0]: src port number
>> + *		port16[1]: dst port number
>> + *	@thoff: Transport header offset
>> + *	@n_proto: Network header protocol (eg. IPv4/IPv6)
>> + *	@ip_proto: Transport header protocol (eg. TCP/UDP)
>> + * All the members, except thoff, are in network byte order.
>> + */
>>   struct flow_keys {
>>   	/* (src,dst) must be grouped, in the same way than in IP header */
>>   	__be32 src;
>> @@ -10,6 +23,7 @@ struct flow_keys {
>>   		__be16 port16[2];
>>   	};
>>   	u16 thoff;
>> +	u16 n_proto;
>>   	u8 ip_proto;
>>   };
>> 
>> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
>> index 624f985..a3cfb8e 100644
>> --- a/include/net/sch_generic.h
>> +++ b/include/net/sch_generic.h
>> @@ -231,7 +231,7 @@ struct qdisc_skb_cb {
>>   	unsigned int		pkt_len;
>>   	u16			slave_dev_queue_mapping;
>>   	u16			_pad;
>> -	unsigned char		data[20];
>> +	unsigned char		data[24];
>
> I'm wondering if this is actually needed. We add an extra
> u16 n_proto into the flow_keys *just* to determine IPv4/v6
> while if it finds anything else than this the dissector
> returns false anyway w/o filling out the flow keys structure.
> Plus, in case of IPv6 you'll have a hashed/folded src/dst
> addr anyway.
>

determining IPv4/IPv6 is important because this can be used in dissecting flow
in Accelerated RFS. Adaptor does not support IPv6 filters. Since Accelerated
RFS is supported for IPV6, using skb_flow_dissect will return true with non-zero
values in src/dst for IPv6.

If I am going to write separate function for getting IP address and port
numbers, its definition is going to be somewhat same as skb_flow_dissect.
Why not improve whats already written and reuse it?

Is there any significant downside of adding u16 n_proto and increasing
size of qdisc_skb_cb by 4 bytes?

Thanks
Govind

>>   };
>>
>>   static inline void qdisc_cb_private_validate(const struct sk_buff *skb, 
>> int sz)
>> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>> index 107ed12..c2b53c1 100644
>> --- a/net/core/flow_dissector.c
>> +++ b/net/core/flow_dissector.c
>> @@ -175,6 +175,7 @@ ipv6:
>>   		break;
>>   	}
>> 
>> +	flow->n_proto = proto;
>>   	flow->ip_proto = ip_proto;
>>   	flow->ports = skb_flow_get_ports(skb, nhoff, ip_proto);
>>   	flow->thoff = (u16) nhoff;
>> 
>
