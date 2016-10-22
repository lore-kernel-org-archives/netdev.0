From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH] flow_dissector: avoid uninitialized variable access
Date: Sat, 22 Oct 2016 11:20:34 -0700
Message-ID: <CALx6S35oHmGNw=7taBLxY8ZJHso-b8eRokz3QFA5j_8tW5N8yg@mail.gmail.com>
References: <20161021155626.4020344-1-arnd@arndb.de> <20161021163118.GA2155@nanopsycho.orion>
 <5467015.N4DG5uA0DU@wuerfel> <3516805.IZ705sLgKU@wuerfel> <20161022155752.GD26044@egarver>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Arnd Bergmann <arnd@arndb.de>, Jiri Pirko <jiri@resnulli.us>,
        "David S. Miller" <davem@davemloft.net>,
        Alexander Duyck <aduyck@mirantis.com>,
        Tom Herbert <tom@herbertland.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Gao Feng <fgao@48lvckh6395k16k5.yundunddos.com>,
        Amir Vadai <amir@vadai.me>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161022155752.GD26044@egarver>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 22, 2016 at 8:57 AM, Eric Garver <e@erig.me> wrote:
> On Sat, Oct 22, 2016 at 12:16:29AM +0200, Arnd Bergmann wrote:
>> On Friday, October 21, 2016 11:05:45 PM CEST Arnd Bergmann wrote:
>> >
>> > Can you explain why "dissector_uses_key(flow_dissector,
>> > FLOW_DISSECTOR_KEY_VLAN) && skb_vlan_tag_present(skb)" implies
>> > "eth_type_vlan(proto))"?
>> >
>> > If I add uninitialized_var() here, I would at least put that in
>> > a comment here.
>>
>> Found it now myself: if skb_vlan_tag_present(skb), then we don't
>> access 'vlan', otherwise we know it is initialized because
>> eth_type_vlan(proto) has to be true.
>>
>> > On a related note, I also don't see how
>> > "dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_VLAN)"
>> > implies that skb is non-NULL. I guess this is related to the
>> > first one.
>>
>> I'm still unsure about this one.
>
> Only skb_flow_dissect_flow_keys_buf() calls this function with skb ==
> NULL. It uses flow_keys_buf_dissector_keys which does not specify
> FLOW_DISSECTOR_KEY_VLAN, so the if statement is false.
>
> A similar assumption is made for FLOW_DISSECTOR_KEY_ETH_ADDRS higher up.
>
This is a serious problem. We can't rely on the callers to know which
keys they are allowed to use to avoid crashing the kernel. We should
fix those to check if skb is NULL, add a comment to the head of the
function warning people to never assume skb is non-NULL, and also
maybe add a degenerative check that both data argument and skb are not
NULL.

Tom

>> I also found something else that is suspicious: 'vlan' points
>> to the local _vlan variable, but that has gone out of scope
>> by the time we access the pointer, which doesn't seem safe.
>
> I see no harm in moving _vlan to the same scope as vlan.
