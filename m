From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] veth: Showing peer of veth type dev in ip link (kernel
 side)
Date: Tue, 15 Oct 2013 18:44:57 +0200
Message-ID: <525D7109.4010004@6wind.com>
References: <1380854061-30091-1-git-send-email-yamato@redhat.com>	<20131008.152349.729447337097758010.davem@davemloft.net>	<20131008141337.1a8a556c@nehalam.linuxnetplumber.net>	<20131009165254.2e1c8332@nehalam.linuxnetplumber.net> <87li22vv1w.fsf@xmission.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, yamato@redhat.com,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:50795 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932439Ab3JOQo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 12:44:59 -0400
Received: by mail-wi0-f170.google.com with SMTP id l12so5801934wiv.3
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 09:44:58 -0700 (PDT)
In-Reply-To: <87li22vv1w.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/10/2013 02:17, Eric W. Biederman a =C3=A9crit :
> Stephen Hemminger <stephen@networkplumber.org> writes:
>
>> On Tue, 8 Oct 2013 14:13:37 -0700
>> Stephen Hemminger <stephen@networkplumber.org> wrote:
>>
>>> On Tue, 08 Oct 2013 15:23:49 -0400 (EDT)
>>> David Miller <davem@davemloft.net> wrote:
>>>
>>>> From: Masatake YAMATO <yamato@redhat.com>
>>>> Date: Fri,  4 Oct 2013 11:34:21 +0900
>>>>
>>>>> ip link has ability to show extra information of net work device =
if
>>>>> kernel provides sunh information. With this patch veth driver can
>>>>> provide its peer ifindex information to ip command via netlink
>>>>> interface.
>>>>>
>>>>> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
>>>>
>>>> Applied to net-next, thank you.
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" =
in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>> Please revert this. It is incorrect.
>>> The info returned by any netlink message should be equal to the mes=
sage
>>> for setting.
>>>
>>> I think the correct patch would be something like this (compile tes=
ted only).
>>>
>>> --- a/drivers/net/veth.c	2013-10-06 14:48:23.806461177 -0700
>>> +++ b/drivers/net/veth.c	2013-10-08 14:11:42.434074690 -0700
>>> @@ -434,6 +434,35 @@ static const struct nla_policy veth_poli
>>>   	[VETH_INFO_PEER]	=3D { .len =3D sizeof(struct ifinfomsg) },
>>>   };
>>>
>>> +static size_t veth_get_size(const struct net_device *dev)
>>> +{
>>> +	return nla_total_size(sizeof(struct ifinfomsg)) + /* VETH_INFO_PE=
ER */
>>> +		0;
>>> +}
>>> +
>>> +static int veth_fill_info(struct sk_buff *skb, const struct net_de=
vice *dev)
>>> +{
>>> +	struct veth_priv *priv =3D netdev_priv(dev);
>>> +	struct net_device *peer =3D rtnl_dereference(priv->peer);
>>> +
>>> +	if (peer) {
>>> +		struct ifinfomsg ifi =3D {
>>> +			.ifi_family =3D AF_UNSPEC,
>>> +			.ifi_type =3D peer->type,
>>> +			.ifi_index =3D peer->ifindex,
>>> +			.ifi_flags =3D dev_get_flags(peer),
>>> +		};
>>> +
>>> +		if (nla_put(skb, VETH_INFO_PEER, sizeof(ifi), &ifi))
>>> +			goto nla_put_failure;
>>> +	}
>>> +
>>> +	return 0;
>>> +
>>> +nla_put_failure:
>>> +	return -EMSGSIZE;
>>> +}
>>> +
>>>   static struct rtnl_link_ops veth_link_ops =3D {
>>>   	.kind		=3D DRV_NAME,
>>>   	.priv_size	=3D sizeof(struct veth_priv),
>>> @@ -443,6 +472,8 @@ static struct rtnl_link_ops veth_link_op
>>>   	.dellink	=3D veth_dellink,
>>>   	.policy		=3D veth_policy,
>>>   	.maxtype	=3D VETH_INFO_MAX,
>>> +	.get_size	=3D veth_get_size,
>>> +	.fill_info	=3D veth_fill_info,
>>>   };
>>>
>>>   /*
>>>
>>>
>>
>> This patch is ok as RFC starting point but the full implementation n=
eeds to
>> add on IFLA_NAME and other attributes such that the full peer can be=
 reconstructed.
>>
>> Ideally, the output of 'ip link' command can be in a format that can=
 be used
>> to recreate the same veth pair.
>>
>> One issue is that veth has the ability to make a peer in a different=
 namespace
>> and the network namespace code does not appear to have the ability t=
o be invertable.
>> I.e it is not possible to construct IFLA_NET_NS_PID or IFLA_NET_NS_F=
D attributes
>> from an existing network device namespace.
>
> Right.
>
> IFLA_NET_NS_PID is not invertible as there may be no processes runnin=
g
> in a pid namespace.
>
> IFLA_NET_NS_FD is in principle invertible.  We just need to add a fil=
e
> descriptor to the callers fd table.  I don't see IFLA_NET_NS_FD being
> invertible for broadcast messages, but for unicast it looks like a bi=
t
> of a pain but there are no fundamental problems.
I'm not sure to understand why it is invertible only for unicast messag=
e.
Or are you saying that it is invertible only for the netns where the ca=
ller=20
stands (and then not for the veth peer)?

>
> I don't know if we care enough yet to write the code for the
> IFLA_NET_NS_FD attribute but it is doable.
I care ;-)
Has somebody already started to write a patch?
