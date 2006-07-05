From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.17 6/9] NetXen: hw initialization routines
Date: Wed, 05 Jul 2006 12:12:26 -0400
Message-ID: <44ABE4EA.6090603@garzik.org>
References: <Pine.LNX.4.64.0607050602310.27969@dut46> <Pine.LNX.4.64.0607050638260.27969@dut46>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sanjeev@netxen.com, unmproj@linsyssoft.com,
	Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57230 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964798AbWGEQMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2006 12:12:32 -0400
To: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
In-Reply-To: <Pine.LNX.4.64.0607050638260.27969@dut46>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linsys Contractor Amit S. Kale wrote:

> +    while (state != PHAN_INITIALIZE_COMPLETE && loops < 200000) {
> +        udelay(100);
> +        /* Window 1 call */
> +        read_lock(&adapter->adapter_lock);
> +        state = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
> +        read_unlock(&adapter->adapter_lock);
> +
> +        loops++;
> +    }
> +    if (loops >= 200000) {
> +        printk(KERN_ERR "Cmd Peg initialization not complete:%x.\n",
> +               state);
> +        err = -EIO;
> +        return err;
> +    }

worst case udelay() spins CPU for far too long, locking out other tasks

Good thing this driver isn't used in latency-senstitive applications, or 
medical equipment!


