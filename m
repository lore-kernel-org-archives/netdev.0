From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.17 2/9] NetXen: Main header file.
Date: Wed, 05 Jul 2006 11:46:26 -0400
Message-ID: <44ABDED2.5010803@garzik.org>
References: <Pine.LNX.4.64.0607050602310.27969@dut46> <Pine.LNX.4.64.0607050627170.27969@dut46>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sanjeev@netxen.com, unmproj@linsyssoft.com,
	Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:9358 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964909AbWGEPqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2006 11:46:30 -0400
To: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
In-Reply-To: <Pine.LNX.4.64.0607050627170.27969@dut46>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linsys Contractor Amit S. Kale wrote:
> +#define NETXEN_NIC_FW_VERSIONID "2.1.39"

This duplicates the driver version, rather than being used for its 
intended purpose, firmware version.

If firmware (or if no firmware on card, silicon) version is not 
available, just use the string "n/a"


> +#define NETXEN_NIC_TIMESTAMP "Mon May  1 01:34:07 PDT 2006"

why is this needed?



> +#define NETXEN_CRB_NORMALIZE(adapter, reg) \
> +    (void *)(ptrdiff_t)(adapter->ahw.pci_base+ (reg)    \
> +    - NETXEN_CRB_PCIX_HOST2 + NETXEN_CRB_PCIX_HOST)
> +
> +#define DB_NORMALIZE(adapter, off) \
> +    (void *)(ptrdiff_t)(adapter->ahw.db_base + (off))

Highly likely that this needs __iomem marking, and potentially 
additional attention.



> +#define get_next_index(index, length)    \
> +    ((((index) + 1) == length) ? \
> +        0 : \
> +        (index) +1)
> +
> +#define get_index_range(index,length,count)    \
> +    ((((index) + (count)) >= length) ?    \
> +        (((index) + (count))-(length)) :    \
> +        ((index) + (count)))

Seems like you could eliminate the branches with power-of-2 + masks.


> + * Following data structures describe the descriptors that will be used.
> + * Added fileds of tcpHdrSize and ipHdrSize, The driver needs to do it 
> only when
> + * we are doing LSO (above the 1500 size packet) only.
> + **/
> +
> +/**
> + * The size of reference handle been changed to 16 bits to pass the MSS 
> fields
> + * for the LSO packet
> + **/
> +
> +#define FLAGS_CHECKSUM_ENABLED    0x01
> +#define FLAGS_LSO_ENABLED    0x02
> +#define FLAGS_IPSEC_SA_ADD    0x04
> +#define FLAGS_IPSEC_SA_DELETE    0x08
> +#define FLAGS_VLAN_TAGGED    0x10
> +
> +struct cmd_desc_type0_t {
> +    u64 netxen_next;    /* for fragments handled by Phantom */
> +    union {
> +        struct {
> +            u32 addr_low_part2;
> +            u32 addr_high_part2;
> +        };
> +        u64 addr_buffer2;
> +    };
> +
> +    u64 total_length:24,    /* Total size of the packet */
> +     tcp_hdr_offset:8,    /* For LSO only */
> +     ip_hdr_offset:8,    /* For LSO only */
> +     num_of_buffers:8,    /* total number of segments */
> +     flags:8,        /* as defined above */
> +     opcode:8;
> +
> +    u64 reference_handle:16,    /* changed to u16 to add mss */
> +     mss:16,        /* passed by NDIS_PACKET for LSO */
> +     port:4,
> +     ctx_id:4,
> +     total_hdr_length:8,    /* LSO only : MAC+IP+TCP Hdr size */
> +     conn_id:16;        /* IPSec offoad only */
> +
> +    union {
> +        struct {
> +            u32 addr_low_part3;
> +            u32 addr_high_part3;
> +        };
> +        u64 addr_buffer3;
> +    };
> +
> +    union {
> +        struct {
> +            u32 addr_low_part1;
> +            u32 addr_high_part1;
> +        };
> +        u64 addr_buffer1;
> +    };
> +
> +    u64 buffer1_length:16,
> +        buffer2_length:16, buffer3_length:16, buffer4_length:16;
> +
> +    union {
> +        struct {
> +            u32 addr_low_part4;
> +            u32 addr_high_part4;
> +        };
> +        u64 addr_buffer4;
> +    };
> +
> +} __attribute__ ((aligned(64)));
> +
> +/* Note: sizeof(rcv_desc) should always be a mutliple of 2 */
> +struct rcv_desc_t {
> +    u64 reference_handle:16,
> +     reserved:16,
> +     buffer_length:32;    /* allocated buffer length (usually 2K) */
> +    u64 addr_buffer;
> +};

