From: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Subject: Re: [PATCH net-drivers-2.6 5/6] e100: Performance optimizations to e100 Tx Path
Date: Thu, 21 Apr 2005 09:51:01 -0700
Message-ID: <5fc59ff305042109514b792bbf@mail.gmail.com>
References: <Pine.LNX.4.61.0504190534410.11186@anoushka.jf.intel.com>
	 <20050420200524.3e284eb9.rddunlap@osdl.org>
Reply-To: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Malli Chilakala <mallikarjuna.chilakala@intel.com>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20050420200524.3e284eb9.rddunlap@osdl.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 4/20/05, Randy.Dunlap <rddunlap@osdl.org> wrote:
> On Tue, 19 Apr 2005 22:50:31 -0700 (PDT) Malli Chilakala wrote:

> 
> |
> | -#define E100_WAIT_SCB_TIMEOUT 40
> | +#define E100_WAIT_SCB_TIMEOUT 20000 /* we might have to wait 100ms!!! */
> 
> What correlation is there between 20000 and 100 ms ?
> 

This needs some review and fixing on our side. 

> |  static inline int e100_exec_cmd(struct nic *nic, u8 cmd, dma_addr_t dma_addr)
> |  {
> |       unsigned long flags;
> | @@ -847,6 +847,10 @@ static inline int e100_exec_cb(struct ni
> |                        * because the controller is too busy, so
> |                        * let's just queue the command and try again
> |                        * when another command is scheduled. */
> | +                     if(err == -ENOSPC) {
>                         if (err == -ENOSPC) {
> is preferred (with space after if).
> (same comment for below)

Is there a clear directive on 'if(' versus 'if ('? I see both styles
being used. We are trying to stay consistent with 'if('.


> 
> | +                             //request a reset
> Kernel comment style is /* ... */, not //.
> (same comment for below)
> 

Agreed. Will fix this.

> | +                             schedule_work(&nic->tx_timeout_task);
> | +                     }
> |                       break;
> |               } else {
> |                       nic->cuc_cmd = cuc_resume;
> | @@ -1289,12 +1294,15 @@ static inline void e100_xmit_prepare(str
> |       struct sk_buff *skb)
> |  {
> |       cb->command = nic->tx_command;
> | +     /* interrupt every 16 packets regardless of delay */
> | +     if((nic->cbs_avail & ~15) == nic->cbs_avail) cb->command |= cb_i;
> Don't put if() and statement on one line, please.
> It tends to hide code unintentionally.

Will fix this.

> 
> |       cb->u.tcb.tbd_array = cb->dma_addr + offsetof(struct cb, u.tcb.tbd);
> |       cb->u.tcb.tcb_byte_count = 0;
> |       cb->u.tcb.threshold = nic->tx_threshold;
> |       cb->u.tcb.tbd_count = 1;
> |       cb->u.tcb.tbd.buf_addr = cpu_to_le32(pci_map_single(nic->pdev,
> |               skb->data, skb->len, PCI_DMA_TODEVICE));
> | +     // check for mapping failure?
> |       cb->u.tcb.tbd.size = cpu_to_le16(skb->len);
> |  }
> 
> ---
> ~Randy
> 
>
