From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] New driver for IBM System i/p VNIC protocol
Date: Mon, 07 Apr 2014 21:05:49 -0400 (EDT)
Message-ID: <20140407.210549.1328767093987376604.davem@davemloft.net>
References: <5342EA0E.2080502@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60538 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756189AbaDHBFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 21:05:51 -0400
In-Reply-To: <5342EA0E.2080502@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santiago Leon <santil@linux.vnet.ibm.com>
Date: Mon, 07 Apr 2014 13:10:22 -0500

> This is a new device driver for a high performance SR-IOV assisted virtual network for IBM System p and IBM System i systems.  The SR-IOV VF will be attached to the VIOS partition and mapped to the Linux client via the hypervisors VNIC protocol that this driver implements. 
> 
> This driver is able to perform basic tx and rx, new features and improvements will be added as they are being developed and tested. 

Please format your commit message to ~80 columns, it is ascii
text and just because your mail client formats it automatically
doesn't mean it will do so when this gets committed into the
tree.

> +struct vnic_login_buffer {
> +	u32 len;
> +	u32 version;
> +#define INITIAL_VERSION_LB 1
> +	u32 num_txcomp_subcrqs;
> +	u32 off_txcomp_subcrqs;
> +	u32 num_rxcomp_subcrqs;
> +	u32 off_rxcomp_subcrqs;
> +	u32 login_rsp_ioba;
> +	u32 login_rsp_len;
> +}__attribute__((packed, aligned (8)));

What are the endianness of these buffers?  Use the appropriate big-endian
or little-endian types as needed.  Compile with sparse warnings enabled
to make sure all accesses to these members use the proper conversion
interfaces.

> +};
> +
> +
> +struct vnic_crq_queue {

Please only put one empty line instead of two between declarations,
functions, etc.  Please audit your entire submission for this problem.

> +	/* partner capabilities */
> +	long min_tx_queues; 
> +	long min_rx_queues; 

Is this a fixed type?  If so use u32, u64, or similar instead of
'long' which is a variably sized type.

> +#define DBG_CMD(CMD) do { if (vnic_debug) CMD; } while (0)
> +#define ENTER DBG_CMD(printk(KERN_INFO VNIC_NAME": Entering %s\n", __func__))
> +#define LEAVE DBG_CMD(printk(KERN_INFO VNIC_NAME": Leaving %s\n", __func__))
> +#define vnic_dbg(adapter, ...) \
> +        DBG_CMD(dev_info(&adapter->vdev->dev, ##__VA_ARGS__))

Please, absolutely, do not define your own debugging facilities.

The kernel has a plethora of debugging facilities that can satisfy
any objective you are striving for.

> +static int vnic_rx_weight = VNIC_RX_WEIGHT;
> +module_param(vnic_rx_weight, int, S_IRUGO);
> +MODULE_PARM_DESC(vnic_rx_weight, "VNIC rx weight for NAPI");

Do not define module parameters for these kinds of things, it is the
worst user experience possible.  Instead use existing, or newly
created, facilities via ethtool or other network configuration
interfaces to tweak these values.

> +static long h_reg_sub_crq(unsigned long unit_address, unsigned long token,
> +			  unsigned long length, unsigned long *number,
> +			  unsigned long *irq)

Arguments appearing on the second and subsequent lines of function
declarations,  definitions, and call sites, shall start precisely
at the first column after the openning parenthesis on the first line.

You should use the appropriate number of TAB and space characters
necessary to achieve this.

> +	u64* handle_array =
> +	    (u64 *)((u8*)(adapter->login_rsp_buf) +
> +		    adapter->login_rsp_buf->off_rxadd_subcrqs);

Pointers are to be declared as "type *", not "type* ".

> +	mb();
> +	for (i = 0; i < count; ++i) {

What kind of memory barrier is really necessary here?  What
actions must complete before the memory barrier, and what
operations after the memory barrier depend upon them.

Any memory barrier without a detailed comment explaining the
constraints is a bug.

> +	if(pool->rx_buff) {

There must be a between "if" and "(".

> +static int vnic_open(struct net_device *netdev)
> +{
> +	struct vnic_adapter *adapter = netdev_priv(netdev);
> +	struct device* dev = &adapter->vdev->dev;
> +	union vnic_crq crq;
> +
> +	int i, j;
> +	int rxadd_subcrqs = adapter->login_rsp_buf->num_rxadd_subcrqs;
> +	int tx_subcrqs = adapter->login_rsp_buf->num_txsubm_subcrqs;
> +	u64* size_array =
> +	    (u64 *)((u8*)(adapter->login_rsp_buf) +
> +		    adapter->login_rsp_buf->off_rxadd_buff_size);

Please to not put empty lines in the middle of a series of variable
declarations.

An empty line should only occur before the first line of actual code
and after the last local variable declaration.

> +	ENTER;

As mentioned, please get rid of these custom debugging hacks.

> +	adapter->napi =
> +	    kmalloc(sizeof(struct napi_struct) * adapter->req_rx_queues,
> +		    GFP_KERNEL);

Please us kcalloc().

And that's all I have time for today, you can expect that it will take
several revisions of review before this driver is in a state where it
can actually be intergrated.