Problems:

1) bitfields are not endian-clean

2) it's silly to use bitfields of sizes 8, 16, and 32.  This generates 
grossly sub-optimal code compared to use of u8, u16, u32 C types.

3) Most likely you should be using __le32, etc.



> +/* opcode field in status_desc_t */
> +#define RCV_NIC_PKT    (0xA)
> +#define STATUS_NIC_PKT    ((RCV_NIC_PKT) << 12)
> +
> +/* for status field in status_desc_t */
> +#define STATUS_NEED_CKSUM    (1)
> +#define STATUS_CKSUM_OK        (2)
> +
> +/* owner bits of status_desc_t */
> +#define STATUS_OWNER_HOST    (1ULL)
> +#define STATUS_OWNER_PHANTOM    (2ULL)
> +#define HOST_STATUS_DESC    ((STATUS_OWNER_HOST) << 48)
> +#define PHANTOM_STATUS_DESC    ((STATUS_OWNER_PHANTOM) << 48)
> +
> +#define NETXEN_PROT_IP        (1)
> +#define NETXEN_PROT_UNKNOWN    (0)
> +
> +/* Note: sizeof(status_desc) should always be a mutliple of 2 */
> +struct status_desc_t {
> +    u64 port:4,        /* initially to be used but noe now */
> +     status:4,        /* completion status may not have use */
> +     type:4,        /* type/index of descriptor ring */
> +     opcode:4,        /* Completion of receive or transmit */
> +     total_length:16,    /* NIC mode */
> +     reference_handle:16,    /* handle for the associated packet */
> +     owner:2,        /* Owner of the descriptor */
> +     prot:4;        /* protocol type for skb (Linux) */
> +} __attribute__ ((aligned(8)));

ditto above comments




