From: jamal <hadi@cyberus.ca>
Subject: reminder to netdriver authors
Date: 03 Jul 2004 23:13:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1088910801.1041.818.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



chasing that cbq issue i noticed things from return codes of
dev->hard_start_xmit().

The rules are as follows (unfortunately the documentation is outdated;
closest i could find was
http://www.firstfloor.org/~andi/softnet/softnet.drivers.HOWTO). Jeff i
thought you may have had something new.

0) no point of doing things like: 

if (netif_queue_stopped(dev)

Your code will never be entered to begin with if you are stopped.
You are wasting fast path cycles.
Also no point in doing a netif_stop_queue(dev) as soon as you enter
the driver. The driver will not be reentered (from say another CPU)
until you return.

1) When you have no space in your DMA 

Do NOT stash the packet in your ring
a) netif_stop_queue()
b) return 1

A _lot_ of drivers dont follow this rule. A good driver to copy
from if you are into cutnpaste is the e1000.
If you stash the packet in your ring then return 1 you are in deep 
doodoo friend. 

2) return a 0 only when you have succesfully put things on DMA.
Returning 0 always is not a BadThing. Most drivers do this.
It is a little less efficient at the top layer for each batch of packets
sent to the driver and you end up stopping the netif at this point.

3) In case of error probably return a 1 and dont try anything funny
with the skb. Dont put on your DMA or try to free it or muck with it in
any way. You probably should whine if you have too many errors in
sequence. 

Someone with more time than myself can audit the drivers - I have seen
these issues.

cheers,
jamal
