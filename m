From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [patch net] team: loadbalance: push lacpdus to exact delivery
Date: Thu, 25 Aug 2016 10:35:27 -0700
Message-ID: <CAF2d9ji0s0Jf2NjfS1uDyCm2yP7my+E2-jS1PpZzd25To1Pdnw@mail.gmail.com>
References: <1472142214-14787-1-git-send-email-jiri@resnulli.us>
 <CAF2d9jjOuhaPYOkr80H-OfE2mETYsb1ww+UcFpA_SkaON8wOCw@mail.gmail.com> <20160825164622.GE1880@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f170.google.com ([209.85.161.170]:35281 "EHLO
        mail-yw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751708AbcHYRgF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 13:36:05 -0400
Received: by mail-yw0-f170.google.com with SMTP id j12so33851162ywb.2
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 10:35:48 -0700 (PDT)
In-Reply-To: <20160825164622.GE1880@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2016 at 9:46 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Aug 25, 2016 at 06:37:35PM CEST, maheshb@google.com wrote:
>>On Thu, Aug 25, 2016 at 9:23 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> When team is in bridge and LACP is utilized, LACPDU packets are pushed
>>> to userspace using raw socket and there they are processed. However,
>>> since 8626c56c8279b, LACPDU skbs are dropped by bridge rx_handler so
>>> they never reach packet handlers in rx path. Fix this by explicity treat
>>> LACPDUs to be pushed to exact delivery in team rx_handler.
>>>
>>> Reported-by: Ido Schimmel <idosch@mellanox.com>
>>> Fixes: 8626c56c8279b ("bridge: fix potential use-after-free when hook returns QUEUE or STOLEN verdict")
>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>> ---
>>>  drivers/net/team/team_mode_loadbalance.c | 14 ++++++++++++++
>>>  1 file changed, 14 insertions(+)
>>>
>>> diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
>>> index cdb19b3..e7c8210 100644
>>> --- a/drivers/net/team/team_mode_loadbalance.c
>>> +++ b/drivers/net/team/team_mode_loadbalance.c
>>> @@ -17,6 +17,19 @@
>>>  #include <linux/filter.h>
>>>  #include <linux/if_team.h>
>>>
>>> +static rx_handler_result_t lb_receive(struct team *team, struct team_port *port,
>>> +                                     struct sk_buff *skb)
>>> +{
>>> +       if (unlikely(skb->protocol == htons(ETH_P_SLOW))) {
>>> +               /* LACPDU packets should go to exact delivery */
>>> +               const unsigned char *dest = eth_hdr(skb)->h_dest;
>>> +
>>> +               if (is_link_local_ether_addr(dest) && dest[5] == 0x02)
>>> +                       return RX_HANDLER_EXACT;
>>I believe every link-local-frame should get this treatment whether
>>it's 802.3ad or otherwise (e.g. LLDP etc.), no?
>>BTW same should be true for bonding too (of course except LACP since
>>it handles/consumes it!)
>
> I think so as well, but stayed more conservative for this fix. LLDP case
> is handled in bridge rx_handler though...
>
bridge rx_handler when team is in bridge, otherwise these link-local
frames will be appear on master. So I guess it's a choice between
being conservative (and fix only LACP case as this fix does) or fix a
generic case.

>
>>> +       }
>>> +       return RX_HANDLER_ANOTHER;
>>> +}
>>> +
>>>  struct lb_priv;
>>>
>>>  typedef struct team_port *lb_select_tx_port_func_t(struct team *,
>>> @@ -652,6 +665,7 @@ static const struct team_mode_ops lb_mode_ops = {
>>>         .port_enter             = lb_port_enter,
>>>         .port_leave             = lb_port_leave,
>>>         .port_disabled          = lb_port_disabled,
>>> +       .receive                = lb_receive,
>>>         .transmit               = lb_transmit,
>>>  };
>>>
>>> --
>>> 2.5.5
>>>
