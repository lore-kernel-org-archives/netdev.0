From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Submission #3  for S2io 10GbE driver
Date: Tue, 02 Mar 2004 13:47:09 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4044D6AD.9090209@pobox.com>
References: <4223A04BF7D1B941A25246ADD0462FF50115AFCF@blr-m3-msg.wipro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: leonid.grossman@s2io.com, netdev@oss.sgi.com, shemminger@osdl.org,
        hch@infradead.org, ravinandan.arakali@s2io.com,
        raghavendra.koushik@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: raghavendra.koushik@wipro.com
In-Reply-To: <4223A04BF7D1B941A25246ADD0462FF50115AFCF@blr-m3-msg.wipro.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

raghavendra.koushik@wipro.com wrote:
> Hi Jeff,
> 
> 	Really sorry about that "confidentiality notice" that gets attached.
> I have asked my sysAdmin to get rid of it. He has promised to do so ASAP.
> Hope this mail does not have it attached at the end :-). If at all the
> message still persists please ignore it as inconsequential to our discussion.
> 
> I Have a few more questions.
> 
> 
>>>4) just delete the SET_NETDEV_DEV(), FREE_NETDEV, and IRQ_NONE
>>>compatibility defines.  these are in 2.4 just like 2.6.
> 
> 
> Not all 2.4 kernels have them yet right? but since this driver is going

Correct.  But when I merge this driver into 2.4, it will be latest 2.4 
(which contains these definitions).

The vendor (s2io) is expected to maintain any old-kernel compatibility 
outside the kernel.  For example, if you submitting the s2io driver for 
inclusion in my employer's product, Red Hat Enterprise Linux, then you 
would submit with the compatibility gunk.


> into 2.6 kernel if you want all these backward compatibility macros eliminated
> I can do that.

Yes, please.


>>>13) in s2io_xmit, kfree the skb (drop it) if you don't have enough free
>>>space to queue it.  this is normally a BUG condition, since proper use
>>>of netif_{start,stop,wake}_queue() will guarantee that s2io_xmit will
>>>only be called when there is free space to queue another skb.
> 
> 
> On returning error (non zero) from s2io_xmit, I think the calling function frees
> the skb.

Not correct in all cases, this is why the driver should drop the skb and 
free it.  Several existing drivers get this wrong, in fact :/


> How s2io_xmit works is when I get a packet for Tx and I find that all the
> Tx descriptors are owned by the NIC, I stop the queue and return error.
> So I wouldn't know before hand whether free queue space is available or not.

This is incorrect, and definitely an issue that needs to be addressed.

As I said, the model is, the driver calls netif_stop_queue() after 
queueing a packet, when it knows there is no more room for a full 
packet.  The tg3 driver does it like this:
	
	...queue an skb to hardware...
         if (TX_BUFFS_AVAIL(tp) <= (MAX_SKB_FRAGS + 1))
                 netif_stop_queue(dev);

Therefore you guarantee the queue is stopped until you are 100% certain 
that another skb (up to MAX_SKB_FRAGS + "main frag" fragments) may be 
queued to hardware.

You do -not- want to figure out "after the fact" that you cannot queue 
the skb you were just passed.

	Jeff
