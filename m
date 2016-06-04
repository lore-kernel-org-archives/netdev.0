From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net] bridge: Fix incorrect re-injection of STP
	packets
Date: Sat, 4 Jun 2016 11:15:34 +0300
Message-ID: <20160604081534.GA22055@colbert.idosch.org>
References: <1464946785-7651-1-git-send-email-idosch@mellanox.com>
	<20160604094141.7dcc5687@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: yotamg@mellanox.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	Florian Westphal <fw@strlen.de>, jiri@mellanox.com,
	nogahf@mellanox.com, eladr@mellanox.com, ogerlitz@mellanox.com,
	davem@davemloft.net
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20160604094141.7dcc5687@halley>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Sat, Jun 04, 2016 at 09:41:41AM IDT, shmulik.ladkani@gmail.com wrote:
>Hi,
>
>On Fri, 3 Jun 2016 12:39:45 +0300 Ido Schimmel <idosch@mellanox.com> wrote:
>> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
>> index 1607977..c73ed44 100644
>> --- a/net/bridge/br_input.c
>> +++ b/net/bridge/br_input.c
>> @@ -223,9 +223,7 @@ static int br_handle_local_finish(struct net *net, struct sock *sk, struct sk_bu
>>  	if (p->flags & BR_LEARNING && br_should_learn(p, skb, &vid))
>>  		br_fdb_update(p->br, p, eth_hdr(skb)->h_source, vid, false);
>>  
>> -	BR_INPUT_SKB_CB(skb)->brdev = p->br->dev;
>> -	br_pass_frame_up(skb);
>> -	return 0;
>> +	return RX_HANDLER_PASS;
>>  }
>>  
>>  /*
>> @@ -238,6 +236,7 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
>>  	struct sk_buff *skb = *pskb;
>>  	const unsigned char *dest = eth_hdr(skb)->h_dest;
>>  	br_should_route_hook_t *rhook;
>> +	int err;
>>  
>>  	if (unlikely(skb->pkt_type == PACKET_LOOPBACK))
>>  		return RX_HANDLER_PASS;
>> @@ -287,8 +286,11 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
>>  		}
>>  
>>  		/* Deliver packet to local host only */
>> -		NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, dev_net(skb->dev),
>> -			NULL, skb, skb->dev, NULL, br_handle_local_finish);
>> +		err = NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, dev_net(skb->dev),
>> +			      NULL, skb, skb->dev, NULL,
>> +			      br_handle_local_finish);
>> +		if (err == RX_HANDLER_PASS)
>> +			return RX_HANDLER_PASS;
>>  		return RX_HANDLER_CONSUMED;
>
>Seems '*pskb = skb' is needed prior returning RX_HANDLER_PASS - there's
>a 'skb = skb_share_check()' at beginning of br_handle_frame.
>
>(The *pskb = skb was present prior 8626c56c8279, but gone since there
>was no longer an RX_HANDLER_PASS return).

Right! Will fix that in v2.

>
>One nit to consider:
>
>The fix relies on the fact that RX_HANDLER_PASS != 0 (otherwise we end up
>not knowing whether skb was STOLEN or br_handle_local_finish has
>executed, which was the original problem 8626c56c8279 tried to address).
>
>No reason to use the RX_HANDLER_xxx enumeration space as the ret code
>of an 'okfn' (br_handle_local_finish in this case).
>Some positive value locally defined in br_input.c (and documented in
>br_handle_local_finish) would do.

Yes, I agree it would be clearer to state that explicitly. Will add that
in v2.

Thanks for reviewing!
