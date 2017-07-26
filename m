From: Dmitry <d.andreev@uni-eng.ru>
Subject: Re: [BUG] /net/hsr: prune_timer
Date: Wed, 26 Jul 2017 17:06:12 +0300
Message-ID: <op.y3zlgmnllevu92@dandreev01.uni-eng.ru>
References: <op.y3kbi1pqlevu92@dandreev01.uni-eng.ru>
 <CAM_iQpX96_Q_dQdoC4kEN4DXjmYgjgoLJY7JeT9qx_oLj++ZWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Cong Wang" <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback15.m.smailru.net ([94.100.179.50]:57948 "EHLO
        fallback.mail.ru" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750783AbdGZOGS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 10:06:18 -0400
Received: from [10.161.64.46] (port=45148 helo=smtp38.i.mail.ru)
        by fallback15.m.smailru.net with esmtp (envelope-from <d.andreev@uni-eng.ru>)
        id 1daMx6-000665-5O
        for netdev@vger.kernel.org; Wed, 26 Jul 2017 17:06:16 +0300
In-Reply-To: <CAM_iQpX96_Q_dQdoC4kEN4DXjmYgjgoLJY7JeT9qx_oLj++ZWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Tue, Jul 18, 2017 at 1:07 AM, Dmitry <d.andreev@uni-eng.ru> wrote:
>> Hello!
>>
>>
>> void hsr_prune_nodes(unsigned long data) called once by timer.
>>
>> hsr_prune_nodes must be called periodically every PRUNE_PERIOD (60s).
>>
>>
>>
>>
>> This code want be added to tail of hsr_prune_nodes function
>>
>> hsr->prune_timer.expires = jiffies + msecs_to_jiffies(PRUNE_PERIOD);
>> add_timer(&hsr->prune_timer);
>>
>> or
>>
>> mod_timer(&hsr->prune_timer, jiffies + msecs_to_jiffies(PRUNE_PERIOD));
>
> Please feel free to send a patch.
>
> You can follow this doc:
> https://www.kernel.org/doc/html/v4.11/process/submitting-patches.html
>
>
> Thanks!

Thanks!

But I`m not ready to patch because fixing this bug open way for this (I  
wrote in another message, now I trying investigate this):


"I added
mod_timer(&hsr->prune_timer, jiffies + msecs_to_jiffies(PRUNE_PERIOD))
to end of hsr_prune_nodes function for periodically calling. I wrote
earlier that it looks like it's a bug.

HSR ring first time (some hours) works properly then works not stable.

    After some hours situation become like this:

    node1 ping
    node 2 OK
    node 3 OK
    node 4 NO PING
    node 5 OK
    node 6 NO PING
    node 7 NO PING
    node 8 OK
    and etc.
    in same time nodeN ping
    node 1 NO PING
    node 2 OK
    node 3 OK
    node 4 OK
    node 5 OK
    node 6 NO PING
    node 7 OK
    node 8 NO PING
    and etc

    and ping result dynamcally changing and not similiar for each node.




Some thinking and tests:

I added debug code into hsr_forward_do function:

...
if (hsr_register_frame_out(port, frame->node_src,frame->sequence_nr))
			{			
			//debug code
			struct hsr_node *node = frame->node_src;
			printk("\nhsr_forward_do(): registered frame dropped:  
hsr_port_type:%d     %x:%x:%x:%x:%x:%x   %u\n", port->type,
				node->MacAddressA[0], node->MacAddressA[1], node->MacAddressA[2],  
node->MacAddressA[3], node->MacAddressA[4], node->MacAddressA[5],
				frame->sequence_nr);
			
			continue;
			}
...

As usual frame passed for port->type == 1, port->type == 2 and one frame
for port->type == 4 passed, one frame for port->type == 4 dropped.
Sometime in limited period of time type == 1, type == 2 suddenly dropped
as already registered

For debug purpose I commented this part of code:
...
/*if (hsr_register_frame_out(port, frame->node_src,
					   frame->sequence_nr))
			{			
			//debug code
			struct hsr_node *node = frame->node_src;
			printk("\nhsr_forward_do(): registered frame dropped:  
hsr_port_type:%d     %x:%x:%x:%x:%x:%x   %u\n", port->type,
				node->MacAddressA[0], node->MacAddressA[1], node->MacAddressA[2],  
node->MacAddressA[3], node->MacAddressA[4], node->MacAddressA[5],  
frame->sequence_nr);
			
			continue;
			}*/
...

and got stable ping on long time.
In this case of course there are dublicated frames and they are dropped on  
IP protocol layer.

IMHO there are cumulative malfunction in code whitch manage list of nodes
and detect already processed frames."
