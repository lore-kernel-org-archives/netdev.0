From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: NAPI note
Date: Tue, 18 Feb 2003 22:14:55 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E52F6AF.7000004@pobox.com>
References: <3E4D66DF.3040800@colorfullife.com> <3E4D8295.2050400@pobox.com> <20030217.185719.28797590.davem@redhat.com> <3E525FD8.1060009@colorfullife.com> <20030218212441.M25195@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
   "David S. Miller" <davem@redhat.com>, zaitcev@redhat.com,
   jbourne@mtroyal.ab.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <20030218212441.M25195@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> 
> On Tue, 18 Feb 2003, Manfred Spraul wrote:
> 
> 
>>David S. Miller wrote:
>>
>>
>>>  From: Jeff Garzik <jgarzik@pobox.com>
>>>  Date: Fri, 14 Feb 2003 18:58:13 -0500
>>>
>>>  Manfred Spraul wrote:
>>>  > It seems to be a generic NAPI restriction:
>>>  > The caller of netif_receive_skb() must not own a spinlock that is
>>>  > acquired from an interrupt handler.
>>>
>>>  Thanks much for noticing this, Manfred.
>>>
>>>I think this logic is buggy.
>>>
>>>In the example I've seen posted, only a NAPI implementation bug
>>>could cause the situation to occur.
>>>
>>>If cpu1 is in ->poll() for the driver, then by definition the
>>>device shall not cause interrupts.  The device's interrupts
>>>are disabled before we enter the ->poll() handler, and as such
>>>the "cpu2 take device interrupt and takes driver->lock" cannot
>>>occur.
>>>
>>>
>>
>>No. I think the rule is that drivers that use the NAPI interface must
>>not cause interrupts for packet receive and out-of-rx-buffers conditions.
> 
> 
> Ah, but that is only one of two rules.
> Theres other drivers which dont follow this rule and just shutdown
> all interupt sources. I know that the e1000 for example does this.
> I am not sure about the tg3. I think the doc says this but may not
> emphasize it as strongly.
> So if tg3 uses method 2 then its as Dave says - a bug.

tg3 shuts down all interrupt sources, and handles all interrupt events 
in dev->poll().

David and I hashed it out a bit on IRC.  The problem is that 
deliver_to_old_ones() waits, and thus the deadlock that Manfred 
described.  For 2.4.x, the solution is simply to avoid the deadlock in 
the driver.  For 2.5.x, David hinted that deliver_to_old_ones() may be 
going away.


>>But what about media error interrupts, or tx interrupts? Or MIB counter
>>overflow, etc. What about shared pci interrupts?
> 
> 
> Shared interupts should be interesting actually.
> However if you are in poll mode and you receive an interupt you should be
> able to quickly determine its not yours without much effect on shared
> locks, no?

Normally, yes.  However tg3 grabs a lock just about anytime it does 
anything.  ;-)  A long term project of mine is to slowly remove these 
locks, but that must wait until the driver stabilizes, and is overall a 
long process.  Most of the locks _are_ removeable, but we keep hit 
deadlock bugs like this, and hardware bugs which need workarounds, so 
those come first.


>>All of them could occur, and if they take a spinlock that is held across
>>netif_receive_skb(), then it can deadlock.
>>
> 
> 
> yes this could happen with method 1 of programming the driver; however,
> tx, receive, link are essentially separate threads and would hardly share
> locks.

They do in tg3's case.

The locks can be removed eventually, but such is the state of life right 
now.

	Jeff
