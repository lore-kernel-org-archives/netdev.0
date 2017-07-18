From: Dmitry <d.andreev@uni-eng.ru>
Subject: [malfuction] /net/hsr: unstable node ping after hours of work
Date: Tue, 18 Jul 2017 11:51:31 +0300
Message-ID: <op.y3kdj5calevu92@dandreev01.uni-eng.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback8.mail.ru ([94.100.181.110]:38370 "EHLO
        fallback.mail.ru" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751407AbdGRIvh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:51:37 -0400
Received: from [10.161.25.37] (port=59148 helo=smtp60.i.mail.ru)
        by fallback8.mail.ru with esmtp (envelope-from <d.andreev@uni-eng.ru>)
        id 1dXOE9-0005mE-W5
        for netdev@vger.kernel.org; Tue, 18 Jul 2017 11:51:35 +0300
Received: by smtp60.i.mail.ru with esmtpa (envelope-from <d.andreev@uni-eng.ru>)
        id 1dXOE7-0006JO-T5
        for netdev@vger.kernel.org; Tue, 18 Jul 2017 11:51:32 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello!

I added
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
if (hsr_register_frame_out(port, frame->node_src,
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
and detect already processed frames.
