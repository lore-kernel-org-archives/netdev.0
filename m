From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] net: Move VRF change to udp_sendmsg to function
Date: Tue, 18 Aug 2015 10:07:56 -0600
Message-ID: <55D3585C.9030100@cumulusnetworks.com>
References: <1439912309-5726-1-git-send-email-dsa@cumulusnetworks.com> <1439913797.6443.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:36058 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177AbbHRQIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 12:08:00 -0400
Received: by iodv127 with SMTP id v127so179063848iod.3
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 09:07:59 -0700 (PDT)
In-Reply-To: <1439913797.6443.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/15 10:03 AM, Eric Dumazet wrote:

>> +/* unconnected socket. If output device is enslaved to a VRF
>> + * device lookup source address from VRF table.
>> + */
>> +static void udp_sendmsg_vrf_saddr(struct net *net, struct flowi4 *fl4,
>> +				   int oif, struct sock *sk)
>> +{
>> +	if (netif_index_is_vrf(net, oif)) {
>> +		__u8 flow_flags = fl4->flowi4_flags;
>> +		struct rtable *rt;
>> +
>> +		fl4->flowi4_flags = flow_flags | FLOWI_FLAG_VRFSRC;
>> +		rt = ip_route_output_flow(net, fl4, sk);
>> +		if (!IS_ERR(rt))
>> +			ip_rt_put(rt);
>
> This looks buggy. What happened to saddr = fl4->saddr; ?

Not needed.

>
>> +		fl4->flowi4_flags = flow_flags;
>> +	}
>> +}
>> +
>>   int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
>>   {
>>   	struct inet_sock *inet = inet_sk(sk);
>> @@ -1013,33 +1033,16 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
>>
>>   	if (!rt) {
>>   		struct net *net = sock_net(sk);
>> -		__u8 flow_flags = inet_sk_flowi_flags(sk);
>>
>>   		fl4 = &fl4_stack;
>>
>> -		/* unconnected socket. If output device is enslaved to a VRF
>> -		 * device lookup source address from VRF table. This mimics
>> -		 * behavior of ip_route_connect{_init}.
>> -		 */
>> -		if (netif_index_is_vrf(net, ipc.oif)) {
>> -			flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
>> -					   RT_SCOPE_UNIVERSE, sk->sk_protocol,
>> -					   (flow_flags | FLOWI_FLAG_VRFSRC),
>> -					   faddr, saddr, dport,
>> -					   inet->inet_sport);
>> -
>> -			rt = ip_route_output_flow(net, fl4, sk);
>> -			if (!IS_ERR(rt)) {
>> -				saddr = fl4->saddr;
>> -				ip_rt_put(rt);
>> -			}
>> -		}
>> -
>>   		flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
>>   				   RT_SCOPE_UNIVERSE, sk->sk_protocol,
>> -				   flow_flags,
>> +				   inet_sk_flowi_flags(sk),
>>   				   faddr, saddr, dport, inet->inet_sport);
>>
>> +		udp_sendmsg_vrf_saddr(net, fl4, ipc.oif, sk);
>> +

fl4->saddr gets set in udp_sendmsg_vrf_saddr, stays for the next two...

>>   		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
>>   		rt = ip_route_output_flow(net, fl4, sk);
>>   		if (IS_ERR(rt)) {
>

and then right after the above block you have:


         if (msg->msg_flags&MSG_CONFIRM)
                 goto do_confirm;
back_from_confirm:

         saddr = fl4->saddr;

So in short the original code change did not need the 'saddr = 
fl4->saddr;'.

David