> +struct netxen_board_info {
> +    u32 header_version;
> +
> +    u32 board_mfg;
> +    u32 board_type;
> +    u32 board_num;
> +    u32 chip_id;
> +    u32 chip_minor;
> +    u32 chip_major;
> +    u32 chip_pkg;
> +    u32 chip_lot;
> +
> +    u32 port_mask;        /* available niu ports */
> +    u32 peg_mask;        /* available pegs */
> +    u32 icache_ok;        /* can we run with icache? */
> +    u32 dcache_ok;        /* can we run with dcache? */
> +    u32 casper_ok;
> +
> +    u32 mac_addr_lo_0;
> +    u32 mac_addr_lo_1;
> +    u32 mac_addr_lo_2;
> +    u32 mac_addr_lo_3;
> +
> +    /* MN-related config */
> +    u32 mn_sync_mode;    /* enable/ sync shift cclk/ sync shift mclk */
> +    u32 mn_sync_shift_cclk;
> +    u32 mn_sync_shift_mclk;
> +    u32 mn_wb_en;
> +    u32 mn_crystal_freq;    /* in MHz */
> +    u32 mn_speed;        /* in MHz */
> +    u32 mn_org;
> +    u32 mn_depth;
> +    u32 mn_ranks_0;        /* ranks per slot */
> +    u32 mn_ranks_1;        /* ranks per slot */
> +    u32 mn_rd_latency_0;
> +    u32 mn_rd_latency_1;
> +    u32 mn_rd_latency_2;
> +    u32 mn_rd_latency_3;
> +    u32 mn_rd_latency_4;
> +    u32 mn_rd_latency_5;
> +    u32 mn_rd_latency_6;
> +    u32 mn_rd_latency_7;
> +    u32 mn_rd_latency_8;
> +    u32 mn_dll_val[18];
> +    u32 mn_mode_reg;    /* MIU DDR Mode Register */
> +    u32 mn_ext_mode_reg;    /* MIU DDR Extended Mode Register */
> +    u32 mn_timing_0;    /* MIU Memory Control Timing Rgister */
> +    u32 mn_timing_1;    /* MIU Extended Memory Ctrl Timing Register */
> +    u32 mn_timing_2;    /* MIU Extended Memory Ctrl Timing2 Register */
> +
> +    /* SN-related config */
> +    u32 sn_sync_mode;    /* enable/ sync shift cclk / sync shift mclk */
> +    u32 sn_pt_mode;        /* pass through mode */
> +    u32 sn_ecc_en;
> +    u32 sn_wb_en;
> +    u32 sn_crystal_freq;
> +    u32 sn_speed;
> +    u32 sn_org;
> +    u32 sn_depth;
> +    u32 sn_dll_tap;
> +    u32 sn_rd_latency;
> +
> +    u32 mac_addr_hi_0;
> +    u32 mac_addr_hi_1;
> +    u32 mac_addr_hi_2;
> +    u32 mac_addr_hi_3;
> +
> +    u32 magic;        /* indicates flash has been initialized */
> +
> +    u32 mn_rdimm;
> +    u32 mn_dll_override;
> +
> +};
> +
> +#define FLASH_NUM_PORTS        (4)
> +
> +struct netxen_flash_mac_addr {
> +    u32 flash_addr[32];
> +};
> +
> +#define FLASH_NUM_MAC_PER_PORT    32
> +struct netxen_user_info {
> +    u8 flash_md5[16 * 64];
> +    /* bootloader */
> +    u32 bootld_version;
> +    u32 bootld_size;
> +    /* image */
> +    u32 image_version;
> +    u32 image_size;
> +    /* primary image status */
> +    u32 primary_status;
> +    u32 secondary_present;
> +
> +    /* MAC address , 4 ports, 32 address per port */
> +    u64 mac_addr[FLASH_NUM_PORTS * FLASH_NUM_MAC_PER_PORT];
> +    u32 sub_sys_id;
> +    u8 serial_num[32];
> +
> +    /* Any user defined data */
> +};
> +
> +/*
> + * Flash Layout - new format.
> + */
> +#define FLASH_NUM_MAC_PER_PORT    32
> +struct netxen_new_user_info {
> +    u8 flash_md5[16 * 64];
> +    /* bootloader */
> +    u32 bootld_version;
> +    u32 bootld_size;
> +    /* image */
> +    u32 image_version;
> +    u32 image_size;
> +    /* primary image status */
> +    u32 primary_status;
> +    u32 secondary_present;
> +
> +    /* MAC address , 4 ports, 32 address per port */
> +    u64 mac_addr[FLASH_NUM_PORTS * FLASH_NUM_MAC_PER_PORT];
> +    u32 sub_sys_id;
> +    u8 serial_num[32];
> +
> +    /* Any user defined data */
> +};
> +
> +#define SECONDARY_IMAGE_PRESENT 0xb3b4b5b6
> +#define SECONDARY_IMAGE_ABSENT    0xffffffff
> +#define PRIMARY_IMAGE_GOOD    0x5a5a5a5a
> +#define PRIMARY_IMAGE_BAD    0xffffffff
> +
> +/* Flash memory map */
> +typedef enum {
> +    CRBINIT_START = 0,    /* Crbinit section */
> +    BRDCFG_START = 0x4000,    /* board config */
> +    INITCODE_START = 0x6000,    /* pegtune code */
> +    BOOTLD_START = 0x10000,    /* bootld */
> +    IMAGE_START = 0x43000,    /* compressed image */
> +    SECONDARY_START = 0x200000,    /* backup images */
> +    PXE_START = 0x3E0000,    /* user defined region */
> +    USER_START = 0x3E8000,    /* User defined region for new boards */
> +    FIXED_START = 0x3F0000    /* backup of crbinit */
> +} netxen_flash_map_t;
> +
> +#define USER_START_OLD PXE_START    /* for backward compatibility */
> +
> +#define FLASH_START        (CRBINIT_START)
> +#define INIT_SECTOR        (0)
> +#define PRIMARY_START         (BOOTLD_START)
> +#define FLASH_CRBINIT_SIZE     (0x4000)
> +#define FLASH_BRDCFG_SIZE     (sizeof(struct netxen_board_info))
> +#define FLASH_USER_SIZE        (sizeof(netxen_user_info)/sizeof(u32))
> +#define FLASH_SECONDARY_SIZE     (USER_START-SECONDARY_START)
> +#define NUM_PRIMARY_SECTORS    (0x20)
> +#define NUM_CONFIG_SECTORS     (1)
> +int is_flash_supported(struct netxen_adapter *adapter);
> +int get_flash_mac_addr(struct netxen_adapter *adapter, u64 mac[]);
> +extern char netxen_nic_driver_string[];
> +extern void netxen_change_ringparam(struct netxen_adapter *adapter);
> +extern int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr,
> +                int *valp);
> +
> +extern struct ethtool_ops netxen_nic_ethtool_ops;
> +
> +/*
> + * The PCI VendorID and DeviceID for our board.
> + */
> +#define PCI_VENDOR_ID_NX       0x4040
> +#define PCI_DEVICE_ID_NX_XG    0x0001
> +#define PCI_DEVICE_ID_NX_CX4   0x0002
> +#define PCI_DEVICE_ID_NX_QG    0x0003
> +#define PCI_DEVICE_ID_NX_IMEZ  0x0004
> +#define PCI_DEVICE_ID_NX_HMEZ  0x0005
> +
> +#define NETXEN_PCI_ID(X) { PCI_DEVICE(PCI_VENDOR_ID_NX, (X)) }

