From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: FW: Submission for S2io 10GbE driver
Date: Sat, 24 Jan 2004 01:38:07 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040124013807.B24000@electric-eye.fr.zoreil.com>
References: <002201c3e1f6$f97896e0$5d50ff11@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@s2io.com>
Content-Disposition: inline
In-Reply-To: <002201c3e1f6$f97896e0$5d50ff11@S2IOtech.com>; from leonid.grossman@s2io.com on Fri, Jan 23, 2004 at 01:22:11PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Leonid Grossman <leonid.grossman@s2io.com> :
[...]
> Send me your comments/suggestions on the source please,  and we will
> address the code changes (if any) in real time.

No need to hurry.

s2io.c:

[...]
int s2io_starter(void);
void s2io_closer(void);
void s2io_tx_watchdog(struct net_device *dev);
void s2io_tasklet(unsigned long dev_addr);
void s2io_set_multicast(struct net_device *dev);
int rxOsmHandler(nic_t *sp,u16 len,RxD_t *rxdp,int ring_no);
void s2io_link(nic_t *sp, int link);
void s2io_reset(nic_t *sp);

-> s2io_tx_watchdog()...s2io_reset() probably want to be 'static'

#ifdef CONFIGURE_NAPI_SUPPORT
static int s2io_poll(struct net_device *dev, int *budget);
#endif

#define TASKLET_IN_USE	test_and_set_bit(0, (unsigned long *)&sp->tasklet_status)
#define PANIC	1
#define LOW	2
static inline int rx_buffer_level(nic_t *sp, int rxb_size, int ring)
{
	int level = 0;
	if((sp->pkt_cnt[ring] - rxb_size) > 128) {
		level = LOW;
		if(rxb_size < sp->pkt_cnt[ring]/8)
			level = PANIC;

-> whitespaces after the C keywords help sometimes (especially at 1:00 am)

	}
	
	return level;
}

