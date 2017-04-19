From: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: bluetooth 6lowpan interfaces are not virtual anymore
Date: Wed, 19 Apr 2017 19:43:07 +0200
Message-ID: <f3c04860-651e-c9f3-e7ab-db609d105436@pengutronix.de>
References: <2d178eb8-3fbc-3385-6e0c-fa9941713959@pengutronix.de>
 <CABBYNZLqTvd5cnG4fKJgPKJGvS6hsk8vOM+7NQ_RhLJ-WOszmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Jukka Rissanen <jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        "linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Bluetooth <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Michael Richardson <mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org>
To: Luiz Augusto von Dentz <luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CABBYNZLqTvd5cnG4fKJgPKJGvS6hsk8vOM+7NQ_RhLJ-WOszmg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

at first I want to clarify what my definition of virtual and non virtual
interface is:

- virtual interfaces: has no queue(s)
- non virtual interfaces: has a queue(s)

I did some "big" ASCII graphic what I think it will do now.
At first the virtual interface:

--- snip ---

Transmit side only! Case of virtual interface.            
                                                          
IPv6 Stack                                                
                                                          
                +-----------------------------+           
                |    IPv6 Packet (ND, etc)    |           
                +--------------+--------------+           
                               |                          
      -------------------------+---------------------------------
6LoWPAN Interface              |                          
                               |                          
                +--------------v--------------+           
                | Adaptation (IPv6 to 6Lo)    |           
                +--------------+--------------+
    +--------------------------+
    |
    | -----------------------------------------------------------
Link|Layer (802.15.4/hci_dev/etc)
    |
    |                  SKB Queue (With kind of discipline)
    |           +----------------+---------------+-------------+
    +----------->      SKB1      |     SKBN      |     ...     +----+
                +----------------+---------------+-------------+    |
                                                                    |
                                                                    |
      ------------------------------------------------------------  |
Real Transeiver Hardware                                            |
                                       +----------------------------+
                                       |
              +------------------------v-----------------------+
              |        Framebuffers (YOUR hardware resource)   |
              +------------------------------------------------+

--- snap ---

The non virtual interface:

--- snip ---

Transmit side only! Case of non virtual interface.
                                                          
IPv6 Stack                                                
                                                          
                +-----------------------------+           
                |    IPv6 Packet (ND, etc)    |           
                +--------------+--------------+
                               |
      -------------------------+---------------------------------
6LoWPAN Interface              |
                               |
    +--------------------------+
    |                                                              /> Will be queued if you stop the queue          
    |                  SKB Queue (With kind of discipline)      /--   Because Link Layer is full/software limitation
    |           +----------------+---------------+-------------+                                                     
    +----------->      SKB1      |     SKBN      |     ...     +----+                                                
                +----------------+---------------+-------------+    |                                                
                                                                    |                                                
                               +------------------------------------+                                                
                               |                                                                                     
                +--------------v--------------+                                                                      
                | Adaptation (IPv6 to 6Lo)    |                                                                      
                +--------------+--------------+                                                                      
    +--------------------------+                                                                                     
    |                                                                                                                
    | -----------------------------------------------------------                                                    
Link|Layer (802.15.4/hci_dev/etc)                                                                                    
    |                                                              -> software limitation (tx credits?)              
    |                  SKB Queue (With kind of discipline)     ---/   Right position to make different handling (for virtual case).
    |           +----------------+---------------+------------/+
    +----------->      SKB1      |     SKBN      |     ...     +----+
                +----------------+---------------+-------------+    |
                                                                    |
                                                                    |
      ------------------------------------------------------------  |
Real Transeiver Hardware                                            | 
                                       +----------------------------+
                                       |
              +------------------------v-----------------------+
              |        Framebuffers (YOUR hardware resource)   |
              +------------------------------------------------+


--- snap ---

Adding a queue to a interface which does a protocol translation only is
in my opinion: wrong.

At least if you want to try to make a more efficient qdisc handling,
means dropping skb's in queue when userspace sends too much. You will
change it back, control two queues seems to be difficult.