why do you need these defines at all?  Device IDs used on only one place 
can normally just be directly coded as a numeric hexidecimal constant.


> +#define PFX "netxen: "
> +
> +/* Note: Make sure to not call this before adapter->port is valid */
> +#if !defined(NETXEN_DEBUG)
> +#define DPRINTK(klevel, fmt, args...)    do { \
> +    } while (0)
> +#else
> +#define DPRINTK(klevel, fmt, args...)    do { \
> +    printk(KERN_##klevel PFX "%s: %s: " fmt, __FUNCTION__,\
> +        (adapter != NULL && adapter->port != NULL && \
> +        adapter->port[0] != NULL && \
> +        adapter->port[0]->netdev != NULL) ? \
> +        adapter->port[0]->netdev->name : NULL, \
> +        ## args); } while(0)
> +#endif
> +
> +/* Number of status descriptors to handle per interrupt */
> +#define MAX_STATUS_HANDLE    (128)
> +
> +/*
> + * netxen_skb_frag{} is to contain mapping info for each SG list. This
> + * has to be freed when DMA is complete. This is part of 
> netxen_tx_buffer{}.
> + */
> +struct netxen_skb_frag {
> +    u64 dma;
> +    u32 length;
> +};

This generated padding -- is that ok?



> +/*    Following defines are for the state of the buffers    */
> +#define    NETXEN_BUFFER_FREE    0
> +#define    NETXEN_BUFFER_BUSY    1
> +
> +/*
> + * There will be one netxen_buffer per skb packet.    These will be
> + * used to save the dma info for pci_unmap_page()
> + */
> +struct netxen_cmd_buffer {
> +    struct sk_buff *skb;
> +    struct netxen_skb_frag frag_array[MAX_BUFFERS_PER_CMD + 1];
> +    u32 total_length;
> +    u32 mss;
> +    u32 port:16, cmd:8, frag_count:8;
> +    unsigned long time_stamp;
> +    u32 state;
> +    u32 no_of_descriptors;
> +};

ditto bitfield comments.

In general bitfields are to be avoided for many reasons.


> +/* In rx_buffer, we do not need multiple fragments as is a single 
> buffer */
> +struct netxen_rx_buffer {
> +    struct sk_buff *skb;
> +    u64 dma;
> +    u32 ref_handle:16, state:16;
> +};

ditto


> +/* Board types */
> +#define    NETXEN_NIC_GBE    0x01
> +#define    NETXEN_NIC_XGBE    0x02
> +
> +/*
> + * One hardware_context{} per adapter
> + * contains interrupt info as well shared hardware info.
> + */
> +struct netxen_hardware_context {
> +    struct pci_dev *pdev;
> +    unsigned long pci_base;    /* base of mapped phantom memory */
> +    unsigned long pci_len;    /* length of mapped phantom memory */

kill pci_base, pci_len


> +    u16 vendor_id;
> +    u16 device_id;
> +    u8 revision_id;

kill all three of these


> +    u16 pci_cmd_word;

kill


> +    u16 board_type;
> +    u16 max_ports;
> +    struct netxen_board_info boardcfg;
> +    u32 xg_linkup;
> +    struct netxen_adapter *adapter;
> +    u32 crb_base;
> +    unsigned long db_base;    /* base of mapped db memory */
> +    unsigned long db_len;    /* length of mapped db memory */

kill db_base, db_len


> +#define MINIMUM_ETHERNET_FRAME_SIZE    64    /* With FCS */
> +#define ETHERNET_FCS_SIZE        4
> +
> +struct netxen_adapter_stats {
> +    u64 ints;
> +    u64 hostints;
> +    u64 otherints;
> +    u64 process_rcv;
> +    u64 process_xmit;
> +    u64 noxmitdone;
> +    u64 xmitcsummed;
> +    u64 post_called;
> +    u64 posted;
> +    u64 lastposted;
> +    u64 goodskbposts;
> +};
> +
> +/*
> + * Ring which will hold the skbs which can be fed to receive ring
> + */
> +#define NETXEN_SKB_ARRAY_SIZE    1024
> +
> +struct netxen_recv_skb_ring {
> +    struct sk_buff **skb_array;
> +    u32 interrupt_index;
> +    u32 tasklet_index;
> +    u32 data_size;
> +};
> +
> +/*
> + * Rcv Descriptor Context. One such per Rcv Descriptor. There may
> + * be one Rcv Descriptor for normal packets, one for jumbo and may be 
> others.
> + */
> +struct netxen_rcv_desc_ctx {
> +    u32 flags;
> +    u32 producer;
> +    u32 rcv_pending;    /* Num of bufs posted in phantom */
> +    u32 rcv_free;        /* Num of bufs in free list */
> +    u32 phys_addr;
> +    struct rcv_desc_t *desc_head;    /* address of rx ring in Phantom */
> +    u32 max_rx_desc_count;
> +    u32 dma_size;
> +    u32 skb_size;
> +    struct netxen_rx_buffer *rx_buf_arr;    /* rx buffers for receive   */
> +    dma_addr_t rx_buf_phys;    /* physical address of above */
> +    int begin_alloc;
> +};
> +
> +/*
> + * Receive context. There is one such structure per instance of the
> + * receive processing. Any state information that is relevant to
> + * the receive, and is must be in this structure. The global data may be
> + * present elsewhere.
> + */
> +struct netxen_recv_context {
> +    struct netxen_rcv_desc_ctx rcv_desc[NUM_RCV_DESC_RINGS];
> +    u32 status_rx_producer;
> +    u32 status_rx_consumer;
> +    u32 rcv_status_desc_phys_addr;
> +    struct status_desc_t *rcv_status_desc_head;
> +};
> +
> +#define NETXEN_NIC_MSI_ENABLED 0x02
> +
> +struct netxen_hardware_ring_context {
> +    /* Address of cmd ring in Phantom */
> +    struct cmd_desc_type0_t *cmd_desc_head;
> +    u32 cmd_producer;
> +    u32 cmd_consumer;
> +    u32 status_rx_producer;
> +    u32 status_rx_consumer;
> +    u32 cmd_desc_phys_addr;
> +};
> +
> +struct netxen_ring_context {
> +    struct netxen_hardware_ring_context hw_ring_ctx;
> +    u32 cmd_producer;
> +    u32 *cmd_consumer;
> +
> +    u32 last_cmd_consumer;
> +    /* Num of bufs posted in phantom */
> +    u32 pending_cmd_count;
> +    u32 free_cmd_count;    /* Num of bufs in free list */
> +    u32 max_tx_desc_count;
> +    u32 max_rx_desc_count;
> +    u32 max_jumbo_rx_desc_count;
> +    /* Num of instances active on cmd buffer ring */
> +    u32 proc_cmd_buf_counter;
> +    volatile u32 cmd_peg_consumer;
> +
> +    struct netxen_cmd_buffer *cmd_buf_arr;    /* Command buffers for 
> xmit */
> +    struct netxen_rx_buffer *rx_buf_arr;    /* rx buffers for receive   */
> +
> +    /*
> +     * Receive instance.
> +     */
> +    struct netxen_recv_context recv_ctx;
> +
> +    /* context interface shared between card and host */
> +    struct ring_context *ctx_desc;
> +    u32 ctx_desc_phys_addr;
> +
> +};
> +
> +/* this structure by all ports on the adapter */
> +struct netxen_adapter {
> +    struct netxen_hardware_context ahw;
> +    int port_count;        /* Number of configured ports  */
> +    int active_ports;    /* Number of open ports */
> +    struct netxen_port **port;    /* ptr to each port  */
> +    spinlock_t tx_lock;
> +    rwlock_t adapter_lock;
> +    spinlock_t lock;

Most likely need to eliminate some locks here.


> +    struct work_struct watchdog_task;
> +    struct work_struct tx_timeout_task[4];

Why do you have 4 tx_timeout_tasks ?


> +    struct timer_list watchdog_timer;
> +
> +    u32 curr_window;
> +
> +    u32 num_threads, total_threads;    /*Use to keep track of xmit 
> threads */
> +
> +    u32 flags;
> +    u32 irq;
> +    int driver_mismatch;
> +
> +    struct netxen_adapter_stats stats;
> +
> +    struct netxen_ring_context ring_ctx[MAX_RING_CTX];
> +    int number;
> +    int is_up;
> +    int work_done;
> +};                /* netxen_adapter structure */
> +
> +/* Max number of xmit producer threads that can run simultaneously */
> +#define    MAX_XMIT_PRODUCERS        16
> +
> +struct netxen_port_stats {
> +    u64 rcvdbadskb;
> +    u64 xmitcalled;
> +    u64 xmitedframes;
> +    u64 xmitfinished;
> +    u64 badskblen;
> +    u64 nocmddescriptor;
> +    u64 polled;
> +    u64 uphappy;
> +    u64 updropped;
> +    u64 uplcong;
> +    u64 uphcong;
> +    u64 upmcong;
> +    u64 updunno;
> +    u64 skbfreed;
> +    u64 txdropped;
> +    u64 txnullskb;
> +    u64 csummed;
> +    u64 no_rcv;
> +    u64 rxbytes;
> +    u64 txbytes;
> +};
> +
> +struct netxen_port {
> +    struct netxen_adapter *adapter;
> +
> +    u16 portnum;        /* GBE port number */
> +    u16 link_speed;
> +    u16 link_duplex;
> +    u16 link_autoneg;
> +
> +    int flags;
> +    spinlock_t stats_lock;
> +
> +    struct net_device *netdev;
> +    struct pci_dev *pdev;
> +    struct net_device_stats net_stats;
> +    struct netxen_port_stats stats;
> +};
> +
> +extern char netxen_nic_driver_name[];
> +
> +#define NETXEN_CTX_SIGNATURE    0xdee0
> +#define MAX_PEG_RING_CTX    4
> +
> +#define RX_PRODUCER 0
> +#define RX_PRODUCER_JUMBO 1
> +#define TX_PRODUCER 2
> +#define STS_PRODUCER 3
> +
> +#define NUM_DB_CODE 16
> +
> +#define NETXEN_RCV_PRODUCER(ringid)    (ringid)
> +
> +#define NETXEN_CMD_PRODUCER 2
> +#define NETXEN_RCV_STATUS_CONSUMER 3
> +
> +struct ctx_msg {
> +    u32 PegId:2, Count:16, CtxId:10, Opcode:4;
> +};

bitfields


> +struct rcv_context {
> +    u64 RcvRingAddrLo:32, RcvRingAddrHi:32;
> +    u32 RcvRingSize;
> +    u32 Rsrv;
> +};
> +
> +struct ring_context {
> +
> +    u64 CMD_CONSUMER_OFFSET;
> +    u64 CmdRingAddrLo:32, CmdRingAddrHi:32;
> +    u32 CmdRingSize;
> +    u32 Rsrv;
> +    struct rcv_context RcvContext[2];
> +    u64 StsRingAddrLo:32, StsRingAddrHi:32;
> +    u32 StsRingSize;
> +    u32 CtxId;
> +} __attribute__ ((aligned(64)));

ditto, ditto



> +static inline void netxen_nic_disable_int(struct netxen_adapter *adapter)
> +{
> +    u32 mask;
> +
> +    mask = 0x7ff;
> +
> +    /*
> +     * ISR_INT_MASK: Can be read from window 0 or 1.
> +     */
> +    writel(mask, (void *)(adapter->ahw.pci_base + ISR_INT_MASK));
> +}

kill 'mask' variable


> +static inline void netxen_nic_enable_int(struct netxen_adapter *adapter)
> +{
> +    u32 mask;
> +
> +    switch (adapter->ahw.board_type) {
> +    case NETXEN_NIC_GBE:
> +        mask = 0x77b;
> +        break;
> +    case NETXEN_NIC_XGBE:
> +        mask = 0x77f;
> +        break;
> +    default:
> +        mask = 0x7ff;
> +        break;
> +    }
> +
> +    writel(mask, (void *)(adapter->ahw.pci_base + ISR_INT_MASK));
> +
> +    if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
> +        mask = 0xbff;
> +        writel(mask,
> +               (void *)(adapter->ahw.pci_base + ISR_INT_TARGET_MASK));
> +    }
> +}
> +
> +#endif                /* __NETXEN_NIC_H_ */
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

