From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Submission #3  for S2io 10GbE driver
Date: Tue, 02 Mar 2004 16:21:02 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4044FABE.9070408@pobox.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDECB@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: raghavendra.koushik@wipro.com, leonid.grossman@s2io.com,
        netdev@oss.sgi.com, shemminger@osdl.org, hch@infradead.org,
        ravinandan.arakali@s2io.com, raghavendra.koushik@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDECB@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Feldman, Scott wrote:
>>This is incorrect, and definitely an issue that needs to be addressed.
>>
>>As I said, the model is, the driver calls netif_stop_queue() after 
>>queueing a packet, when it knows there is no more room for a full 
>>packet.  The tg3 driver does it like this:
>>	
>>	...queue an skb to hardware...
>>         if (TX_BUFFS_AVAIL(tp) <= (MAX_SKB_FRAGS + 1))
>>                 netif_stop_queue(dev);
>>
>>Therefore you guarantee the queue is stopped until you are 
>>100% certain that another skb (up to MAX_SKB_FRAGS + "main frag"
>>fragments) may be queued to hardware.
>>
>>You do -not- want to figure out "after the fact" that you 
>>cannot queue the skb you were just passed.
> 
> 
> But tg3 checks this case also and returns 1:
> 
>         /* This is a hard error, log it. */
>         if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->nr_frags +
> 1))) {
>                 netif_stop_queue(dev);
>                 ...
>                 return 1;
>         }
> 
> Does this code path happen?

You snipped the important

                 printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue 
awake!\n",
                        dev->name);

It's a BUG because it should never happen.

tg3 needs to kfree the skb too, leading to my comment "some existing 
drivers get this wrong too".  Requeueing the skb only occurs in -some- 
packet schedulers, not all.  So drivers cannot depend on the net stack 
doing what you want in all cases.  Conditional correct behavior or 
leak..  :/

	Jeff
