From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next v2] xen-netback: Adding debugfs "io_ring_qX"
 files
Date: Tue, 8 Jul 2014 15:33:50 +0100
Message-ID: <53BC014E.5090600@citrix.com>
References: <1404330830-24504-1-git-send-email-zoltan.kiss@citrix.com> <20140702200252.GA17294@laptop.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140702200252.GA17294@laptop.dumpdata.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/07/14 21:02, Konrad Rzeszutek Wilk wrote:
> On Wed, Jul 02, 2014 at 08:53:50PM +0100, Zoltan Kiss wrote:
>> +static ssize_t
>> +xenvif_write_io_ring(struct file *filp, const char __user *buf, size_t count,
>> +		     loff_t *ppos)
>> +{
>> +	struct xenvif_queue *queue =
>> +		((struct seq_file *)filp->private_data)->private;
>> +	int len;
>> +	char write[sizeof("kick")];
>
> <blinks>
>> +
>> +	/* don't allow partial writes and check the length */
>> +	if (*ppos != 0)
>> +		return 0;
>> +	if (count < sizeof("kick") - 1)
>
> Um, could you just use a #define please?
OK

>
>> +		return -ENOSPC;
>> +
>> +	len = simple_write_to_buffer(write,
>> +				     sizeof(write),
>> +				     ppos,
>> +				     buf,
>> +				     count);
>> +	if (len < 0)
>> +		return len;
>> +
>> +	if (!strncmp(write, "kick", sizeof("kick") - 1))
>> +		xenvif_interrupt(0, (void *)queue);
>> +	else
>> +		pr_warn("Unknown command to io_ring. Available: kick\n");
>
> It is 'io_ring_q%d'?
Yes

> Why don't you split that back out to the user
> instead of the console?
How do you mean? Printing it into buf? I don't think the user cares 
about its content after doing the write syscall. More importantly, I 
don't know if that buffer is big enough to hold the message.
>
>
>> +	return count;
>> +}
>> +
>> +static int xenvif_dump_open(struct inode *inode, struct file *filp)
>> +{
>> +	int ret;
>> +	void *queue = NULL;
>> +
>> +	if (inode->i_private)
>> +		queue = inode->i_private;
>> +	ret = single_open(filp, xenvif_read_io_ring, queue);
>> +	filp->f_mode |= FMODE_PWRITE;
>> +	return ret;
>> +}
>> +
>> +static const struct file_operations xenvif_dbg_io_ring_ops_fops = {
>> +	.owner = THIS_MODULE,
>> +	.open = xenvif_dump_open,
>> +	.read = seq_read,
>> +	.llseek = seq_lseek,
>> +	.release = single_release,
>> +	.write = xenvif_write_io_ring,
>> +};
>> +
>> +static void xenvif_debugfs_addif(struct xenvif_queue *queue)
>> +{
>> +	struct dentry *pfile;
>> +	struct xenvif *vif = queue->vif;
>> +	int i;
>> +
>> +	vif->xenvif_dbg_root = debugfs_create_dir(vif->dev->name,
>> +						  xen_netback_dbg_root);
>> +	if (!IS_ERR_OR_NULL(vif->xenvif_dbg_root)) {
>> +		for (i = 0; i < vif->num_queues; ++i) {
>> +			char filename[sizeof("io_ring_q") + 4];
>> +
>> +			snprintf(filename, sizeof(filename), "io_ring_q%d", i);
>> +			pfile = debugfs_create_file(filename,
>> +						    0600,
>
> Pls use macros for that.
OK

>> +						    vif->xenvif_dbg_root,
>> +						    &vif->queues[i],
>> +						    &xenvif_dbg_io_ring_ops_fops);
>> +			if (IS_ERR_OR_NULL(pfile))
>> +				pr_warn("Creation of io_ring file returned %ld!\n",
>> +					PTR_ERR(pfile));
>> +		}
>> +	} else
>> +		netdev_warn(vif->dev,
>> +			    "Creation of vif debugfs dir returned %ld!\n",
>> +			    PTR_ERR(vif->xenvif_dbg_root));
>> +}
>> +
>> +static void xenvif_debugfs_delif(struct xenvif *vif)
>> +{
>
> Could you add:
>
> 	if (!IS_ERR_OR_NULL(xen_netback_dbg_root))
> 		return;
>
Ok

>> +	if (!IS_ERR_OR_NULL(vif->xenvif_dbg_root))
>> +		debugfs_remove_recursive(vif->xenvif_dbg_root);
>> +	vif->xenvif_dbg_root = NULL;
>> +}
>> +#endif /* CONFIG_DEBUG_FS */
>> +
>>   static int netback_remove(struct xenbus_device *dev)
>>   {
>>   	struct backend_info *be = dev_get_drvdata(&dev->dev);
>> @@ -246,8 +404,13 @@ static void backend_create_xenvif(struct backend_info *be)
>>
>>   static void backend_disconnect(struct backend_info *be)
>>   {
>> -	if (be->vif)
>> +	if (be->vif) {
>> +#ifdef CONFIG_DEBUG_FS
>> +		if (!IS_ERR_OR_NULL(xen_netback_dbg_root))
>> +			xenvif_debugfs_delif(be->vif);
>
> .. and then you can remove these 'if' here
>> +#endif /* CONFIG_DEBUG_FS */
>>   		xenvif_disconnect(be->vif);
>> +	}
>>   }
>>
>>   static void backend_connect(struct backend_info *be)
>> @@ -560,6 +723,10 @@ static void connect(struct backend_info *be)
>>   			be->vif->num_queues = queue_index;
>>   			goto err;
>>   		}
>> +#ifdef CONFIG_DEBUG_FS
>> +		if (!IS_ERR_OR_NULL(xen_netback_dbg_root))
>
> .. and here.
>> +			xenvif_debugfs_addif(queue);
>> +#endif /* CONFIG_DEBUG_FS */
>>   	}
>>
>>   	/* Initialisation completed, tell core driver the number of
>>
>> _______________________________________________
>> Xen-devel mailing list
>> Xen-devel@lists.xen.org
>> http://lists.xen.org/xen-devel
