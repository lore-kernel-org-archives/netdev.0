From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC PATCH 1/1] igb: add tracing ability with ring_buffer
Date: Tue, 23 Feb 2010 10:24:22 -0800
Message-ID: <4B841D56.9020503@intel.com>
References: <4B836F63.4050901@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Taku Izumi <izumi.taku@jp.fujitsu.com>,
	"kaneshige.kenji@jp.fujitsu.com" <kaneshige.kenji@jp.fujitsu.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:53987 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751252Ab0BWSYY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2010 13:24:24 -0500
In-Reply-To: <4B836F63.4050901@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The biggest issue I see is that this patch is adding over 600 lines to 
the igb driver, and to make similar changes to our other drivers would 
mean adding thousands of lines of code just for some debugging output.

Is there any way igb_trace.[ch] could be renamed and moved into a 
network driver agnostic location so that it could be reused by all the 
drivers that wish to implement such functionality?

Thanks,

Alex

Koki Sanagi wrote:
> This patch adds a tracing ability to igb driver using ring_buffer and debugfs.
> Traced locations are transmit, clean tx and clean rx.
> Outputs are like this,
> 
> [  0] 74955.641155: xmit qidx=1 ntu=64->66
> [  1] 74955.641170: clean_tx qidx=1 ntc=64->66
> [  0] 74955.641194: clean_rx qidx=0 ntc=151->152
> [  0] 74955.641205: xmit qidx=1 ntu=66->68
> [  1] 74955.641220: clean_tx qidx=1 ntc=66->68
> [  0] 74955.641244: clean_rx qidx=0 ntc=152->153
> 
> These information make tx/rx ring's state visible.
> Parsing above output, we can find out how long it takes transmited packet to be
> cleaned.
> For example,
> 
> transmit_elapsed_time
> queue=0:
> ------------------------
> avg=    0.013540msec
> max=    2.495185msec
> 
>     less 1msec 31000
>       1-10msec   760
>     10-100msec     0
>   100-1000msec     0
> over 1000msec     0
> ------------------------
> total         31760
> 
> This information is helpful. Beacause sometimes igb or another intel driver
> says "Tx Unit Hang". This message indicates tx descriptor ring's process is
> delayed.
> So we must take some measures(change Interrput throttle rate, TSO, num of desc,
> or redesign network). If there is this information, we can check that a measure
> we taked is effective or not.
> On the other hand, rx descriptor is difficult to be visible. Because we cannot
> check whether packet is in descriptor or not without reading register RDH.
> But using informaiton how much descriptors are processed(it is near budget),
> we can some find out tx ring's state.
> 
> HOW TO USE:
> 
> # mount -t debugfs nodev /sys/kernel/debug
> # cd /sys/kernel/debug/igb/eth1
> # ls
> trace trace_size
> # echo 1000000 > trace_size
> # cat trace
> [  0] 74955.641155: xmit qidx=1 ntu=64->66
> [  1] 74955.641170: clean_tx qidx=1 ntc=64->66
> [  0] 74955.641194: clean_rx qidx=0 ntc=151->152
> [  0] 74955.641205: xmit qidx=1 ntu=66->68
> [  1] 74955.641220: clean_tx qidx=1 ntc=66->68
> [  0] 74955.641244: clean_rx qidx=0 ntc=152->153
> 
> -trace       output of traced record.
> -trace_size  size of ring_buffer per cpu. If 0, trace is disable.(default 0)
> 
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> ---
>   drivers/net/igb/Makefile    |    2 +-
>   drivers/net/igb/igb.h       |   10 +
>   drivers/net/igb/igb_main.c  |   11 +-
>   drivers/net/igb/igb_trace.c |  594 +++++++++++++++++++++++++++++++++++++++++++
>   drivers/net/igb/igb_trace.h |   29 ++
>   5 files changed, 643 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/igb/Makefile b/drivers/net/igb/Makefile
> index 8372cb9..286541e 100644
> --- a/drivers/net/igb/Makefile
> +++ b/drivers/net/igb/Makefile
> @@ -33,5 +33,5 @@
>   obj-$(CONFIG_IGB) += igb.o
> 
>   igb-objs := igb_main.o igb_ethtool.o e1000_82575.o \
> -           e1000_mac.o e1000_nvm.o e1000_phy.o e1000_mbx.o
> +           e1000_mac.o e1000_nvm.o e1000_phy.o e1000_mbx.o igb_trace.o
> 
> diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
> index b1c1eb8..fc944b5 100644
> --- a/drivers/net/igb/igb.h
> +++ b/drivers/net/igb/igb.h
> @@ -237,6 +237,15 @@ static inline int igb_desc_unused(struct igb_ring *ring)
>         return ring->count + ring->next_to_clean - ring->next_to_use - 1;
>   }
> 
> +struct igb_trace {
> +       struct dentry *if_dir;
> +       struct dentry *trace_file;
> +       struct dentry *trace_size_file;
> +       struct ring_buffer *trace_buffer;
> +       unsigned long trace_size;
> +       struct mutex trace_lock;
> +};
> +
>   /* board specific private data structure */
> 
>   struct igb_adapter {
> @@ -313,6 +322,7 @@ struct igb_adapter {
>         unsigned int vfs_allocated_count;
>         struct vf_data_storage *vf_data;
>         u32 rss_queues;
> +       struct igb_trace trace;
>   };
> 
>   #define IGB_FLAG_HAS_MSI           (1 << 0)
> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
> index 0a064ce..1396bfe 100644
> --- a/drivers/net/igb/igb_main.c
> +++ b/drivers/net/igb/igb_main.c
> @@ -48,6 +48,7 @@
>   #include <linux/dca.h>
>   #endif
>   #include "igb.h"
> +#include "igb_trace.h"
> 
>   #define DRV_VERSION "2.1.0-k2"
>   char igb_driver_name[] = "igb";
> @@ -268,6 +269,7 @@ static int __init igb_init_module(void)
>   #ifdef CONFIG_IGB_DCA
>         dca_register_notify(&dca_notifier);
>   #endif
> +       igb_trace_init();
>         ret = pci_register_driver(&igb_driver);
>         return ret;
>   }
> @@ -285,6 +287,7 @@ static void __exit igb_exit_module(void)
>   #ifdef CONFIG_IGB_DCA
>         dca_unregister_notify(&dca_notifier);
>   #endif
> +       igb_trace_exit();
>         pci_unregister_driver(&igb_driver);
>   }
> 
> @@ -1654,6 +1657,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
>                 (adapter->flags & IGB_FLAG_HAS_MSI) ? "MSI" : "legacy",
>                 adapter->num_rx_queues, adapter->num_tx_queues);
> 
> +       igb_create_debugfs_file(adapter);
>         return 0;
> 
>   err_register:
> @@ -1709,7 +1713,7 @@ static void __devexit igb_remove(struct pci_dev *pdev)
>                 wr32(E1000_DCA_CTRL, E1000_DCA_CTRL_DCA_MODE_DISABLE);
>         }
>   #endif
> -
> +       igb_remove_debugfs_file(adapter);
>         /* Release control of h/w to f/w.  If f/w is AMT enabled, this
>          * would have already happened in close and is redundant. */
>         igb_release_hw_control(adapter);
> @@ -3796,6 +3800,7 @@ netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
>         }
> 
>         igb_tx_queue_adv(tx_ring, tx_flags, count, skb->len, hdr_len);
> +       IGB_WRITE_TRACE_BUFFER(IGB_TRACE_XMIT, adapter, tx_ring, &first);
> 
>         /* Make sure there is space in the ring for the next send. */
>         igb_maybe_stop_tx(tx_ring, MAX_SKB_FRAGS + 4);
> @@ -4960,7 +4965,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
>                 eop = tx_ring->buffer_info[i].next_to_watch;
>                 eop_desc = E1000_TX_DESC_ADV(*tx_ring, eop);
>         }
> -
> +       IGB_WRITE_TRACE_BUFFER(IGB_TRACE_CLEAN_TX, adapter, tx_ring, &i);
>         tx_ring->next_to_clean = i;
> 
>         if (unlikely(count &&
> @@ -5115,6 +5120,7 @@ static bool igb_clean_rx_irq_adv(struct igb_q_vector *q_vector,
>                                    int *work_done, int budget)
>   {
>         struct igb_ring *rx_ring = q_vector->rx_ring;
> +       struct igb_adapter *adapter = q_vector->adapter;
>         struct net_device *netdev = rx_ring->netdev;
>         struct pci_dev *pdev = rx_ring->pdev;
>         union e1000_adv_rx_desc *rx_desc , *next_rxd;
> @@ -5230,6 +5236,7 @@ next_desc:
>                 staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
>         }
> 
> +       IGB_WRITE_TRACE_BUFFER(IGB_TRACE_CLEAN_RX, adapter, rx_ring, &i);
>         rx_ring->next_to_clean = i;
>         cleaned_count = igb_desc_unused(rx_ring);
> 
> diff --git a/drivers/net/igb/igb_trace.c b/drivers/net/igb/igb_trace.c
> new file mode 100644
> index 0000000..0e214e8
> --- /dev/null
> +++ b/drivers/net/igb/igb_trace.c
> @@ -0,0 +1,594 @@
> +#include "igb_trace.h"
> +
> +struct igb_trace_info {
> +       void (*write)(void *, void *, void *);
> +       ssize_t (*read)(char *, size_t, void *);
> +       size_t size;
> +};
> +
> +struct trace_data {
> +       unsigned short type;
> +};
> +
> +struct trace_reader {
> +       int idx;
> +       char *left_over;
> +       size_t left_over_len;
> +       struct ring_buffer_iter **iter;
> +       struct mutex *trace_lock;
> +};
> +
> +#define IGB_STR_BUF_LEN 256
> +
> +static struct igb_trace_info igb_trace_info_tbl[];
> +
> +/**
> + * igb_write_tb - Write trace_event to ring_bufffer per cpu
> + * @type: identifier of traced event
> + * @adapter: board private structure
> + * @data1: traced data
> + * @data2: traced data
> + **/
> +
> +void igb_write_tb(unsigned short type, struct igb_adapter *adapter,
> +                       void *data1, void *data2)
> +{
> +       void *event;
> +       void *entry;
> +       unsigned long flags;
> +       struct igb_trace *trace = &adapter->trace;
> +
> +       if (type >= IGB_TRACE_EVENT_NUM)
> +               return;
> +
> +       local_irq_save(flags);
> +       event = ring_buffer_lock_reserve(trace->trace_buffer,
> +                                       igb_trace_info_tbl[type].size);
> +       if (!event)
> +               goto out;
> +       entry = ring_buffer_event_data(event);
> +
> +       igb_trace_info_tbl[type].write(entry, data1, data2);
> +
> +       ring_buffer_unlock_commit(trace->trace_buffer, event);
> +out:
> +       local_irq_restore(flags);
> +}
> +
> +/**
> + * igb_open_tb - Open ring_buffer for trace to read
> + * @inode: The inode pointer that contains igb_adapter pointer
> + * @file: The file pointer to attach the iter of ring_buffer
> + **/
> +
> +static int igb_open_tb(struct inode *inode, struct file *file)
> +{
> +       struct igb_adapter *adapter = inode->i_private;
> +       struct igb_trace *trace = &adapter->trace;
> +       struct ring_buffer *buffer;
> +       struct trace_reader *reader;
> +       int cpu;
> +
> +       mutex_lock(&trace->trace_lock);
> +       if (!trace->trace_size)
> +               return -ENODEV;
> +
> +       reader = kmalloc(sizeof(struct trace_reader), GFP_KERNEL);
> +       if (!reader)
> +               goto err_alloc_reader;
> +
> +       reader->iter = kmalloc(sizeof(struct ring_buffer_iter *) * nr_cpu_ids,
> +                               GFP_KERNEL);
> +       if (!reader->iter)
> +               goto err_alloc_iter;
> +
> +       buffer = trace->trace_buffer;
> +       reader->left_over = kmalloc(IGB_STR_BUF_LEN, GFP_KERNEL);
> +       if (!reader->left_over)
> +               goto err_alloc_left_over;
> +
> +       reader->left_over_len = 0;
> +       reader->idx = 0;
> +       for_each_online_cpu(cpu) {
> +               reader->iter[cpu] = ring_buffer_read_start(buffer, cpu);
> +       }
> +       reader->trace_lock = &trace->trace_lock;
> +       file->private_data = reader;
> +       mutex_unlock(&trace->trace_lock);
> +       return 0;
> +
> +err_alloc_left_over:
> +       kfree(reader->iter);
> +err_alloc_iter:
> +       kfree(reader);
> +err_alloc_reader:
> +       mutex_unlock(&trace->trace_lock);
> +       return -ENOMEM;
> +}
> +
> +/**
> + * igb_release_tb - release iter and some resourse
> + * @inode: The inode pointer that contains igb_adapter pointer
> + * @file: The file pointer to attach the iter of ring_buffer
> + **/
> +
> +static int igb_release_tb(struct inode *inode, struct file *file)
> +{
> +       struct trace_reader *reader = file->private_data;
> +       struct ring_buffer_iter **iter = reader->iter;
> +       int cpu;
> +
> +       for_each_online_cpu(cpu) {
> +               ring_buffer_read_finish(iter[cpu]);
> +       }
> +       kfree(reader->left_over);
> +       kfree(iter);
> +       kfree(reader);
> +       return 0;
> +}
> +
> +static inline unsigned long long ns2usecs(cycle_t nsec)
> +{
> +       nsec += 500;
> +       do_div(nsec, 1000);
> +       return nsec;
> +}
> +
> +static int trace_print_format(char *buf, struct trace_data *entry,
> +                               int cpu , u64 ts)
> +{
> +       int strlen = 0;
> +       unsigned long long t;
> +       unsigned long usecs_rem, secs;
> +
> +       t = ns2usecs(ts);
> +       usecs_rem = do_div(t, USEC_PER_SEC);
> +       secs = (unsigned long)t;
> +       strlen += snprintf(buf, IGB_STR_BUF_LEN, "[%3d] %5lu.%06lu: ",
> +                               cpu, secs, usecs_rem);
> +       if (entry->type < IGB_TRACE_EVENT_NUM)
> +               strlen += igb_trace_info_tbl[entry->type].read(buf + strlen,
> +                                        IGB_STR_BUF_LEN - strlen, entry);
> +       else
> +               strlen += snprintf(buf + strlen, IGB_STR_BUF_LEN - strlen,
> +                                       "type %u is not defined", entry->type);
> +       strlen += snprintf(buf + strlen, IGB_STR_BUF_LEN - strlen, "\n");
> +       return strlen;
> +}
> +
> +static loff_t _igb_lseek_tb(struct trace_reader *reader, loff_t pos)
> +{
> +       struct ring_buffer_iter **iter = reader->iter;
> +       struct ring_buffer_event *event;
> +       struct trace_data *entry;
> +       char str[IGB_STR_BUF_LEN];
> +       int cpu, next_cpu;
> +       u64 ts, next_ts;
> +       int exceed;
> +       int strlen;
> +
> +       reader->idx = 0;
> +       for_each_online_cpu(cpu) {
> +               ring_buffer_iter_reset(iter[cpu]);
> +       }
> +       while (1) {
> +               next_ts = 0;
> +               next_cpu = -1;
> +               for_each_online_cpu(cpu) {
> +                       if (!iter[cpu])
> +                               continue;
> +                       event = ring_buffer_iter_peek(iter[cpu], &ts);
> +                       if (!event)
> +                               continue;
> +                       if (!next_ts || ts < next_ts) {
> +                               next_ts = ts;
> +                               next_cpu = cpu;
> +                       }
> +               }
> +               if (next_cpu < 0)
> +                       return -EINVAL;
> +               event = ring_buffer_read(iter[next_cpu], &ts);
> +               entry = ring_buffer_event_data(event);
> +               strlen = trace_print_format(str, entry, cpu, ts);
> +
> +               if (reader->idx + strlen >= pos)
> +                       break;
> +               reader->idx += strlen;
> +       }
> +       exceed = reader->idx + strlen - pos;
> +       if (exceed) {
> +               int from = strlen - exceed;
> +               memcpy(reader->left_over, str + from, exceed);
> +       }
> +       reader->left_over_len = exceed;
> +       reader->idx = pos;
> +       return pos;
> +}
> +
> +/**
> + * igb_lseek_tb - seek a ring_buffer
> + * @file: The file pointer to attach the iter of ring_buffer
> + * @offset: The offset to seek
> + * @origin: absolute(0) or relative(1)
> + **/
> +
> +static loff_t igb_lseek_tb(struct file *file, loff_t offset, int origin)
> +{
> +       struct trace_reader *reader = file->private_data;
> +       loff_t ret = -EINVAL;
> +
> +       mutex_lock(reader->trace_lock);
> +       switch (origin) {
> +       case 1:
> +               offset += file->f_pos;
> +       case 0:
> +               if (offset < 0)
> +                       break;
> +               ret = _igb_lseek_tb(reader, offset);
> +       }
> +       if (ret > 0)
> +               file->f_pos = ret;
> +       mutex_unlock(reader->trace_lock);
> +       return ret;
> +}
> +
> +/**
> + * igb_read_tb - read a ring_buffer and transform print format
> + * @file: The file pointer to attach the iter of ring_buffer
> + * @buf: The buffer to copy to
> + * @nbytes: The maximum number of bytes to read
> + * @ppos: The position to read from
> + **/
> +
> +static ssize_t igb_read_tb(struct file *file, char __user *buf,
> +                               size_t nbytes, loff_t *ppos)
> +{
> +       struct trace_reader *reader = file->private_data;
> +       struct ring_buffer_iter **iter = reader->iter;
> +       struct trace_data *entry;
> +       struct ring_buffer_event *event;
> +       loff_t pos = *ppos;
> +       u64 ts, next_ts = 0;
> +       int cpu, next_cpu = -1;
> +       char str[IGB_STR_BUF_LEN];
> +       unsigned int strlen = 0;
> +       size_t copy;
> +       int ret;
> +
> +       mutex_lock(reader->trace_lock);
> +       if (pos != reader->idx)
> +               _igb_lseek_tb(reader, pos);
> +       if (reader->left_over_len) {
> +               copy = min(reader->left_over_len, nbytes);
> +               ret = copy_to_user(buf, reader->left_over,
> +                               reader->left_over_len);
> +               copy -= ret;
> +               reader->left_over_len = ret;
> +               reader->idx += copy;
> +               *ppos += copy;
> +               mutex_unlock(reader->trace_lock);
> +               return reader->left_over_len - ret;
> +       }
> +       for_each_online_cpu(cpu) {
> +               if (!iter[cpu])
> +                       continue;
> +               event = ring_buffer_iter_peek(iter[cpu], &ts);
> +               if (!event)
> +                       continue;
> +               if (!next_ts || ts < next_ts) {
> +                       next_ts = ts;
> +                       next_cpu = cpu;
> +               }
> +       }
> +       if (next_cpu < 0) {
> +               mutex_unlock(reader->trace_lock);
> +               return 0;
> +       }
> +       event = ring_buffer_read(iter[next_cpu], &ts);
> +       entry = ring_buffer_event_data(event);
> +
> +       strlen = trace_print_format(str, entry, next_cpu, ts);
> +       copy = min(strlen, nbytes);
> +       ret = copy_to_user(buf, str, strlen);
> +       copy -= ret;
> +       reader->left_over_len = ret;
> +       if (ret) {
> +               memcpy(reader->left_over, str + copy, ret);
> +               reader->left_over_len = ret;
> +       }
> +       *ppos = pos + copy;
> +       reader->idx = *ppos;
> +       mutex_unlock(reader->trace_lock);
> +       return copy;
> +}
> +
> +static const struct file_operations igb_trace_file_ops = {
> +       .owner =        THIS_MODULE,
> +       .open =         igb_open_tb,
> +       .llseek =       igb_lseek_tb,
> +       .read =         igb_read_tb,
> +       .release =      igb_release_tb,
> +};
> +
> +/**
> + * igb_open_trace_size - connect the pinter
> + * @inode: The inode pointer that contains igb_adapter pointer
> + * @file: The file pointer to attach the igb_adapter pointer
> + **/
> +
> +static int igb_open_trace_size(struct inode *inode, struct file *file)
> +{
> +       file->private_data = inode->i_private;
> +       return 0;
> +}
> +
> +/**
> + * igb_read_tb - print the size of ring_buffer byte unit to buf
> + *               if trace is disable, print 0
> + * @file: The file pointer that contains an igb_adapter pointer
> + * @buf: The buffer to copy to
> + * @nbytes: The maximum number of bytes to read
> + * @ppos: The position to read from
> + **/
> +
> +static ssize_t igb_read_trace_size(struct file *file, char __user *ubuf,
> +                               size_t nbytes, loff_t *ppos)
> +{
> +       struct igb_adapter *adapter = file->private_data;
> +       struct igb_trace *trace = &adapter->trace;
> +       unsigned long size = trace->trace_size;
> +       char buf[16];
> +       int r;
> +
> +       r = sprintf(buf, "%lu\n", size);
> +
> +       return simple_read_from_buffer(ubuf, nbytes, ppos, buf, r);
> +}
> +
> +/**
> + * igb_trace_buffer_enable - enable trace and set ring_buffer size
> + * @adapter: board private structure
> + * @size: size of ring_buffer per cpu
> + **/
> +
> +static int igb_trace_buffer_enable(struct igb_adapter *adapter, ssize_t size)
> +{
> +       struct igb_trace *trace = &adapter->trace;
> +       struct pci_dev *pdev = adapter->pdev;
> +
> +       trace->trace_buffer =  ring_buffer_alloc(size, RB_FL_OVERWRITE);
> +       if (!trace->trace_buffer) {
> +               dev_err(&pdev->dev, "Cannot alloc trace_buffer\n");
> +               return -EINVAL;
> +       }
> +       trace->trace_size = size;
> +       return 0;
> +}
> +
> +/**
> + * igb_trace_buffer_disable - disable trace
> + * @adapter: board private structure
> + **/
> +
> +static void igb_trace_buffer_disable(struct igb_adapter *adapter)
> +{
> +       struct igb_trace *trace = &adapter->trace;
> +
> +       ring_buffer_free(trace->trace_buffer);
> +       trace->trace_size = 0;
> +}
> +
> +/**
> + * igb_write_trace_size - write a ring_buffer size per cpu
> + *                        if 0, disable trace
> + * @file: Ther file pointer thar contains an igb_adapter pointer
> + * @buf: The buffer to read and write for trace_size
> + * @nbytes: size of buffe to read
> + * @ppos: the position to read
> + **/
> +
> +static ssize_t igb_write_trace_size(struct file *file, const char __user *ubuf,
> +                                       size_t nbytes, loff_t *ppos)
> +{
> +       struct igb_adapter *adapter = file->private_data;
> +       struct igb_trace *trace = &adapter->trace;
> +       unsigned long cur = trace->trace_size;
> +       int ret;
> +       unsigned long new;
> +       char buf[64];
> +
> +       if (nbytes >= sizeof(buf))
> +               return -EINVAL;
> +
> +       if (copy_from_user(&buf, ubuf, nbytes))
> +               return -EFAULT;
> +       buf[nbytes] = 0;
> +       ret = strict_strtoul(buf, 10, &new);
> +       if (ret < 0)
> +               return ret;
> +
> +       mutex_lock(&trace->trace_lock);
> +       if (!cur && new) {
> +               igb_trace_buffer_enable(adapter, new);
> +       } else if (cur && !new) {
> +               igb_trace_buffer_disable(adapter);
> +       } else if (cur != new) {
> +               igb_trace_buffer_disable(adapter);
> +               igb_trace_buffer_enable(adapter, new);
> +       }
> +       mutex_unlock(&trace->trace_lock);
> +       return nbytes;
> +}
> +
> +static const struct file_operations igb_trace_size_ops = {
> +       .owner =        THIS_MODULE,
> +       .open =         igb_open_trace_size,
> +       .read =         igb_read_trace_size,
> +       .write =        igb_write_trace_size,
> +};
> +
> +static struct dentry *igb_trace_root;
> +
> +void igb_trace_init()
> +{
> +       igb_trace_root = debugfs_create_dir("igb", NULL);
> +       if (!igb_trace_root) {
> +               printk(KERN_ERR "Cannot create debugfs\n");
> +               return;
> +       }
> +}
> +
> +void igb_trace_exit(void)
> +{
> +       if (igb_trace_root)
> +               debugfs_remove_recursive(igb_trace_root);
> +}
> +
> +void igb_create_debugfs_file(struct igb_adapter *adapter)
> +{
> +       struct net_device *netdev = adapter->netdev;
> +       struct igb_trace *trace = &adapter->trace;
> +       struct pci_dev *pdev = adapter->pdev;
> +
> +       if (!igb_trace_root)
> +               return;
> +       trace->if_dir =
> +               debugfs_create_dir(netdev->name, igb_trace_root);
> +       if (!trace->if_dir) {
> +               dev_err(&pdev->dev, "Cannot create if_dir %s\n",
> +                       netdev->name);
> +               goto err_alloc_dir;
> +       }
> +       trace->trace_file =
> +               debugfs_create_file("trace", S_IFREG|S_IRUGO|S_IWUSR,
> +                       trace->if_dir,
> +                       adapter, &igb_trace_file_ops);
> +       if (!trace->trace_file) {
> +               dev_err(&pdev->dev, "Cannot create debugfs for trace %s\n",
> +                       netdev->name);
> +               goto err_alloc_trace;
> +       }
> +       trace->trace_size_file =
> +               debugfs_create_file("trace_size", S_IFREG|S_IRUGO|S_IWUSR,
> +                       trace->if_dir,
> +                       adapter, &igb_trace_size_ops);
> +       if (!trace->trace_file) {
> +               dev_err(&pdev->dev, "Cannot create debugfs for trace_size %s\n",
> +                       netdev->name);
> +               goto err_alloc_trace_size;
> +       }
> +       mutex_init(&trace->trace_lock);
> +       return;
> +
> +err_alloc_trace_size:
> +       debugfs_remove(trace->trace_file);
> +err_alloc_trace:
> +       debugfs_remove(trace->if_dir);
> +err_alloc_dir:
> +       return;
> +}
> +
> +void igb_remove_debugfs_file(struct igb_adapter *adapter)
> +{
> +       struct igb_trace *trace = &adapter->trace;
> +
> +       if (trace->trace_size_file)
> +               debugfs_remove(trace->trace_size_file);
> +       if (trace->trace_file)
> +               debugfs_remove(trace->trace_file);
> +       if (trace->if_dir)
> +               debugfs_remove(trace->if_dir);
> +}
> +
> +/* function and struct for tracing xmit */
> +struct trace_data_xmit {
> +       unsigned short type;
> +       u8 queue_index;
> +       u16 ntu;
> +       unsigned int first;
> +};
> +
> +static void igb_write_tb_xmit(void *entry, void *data1, void *data2)
> +{
> +       struct trace_data_xmit *td = entry;
> +       struct igb_ring *tx_ring = (struct igb_ring *)data1;
> +       unsigned int first = *(unsigned int *)data2;
> +
> +       td->type = IGB_TRACE_XMIT;
> +       td->queue_index = tx_ring->queue_index;
> +       td->ntu = tx_ring->next_to_use;
> +       td->first = first;
> +}
> +
> +static ssize_t igb_read_tb_xmit(char *str, size_t size, void *entry)
> +{
> +       struct trace_data_xmit *t_data = entry;
> +
> +       return snprintf(str, size, "xmit qidx=%u ntu=%u->%u",
> +                       t_data->queue_index, t_data->first, t_data->ntu);
> +}
> +
> +/* function and struct for tracing clean_tx */
> +struct trace_data_clean_tx {
> +       unsigned short type;
> +       u8 queue_index;
> +       u16 ntc;
> +       unsigned int i;
> +};
> +
> +static void igb_write_tb_clean_tx(void *entry, void *data1, void *data2)
> +{
> +       struct trace_data_clean_tx *td = entry;
> +       struct igb_ring *tx_ring = (struct igb_ring *)data1;
> +       unsigned int i = *(unsigned int *)data2;
> +
> +       td->type = IGB_TRACE_CLEAN_TX;
> +       td->queue_index = tx_ring->queue_index;
> +       td->ntc = tx_ring->next_to_clean;
> +       td->i = i;
> +}
> +
> +static ssize_t igb_read_tb_clean_tx(char *str, size_t size, void *entry)
> +{
> +       struct trace_data_clean_tx *t_data = entry;
> +
> +       return snprintf(str, size, "clean_tx qidx=%u ntc=%u->%u",
> +                       t_data->queue_index, t_data->ntc, t_data->i);
> +}
> +
> +/* function and struct for tracing clean_rx */
> +struct trace_data_clean_rx {
> +       unsigned short type;
> +       u8 queue_index;
> +       u16 ntc;
> +       unsigned int i;
> +};
> +
> +static void igb_write_tb_clean_rx(void *entry, void *data1, void *data2)
> +{
> +       struct trace_data_clean_rx *td = entry;
> +       struct igb_ring *rx_ring = (struct igb_ring *)data1;
> +       unsigned int i = *(unsigned int *)data2;
> +
> +       td->type = IGB_TRACE_CLEAN_RX;
> +       td->queue_index = rx_ring->queue_index;
> +       td->ntc = rx_ring->next_to_clean;
> +       td->i = i;
> +}
> +
> +static ssize_t igb_read_tb_clean_rx(char *str, size_t size, void *entry)
> +{
> +       struct trace_data_clean_rx *t_data = entry;
> +
> +       return snprintf(str, size, "clean_rx qidx=%u ntc=%u->%u",
> +                       t_data->queue_index, t_data->ntc, t_data->i);
> +}
> +
> +static struct igb_trace_info igb_trace_info_tbl[] = {
> +       {igb_write_tb_xmit, igb_read_tb_xmit,
> +               sizeof(struct trace_data_xmit)},
> +       {igb_write_tb_clean_tx, igb_read_tb_clean_tx,
> +               sizeof(struct trace_data_clean_tx)},
> +       {igb_write_tb_clean_rx, igb_read_tb_clean_rx,
> +               sizeof(struct trace_data_clean_rx)},
> +};
> diff --git a/drivers/net/igb/igb_trace.h b/drivers/net/igb/igb_trace.h
> new file mode 100644
> index 0000000..4e6a85b
> --- /dev/null
> +++ b/drivers/net/igb/igb_trace.h
> @@ -0,0 +1,29 @@
> +#ifndef _IGB_TRACE_H_
> +#define _IGB_TRACE_H_
> +
> +#include <linux/module.h>
> +#include <linux/ring_buffer.h>
> +#include <linux/netdevice.h>
> +#include <linux/pci.h>
> +#include <linux/debugfs.h>
> +#include "igb.h"
> +
> +#define IGB_TRACE_XMIT                 0x00
> +#define IGB_TRACE_CLEAN_TX     0x01
> +#define IGB_TRACE_CLEAN_RX     0x02
> +#define IGB_TRACE_EVENT_NUM    0x03
> +
> +extern void igb_trace_init(void);
> +extern void igb_trace_exit(void);
> +extern void igb_create_debugfs_file(struct igb_adapter *adapter);
> +extern void igb_remove_debugfs_file(struct igb_adapter *adapter);
> +extern void igb_write_tb(unsigned short type, struct igb_adapter *adapter,
> +                       void *data1, void *data2);
> +
> +#define IGB_WRITE_TRACE_BUFFER(type, adapter, data1, data2)            \
> +       do {                                                            \
> +               if (adapter->trace.trace_size)                          \
> +                       igb_write_tb(type, adapter, data1, data2);      \
> +       } while (0)
> +
> +#endif /* _IGB_TRACE_H_ */
> 

