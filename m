From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [net-next] igb: add function to set I210
 transmit mode
Date: Sat, 13 Aug 2016 08:27:38 -0700
Message-ID: <CAKgT0UeOmzDaLm0-yuvEjzYoN5g8=ouBv+8rpOmx7MgkWRfA+A@mail.gmail.com>
References: <1470811692-24574-1-git-send-email-gangfeng.huang@ni.com> <1470811692-24574-2-git-send-email-gangfeng.huang@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Gangfeng <gangfeng.huang@ni.com>, Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35400 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648AbcHMP1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2016 11:27:39 -0400
Received: by mail-it0-f66.google.com with SMTP id f6so907060ith.2
        for <netdev@vger.kernel.org>; Sat, 13 Aug 2016 08:27:39 -0700 (PDT)
In-Reply-To: <1470811692-24574-2-git-send-email-gangfeng.huang@ni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 9, 2016 at 11:48 PM, Gangfeng <gangfeng.huang@ni.com> wrote:
> From: Gangfeng Huang <gangfeng.huang@ni.com>
>
> I210 supports two transmit modes, legacy and Qav. The transmit mode is
> configured in TQAVCTRL.QavMode register. Before this patch igb driver
> only support legacy mode. This patch makes it possible to configure the
> transmit mode.
>
> Example:
> Get the transmit mode:
> $ echo /sys/class/net/eth0/qav_mode
> 0
> Set transmit mode to qav mode
> $ echo 1 > /sys/class/net/eth0/qav_mode
>
> Tested:
> Setting /sys/class/net/eth0/qav_mode to Qav mode,
>  1) Switch back and forth between Qav mode and legacy mode
>  2) Send/recv packets in both mode.
>
> Signed-off-by: Gangfeng Huang <gangfeng.huang@ni.com>

I really don' think this patch is going to work.  If you are going to
implement something like this and have a hope to get it accepted into
the Linux kernel you need to come up with a solution that will work
fore more than this one device.  We don't want the drivers having to
carry around their own sysfs controls for things that really are not
proprietary to the device.  There needs to be a generic kernel
interface for this.  The fact is something like QAV more than likely
exists on other devices as well so it may be worth while to look into
seeing if you could come up with some way of interfacing this with
either ethtool ,iproute2, or maybe even the DCB/LLDP utilities since
this is essentially splitting the Tx into two separate traffic
classes.

Also for these kind of patches it would be best to include the netdev
mailing list.  That way it can be reviewed by a wider audience and you
are much more likely to get this accepted upstream rather than have it
rejected when Jeff Kirsher attempts to submit it.