> +void initialize_adapter_sw(struct netxen_adapter *adapter)
> +{
> +    int ctxid, ring;
> +    u32 i;
> +    u32 num_rx_bufs = 0;
> +    struct netxen_rcv_desc_ctx *rcv_desc;
> +    struct netxen_ring_context *ctx;
> +
> +    DPRINTK(INFO, "initializing some queues: %p\n", adapter);
> +    for (ctxid = 0; ctxid < MAX_RING_CTX; ++ctxid) {
> +        ctx = &adapter->ring_ctx[ctxid];
> +        ctx->free_cmd_count = ctx->max_tx_desc_count;
> +        for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
> +            struct netxen_rx_buffer *rx_buf;
> +            rcv_desc = &ctx->recv_ctx.rcv_desc[ring];
> +            rcv_desc->rcv_free = rcv_desc->max_rx_desc_count;
> +            rcv_desc->begin_alloc = 0;
> +            rx_buf = rcv_desc->rx_buf_arr;
> +            num_rx_bufs = rcv_desc->max_rx_desc_count;
> +            /*
> +             * Now go through all of them, set reference handles
> +             * and put them in the queues.
> +             */
> +            for (i = 0; i < num_rx_bufs; i++) {
> +                rx_buf->ref_handle = i;
> +                rx_buf->state = NETXEN_BUFFER_FREE;
> +
> +                DPRINTK(INFO, "Rx buf:ctx%d i(%d) rx_buf:"
> +                    "%p\n", ctxid, i, rx_buf);
> +                rx_buf++;
> +            }
> +        }
> +    }
> +    DPRINTK(INFO, "initialized buffers for %s and %s\n",
> +        "adapter->free_cmd_buf_list", "adapter->free_rxbuf");
> +}
> +
> +int initialize_adapter_hw(struct netxen_adapter *adapter)
> +{
> +    u32 value = 0;
> +
> +    if (netxen_nic_get_board_info(adapter) != 0)
> +        printk("%s: Error getting board config info.\n",
> +            netxen_nic_driver_name);
> +
> +    switch (adapter->ahw.board_type) {
> +    case NETXEN_NIC_GBE:
> +        adapter->ahw.max_ports = 4;
> +        break;
> +
> +    case NETXEN_NIC_XGBE:
> +        adapter->ahw.max_ports = 1;
> +        break;
> +
> +    default:
> +        printk(KERN_ERR "%s: Unknown board type\n",
> +            netxen_nic_driver_name);
> +    }
> +
> +    return value;
> +}
> +
> +/*
> + * netxen_decode_crb_addr(0 - utility to translate from internal 
> Phantom CRB
> + * address to external PCI CRB address.
> + */
> +unsigned long netxen_decode_crb_addr(unsigned long addr)
> +{
> +    int i;
> +    unsigned long base_addr, offset, pci_base;
> +
> +    crb_addr_transform_setup();
> +
> +    pci_base = NETXEN_ADDR_ERROR;
> +    base_addr = addr & 0xfff00000;
> +    offset = addr & 0x000fffff;
> +
> +    for (i = 0; i < NETXEN_MAX_CRB_XFORM; i++) {
> +        if (crb_addr_xform[i] == base_addr) {
> +            pci_base = i << 20;
> +            break;
> +        }
> +    }
> +    if (pci_base == NETXEN_ADDR_ERROR)
> +        return pci_base;
> +    else
> +        return (pci_base + offset);
> +}
> +
> +static long rom_max_timeout = 10000;
> +static long rom_lock_timeout = 100000000;
> +
> +int rom_lock(struct netxen_adapter *adapter)
> +{
> +    int iter;
> +    int done = 0, timeout = 0;
> +
> +    while (!done) {
> +        /* acquire semaphore2 from PCI HW block */
> +        netxen_nic_read_w0(adapter, NETXEN_PCIE_REG(PCIE_SEM2_LOCK),
> +                   &done);
> +        if (done == 1)
> +            break;
> +        if (timeout >= rom_lock_timeout)
> +            return -1;
> +
> +        timeout++;
> +        /*
> +         * Yield CPU
> +         */
> +        if (!in_atomic())
> +            schedule();
> +        else {
> +            for (iter = 0; iter < 20; iter++)
> +                cpu_relax();    /*This a nop instr on i386 */

when is this function ever used in atomic context?

> +int netxen_wait_rom_done(struct netxen_adapter *adapter)
> +{
> +    long timeout = 0;
> +    long done = 0;
> +
> +    while (done == 0) {
> +        done = netxen_nic_reg_read(adapter, NETXEN_ROMUSB_GLB_STATUS);
> +        done &= 2;
> +        timeout++;
> +        if (timeout >= rom_max_timeout) {
> +            printk("Timeout reached  waiting for rom done");
> +            return -1;
> +        }
> +    }
> +    return 0;

how long does this spin the cpu?


> +int do_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
> +{
> +    netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
> +    netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
> +    udelay(100);        /* prevent bursting on CRB */

likely PCI posting bug


> +    netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
> +    netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE, 0xb);
> +    if (netxen_wait_rom_done(adapter)) {
> +        printk("Error waiting for rom done\n");
> +        return -1;
> +    }
> +    /* reset abyte_cnt and dummy_byte_cnt */
> +    netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
> +    udelay(100);        /* prevent bursting on CRB */

ditto



> +    netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
> +
> +    *valp = netxen_nic_reg_read(adapter, NETXEN_ROMUSB_ROM_RDATA);
> +    return 0;
> +}
> +
> +int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr, int 
> *valp)
> +{
> +    int ret;
> +
> +    if (rom_lock(adapter) != 0)
> +        return -1;
> +
> +    ret = do_rom_fast_read(adapter, addr, valp);
> +    rom_unlock(adapter);
> +    return ret;
> +}
> +
> +int pinit_from_rom(struct netxen_adapter *adapter, int verbose)
> +{
> +    int addr, val, status;
> +    int n, i;
> +    int init_delay = 0;
> +    struct crb_addr_pair *buf;
> +    unsigned long off;
> +    unsigned long flags;
> +
> +    /* resetall */
> +    status = netxen_nic_get_board_info(adapter);
> +    if (status)
> +        printk("%s: pinit_from_rom: Error getting board info\n",
> +               netxen_nic_driver_name);
> +
> +    netxen_crb_writelit_adapter(adapter, NETXEN_ROMUSB_GLB_SW_RESET,
> +                    0xffffffff);
> +
> +    if (verbose) {
> +        int val;
> +        if (netxen_rom_fast_read(adapter, 0x4008, &val) == 0)
> +            printk("P2 ROM board type: 0x%08x\n", val);
> +        else
> +            printk("Could not read board type\n");
> +        if (netxen_rom_fast_read(adapter, 0x400c, &val) == 0)
> +            printk("P2 ROM board  num: 0x%08x\n", val);
> +        else
> +            printk("Could not read board number\n");
> +        if (netxen_rom_fast_read(adapter, 0x4010, &val) == 0)
> +            printk("P2 ROM chip   num: 0x%08x\n", val);
> +        else
> +            printk("Could not read chip number\n");
> +    }
> +
> +    if (netxen_rom_fast_read(adapter, 0, &n) == 0 && (n & 
> 0x800000000ULL)) {
> +        n &= ~0x80000000ULL;

kill magic numbers, use named constants


> +        if (n < 1024) {
> +            if (verbose)
> +                printk("%s: %d CRB init values found"
> +                       " in ROM.\n", netxen_nic_driver_name, n);
> +        } else {
> +            printk("%s:n=0x%x Error! NetXen card flash not"
> +                   " initialized.\n", __FUNCTION__, n);
> +            return -1;
> +        }
> +        buf = kcalloc(n, sizeof(struct crb_addr_pair), GFP_KERNEL);
> +        if (buf == NULL) {
> +            printk("%s: pinit_from_rom: Unable to calloc memory.\n",
> +                   netxen_nic_driver_name);
> +            return -1;
> +        }
> +        for (i = 0; i < n; i++) {
> +            if (netxen_rom_fast_read(adapter, 8 * i + 4, &val) != 0
> +                || netxen_rom_fast_read(adapter, 8 * i + 8,
> +                            &addr) != 0)
> +                goto error_ret;
> +
> +            buf[i].addr = addr;
> +            buf[i].data = val;
> +
> +            if (verbose)
> +                printk("%s: PCI:     0x%08x == 0x%08x\n",
> +                       netxen_nic_driver_name, (unsigned int)
> +                       netxen_decode_crb_addr((unsigned long)
> +                                  addr), val);
> +        }
> +        for (i = 0; i < n; i++) {
> +
> +            off =
> +                netxen_decode_crb_addr((unsigned long)buf[i].addr) +
> +                NETXEN_PCI_CRBSPACE;
> +            /* skipping cold reboot MAGIC */
> +            if (off == NETXEN_CAM_RAM(0x1fc))
> +                continue;
> +
> +            /* After writing this register, HW needs time for CRB */
> +            /* to quiet down (else crb_window returns 0xffffffff) */
> +            if (off == NETXEN_ROMUSB_GLB_SW_RESET) {
> +                init_delay = 1;
> +                /* hold xdma in reset also */
> +                buf[i].data = 0x8000ff;
> +            }
> +
> +            if (ADDR_IN_WINDOW1(off)) {
> +                read_lock(&adapter->adapter_lock);
> +                writel(buf[i].data,
> +                       NETXEN_CRB_NORMALIZE(adapter, off));
> +                read_unlock(&adapter->adapter_lock);
> +            } else {
> +                write_lock_irqsave(&adapter->adapter_lock,
> +                           flags);
> +                netxen_nic_pci_change_crbwindow(adapter, 0);
> +                off = adapter->ahw.pci_base + off;
> +                writel(buf[i].data, (void *)off);
> +                netxen_nic_pci_change_crbwindow(adapter, 1);
> +                write_unlock_irqrestore(&adapter->adapter_lock,
> +                            flags);
> +            }
> +            if (init_delay == 1) {
> +                msleep(1000);

ssleep()

> +                init_delay = 0;
> +            }
> +            msleep(1);
> +        }
> +        kfree(buf);
> +
> +        /* disable_peg_cache_all */
> +
> +        /* unreset_net_cache */
> +        netxen_nic_hw_read_wx(adapter, NETXEN_ROMUSB_GLB_SW_RESET, &val,
> +                      4);
> +        netxen_crb_writelit_adapter(adapter, NETXEN_ROMUSB_GLB_SW_RESET,
> +                        (val & 0xffffff0f));
> +        /* p2dn replyCount */
> +        netxen_crb_writelit_adapter(adapter,
> +                        NETXEN_CRB_PEG_NET_D + 0xec, 0x1e);
> +        /* disable_peg_cache 0 */
> +        netxen_crb_writelit_adapter(adapter,
> +                        NETXEN_CRB_PEG_NET_D + 0x4c, 8);
> +        /* disable_peg_cache 1 */
> +        netxen_crb_writelit_adapter(adapter,
> +                        NETXEN_CRB_PEG_NET_I + 0x4c, 8);
> +
> +        /* peg_clr_all */
> +
> +        /* peg_clr 0 */
> +        netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_0 + 0x8,
> +                        0);
> +        netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_0 + 0xc,
> +                        0);
> +        /* peg_clr 1 */
> +        netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_1 + 0x8,
> +                        0);
> +        netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_1 + 0xc,
> +                        0);
> +        /* peg_clr 2 */
> +        netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_2 + 0x8,
> +                        0);
> +        netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_2 + 0xc,
> +                        0);
> +        /* peg_clr 3 */
> +        netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_3 + 0x8,
> +                        0);
> +        netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_3 + 0xc,
> +                        0);
> +    }
> +    return 0;
> +      error_ret:
> +    return -1;
> +}
> +
> +void phantom_init(struct netxen_adapter *adapter)
> +{
> +    u32 val = 0;
> +    int loops = 0;
> +
> +    read_lock(&adapter->adapter_lock);
> +    netxen_nic_hw_read_wx(adapter, NETXEN_ROMUSB_GLB_PEGTUNE_DONE, 
> &val, 4);
> +    writel(1,
> +           NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_PEGTUNE_DONE));
> +
> +    if (0 == val) {
> +        while (val != PHAN_INITIALIZE_COMPLETE && loops < 2000000) {
> +            udelay(100);

locks up CPU for too long



> +            val =
> +                readl(NETXEN_CRB_NORMALIZE
> +                  (adapter, CRB_CMDPEG_STATE));
> +            loops++;
> +        }
> +        if (val != PHAN_INITIALIZE_COMPLETE)
> +            printk("WARNING: Initial boot wait loop failed...\n");
> +    }
> +    read_unlock(&adapter->adapter_lock);
> +}
> +
> +void load_firmware(struct netxen_adapter *adapter)
> +{
> +    int i;
> +    long data, size = 0;
> +    long flashaddr = NETXEN_FLASH_BASE, memaddr = NETXEN_PHANTOM_MEM_BASE;
> +
> +    size = (16 * 1024) / 4;
> +    read_lock(&adapter->adapter_lock);
> +    writel(1, NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_CAS_RST));
> +    read_unlock(&adapter->adapter_lock);
> +
> +    for (i = 0; i < size; i++) {
> +        if (netxen_rom_fast_read(adapter, flashaddr, (int *)&data) != 0) {
> +            DPRINTK(ERR,
> +                "Error in netxen_rom_fast_read(). Will skip"
> +                "loading flash image\n");
> +            return;
> +        }
> +        netxen_nic_pci_mem_write(adapter, memaddr, &data, 4);
> +        flashaddr += 4;
> +        memaddr += 4;
> +    }
> +    udelay(100);