On 04/18/2017 12:43 PM, Luiz Augusto von Dentz wrote:
> Hi Alex,
> 
> On Mon, Apr 17, 2017 at 8:56 PM, Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org> wrote:
>> Hi,
>>
>> bluetooth-next contains patches which introduces a queue for bluetooth
>> 6LoWPAN interfaces. [0]
>>
>> At first, the current behaviour is now that 802.15.4 6LoWPAN interfaces
>> are virtual and bluetooth 6LoWPAN interfaces are not virtual anymore.
>> To have a different handling in both subsystems is _definitely_ wrong.
> 
> Well 15.4 and Bluetooth have very different handling, iirc in 15.4 you
> do have a real interface which has, in fact, queueing support:
> 
> net/mac802154/iface.c:ieee802154_if_setup:
> dev->tx_queue_len = 300;
> 

Is l2cap_chan_send a call with is synchronized which wait for it so
after that the "l2cap bluetooth *frame*. etc." is send?

I looked at the code [0]. It will queue it in some skb queue, so far I
see. Hard to see it in this code, but I see some queueing and workqueue
scheduling [1] in the function which will be called by l2cap_chan_send.

This queue should have the same meaning like our queue in IEEE
802.15.4 interface which you mentioned above.
At this point, we have no difference. There exists already a queue for
your real transeiver hardware.

>> What does the 6LoWPAN interface?
>>
>> It will do a protocol change (an adaptation, because 6LoWPAN should
>> provide the same functionality as IPv6) from IPv6 to 6LoWPAN (tx) and
>> vice versa for (rx). In my opinion this should be handled as a virtual
>> interface and not as an interface with a queue.
> 
> Then we need a real netif for Bluetooth as well, one that does
> queueing since introducing for l2cap_chan makes no sense when most of
> time the userspace has a socket which does its own queueing. Btw, I
> have the opinion that doing a second interface just to make Bluetooth
> behave like 15.4 is very wasteful since we don't have any other
> network support except for bnep, which in fact does the same thing
> regarding queueing.
> 

If bnep just generates some ethernet frames and you put L2CAP around,
then it should be virtual too. If it queue skbs for sending out for the
hci_dev. Then it ends in a similar queue handling like "non virtual
6LoWPAN interface".

What you mean with second interface? At least you need a capable
net_device interface to offer an IP connection from userspace.

>> What makes a queue on 6LoWPAN interfaces?
>>
>> It will queue IPv6 packets which waits for it adaptation (the protocol
>> change) with some additional qdisc handling.
>> If finally the xmit_do callback will occur it will replace IPv6 header
>> with 6LoWPAN, etc. After that it should be queued into some queue on
>> link layer side which should be do the transmit finally.
> 
> In case of Bluetooth it does the Link Layer using L2CAP, which is not
> exactly at Link Layer, in fact it is one of the major problems of
> having this in Kernel space since it is similar of doing IP over TCP
> tunnel.
> 

aha, but this has nothing to do to decide that you have a 6LoWPAN queue,
or? I think this is one reason why you want a "6lowtun" interface. To
handle L2CAP in userspace.

>> Why I think bluetooth introduced a queue handling on 6LoWPAN interfaces?
>>
>> Because I think they don't like their own *qdisc* handling on their link
>> layer interface. I write *qdisc* here because, they have no net_devices
>> and use some kind of own qdisc handling.
> 
> No we don't, and except we do change the whole architecture of
> Bluetooth to work as a net_device I don't think we can have a similar
> design as 15.4. Anyway Bluetooth is not really designed to carry IP,
> the L2CAP and other profiles above are mostly a Bluetooth thing so
> having a net_device would not buy us much more than queueing for bnep
> and ipsp.
> 

At least, having a queue and don't put anything anymore into the queue
when "tx credits" is at zero (because queue is full). _Is_ a kind of
qdisc handling.

>> My question: is this correct?
>>
>> How to fix that (In my opinion):
>>
>> So commit [0] says something "out of credits" that's what I think it's
>> the *qdisc* handling. If you cannot queue anymore -> you need to drop
>> it. If you don't like how the current behaviour is, you need to change
>> your *qdisc* handling on your link layer interface. Introducing queue at
>> 6LoWPAN interfaces will introduce "buffer bloating".
> 
> That is not what the code comments says, eg. netif_stop_queue:
> 
>  * Stop upper layers calling the device hard_start_xmit routine.
>  * Used for flow control when transmit resources are unavailable.
> 

This comments are correct so long you operate on "real hardware
resources" which 6LoWPAN interfaces doesn't do. In case so far I see, it
will call l2cap_chan_send which putting some L2CAP protocol on it (to
provide data) and somewhere queue it for transmit to fill "real hardware
resources" e.g. framebuffers.

