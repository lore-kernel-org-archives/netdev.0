From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.9-rc2 6/8] S2io: new txd allocation
Date: Thu, 14 Oct 2004 10:58:18 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416E940A.5010501@pobox.com>
References: <005201c4b18b$538b5ff0$6c10100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Francois Romieu'" <romieu@fr.zoreil.com>, netdev@oss.sgi.com,
        leonid.grossman@s2io.com, raghavendra.koushik@s2io.com,
        rapuru.sriram@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@s2io.com
In-Reply-To: <005201c4b18b$538b5ff0$6c10100a@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ravinandan Arakali wrote:
> Hi,
> The attached patch contains a modified scheme for allocating Tx descriptor
> blocks.
> More description follows.
> 
> In the old scheme, the entire Tx descriptor space was allocated in one go.
> This could cause driver load to fail on systems with low(or scattered)
> memory. The Tx descriptor blocks are now allocated on per-page basis. A new
> structure (list_info) has been introduced in nic_t structure to keep track
> of the physical and virtual addresses of every TxD allocated this way.
> 
> Signed-off-by: Raghavendra Koushik <raghavendra.koushik@s2io.com>


Comments:

1) spinlock in s2io_close looks questionable.  at best you want to 
minimize the area covered by it.

you are guaranteed that netif_running() will be false if the net stack 
is calling, or has called, dev->stop() hook.


2) netif_queue_stopped() will never be false when your 
dev->hard_start_xmit() hook is called

> +       if ((netif_queue_stopped(dev)) || (!netif_carrier_ok(dev))) {
> +               DBG_PRINT(TX_DBG, "%s:s2io_xmit: Tx Queue stopped\n",
> +                         dev->name);
> +               dev_kfree_skb(skb);
> +               spin_unlock_irqrestore(&sp->tx_lock, flags);
> +               return 0;
> +       }
> +


3) referencing the code above, you should (a) not free the package and 
(b) return from the following codes listed in include/linux/netdevice.h:

#define NETDEV_TX_OK 0          /* driver took care of packet */
#define NETDEV_TX_BUSY 1        /* driver tx path was busy*/
#define NETDEV_TX_LOCKED -1     /* driver tx lock was already taken */