> ---
>  drivers/net/ethernet/intel/igb/e1000_defines.h |  21 +++
>  drivers/net/ethernet/intel/igb/e1000_regs.h    |   7 +
>  drivers/net/ethernet/intel/igb/igb.h           |   5 +
>  drivers/net/ethernet/intel/igb/igb_main.c      | 178 ++++++++++++++++++++++++-
>  4 files changed, 209 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
> index cf3846b..f13d6a7 100644
> --- a/drivers/net/ethernet/intel/igb/e1000_defines.h
> +++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
> @@ -360,6 +360,7 @@
>  #define MAX_JUMBO_FRAME_SIZE   0x2600
>
>  /* PBA constants */
> +#define E1000_PBA_32K 0x0020
>  #define E1000_PBA_34K 0x0022
>  #define E1000_PBA_64K 0x0040    /* 64KB */
>
> @@ -1028,4 +1029,24 @@
>  #define E1000_VLAPQF_P_VALID(_n)          (0x1 << (3 + (_n) * 4))
>  #define E1000_VLAPQF_QUEUE_MASK           0x03
>
> +/* Queue mode, 0=strict, 1=SR mode */
> +#define E1000_TQAVCC_QUEUEMODE         0x80000000
> +/* Transmit mode, 0=legacy, 1=QAV */
> +#define E1000_TQAVCTRL_TXMODE          0x00000001
> +/* Report DMA time of tx packets */
> +#define E1000_TQAVCTRL_1588_STAT_EN    0x00000004
> +#define E1000_TQAVCTRL_DATA_FETCH_ARB  0x00000010 /* Data fetch arbitration */
> +#define E1000_TQAVCTRL_DATA_TRAN_ARB   0x00000100 /* Data tx arbitration */
> +#define E1000_TQAVCTRL_DATA_TRAN_TIM   0x00000200 /* Data launch time valid */
> +/* Stall SP to guarantee SR */
> +#define E1000_TQAVCTRL_SP_WAIT_SR      0x00000400
> +#define E1000_TQAVCTRL_FETCH_TM_SHIFT  (16)
> +
> +#define E1000_TXPBSIZE_TX0PB_SHIFT    0
> +#define E1000_TXPBSIZE_TX1PB_SHIFT    6
> +#define E1000_TXPBSIZE_TX2PB_SHIFT    12
> +#define E1000_TXPBSIZE_TX3PB_SHIFT    18
> +
> +#define E1000_DTXMXPKTSZ_DEFAULT 0x00000098
> +
>  #endif
> diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
> index 9b66b6f..7cffabc 100644
> --- a/drivers/net/ethernet/intel/igb/e1000_regs.h
> +++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
> @@ -138,6 +138,12 @@
>  #define E1000_FCRTC    0x02170 /* Flow Control Rx high watermark */
>  #define E1000_PCIEMISC 0x05BB8 /* PCIE misc config register */
>
> +/* High credit registers where _n can be 0 or 1. */
> +#define E1000_TQAVHC(_n)       (0x300C + 0x40 * (_n))
> +/* QAV Tx mode control registers where _n can be 0 or 1. */
> +#define E1000_TQAVCC(_n)       (0x3004 + 0x40 * (_n))
> +#define E1000_TQAVCTRL 0x3570 /* Tx Qav Control registers */
> +
>  /* TX Rate Limit Registers */
>  #define E1000_RTTDQSEL 0x3604 /* Tx Desc Plane Queue Select - WO */
>  #define E1000_RTTBCNRM 0x3690 /* Tx BCN Rate-scheduler MMW */
> @@ -204,6 +210,7 @@
>  #define E1000_TDFT     0x03418  /* TX Data FIFO Tail - RW */
>  #define E1000_TDFHS    0x03420  /* TX Data FIFO Head Saved - RW */
>  #define E1000_TDFPC    0x03430  /* TX Data FIFO Packet Count - RW */
> +#define E1000_DTXMXPKT 0x0355C  /* DMA TX Maximum Packet Size */
>  #define E1000_DTXCTL   0x03590  /* DMA TX Control - RW */
>  #define E1000_CRCERRS  0x04000  /* CRC Error Count - R/clr */
>  #define E1000_ALGNERRC 0x04004  /* Alignment Error Count - R/clr */
> diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
> index 3e24e92..78782f9 100644
> --- a/drivers/net/ethernet/intel/igb/igb.h
> +++ b/drivers/net/ethernet/intel/igb/igb.h
> @@ -139,6 +139,9 @@ struct vf_data_storage {
>  /* this is the size past which hardware will drop packets when setting LPE=0 */
>  #define MAXIMUM_ETHERNET_VLAN_SIZE 1522
>
> +/* In qav mode, the maximum frame size is 1536 */
> +#define IGB_MAX_QAV_FRAME_SIZE 1536
> +
>  /* Supported Rx Buffer Sizes */
>  #define IGB_RXBUFFER_256       256
>  #define IGB_RXBUFFER_2048      2048
> @@ -521,6 +524,8 @@ struct igb_adapter {
>         /* lock for RX network flow classification filter */
>         spinlock_t nfc_lock;
>         bool etype_bitmap[MAX_ETYPE_FILTER];
> +
> +       bool qav_mode;
>  };
>
>  /* flags controlling PTP/1588 function */
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index af75eac..1684a75 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -179,6 +179,17 @@ static void igb_check_vf_rate_limit(struct igb_adapter *);
>  static void igb_nfc_filter_exit(struct igb_adapter *adapter);
>  static void igb_nfc_filter_restore(struct igb_adapter *adapter);
>
> +/* Switch qav mode and legacy mode by sysfs*/
> +static void igb_setup_qav_mode(struct igb_adapter *adapter);
> +static void igb_setup_normal_mode(struct igb_adapter *adapter);
> +static ssize_t igb_get_qav_mode(struct device *dev,
> +                               struct device_attribute *attr, char *buf);
> +static ssize_t igb_set_qav_mode(struct device *dev,
> +                               struct device_attribute *attr,
> +                               const char *buf, size_t count);
> +static DEVICE_ATTR(qav_mode, S_IRUGO | S_IWUSR,
> +                  igb_get_qav_mode, igb_set_qav_mode);
> +
>  #ifdef CONFIG_PCI_IOV
>  static int igb_vf_configure(struct igb_adapter *adapter, int vf);
>  static int igb_pci_enable_sriov(struct pci_dev *dev, int num_vfs);
> @@ -1609,6 +1620,11 @@ static void igb_configure(struct igb_adapter *adapter)
>
>         igb_restore_vlan(adapter);
>
> +       if (adapter->qav_mode)
> +               igb_setup_qav_mode(adapter);
> +       else
> +               igb_setup_normal_mode(adapter);
> +
>         igb_setup_tctl(adapter);
>         igb_setup_mrqc(adapter);
>         igb_setup_rctl(adapter);
> @@ -1887,8 +1903,10 @@ void igb_reset(struct igb_adapter *adapter)
>                 pba = rd32(E1000_RXPBS);
>                 pba &= E1000_RXPBS_SIZE_MASK_82576;
>                 break;
> -       case e1000_82575:
>         case e1000_i210:
> +               pba = (adapter->qav_mode) ? E1000_PBA_32K : E1000_PBA_34K;
> +               break;
> +       case e1000_82575:
>         case e1000_i211:
>         default:
>                 pba = E1000_PBA_34K;
> @@ -2366,6 +2384,7 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>         hw = &adapter->hw;
>         hw->back = adapter;
>         adapter->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
> +       adapter->qav_mode = false;
>
>         err = -EIO;
>         adapter->io_addr = pci_iomap(pdev, 0, 0);
> @@ -2643,6 +2662,15 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>         if (err)
>                 goto err_register;
>
> +       if (hw->mac.type == e1000_i210) {
> +               err = sysfs_create_file(&netdev->dev.kobj,
> +                                       &dev_attr_qav_mode.attr);
> +               if (err) {
> +                       netdev_err(netdev, "error creating sysfs file\n");
> +                       goto err_register;
> +               }
> +       }
> +
>         /* carrier off reporting is important to ethtool even BEFORE open */
>         netif_carrier_off(netdev);
>
> @@ -2923,6 +2951,8 @@ static void igb_remove(struct pci_dev *pdev)
>  #ifdef CONFIG_PCI_IOV
>         igb_disable_sriov(pdev);
>  #endif
> +       if (hw->mac.type == e1000_i210)
> +               sysfs_remove_file(&netdev->dev.kobj, &dev_attr_qav_mode.attr);
>
>         unregister_netdev(netdev);
>
> @@ -3007,7 +3037,12 @@ static void igb_init_queue_configuration(struct igb_adapter *adapter)
>                 break;
>         }
>
> -       adapter->rss_queues = min_t(u32, max_rss_queues, num_online_cpus());
> +       /* For QAV mode, always enable all queues */
> +       if (adapter->qav_mode)
> +               adapter->rss_queues = max_rss_queues;
> +       else
> +               adapter->rss_queues = min_t(u32, max_rss_queues,
> +                                           num_online_cpus());
>
>         igb_set_flag_queue_pairs(adapter, max_rss_queues);
>  }
> @@ -5413,6 +5448,10 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
>                 return -EINVAL;
>         }
>
> +       /* For i210 Qav mode, the max frame is 1536 */
> +       if (adapter->qav_mode && max_frame > IGB_MAX_QAV_FRAME_SIZE)
> +               return -EINVAL;
> +
>  #define MAX_STD_JUMBO_FRAME_SIZE 9238
>         if (max_frame > MAX_STD_JUMBO_FRAME_SIZE) {
>                 dev_err(&pdev->dev, "MTU > 9216 not supported.\n");
> @@ -8351,4 +8390,139 @@ static void igb_nfc_filter_restore(struct igb_adapter *adapter)
>
>         spin_unlock(&adapter->nfc_lock);
>  }
> +
> +static void igb_setup_qav_mode(struct igb_adapter *adapter)
> +{
> +       struct e1000_hw *hw = &adapter->hw;
> +       u32     tqavctrl;
> +       u32     tqavcc0, tqavcc1;
> +       u32     tqavhc0, tqavhc1;
> +       u32     txpbsize;
> +
> +       /* reconfigure the tx packet buffer allocation */
> +       txpbsize = (8);
> +       txpbsize |= (8) << E1000_TXPBSIZE_TX1PB_SHIFT;
> +       txpbsize |= (4) << E1000_TXPBSIZE_TX2PB_SHIFT;
> +       txpbsize |= (4) << E1000_TXPBSIZE_TX3PB_SHIFT;
> +
> +       wr32(E1000_TXPBS, txpbsize);
> +
> +       /* In Qav mode, the maximum sized frames of 1536 bytes */
> +       wr32(E1000_DTXMXPKT, IGB_MAX_QAV_FRAME_SIZE / 64);
> +
> +       /* The I210 implements 4 queues, up to two queues are dedicated
> +        * for stream reservation or priority, strict priority queuing
> +        * while SR queue are subjected to launch time policy
> +        */
> +
> +       tqavcc0 = E1000_TQAVCC_QUEUEMODE; /* no idle slope */
> +       tqavcc1 = E1000_TQAVCC_QUEUEMODE; /* no idle slope */
> +       tqavhc0 = 0xFFFFFFFF; /* unlimited credits */
> +       tqavhc1 = 0xFFFFFFFF; /* unlimited credits */
> +
> +       wr32(E1000_TQAVCC(0), tqavcc0);
> +       wr32(E1000_TQAVCC(1), tqavcc1);
> +       wr32(E1000_TQAVHC(0), tqavhc0);
> +       wr32(E1000_TQAVHC(1), tqavhc1);
> +
> +       tqavctrl = E1000_TQAVCTRL_TXMODE |
> +                       E1000_TQAVCTRL_DATA_FETCH_ARB |
> +                       E1000_TQAVCTRL_DATA_TRAN_TIM |
> +                       E1000_TQAVCTRL_SP_WAIT_SR;
> +
> +       /* Default to a 10 usec prefetch delta from launch time - time for
> +        * a 1500 byte rx frame to be received over the PCIe Gen1 x1 link.
> +        */
> +       tqavctrl |= (10 << 5) << E1000_TQAVCTRL_FETCH_TM_SHIFT;
> +
> +       wr32(E1000_TQAVCTRL, tqavctrl);
> +}
> +
> +static void igb_setup_normal_mode(struct igb_adapter *adapter)
> +{
> +       struct e1000_hw *hw = &adapter->hw;
> +
> +       wr32(E1000_TXPBS, I210_TXPBSIZE_DEFAULT);
> +       wr32(E1000_DTXMXPKT, E1000_DTXMXPKTSZ_DEFAULT);
> +       wr32(E1000_TQAVCTRL, 0);
> +}
> +
> +static int igb_change_mode(struct igb_adapter *adapter, int request_mode)
> +{
> +       struct net_device *netdev;
> +       int err = 0;
> +       int current_mode;
> +
> +       if (!adapter) {
> +               dev_err(&adapter->pdev->dev, "map to unbound device!\n");
> +               return -ENOENT;
> +       }
> +
> +       current_mode = adapter->qav_mode;
> +
> +       if (request_mode == current_mode)
> +               return 0;
> +
> +       netdev = adapter->netdev;
> +
> +       rtnl_lock();
> +
> +       if (netif_running(netdev))
> +               igb_close(netdev);
> +       else
> +               igb_reset(adapter);
> +
> +       igb_clear_interrupt_scheme(adapter);
> +
> +       adapter->qav_mode = request_mode;
> +
> +       igb_init_queue_configuration(adapter);
> +
> +       if (igb_init_interrupt_scheme(adapter, true)) {
> +               dev_err(&adapter->pdev->dev,
> +                       "Unable to allocate memory for queues\n");
> +               err = -ENOMEM;
> +               goto err_out;
> +       }
> +
> +       if (netif_running(netdev))
> +               igb_open(netdev);
> +err_out:
> +       rtnl_unlock();
> +       return err;
> +}
> +
> +static ssize_t igb_get_qav_mode(struct device *dev,
> +                               struct device_attribute *attr, char *buf)
> +{
> +       struct net_device *netdev = to_net_dev(dev);
> +       struct igb_adapter *adapter = netdev_priv(netdev);
> +
> +       return scnprintf(buf, PAGE_SIZE, "%d\n", adapter->qav_mode);
> +}
> +
> +static ssize_t igb_set_qav_mode(struct device *dev,
> +                               struct device_attribute *attr,
> +                               const char *buf, size_t len)
> +{
> +       struct net_device *netdev = to_net_dev(dev);
> +       struct igb_adapter *adapter = netdev_priv(netdev);
> +       int request_mode, err;
> +
> +       if (!capable(CAP_NET_ADMIN))
> +               return -EPERM;
> +
> +       if (kstrtoint(buf, 0, &request_mode) < 0)
> +               return -EINVAL;
> +
> +       if (request_mode != 0 && request_mode != 1)
> +               return -EINVAL;
> +
> +       err = igb_change_mode(adapter, request_mode);
> +       if (err)
> +               return err;
> +
> +       return len;
> +}
> +
>  /* igb_main.c */
> --
> 2.7.2
>
> _______________________________________________
> Intel-wired-lan mailing list
> Intel-wired-lan@lists.osuosl.org
> http://lists.osuosl.org/mailman/listinfo/intel-wired-lan
