From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFR] gianfar ethernet driver
Date: Thu, 08 Jul 2004 18:29:28 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40EDCAC8.2050509@pobox.com>
References: <C681B01E-CEA9-11D8-931F-000393DBC2E8@freescale.com> <89563A5C-CFAE-11D8-BA44-000393C30512@freescale.com> <40EB89CC.2040100@pobox.com> <D3458628-D05D-11D8-BA44-000393C30512@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <AFLEMING@motorola.com>, netdev@oss.sgi.com,
        Kumar Gala <kumar.gala@motorola.com>, hadi@cyberus.ca,
        dwmw2@infradead.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <D3458628-D05D-11D8-BA44-000393C30512@freescale.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andy Fleming wrote:
> Ok, I will change the defaults.  Our performance testing indicates that 
> ttcp performance with mtu=1500 drops if NAPI is enabled vs. when it is 
> not.  This is for both TCP and UDP packets.  This made sense to me, as 
> NAPI incurs a slight latency penalty, and for 1518 byte frames, it does 
> not gain much advantage from interrupt reduction.

NAPI only begins to mitigate at the weighted traffic level.  Maybe your 
poll weight is too low?  It sounds like you still need to do some tuning 
and profiling.

For periodic but not high volume traffic, NAPI shouldn't incur latency 
penalties as you should be re-enabling interrupts shortly thereafter.

Only when you start hitting the NAPI thresholds does it start reducing 
interrupts.  At which point you should be at traffic levels where 
eliminating interrupt overhead should -decrease- your CPU usage.


> Hmm...  Does it call dev->set_mac_addr()?  Because that only seems to 
> copy the new address into the dev structure.  While I haven't been able 
> to trace the notification chain to discover the exact sequence of events 
> when someone changes the MAC address, I was thought that, in order for 
> the change to take effect, the interface needed to be brought down, then 
> up.  gfar_set_mac_address() is only called during gfar_open(), so I am 
> not aware of any way someone else could cause it to be called without 
> restarting the interface.  How should I set it up so that some other 
> code could call it?
[...]
> Yes, which is why gfar_change_mtu() halts the controller (thus ceasing 
> all DMA activity, and freeing buffer memory), then changes the MTU, and 
> then starts the controller again, causing buffers to be reallocated.  I 
> feel like I'm missing something obvious.  Perhaps I don't understand 
> exactly what you mean when  you say "synchronization"?  Are we talking 
> about locking, or making sure the hardware is configured without 
> screwing things up?  Or...what?

Through ifconfig, you can test changing MTU and MAC address while the 
interface is up.  Probably other tools (/sbin/ip?) also.

Synchronization means, what happens if all of the following occur at the 
same time:
1) RX packet received
2) net stack calls dev->hard_start_xmit() to transmit a packet
3) user decides he wants to change MAC addr/MTU

?

By synchronization, I mean that you must ensure all entry points into 
your driver are protected from racing against each other, or 
simultaneously accessing the same data structure(s).

>>>>> 33) merge-stopper:  mii_parse_sr().  never wait for autonegotiation to
>>>>> complete.  it is an asynchronous operation that could exceed 30 
>>>>> seconds.
>>>
>>> Hmm...
>>>
>>>>> 34) merge-stopper:  dm9161_wait().  same thing as #33.
>>>
>>> This may be a problem.  That function is there to work around an 
>>> issue in the PHY, wherein if you try to configure it before it has 
>>> come up all the way, it refuses to bring the link up.  We've sworn at 
>>> this code many times, but there has, as of yet, not been a good 
>>> suggestion as to how we can ensure that the 9161 is  ready before we 
>>> configure it.
>>
>>
>> I interpret that as a driver bug :)
>>
>> As common sense, regardless of phy bugs, you should not be trying to 
>> configure the MAC _or_ the phy in the middle of autonegotiation. 
>> Presumeably you are using a combination of netif_stop_queue(), 
>> netif_carrier_off(), and netif_device_detach() to achieve this.
> 
> 
> Hrm... This will require some fun, then.  My current scheme for PHY 
> configuration/management does not allow me to stop if autonegotiation 
> isn't done.  Clearly, I will have to rework the PHY code...

I'm not sure I understand the "My current scheme" sentence.  Clearly 
RX/TX DMA is not running, if you are in the middle of autonegotiation. 
So just make efforts to ensure that the kernel doesn't try to TX packets 
during that time (netif_carrier_off and/or netif_stop_queue), and make 
sure that random user ioctls (such as change-mtu or set-mac-addr :)) do 
not stomp all over the MAC while the phy is in the middle of autoneg.

Good hardware will give you an interrupt when it link is up, otherwise 
you'll probably have to use a timer to poll for link (which isn't 
present until autoneg ends, obviously).


>>>> 2) Also its pretty scary if you are doing:
>>>> txbdp->status |= TXBD_INTERRUPT for every packet.
>>>> Look at other drivers, they try to do this every few packets;
>>>> or enable tx mitigation to slow the rate  of those interupts.
>>>
>>> I don't believe this is as dire as you think.  This bit only 
>>> indicates that, if the conditions are right, an interrupt will be 
>>> generated once that descriptor is processed, and its data sent.  
>>> Conditions which mitigate that are:
>>> 1) coalescing is on, and the timer and counter have not triggered the 
>>> interrupt yet
>>> 2) NAPI is enabled, and so interrupts are disabled after the first 
>>> packet arrives
>>> 3) NAPI is disabled, but the driver is currently handling a previous 
>>> interrupt, so the interrupts are disabled for now.
>>
>>
>> Even at 10/100 speeds, you really don't want to be generating one 
>> interrupt per Tx...
> 
> 
> Hmm... My concern is this from Documentation/networking/driver.txt:
> 
> "For example, this means that it is not allowed for your TX
>    mitigation scheme to let TX packets "hang out" in the TX
>    ring unreclaimed forever if no new TX packets are sent.
>    This error can deadlock sockets waiting for send buffer room
>    to be freed up."
> 
> Is this no longer accurate?  Anyway, as long as coalescing is on, there 
> won't be one interrupt per frame.

Hopefully your hardware provides something other than purely 
packet-based intr mitigation?  Usually there is a timeout, if no TX (or 
RX) interrupt has been sent in X time period.

	Jeff