Your "resource" which is unavailable is the link layer queue, but this
is just a software limitation by bluetooth, which you can change by
software to make a different handling, than just adding more software queues.

What _virtual_ 6LoWPAN interface does is:

Input: IPv6 -> Output: 6LoWPAN, without any queueing in front of that.

> The fact 15.4, and bnep, uses these APIs makes me believe this is the
> proper way of using qdisc handling, the only difference here is at
> what level we would be using them.
> 

On 15.4 we use it for link layer interface queue, but we don't put
another queue in 6LoWPAN. See my aboves ASCII arts which shows the
different when 6LoWPAN is virtual and not virtual.

---

We have already qdisc problems in our case. In 15.4 it "just works" for
now, but we need more handling there to send not garbage if one frame
gets dropped there, see [2].

In my opinion, if bluetooth people will hit similar issues, you will
change it back that 6LoWPAN has no queue anymore. Otherwise it will very
hard to decide which skbs you drop or not - because you need to deal
with two queues.

To make 6LoWPAN non virtual anymore and just adding a queue will occur
that you don't drop much anymore... but the queue at link layer
(hci_dev) will work as before and this occurs buffer bloating only.

>> ---
>>
>> I don't care what bluetooth does with the 6LoWPAN interface. If bluetooth
>> people wants such behaviour, then I am okay with that.
>>
>> I will bookmark this mail for the time when somebody reverts it to a
>> virtual interface again. I think somebody will change it again, or maybe
>> somebody will argument why we need a queue here.
> 
> From what I could grasp from the code except if 6LoWPAN start creating
> its own interface, which it doesn't currently, it should never assume
> any specific behavior for an interface. 6LoWPAN right now only have
> helper functions which the interface code call on TX/RX, and by
> looking at code under 15.4 the only thing we would be doing is to set
> skb->dev = wdev; (wdev being the real device) as Bluetooth don't use
> 6lowpan fragmentation.
> 

yep, there is a lot of work do make a better framework, but has nothing
do to why bluetooth introduced a second queue on 6lowpan interfaces.

> Btw, another big different in terms of design that it seems 15.4 does
> create interfaces to each and every link, in Bluetooth the interface
> is per adapter so it is in fact multi-link, I guess in practice 15.4
> shall only have one 6lowpan link since it is connected to mesh, but in
> Bluetooth we may have more than one Link and I don't think it would be
> a good idea to have each of these links as a different interface,
> especially not with the same mac address as it seems to be what 15.4
> code is doing:
> 
> /* Set the lowpan hardware address to the wpan hardware address. */
> memcpy(ldev->dev_addr, wdev->dev_addr, IEEE802154_ADDR_LEN);
> 

Of course we need the same mac address there (at first), because we
have an address filter on hardware.

(Be aware that you _cannot_ change the mac address (dev->dev_addr) while IP
 capable net device is up. They assume the mac address is read only if net
 device is up.)

There is currently an idea to provide multiple links, but then hardware
need to go into promiscuous mode (disable address filtering) but then we
will lose some hardware offloading stuff e.g. ACK handling.
If we have that, we can provide multiple links with different mac
addresses, at least this will be handled as multiple wpan interfaces for
one PHY.

> So at least with IPSP/RFC-7668 the topology is completely different
> from what we can see in 15.4, it may happen that this changes with
> upcoming changes to Bluetooth, adding yet another topology that we
> will need to support. Personally I wouldn't mind if 15.4 and Bluetooth
> had more in common, at least at 6lowpan level, so we wouldn't have the
> need to create separated modules just to deal with their differences,
> but in reality, these technologies are competing for the same market
> so I don't think it will happen, unfortunately.
>

You already have separated modules, this is .e.g IPHC stuff and 6lowpan
specific implementation for bluetooth. In net/bluetooth/6lowpan.c you
can put your changes for make specific bluetooth handling.

This discussion moved currently to a more complex question about how to
make the whole 6lowpan architecture...

I think I tried to explain so much as possible what a queue on top of
6lowpan interface will do, at least if you want to make a better queue
handling (when dropping skb's inside the queue(s)) then you will fail
and revert that change (I think). But then I can say "I told you so" :-)

- Alex

[0] http://lxr.free-electrons.com/source/net/bluetooth/l2cap_core.c#L2455
[1] http://lxr.free-electrons.com/source/net/bluetooth/hci_core.c#L3490
[2] http://www.spinics.net/lists/linux-wpan/msg03679.html
