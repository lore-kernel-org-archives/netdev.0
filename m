From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCHv1 net-next 0/5] netlink: mmap: kernel panic and some issues
Date: Wed, 02 Sep 2015 11:47:26 +0200
Message-ID: <55E6C5AE.4060308@iogearbox.net>
References: <20150814085807.GA30443@gmail.com> <55CDBC84.8020605@iogearbox.net> <55CDC51D.1060204@iogearbox.net> <20150817.140222.1763422851882964859.davem@davemloft.net> <55D492CC.6010602@iogearbox.net> <20150902000400.GA14821@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	fw@strlen.de
To: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44076 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbbIBJrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 05:47:35 -0400
In-Reply-To: <20150902000400.GA14821@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2015 02:04 AM, Ken-ichirou MATSUZAWA wrote:
> On Wed, Aug 19, 2015 at 04:29:32PM +0200, Daniel Borkmann wrote:
>> On 08/17/2015 11:02 PM, David Miller wrote:
>>> From: Daniel Borkmann <daniel@iogearbox.net>
>>> Date: Fri, 14 Aug 2015 12:38:21 +0200
>>>
>>>> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
>>>> index 67d2104..4307446 100644
>>>> --- a/net/netlink/af_netlink.c
>>>> +++ b/net/netlink/af_netlink.c
>>>> @@ -238,6 +238,13 @@ static void __netlink_deliver_tap(struct sk_buff
>>>> *skb)
>>>>
>>>>   static void netlink_deliver_tap(struct sk_buff *skb)
>>>>   {
>>>> +	/* Netlink mmaped skbs must not access shared info, and thus
>>>> +	 * are not allowed to be cloned. For now, just don't allow
>>>> +	 * them to get inspected by taps.
>>>> +	 */
>>>> +	if (netlink_skb_is_mmaped(skb))
>>>> +		return;
>>>> +
>>>
>>> I would seriously rather see us do an expensive full copy of the SKB
>>> than to have traffic which is unexpectedly invisible to taps.
>>
>> Do you mean generically as we do in TX path, or only in this
>> particular scenario?
>
> It seems that we only handle this particular scenario.
>
> I think I can understand the cause of the panic. The original mmaped
> skb, allocated by netlink_alloc_skb, has a skb destructor which set
> skb head NULL. This prevents from accessing shared info in
> skb_release_all, so my concerns that the shared info of original skb
> may be accessed in kfree_skb and may cause a panic, is unnecessary.
>
> But since skb_clone does not copy the destructor, skb_release_all
> calls skb_release_data for cloned skb, accessing shared info and
> causes the panic, I think. Setting the destructor after clone could
> not fix the problem since __dev_queue_xmit call path,
> netif_skb_features?, accesses shared info.
>
> Talking about skb_copy path, original skb's shared info is accessed
> only in copy_skb_header, to get gso related field. As a result of
> those, we can avoid the panic by:
>
>    @@ -205,7 +205,10 @@ static int __netlink_deliver_tap_skb(struct sk_buff *skb,
>          int ret = -ENOMEM;
>
>          dev_hold(dev);
>          -       nskb = skb_clone(skb, GFP_ATOMIC);
>          +       if (netlink_skb_is_mmaped(skb))
>          +               nskb = skb_copy(skb, GFP_ATOMIC);
>          +       else
>          +               nskb = skb_clone(skb, GFP_ATOMIC);
>
> Thanks to you, my question become clear:
> Should we set gso_size to 0 after copying to make skb_is_gso
> returning false?

It's still not correct. The thing is you can neither call skb_copy() nor
skb_clone() on netlink mmaped skbs. For example, skb_copy_bits() would
look at frags[] in the shared info and tries to copy them. I think adding
extra logic to skb_copy() would be very ugly just to accommodate for this
special case. We need an own netlink_mmap_to_full_skb() handler for this,
that copies/transforms this into a "normal" skb. I'll have a look it this
week.

Thanks,
Daniel
