From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: Submission #3  for S2io 10GbE driver
Date: Tue, 2 Mar 2004 13:16:33 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDECB@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <leonid.grossman@s2io.com>, <netdev@oss.sgi.com>, <shemminger@osdl.org>,
        <hch@infradead.org>, <ravinandan.arakali@s2io.com>,
        <raghavendra.koushik@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>, <raghavendra.koushik@wipro.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> This is incorrect, and definitely an issue that needs to be addressed.
> 
> As I said, the model is, the driver calls netif_stop_queue() after 
> queueing a packet, when it knows there is no more room for a full 
> packet.  The tg3 driver does it like this:
> 	
> 	...queue an skb to hardware...
>          if (TX_BUFFS_AVAIL(tp) <= (MAX_SKB_FRAGS + 1))
>                  netif_stop_queue(dev);
> 
> Therefore you guarantee the queue is stopped until you are 
> 100% certain that another skb (up to MAX_SKB_FRAGS + "main frag"
> fragments) may be queued to hardware.
> 
> You do -not- want to figure out "after the fact" that you 
> cannot queue the skb you were just passed.

But tg3 checks this case also and returns 1:

        /* This is a hard error, log it. */
        if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->nr_frags +
1))) {
                netif_stop_queue(dev);
                ...
                return 1;
        }

Does this code path happen?

Using tg3 for reference, can we say this is the ideal model?

dev->hard_start

	if(!space_avail)
		stop_queue
		return 1;

	queue skb

	if(!space_avail)
		stop_queue

	return 0;

tx_clean

	if(queue_stopped && space_avail)
		wake_queue

-scott
