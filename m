From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH] [-MM,
 FIX V4] e1000e: incorporate napi_struct changes from net-2.6.24.git
Date: Mon, 17 Sep 2007 13:06:09 +0200
Message-ID: <46EE5FA1.3080501@gmail.com>
References: <20070910233503.19058.29051.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, jirislaby@gmail.com, jeff@garzik.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, davem@davemloft.net
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20070910233503.19058.29051.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 12/23/-28158 08:59 PM, Auke Kok wrote:
> This incorporates the new napi_struct changes into e1000e. Included
> bugfix for ifdown hang from Krishna Kumar for e1000.
> 
> Disabling polling is no longer needed at init time, so remove
> napi_disable() call from _probe().
> 
> This also fixes an endless polling loop where the driver signalled
> "polling done" improperly back to the stack.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/e1000.h  |    2 ++
>  drivers/net/e1000e/netdev.c |   40 ++++++++++++++++------------------------
>  2 files changed, 18 insertions(+), 24 deletions(-)
> 
> diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
> index c57e35a..d2499bb 100644
> --- a/drivers/net/e1000e/e1000.h
> +++ b/drivers/net/e1000e/e1000.h
> @@ -187,6 +187,8 @@ struct e1000_adapter {
>  	struct e1000_ring *tx_ring /* One per active queue */
>  						____cacheline_aligned_in_smp;
>  
> +	struct napi_struct napi;
> +
>  	unsigned long tx_queue_len;
>  	unsigned int restart_queue;
>  	u32 txd_cmd;
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> index 372da46..eeb40cc 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -1149,12 +1149,12 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
>  			mod_timer(&adapter->watchdog_timer, jiffies + 1);
>  	}
>  
> -	if (netif_rx_schedule_prep(netdev)) {
> +	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
>  		adapter->total_tx_bytes = 0;
>  		adapter->total_tx_packets = 0;
>  		adapter->total_rx_bytes = 0;
>  		adapter->total_rx_packets = 0;
> -		__netif_rx_schedule(netdev);
> +		__netif_rx_schedule(netdev, &adapter->napi);
>  	} else {
>  		atomic_dec(&adapter->irq_sem);
>  	}
> @@ -1212,12 +1212,12 @@ static irqreturn_t e1000_intr(int irq, void *data)
>  			mod_timer(&adapter->watchdog_timer, jiffies + 1);
>  	}
>  
> -	if (netif_rx_schedule_prep(netdev)) {
> +	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
>  		adapter->total_tx_bytes = 0;
>  		adapter->total_tx_packets = 0;
>  		adapter->total_rx_bytes = 0;
>  		adapter->total_rx_packets = 0;
> -		__netif_rx_schedule(netdev);
> +		__netif_rx_schedule(netdev, &adapter->napi);
>  	} else {
>  		atomic_dec(&adapter->irq_sem);
>  	}
> @@ -1662,10 +1662,10 @@ set_itr_now:
>   * e1000_clean - NAPI Rx polling callback
>   * @adapter: board private structure
>   **/
> -static int e1000_clean(struct net_device *poll_dev, int *budget)
> +static int e1000_clean(struct napi_struct *napi, int budget)
>  {
> -	struct e1000_adapter *adapter;
> -	int work_to_do = min(*budget, poll_dev->quota);
> +	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter, napi);
> +	struct net_device *poll_dev = adapter->netdev;
>  	int tx_cleaned = 0, work_done = 0;
>  
>  	/* Must NOT use netdev_priv macro here. */
> @@ -1684,25 +1684,19 @@ static int e1000_clean(struct net_device *poll_dev, int *budget)
>  		spin_unlock(&adapter->tx_queue_lock);
>  	}
>  
> -	adapter->clean_rx(adapter, &work_done, work_to_do);
> -	*budget -= work_done;
> -	poll_dev->quota -= work_done;
> +	adapter->clean_rx(adapter, &work_done, budget);
>  
>  	/* If no Tx and not enough Rx work done, exit the polling mode */
> -	if ((!tx_cleaned && (work_done == 0)) ||
> +	if ((!tx_cleaned && (work_done < budget)) ||

Hi,

sorry to say that, but this change since last your patch changes nothing on my
machine (ksoftirq spinning at 100 % of CPU usage), I have some traces for you if
it helps:

SysRq : Show Regs
CPU 0:
Modules linked in: floppy sr_mod ehci_hcd cdrom rtc_cmos rtc_core usbhid rtc_lib
Pid: 4, comm: ksoftirqd/0 Not tainted 2.6.23-rc4-mm1_64 #24
RIP: 0010:[<ffffffff803b4ea3>]  [<ffffffff803b4ea3>] e1000_clean_rx_irq+0x273/0x320
RSP: 0000:ffffffff80703e18  EFLAGS: 00000202
RAX: ffff8100032b0700 RBX: ffffffff80703ea8 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff810003097f60
RBP: ffffffff80703d90 R08: ffff810002b85340 R09: 0000000000000002
R10: 0000000000000002 R11: ffff8100032b0700 R12: ffffffff8020c1f1
R13: ffffffff80703d90 R14: ffff810004eac020 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffffffff806ad000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00000000445d9978 CR3: 0000000004c49000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Call Trace:
 <IRQ>  [<ffffffff803b4e86>] e1000_clean_rx_irq+0x256/0x320
 [<ffffffff803b3059>] e1000_clean+0x109/0x250
 [<ffffffff80250a43>] hrtimer_run_queues+0x33/0x1b0
 [<ffffffff8046d777>] net_rx_action+0xd7/0x190
 [<ffffffff8023dc54>] __do_softirq+0x74/0xf0
 [<ffffffff8020ce6c>] call_softirq+0x1c/0x30
 <EOI>  [<ffffffff8020eecd>] do_softirq+0x3d/0x90
 [<ffffffff8023d932>] ksoftirqd+0x72/0x100
 [<ffffffff8023d8c0>] ksoftirqd+0x0/0x100
 [<ffffffff8024dbbd>] kthread+0x4d/0x80
 [<ffffffff8020caf8>] child_rip+0xa/0x12
 [<ffffffff8024db70>] kthread+0x0/0x80
 [<ffffffff8020caee>] child_rip+0x0/0x12

SysRq : Show Regs
CPU 0:
Modules linked in: floppy sr_mod ehci_hcd cdrom rtc_cmos rtc_core usbhid rtc_lib
Pid: 4, comm: ksoftirqd/0 Not tainted 2.6.23-rc4-mm1_64 #24
RIP: 0010:[<ffffffff804cd3f8>]  [<ffffffff804cd3f8>] _spin_trylock+0x8/0x20
RSP: 0000:ffffffff80703ea8  EFLAGS: 00000246
RAX: 0000000000000001 RBX: ffffffff80703ea8 RCX: ffffffff80703f28
RDX: ffff8100032b0888 RSI: 0000000000000040 RDI: ffff8100032b0850
RBP: ffffffff80703e20 R08: ffff810002b85340 R09: 0000000000000002
R10: 0000000000000002 R11: ffff8100032b0700 R12: ffffffff8020c1f1
R13: ffffffff80703e20 R14: 0000000000000040 R15: ffff8100032b0700
FS:  0000000000000000(0000) GS:ffffffff806ad000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00000000445d9978 CR3: 0000000004c49000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Call Trace:
 <IRQ>  [<ffffffff803b302d>] e1000_clean+0xdd/0x250
 [<ffffffff80250a43>] hrtimer_run_queues+0x33/0x1b0
 [<ffffffff8046d777>] net_rx_action+0xd7/0x190
 [<ffffffff8023dc54>] __do_softirq+0x74/0xf0
 [<ffffffff8020ce6c>] call_softirq+0x1c/0x30
 <EOI>  [<ffffffff8020eecd>] do_softirq+0x3d/0x90
 [<ffffffff8023d932>] ksoftirqd+0x72/0x100
 [<ffffffff8023d8c0>] ksoftirqd+0x0/0x100
 [<ffffffff8024dbbd>] kthread+0x4d/0x80
 [<ffffffff8020caf8>] child_rip+0xa/0x12
 [<ffffffff8024db70>] kthread+0x0/0x80
 [<ffffffff8020caee>] child_rip+0x0/0x12

regards,
-- 
Jiri Slaby (jirislaby@gmail.com)
Faculty of Informatics, Masaryk University

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
