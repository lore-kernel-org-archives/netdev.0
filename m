From: Ben Greear <greearb@candelatech.com>
Subject: Re: IPv4 multicast and mac-vlans acting weird on 3.0.4+
Date: Wed, 05 Oct 2011 14:52:00 -0700
Message-ID: <4E8CD180.5010905@candelatech.com>
References: <4E8C89EE.3090600@candelatech.com>  <1317844449.3457.3.camel@edumazet-laptop>  <4E8CB990.1010406@candelatech.com>  <1317845835.3457.5.camel@edumazet-laptop>  <4E8CBBD6.3080500@candelatech.com>  <1317846693.3457.11.camel@edumazet-laptop>  <4E8CC474.7050803@candelatech.com> <1317850603.3457.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55782 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932499Ab1JEVwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 17:52:02 -0400
In-Reply-To: <1317850603.3457.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2011 02:36 PM, Eric Dumazet wrote:
> Le mercredi 05 octobre 2011 =C3=A0 13:56 -0700, Ben Greear a =C3=A9cr=
it :
>
>> Wouldn't you have the same problem with two real Ethernet interfaces=
 on
>> the same LAN, or two 802.1Q devices for that matter?  The addrs will=
 all
>> be the same in that case too?
>>
>
> Usually multicast is coupled with routing.
>
> A JOIN message from your app wont be sent on all interfaces...

It will be if you open two sockets and bind each one of them
to a network device, at least as far as I can tell.

>
> But yes, we might have a similar issue with regular vlans.
>
> Probably nobody noticed yet. Just say no to fragments :)

Heh, it's regression testing time..we're trying all the weird
stuff this week :)

>> Also, if I have just a single mac-vlan active (the other 3 are 'ifco=
nfig foo down'),
>> I still see the problem with mcast.
>>
>
> Thats another bug : macvlan doesnt test IFF_UP on broadcasts, only fo=
r
> unicast messages. Please test following patch.
>
>>    From what you describe, I am thinking I may be hitting a differen=
t
>> issue.  Any ideas on how to figure out why exactly the NF_HOOK isn't
>> calling the ip_rcv_finish method?
>>
>
> Really I believe I tried to explain the thing already...
>
> ip_local_deliver() ->  ip_defrag() :

It seems that netfilter is reporting the pkt as NF_STOLEN, probably
because of the nf_ct_ipv4_gather_frags (which ends up calling ip_defrag=
)
logic in nf_defrag_ipv4.c, line 86 or so.  I'm adding more debugging
to verify this.

I'll try out your patch below shortly.

Thanks,
Ben

>
>
> [PATCH] macvlan: dont send frames on DOWN devices
>
> Reported-by: Ben Greear<greearb@candelatech.com>
> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
> ---
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index b100c90..94a0282 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -145,7 +145,8 @@ static void macvlan_broadcast(struct sk_buff *skb=
,
>   		hlist_for_each_entry_rcu(vlan, n,&port->vlan_hash[i], hlist) {
>   			if (vlan->dev =3D=3D src || !(vlan->mode&  mode))
>   				continue;
> -
> +			if (!(vlan->dev->flags&  IFF_UP))
> +				continue;
>   			nskb =3D skb_clone(skb, GFP_ATOMIC);
>   			err =3D macvlan_broadcast_one(nskb, vlan, eth,
>   					 mode =3D=3D MACVLAN_MODE_BRIDGE);
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