[...]
static char s2io_gstrings[][ETH_GSTRING_LEN] = {
"Register test\t(offline)",
"Eeprom test\t(offline)",
"Loop back test\t(online)",
"Link test\t(online)",
"RLDRAM test\t(offline)",
"BIST Test\t(offline)"

-> please add a tab before the strings

};
[...]
	if(size > MAX_AVAILABLE_TXDS) {
		DBG_PRINT(ERR_DBG,"%s: Total number of Tx FIFOs ",dev->name);
		DBG_PRINT(ERR_DBG,"exceeds the maximum value ");
		DBG_PRINT(ERR_DBG,"that can be used\n");
		return FAILURE;	
                       ^^^^^^^
-> -ESOMETHING ?
                    
[...]
	for(i=0;i<nic->config.TxFIFONum;i++) {
		nic->mac_control.txdl_start_phy[i] = tmp_p_addr;
		nic->mac_control.txdl_start[i] = (TxD_t *)tmp_v_addr;
		nic->mac_control.tx_curr_put_info[i].offset = 0;
		nic->mac_control.tx_curr_put_info[i].fifo_len =
		nic->config.TxCfg[i].FifoLen-1;
		nic->mac_control.tx_curr_get_info[i].offset = 0;
		nic->mac_control.tx_curr_get_info[i].fifo_len =
		nic->config.TxCfg[i].FifoLen-1;

-> you probably want to add local variables (as well as an helper function ?)
   to avoid repeating 'nic->mac_control' over and over.
	
		tmp_p_addr += (nic->config.TxCfg[i].FifoLen*(sizeof(TxD_t))*
			nic->config.MaxTxDs);
		tmp_v_addr += (nic->config.TxCfg[i].FifoLen*(sizeof(TxD_t))*
			 nic->config.MaxTxDs);
	}

/* Allocation and initialization of RXDs in Rings */
	size = 0;
	for(i=0; i<nic->config.RxRingNum; i++) {
		if(nic->config.RxCfg[i].NumRxd % 128) {
			DBG_PRINT(ERR_DBG,"%s: RxD count of ",dev->name);
			DBG_PRINT(ERR_DBG,"Ring%d is not a multiple of ", i);
			DBG_PRINT(ERR_DBG,"RxDs per Block");
			return FAILURE;
		}
		size += nic->config.RxCfg[i].NumRxd;
		nic->block_count[i] = 
			nic->config.RxCfg[i].NumRxd/(MAX_RXDS_PER_BLOCK+1);
		nic->pkt_cnt[i] = 
			nic->config.RxCfg[i].NumRxd-nic->block_count[i];

-> please add local variables.

[...]
/* Enable DTX_Control registers. */
/* LATEST Fix given by Richard to fix XAUI Configuration */
	write64(&bar0->dtx_control,0x8000051500000000);
	udelay(50);	
	write64(&bar0->dtx_control,0x80000515000000E0);
	udelay(50);	
	write64(&bar0->dtx_control,0x80000515D93500E4);
	udelay(50);	

	write64(&bar0->dtx_control,0x8001051500000000);
	udelay(50);	
	write64(&bar0->dtx_control,0x80010515000000E0);
	udelay(50);	
	write64(&bar0->dtx_control,0x80010515001E00E4);
	udelay(50);	

	write64(&bar0->dtx_control,0x8002051500000000);
	udelay(50);	
	write64(&bar0->dtx_control,0x80020515000000E0);
	udelay(50);	
	write64(&bar0->dtx_control,0x80020515F21000E4);
	udelay(50);
[...]

-> this is a loop in disguise. 

	
[...]
		switch(i) {
			case 1:
			write64(&bar0->tx_fifo_partition_0, val64);
			val64 = 0;
			break;
			case 3:
			write64(&bar0->tx_fifo_partition_1, val64);
			val64 = 0;
			break;
			case 5:
			write64(&bar0->tx_fifo_partition_2, val64);
			val64 = 0;
			break;
			case 7:
			write64(&bar0->tx_fifo_partition_3, val64);
			break;
-> please indent (see Documentation/CodingStyle as a general guide).


/* 
 * New procedure to clear mac address reading  problems on Alpha platforms
 *
 */
void FixMacAddress(nic_t *sp)
{

	XENA_dev_config_t *bar0 = (XENA_dev_config_t *)sp->bar0;

	write64(&bar0->gpio_control,0x0060000000000000);
	udelay(10);
	write64(&bar0->gpio_control,0x0060600000000000);
	udelay(10);
[...]

-> this is a loop in disguise.

 *  Description: 
 *   Free all queued Tx buffers.
 */
void freeTxBuffers(struct s2io_nic *nic)
{
[...]
			if(skb == NULL) {
				DBG_PRINT(ERR_DBG,"%s: NULL skb ",dev->name);
				DBG_PRINT(ERR_DBG,"in Tx Int\n");
				spin_unlock(&nic->tx_lock);

-> just goto to the normal spin_unlock and avoid an extra return statement.

				return;
			}
			#if DEBUG_ON
			cnt++;
			#endif
			dev_kfree_skb(skb);
			memset(txdp, 0, sizeof(TxD_t));
		}
		#if DEBUG_ON
		DBG_PRINT(INTR_DBG,"%s:forcibly freeing %d skbs on FIFO%d\n",
			dev->name,cnt,i);
		#endif

-> Please factor these #ifdef.

	}
	spin_unlock(&nic->tx_lock);
}

[...]
int s2io_close(struct net_device *dev)
{
	nic_t *sp = (nic_t *)dev->priv;
	XENA_dev_config_t *bar0 = (XENA_dev_config_t *)sp->bar0;
	register u64 val64 = 0;
	u16 cnt=0;

	spin_lock(&sp->isr_lock);
	netif_stop_queue(dev);

/* disable Tx and Rx traffic on the NIC */
	stopNic(sp);

/* If the device tasklet is running, wait till its done before killing it */
	while(atomic_read(&(sp->tasklet_status))) {
		mdelay(100);
	}
	tasklet_kill(&sp->task);

-> this can schedule() while the driver holds a spinlock.

[...]
#ifdef AS_A_MODULE
MODULE_AUTHOR("Raghavendra Koushik <raghavendra.koushik@s2io.com>");
MODULE_LICENSE("GPL");
MODULE_PARM(ring_num, "1-" __MODULE_STRING(1) "i");
MODULE_PARM(frame_len, "1-" __MODULE_STRING(8) "i");
MODULE_PARM(ring_len, "1-" __MODULE_STRING(8) "i");
MODULE_PARM(fifo_num, "1-" __MODULE_STRING(1) "i");
MODULE_PARM(fifo_len, "1-" __MODULE_STRING(8) "i");
MODULE_PARM(rx_prio, "1-" __MODULE_STRING(1) "i");
MODULE_PARM(tx_prio, "1-" __MODULE_STRING(1) "i");
MODULE_PARM(latency_timer, "1-" __MODULE_STRING(1) "i");
#endif

-> Probably slowly old-fashioning. See include/linux/moduleparam.h

[...]
static int __devinit 
s2io_init_nic(struct pci_dev *pdev,const struct pci_device_id *pre)
{
	nic_t *sp;
	struct net_device *dev;
	char *dev_name="S2IO 10GE NIC";
	int i,j, ret;
	int dma_flag = FALSE;
	u32 mac_up, mac_down;
	u64 val64 = 0, tmp64 = 0;
	XENA_dev_config_t *bar0 = NULL;

	if((ret = pci_enable_device(pdev))) {
		DBG_PRINT(ERR_DBG,"s2io_init_nic: pci_enable_device failed\n");
		return ret;
	}

	if (!pci_set_dma_mask(pdev, 0xffffffffffffffff)) {
		DBG_PRINT(INIT_DBG,"s2io_init_nic: Using 64bit DMA\n");
		dma_flag = TRUE;

		#if defined (XENA_ARCH_64) || (PPC_ARCH64)	
		#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,00)
		if (pci_set_consistent_dma_mask(pdev, 0xffffffffffffffffULL)) {
       			DBG_PRINT(ERR_DBG,"Unable to obtain 64bit DMA for \
					consistent allocations\n");
       			return -ENOMEM;

-> missing pci_disable_device(). You should probably gotoize this part.

[...]
	/* Tx side parameters. */
	if(fifo_num) {
    	sp->config.TxFIFONum = fifo_num;
	} else {
	    sp->config.TxFIFONum = 1;
	}

-> sp->config.TxFIFONum = fifo_num ? fifo_num : 1;

	
[...]
	/* Rx side parameters. */
	if(ring_num) {
		sp->config.RxRingNum = ring_num;
	} else {
		sp->config.RxRingNum = 1;
	}

-> sp->config.RxRingNum = ring_num ? ring_num : 1;

[...]
/* The features the device supports. */
	dev->features |= NETIF_F_SG|NETIF_F_HW_CSUM;
	if(sp->high_dma_flag == TRUE)
		dev->features |= NETIF_F_HIGHDMA;
	#ifdef NETIF_F_TSO
	dev->features |= NETIF_F_TSO;
	#endif

/* Setting the Tx watch dog timeout value and timer functio. */
	dev->tx_timeout = &s2io_tx_watchdog;
	dev->watchdog_timeo = WATCH_DOG_TIMEOUT;

/* Register Device with OS. */
	if(register_netdev(dev)) {
		DBG_PRINT(ERR_DBG, "Device registration failed\n");
		goto register_failed;
	}

/* Save PCI state. */
	pci_save_state(sp->pdev, sp->config_space);

-> the previous comments add no information.

[...]
init_failed:
	pci_disable_device(pdev);
	pci_release_regions(pdev);
	pci_set_drvdata(pdev, NULL);
	kfree(dev);

-> "free_netdev(dev)"

	return -ENODEV;
}

[...]
static void __exit s2io_rem_nic(struct pci_dev *pdev)
{
[...]
	#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,00)
	free_netdev(dev);
	#else
	kfree(dev);
	#endif

-> please take this #ifdef to a common place (start of file/header).

}

int s2io_starter(void)
{
	return pci_module_init(&s2io_driver) ? -ENODEV :0;

-> no ternary operator needed.

--
Ueimor
