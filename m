From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [RFC PATCH v4 linux-next] et131x: Promote staging et131x driver
 to drivers/net
Date: Tue, 29 Jan 2013 12:47:14 +0000
Message-ID: <CANK3SE2kiV0gPRaM0Y-eHs0cxXs8ZgZK=p=eNZnENOdXir7rNA@mail.gmail.com>
References: <1358945130-3101-1-git-send-email-mark.einon@gmail.com>
 <1358958278-3207-1-git-send-email-mark.einon@gmail.com> <20130128.231057.57111832691623178.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: gregkh@linuxfoundation.org, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	linux-kernel@vger.kernel.org, dan.carpenter@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130128.231057.57111832691623178.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29 January 2013 04:10, David Miller <davem@davemloft.net> wrote:
> From: Mark Einon <mark.einon@gmail.com>
> Date: Wed, 23 Jan 2013 16:24:38 +0000
>
>> +endif # NET_VENDOR_AGERE
>> +
>
> Trailing empty line, delete it.
>
>> @@ -0,0 +1,6 @@
>> +#
>> +# Makefile for the Agere ET-131x ethernet driver
>> +#
>> +
>> +obj-$(CONFIG_ET131X) += et131x.o
>> +
>
> Likewise, get rid of this trailing empty line.
>
>> +     /* Spinlocks */
>> +     spinlock_t lock;
>> +
>> +     spinlock_t tcb_send_qlock;
>> +     spinlock_t tcb_ready_qlock;
>> +     spinlock_t send_hw_lock;
>> +
>> +     spinlock_t rcv_lock;
>> +     spinlock_t rcv_pend_lock;
>> +     spinlock_t fbr_lock;
>> +
>> +     spinlock_t phy_lock;
>
> Do you really need _8_ spinlocks in an ethernet driver?  To me that's
> way over the top and excessive.
>
> The most recent driver I've written, for the 10Gbit Sun NIU parts,
> has only one spinlock.
>
>> +     /* Determine if this is a multicast packet coming in */
>
> What in the world are you doing in this huge code block?
>
> Such much complexity, multicast list iteration, etc. just to get some
> statistics correct?  This stuff is going to run on every multicast
> packet receive.
>
> No other driver does crap like this, get rid of this stuff.
>
>> +     skb->dev = adapter->netdev;
>> +     skb->protocol = eth_type_trans(skb, adapter->netdev);
>
> eth_type_trans() sets skb->dev, you don't need to duplicate that.
>
>> +     netif_rx_ni(skb);
>
> Why isn't this driver supporting NAPI?  If you're going to put this
> much time into a driver, use the best interfaces for event processing
> rather than something that might have been appropriate in a new driver
> two decades ago.
>
>> +static int et131x_tx(struct sk_buff *skb, struct net_device *netdev)
>> +{
>> +     int status = 0;
>> +     struct et131x_adapter *adapter = netdev_priv(netdev);
>> +
>> +     /* stop the queue if it's getting full */
>> +     if (adapter->tx_ring.used >= NUM_TCB - 1 &&
>> +         !netif_queue_stopped(netdev))
>> +             netif_stop_queue(netdev);
>> +
>> +     /* Save the timestamp for the TX timeout watchdog */
>> +     netdev->trans_start = jiffies;
>> +
>> +     /* Call the device-specific data Tx routine */
>> +     status = et131x_send_packets(skb, netdev);
>> +
>> +     /* Check status and manage the netif queue if necessary */
>> +     if (status != 0) {
>> +             if (status == -ENOMEM)
>> +                     status = NETDEV_TX_BUSY;
>> +             else
>> +                     status = NETDEV_TX_OK;
>> +     }
>> +     return status;
>> +}
>
> Returning NETDEV_TX_BUSY is an error, no driver should ever return
> that status under normal circumstances.  Some drivers return it
> when internal consistency checks fail, but that indicates a driver
> bug rather than a normal condition.
>
> Memory allocation erorrs do not denote NETDEV_TX_BUSY, simply drop
> the packet silently with kfree_skb() and return NETDEV_TX_OK.
>
> That's about enough for me, this driver still needs a lot of work
> and is far from being ready to move out of staging.

Thanks for taking the time to give feedback. I'll update the TODO list.

Cheers,

Mark
