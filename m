From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: generic 802.11 stack
Date: Wed, 15 Sep 2004 12:57:44 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41488298.7060909@linux.intel.com>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>	<200409090815.40358.vkondra@mail.ru>	<41408D8A.5010307@atheros.com>	<200409122103.21770.vkondra@mail.ru>	<4144E524.1050306@pobox.com> <20040912174544.630a0b44.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, vkondra@mail.ru, greg@atheros.com,
        netdev@oss.sgi.com, acx100-devel@lists.sourceforge.net,
        hadi@cyberus.ca, jkmaline@cc.hut.fi, prism54-devel@prism54.org,
        sam@errno.com, vda@port.imtp.ilyichevsk.odessa.ua
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040912174544.630a0b44.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>On Sun, 12 Sep 2004 20:09:08 -0400
>Jeff Garzik <jgarzik@pobox.com> wrote:
>  
>
>>Vladimir Kondratiev wrote:
>>    
>>
>>>To inform about status:
>>>I started to work on idea of 802.11 generic stack. I start from code by Dave. 
>>>This far I fixed it to compile for 2.6 (Makefile and couple of syntax 
>>>errors).
>>>I am going to implement minimum functionality, at this stage I will somehow 
>>>publish the project. Anyone can suggest what it the right solution for 
>>>hosting? Sourceforge? Something else?
>>>      
>>>
>>I can put it into the wireless-2.6 queue, which is where I would prefer 
>>that work on a generic 802.11 stack went.
>>    
>>
>
>This is fine with me as well.
>  
>
I have seen two paths that need to occur:

1) Creation of a generic 802.11 frame handling stack (management, data, 
etc.) sufficient to do .3 to .11 conversion, .11 fragmentation, state 
machine, etc.
2) Tight integration of a .11 stack into the kernel

The first step can occur with minimal changes to the rest of the 
kernel,  isolated completely within drivers/net/wireless.  Once a stack 
is there, all the drivers there can be adapted to use that.  This would 
seem reasonable to pull into the 2.6 stable series.

The second step will likely require more invasive changes to other parts 
of the networking stack and I hadn't thought such changes would be 
considered for 2.6.

Am I incorrect in the above?

We have been cleaning up the ipw2200/ipw2100 and their corresponding 
ieee80211 stack so that it could then be used with the other wifi 
drivers (adapting it to add back in features from HostAP that are 
currently stub'd out) in a non-intrusive way (we would like to get ipw* 
merged in soon).  We have a bk tree for this cloned from wireless-2.6 
avialable at ipw.bkbits.net/ipw-2.6.

Right now a driver can register with netdev's xmit to receive the 
ethernet frame and then pass it to ieee80211_skb_to_txb() to transform 
it into a chain of 802.11 fragments (encrypted if configured to do so) 
which the device can then pass to the HW.  I don't like the way the 
skb_to_txb transform occurs, but its working right now.  The next level 
of integration would be to have the device driver register an ieee80211 
stack callback as the xmit handler, and then register a .11 xmit with 
the ieee80211 stack.

Anyway, based on what I had read previously on this group, the sequence 
of steps I understood needing to be followed were:

0) Get the ipw2100 and ipw2200 drivers functionally complete so that end 
users can fully utilize that hardware.
1) Create generic ieee80211 frame handling stack.  HW specific piece 
should be limited to Tx/Rx of raw frames as much as possible (while 
supporting drivers that can not do full 802.11 frame tx/rx).  For 
nonintrusive inclusion in kernel, this would be achieved through calls 
into the ieee80211 stack from the driver vs. addition of netdev entry 
points.  To date this has been achieved by adding infrastructure into 
either the ipw2100 or ipw2200 project, then merging it into ieee80211 so 
that the other project could leverage it.
2) Adapt other drivers besides ipw2100 and ipw2200 to use the stack
3) Once 1 and 2 are stabilized, begin restructuring the entry points to 
more tightly integrate the .11 handling into the netdev core.

One area where I wasn't sure on how invasive it would be for stack 
optimizations deal with 802.11 fragmentation and encryption of said 
fragments such that TCP retries do not require 
re-fragmentation/encryption when host based enc/frag is enabled.

The next potentially invasive area is the addition of TGe support which 
Vladimir has discussed previously.

We based the current ieee80211 stack in part on the Host AP stack.  In 
looking through the madwifi stack, there are traights that it carries 
that would be nice to be able to use as well moving forward -- whether 
through code (CVS madwifi is licensed under a GPL compatible BSD 
license) or aspects of design. 

The whole of the ieee80211 stack (and ipw2100/ipw2200 drivers) are 
licensed under GPL version 2.

James
