From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH net-drivers-2.6 5/6] e100: Performance optimizations to
 e100 Tx Path
Date: Wed, 20 Apr 2005 20:05:24 -0700
Message-ID: <20050420200524.3e284eb9.rddunlap@osdl.org>
References: <Pine.LNX.4.61.0504190534410.11186@anoushka.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Malli Chilakala <mallikarjuna.chilakala@intel.com>
In-Reply-To: <Pine.LNX.4.61.0504190534410.11186@anoushka.jf.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Apr 2005 22:50:31 -0700 (PDT) Malli Chilakala wrote:

| Performance optimizations to e100 Tx Path
| 
| Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
| Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
| Signed-off-by: John Ronciak <john.ronciak@intel.com>
| diff -up net-drivers-2.6/drivers/net/e100.c net-drivers-2.6/drivers/net/e100.c.new
| --- net-drivers-2.6/drivers/net/e100.c	2005-04-07 03:22:36.805273784 -0700
| +++ net-drivers-2.6/drivers/net/e100.c.new	2005-04-07 03:22:37.251205992 -0700
| @@ -777,7 +777,7 @@ static int e100_eeprom_save(struct nic *
|  	return 0;
|  }
|  
| -#define E100_WAIT_SCB_TIMEOUT 40
| +#define E100_WAIT_SCB_TIMEOUT 20000 /* we might have to wait 100ms!!! */

What correlation is there between 20000 and 100 ms ?

|  static inline int e100_exec_cmd(struct nic *nic, u8 cmd, dma_addr_t dma_addr)
|  {
|  	unsigned long flags;
| @@ -847,6 +847,10 @@ static inline int e100_exec_cb(struct ni
|  			 * because the controller is too busy, so
|  			 * let's just queue the command and try again
|  			 * when another command is scheduled. */
| +			if(err == -ENOSPC) {
			if (err == -ENOSPC) {
is preferred (with space after if).
(same comment for below)

| +				//request a reset
Kernel comment style is /* ... */, not //.
(same comment for below)

| +				schedule_work(&nic->tx_timeout_task);
| +			}
|  			break;
|  		} else {
|  			nic->cuc_cmd = cuc_resume;
| @@ -1289,12 +1294,15 @@ static inline void e100_xmit_prepare(str
|  	struct sk_buff *skb)
|  {
|  	cb->command = nic->tx_command;
| +	/* interrupt every 16 packets regardless of delay */
| +	if((nic->cbs_avail & ~15) == nic->cbs_avail) cb->command |= cb_i;
Don't put if() and statement on one line, please.
It tends to hide code unintentionally.

|  	cb->u.tcb.tbd_array = cb->dma_addr + offsetof(struct cb, u.tcb.tbd);
|  	cb->u.tcb.tcb_byte_count = 0;
|  	cb->u.tcb.threshold = nic->tx_threshold;
|  	cb->u.tcb.tbd_count = 1;
|  	cb->u.tcb.tbd.buf_addr = cpu_to_le32(pci_map_single(nic->pdev,
|  		skb->data, skb->len, PCI_DMA_TODEVICE));
| +	// check for mapping failure?
|  	cb->u.tcb.tbd.size = cpu_to_le16(skb->len);
|  }


---
~Randy