PCI posting


> +    read_lock(&adapter->adapter_lock);
> +    /* make sure Casper is powered on */
> +    writel(0x3fff,
> +           NETXEN_CRB_NORMALIZE(adapter, 
> NETXEN_ROMUSB_GLB_CHIP_CLK_CTRL));
> +    writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_CAS_RST));
> +    read_unlock(&adapter->adapter_lock);
> +
> +    udelay(10000);

delay far too long


> +int netxen_nic_rx_has_work(struct netxen_adapter *adapter)
> +{
> +    int ctxid;
> +
> +    for (ctxid = 0; ctxid < MAX_RING_CTX; ++ctxid) {
> +        struct netxen_ring_context *ctx = &adapter->ring_ctx[ctxid];
> +        struct netxen_recv_context *recv_ctx = &(ctx->recv_ctx);
> +        u32 consumer;
> +        struct status_desc_t *desc_head;
> +        struct status_desc_t *desc;    /* used to read status desc here */
> +
> +        consumer = recv_ctx->status_rx_consumer;
> +        desc_head = recv_ctx->rcv_status_desc_head;
> +        desc = &desc_head[consumer];
> +
> +        if ((desc->owner & STATUS_OWNER_HOST))
> +            return 1;
> +    }
> +
> +    return 0;
> +}

