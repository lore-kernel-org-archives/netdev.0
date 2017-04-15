From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net-next] bonding: do not pass link-local packets to master-interface
Date: Fri, 14 Apr 2017 17:20:25 -0700
Message-ID: <9142.1492215625@famine>
References: <20170414180022.124453-1-chonggangli@google.com> <2810.1492198224@famine> <CAF2d9jje8vyqzDbppBZ1J680ewjqETBVe9+KhbNLjsn_rh4NZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Chonggang Li <chonggangli@google.com>, andy@greyhouse.net,
        vfalico@gmail.com, nikolay@redhat.com,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        linux-netdev <netdev@vger.kernel.org>,
        =?us-ascii?Q?=3D=3FUTF-8=3FQ=3FMaciej=5F=3DC5=3DBBenczykowski=3F=3D?=
        <maze@google.com>
To: =?us-ascii?Q?=3D=3FUTF-8=3FB=3FTWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLY?=
         =?us-ascii?Q?g4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ=3D=3D=3F=3D?=
        <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:45690 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755490AbdDOAUf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 20:20:35 -0400
In-reply-to: <CAF2d9jje8vyqzDbppBZ1J680ewjqETBVe9+KhbNLjsn_rh4NZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mahesh Bandewar (महेश बंडेवार) wrote:

>On Fri, Apr 14, 2017 at 12:30 PM, Jay Vosburgh
><jay.vosburgh@canonical.com> wrote:
>>
>>
>> Chonggang Li <chonggangli@google.com> wrote:
>>
>> >Previously link-local packets excluding LACP (which are handled by
>> >the recv_probe) received on bond slave interfaces are delivered to
>> >stack with bond-master device with RX_HANDLER_ANOTHER, however all
>> >link-local packets are link specific and should be delivered with
>> >exact same link/dev.
>>
>>         In what case is the current behavior a problem (my guess would
>> be something related to LLDP)?  What if, e.g., the bond is a bridge
>> port, will STP frames no longer propagate to the bridge?
>>
>When a link-local frame made appear to arrive on bond-master, it
>looses value since 'the info' about link on which it arrived is lost.

	This information should really be in the commit message, along
with something about the LLDP issue being solved.

>So idea behind this is to pass the frame to the stack with the link on
>which it arrived without involving the bonding-master. The same will
>happen for the STP frames too. Do you see problem with this approach?

	My look through the STP code suggests not, but I'm far from an
expert there.  I'm just concerned that this change will cause some
obscure regression in something that depends on the current behavior.

>>         Also, I think the description would be better if it mentioned
>> specifically that the patch is changing how skb->dev is set for link
>> local frames (bond->dev vs receiving interface), e.g.,
>>
>>         "[...] however all link-local packets are link specific and
>>         should be delivered with skb->dev set to the original device."
>>
>yes, makes sense.
>
>> >Signed-off-by: Chonggang Li <chonggangli@google.com>
>> >Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> >Signed-off-by: Maciej Żenczykowski <maze@google.com>
>> >---
>> > drivers/net/bonding/bond_main.c | 3 +++
>> > 1 file changed, 3 insertions(+)
>> >
>> >diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> >index 01e4a69af421..aeca3d8541b9 100644
>> >--- a/drivers/net/bonding/bond_main.c
>> >+++ b/drivers/net/bonding/bond_main.c
>> >@@ -1176,6 +1176,9 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
>> >               }
>> >       }
>> >
>> >+      /* link-local packets should not be passed to master interface */
>> >+      if (is_link_local_ether_addr(eth_hdr(skb)->h_dest))
>> >+              return RX_HANDLER_PASS;
>>
>>         Since this returns _PASS and not _EXACT, the packet will go
>> through the ptype_base packet handlers, so is the comment strictly
>> correct?
>>
>The stack does not have all link-local specific packet-type handlers
>registered by default so returning _EXACT would find nothing and
>packet will be dropped, right? So returning _PASS will deliver packet
>to the stack with skb->dev as the link on which packet arrived and
>stack can take whatever (default) action it has to take.

	Fair enough; I do think the comment would be better phrased as
something like "don't change skb->dev of link local frames"; on first
reading, I thought it meant the frames would be dropped.

	-J

>> >       if (bond_should_deliver_exact_match(skb, slave, bond))
>> >               return RX_HANDLER_EXACT;
>> >
>> >--
>> >2.12.2.762.g0e3151a226-goog
>> >
>>
---
	-Jay Vosburgh, jay.vosburgh@canonical.com
