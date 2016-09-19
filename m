From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] net: skbuff: Fix length validation in skb_vlan_pop()
Date: Mon, 19 Sep 2016 14:22:57 +0200
Message-ID: <57DFD8A1.1090103@iogearbox.net>
References: <1474193358-20133-1-git-send-email-shmulik.ladkani@gmail.com>        <CAOrHB_D2ytTK9WjfCPL87E1QomeXg+2GfAvo8N8xCcJULhAC=w@mail.gmail.com> <20160919091538.56defd2b@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51108 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753283AbcISMXD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 08:23:03 -0400
In-Reply-To: <20160919091538.56defd2b@pixies>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2016 08:15 AM, Shmulik Ladkani wrote:
> On Sun, 18 Sep 2016 13:26:30 -0700, pshelar@ovn.org wrote:
>> On Sun, Sep 18, 2016 at 3:09 AM, Shmulik Ladkani
>> <shmulik.ladkani@gmail.com> wrote:
>>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>>> index 1e329d4112..cc2c004838 100644
>>> --- a/net/core/skbuff.c
>>> +++ b/net/core/skbuff.c
>>> @@ -4537,7 +4537,7 @@ int skb_vlan_pop(struct sk_buff *skb)
>>>          } else {
>>>                  if (unlikely((skb->protocol != htons(ETH_P_8021Q) &&
>>>                                skb->protocol != htons(ETH_P_8021AD)) ||
>>> -                            skb->len < VLAN_ETH_HLEN))
>>> +                            skb->mac_len < VLAN_ETH_HLEN))
>>
>> There is already check in __skb_vlan_pop() to validate skb for a vlan
>> header. So it is safe to drop this check entirely.
>
> Seems validation in '__skb_vlan_pop' has slightly different semantics:
>
> 	unsigned int offset = skb->data - skb_mac_header(skb);
>
> 	__skb_push(skb, offset);
> 	err = skb_ensure_writable(skb, VLAN_ETH_HLEN);
>
> this pushes 'data' back to mac_header, then makes sure there's sufficient
> place in skb to _store_ VLAN_ETH_HLEN bytes (by pulling into linear part
> if needed, or erroring if skb is too small).

Yes, but this skb_ensure_writable() is needed for doing the memmove anyway.

> There's no guarantee the original mac header was sized VLAN_ETH_HLEN.

I'm wondering, what happens when you'd call this on tx path, when you'd
change that to suggested skb->mac_len? Isn't that 0 in such case, thus
such setups could fail then?