put function near user, and mark 'static', to enable possibility of inlining



> +void netxen_watchdog_task(unsigned long v)
> +{
> +    int port_num;
> +    struct netxen_port *port;
> +    struct net_device *netdev;
> +    struct netxen_adapter *adapter = (struct netxen_adapter *)v;
> +    unsigned long flags;
> +
> +    if (adapter->driver_mismatch) {
> +        /* We return without turning on the netdev queue as there
> +         * was a mismatch in driver and firmware version
> +         */
> +        return;

huh?  when will this ever happen?


> +    for (port_num = 0; port_num < adapter->ahw.max_ports; port_num++) {
> +        port = adapter->port[port_num];
> +        netdev = port->netdev;
> +
> +        if ((netdev->flags & IFF_UP) && !netif_carrier_ok(netdev)) {

don't test IFF_UP, you likely want netif_running(), etc.


> +            printk(KERN_INFO "%s port %d, %s carrier is now ok\n",
> +                   netxen_nic_driver_name, port_num, netdev->name);
> +            netif_carrier_on(netdev);
> +        }
> +
> +        if (netif_queue_stopped(netdev))


Calling netif_wake_queue() without doing something useful with TX queue 
is bogus



> +inline void
> +netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
> +           struct status_desc_t *desc)

inline without static is likely wrong


> +{
> +    struct netxen_port *port = adapter->port[desc->port];
> +    struct pci_dev *pdev = port->pdev;
> +    struct net_device *netdev = port->netdev;
> +    int index = desc->reference_handle;
> +    struct netxen_recv_context *recv_ctx =
> +        &(adapter->ring_ctx[ctxid].recv_ctx);
> +    struct netxen_rx_buffer *buffer;
> +    struct sk_buff *skb;
> +    u32 length = desc->total_length;
> +    u32 desc_ctx;
> +    struct netxen_rcv_desc_ctx *rcv_desc;
> +    int ret;
> +
> +    desc_ctx = desc->type;
> +    if (unlikely(desc_ctx >= NUM_RCV_DESC_RINGS)) {
> +        printk("%s: %s Bad Rcv descriptor ring\n",
> +               netxen_nic_driver_name, netdev->name);
> +        return;
> +    }
> +
> +    rcv_desc = &recv_ctx->rcv_desc[desc_ctx];
> +    buffer = &rcv_desc->rx_buf_arr[index];
> +
> +    pci_unmap_single(pdev, buffer->dma, rcv_desc->dma_size,
> +             PCI_DMA_FROMDEVICE);
> +
> +    skb = (struct sk_buff *)buffer->skb;
> +
> +    if (unlikely(skb == NULL)) {
> +        /*
> +         * This should not happen and if it does, it is serious,
> +         * catch it
> +         */

When will this EVER happen?

Kill all this code...


Got tired of reviewing at this point.

Please fix the mentioned issues and repost --as one big patch-- (i.e. 
requires a URL).

	Jeff


