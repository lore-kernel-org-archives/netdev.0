From: Andres Lagar-Cavilla <andreslc@gridcentric.ca>
Subject: Re: [PATCH] Xen backend support for paged out grant targets.
Date: Wed, 12 Sep 2012 16:21:10 -0400
Message-ID: <7EF39A37-CC11-4AB8-8B36-F8CD3646F6D3@gridcentric.ca>
References: <1347479153-441-1-git-send-email-andres@lagarcavilla.org> <20120912200641.GB29879@phenom.dumpdata.com>
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Andres Lagar-Cavilla <andres@lagarcavilla.org>,
	xen-devel@xen.lists.org, Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120912200641.GB29879@phenom.dumpdata.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sep 12, 2012, at 4:06 PM, Konrad Rzeszutek Wilk wrote:

> On Wed, Sep 12, 2012 at 03:45:53PM -0400, Andres Lagar-Cavilla wrote:
>> Since Xen-4.2, hvm domains may have portions of their memory paged out. When a
>> foreign domain (such as dom0) attempts to map these frames, the map will
>> initially fail. The hypervisor returns a suitable errno, and kicks an
>> asynchronous page-in operation carried out by a helper. The foreign domain is
>> expected to retry the mapping operation until it eventually succeeds. The
>> foreign domain is not put to sleep because itself could be the one running the
>> pager assist (typical scenario for dom0).
> 
> Looks ok to me. You forgot to put on the CC LKML and netdev mailing list
> so I did that for you.
Thanks. I have a concern though (re-posting from xen-devel). I need to bring attention to the following hunk:
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 682633b..5610fd8 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -635,9 +635,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
		return;

	BUG_ON(npo.copy_prod > ARRAY_SIZE(netbk->grant_copy_op));
-	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy, &netbk->grant_copy_op,
-					npo.copy_prod);
-	BUG_ON(ret != 0);
+	gnttab_batch_copy_no_eagain(netbk->grant_copy_op, npo.copy_prod);

It seems like the (extant) code passes a struct gnttab_copy ** to the grant table hypercall (&netbk->grant_copy_op, defined as struct gnttab_copy [])

I "fixed" it to pass a struct gnttab_copy * (netbk->grant_copy_op, no '&'). This matches the other invocation of the grant copy hyper call (in netbk_tx_action). Did I fix it, though? I am confused as to how this could have ever worked.

Andres

> 
>> 
>> This patch adds support for this mechanism for backend drivers using grant
>> mapping and copying operations. Specifically, this covers the blkback and
>> gntdev drivers (which map foregin grants), and the netback driver (which copies
>> foreign grants).
>> 
>> * Add GNTST_eagain, already exposed by Xen, to the grant interface.
>> * Add a retry method for grants that fail with GNTST_eagain (i.e. because the
>>  target foregin frame is paged out).
>> * Insert hooks with appropriate macro decorators in the aforementioned drivers.
>> 
>> The retry loop is only invoked if the grant operation status is GNTST_eagain.
>> It guarantees to leave a new status code different from GNTST_eagain. Any other
>> status code results in identical code execution as before.
>> 
>> The retry loop performs 256 attempts with increasing time intervals through a
>> 32 second period. It uses msleep to yield while waiting for the next retry.
>> 
>> V2 after feedback from David Vrabel:
>> * Explicit MAX_DELAY instead of wrap-around delay into zero
>> * Abstract GNTST_eagain check into core grant table code for netback module.
>> 
>> Signed-off-by: Andres Lagar-Cavilla <andres@lagarcavilla.org>
>> ---
>> drivers/net/xen-netback/netback.c   |   11 +++-------
>> drivers/xen/grant-table.c           |   26 ++++++++++++++++++++++++
>> drivers/xen/xenbus/xenbus_client.c  |    6 ++----
>> include/xen/grant_table.h           |   38 +++++++++++++++++++++++++++++++++++
>> include/xen/interface/grant_table.h |    2 ++
>> 5 files changed, 71 insertions(+), 12 deletions(-)
>> 
>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
>> index 682633b..fc40258 100644
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -635,9 +635,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
>> 		return;
>> 
>> 	BUG_ON(npo.copy_prod > ARRAY_SIZE(netbk->grant_copy_op));
>> -	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy, &netbk->grant_copy_op,
>> -					npo.copy_prod);
>> -	BUG_ON(ret != 0);
>> +	gnttab_batch_copy_retry_eagain(netbk->grant_copy_op, npo.copy_prod);
>> 
>> 	while ((skb = __skb_dequeue(&rxq)) != NULL) {
>> 		sco = (struct skb_cb_overlay *)skb->cb;
>> @@ -1460,18 +1458,15 @@ static void xen_netbk_tx_submit(struct xen_netbk *netbk)
>> static void xen_netbk_tx_action(struct xen_netbk *netbk)
>> {
>> 	unsigned nr_gops;
>> -	int ret;
>> 
>> 	nr_gops = xen_netbk_tx_build_gops(netbk);
>> 
>> 	if (nr_gops == 0)
>> 		return;
>> -	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy,
>> -					netbk->tx_copy_ops, nr_gops);
>> -	BUG_ON(ret);
>> 
>> -	xen_netbk_tx_submit(netbk);
>> +	gnttab_batch_copy_retry_eagain(netbk->tx_copy_ops, nr_gops);
>> 
>> +	xen_netbk_tx_submit(netbk);
>> }
>> 
>> static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx)
>> diff --git a/drivers/xen/grant-table.c b/drivers/xen/grant-table.c
>> index eea81cf..96543b2 100644
>> --- a/drivers/xen/grant-table.c
>> +++ b/drivers/xen/grant-table.c
>> @@ -38,6 +38,7 @@
>> #include <linux/vmalloc.h>
>> #include <linux/uaccess.h>
>> #include <linux/io.h>
>> +#include <linux/delay.h>
>> #include <linux/hardirq.h>
>> 
>> #include <xen/xen.h>
>> @@ -823,6 +824,26 @@ unsigned int gnttab_max_grant_frames(void)
>> }
>> EXPORT_SYMBOL_GPL(gnttab_max_grant_frames);
>> 
>> +#define MAX_DELAY 256
>> +void
>> +gnttab_retry_eagain_gop(unsigned int cmd, void *gop, int16_t *status,
>> +						const char *func)
>> +{
>> +	unsigned delay = 1;
>> +
>> +	do {
>> +		BUG_ON(HYPERVISOR_grant_table_op(cmd, gop, 1));
>> +		if (*status == GNTST_eagain)
>> +			msleep(delay++);
>> +	} while ((*status == GNTST_eagain) && (delay < MAX_DELAY));
>> +
>> +	if (delay >= MAX_DELAY) {
>> +		printk(KERN_ERR "%s: %s eagain grant\n", func, current->comm);
>> +		*status = GNTST_bad_page;
>> +	}
>> +}
>> +EXPORT_SYMBOL_GPL(gnttab_retry_eagain_gop);
>> +
>> int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
>> 		    struct gnttab_map_grant_ref *kmap_ops,
>> 		    struct page **pages, unsigned int count)
>> @@ -836,6 +857,11 @@ int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
>> 	if (ret)
>> 		return ret;
>> 
>> +	/* Retry eagain maps */
>> +	for (i = 0; i < count; i++)
>> +		if (map_ops[i].status == GNTST_eagain)
>> +			gnttab_retry_eagain_map(map_ops + i);
>> +
>> 	if (xen_feature(XENFEAT_auto_translated_physmap))
>> 		return ret;
>> 
>> diff --git a/drivers/xen/xenbus/xenbus_client.c b/drivers/xen/xenbus/xenbus_client.c
>> index b3e146e..a6e07ea 100644
>> --- a/drivers/xen/xenbus/xenbus_client.c
>> +++ b/drivers/xen/xenbus/xenbus_client.c
>> @@ -490,8 +490,7 @@ static int xenbus_map_ring_valloc_pv(struct xenbus_device *dev,
>> 
>> 	op.host_addr = arbitrary_virt_to_machine(pte).maddr;
>> 
>> -	if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, 1))
>> -		BUG();
>> +	gnttab_map_grant_retry_eagain(&op);
>> 
>> 	if (op.status != GNTST_okay) {
>> 		free_vm_area(area);
>> @@ -572,8 +571,7 @@ int xenbus_map_ring(struct xenbus_device *dev, int gnt_ref,
>> 	gnttab_set_map_op(&op, (unsigned long)vaddr, GNTMAP_host_map, gnt_ref,
>> 			  dev->otherend_id);
>> 
>> -	if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, 1))
>> -		BUG();
>> +	gnttab_map_grant_retry_eagain(&op);
>> 
>> 	if (op.status != GNTST_okay) {
>> 		xenbus_dev_fatal(dev, op.status,
>> diff --git a/include/xen/grant_table.h b/include/xen/grant_table.h
>> index 11e27c3..c829c83 100644
>> --- a/include/xen/grant_table.h
>> +++ b/include/xen/grant_table.h
>> @@ -43,6 +43,7 @@
>> #include <xen/interface/grant_table.h>
>> 
>> #include <asm/xen/hypervisor.h>
>> +#include <asm/xen/hypercall.h>
>> 
>> #include <xen/features.h>
>> 
>> @@ -183,6 +184,43 @@ unsigned int gnttab_max_grant_frames(void);
>> 
>> #define gnttab_map_vaddr(map) ((void *)(map.host_virt_addr))
>> 
>> +/* Retry a grant map/copy operation when the hypervisor returns GNTST_eagain.
>> + * This is typically due to paged out target frames.
>> + * Generic entry-point, use macro decorators below for specific grant
>> + * operations.
>> + * Will retry for 1, 2, ... 255 ms, i.e. 256 times during 32 seconds.
>> + * Return value in *status guaranteed to no longer be GNTST_eagain. */
>> +void gnttab_retry_eagain_gop(unsigned int cmd, void *gop, int16_t *status,
>> +                             const char *func);
>> +
>> +#define gnttab_retry_eagain_map(_gop)                       \
>> +    gnttab_retry_eagain_gop(GNTTABOP_map_grant_ref, (_gop), \
>> +                            &(_gop)->status, __func__)
>> +
>> +#define gnttab_retry_eagain_copy(_gop)                  \
>> +    gnttab_retry_eagain_gop(GNTTABOP_copy, (_gop),      \
>> +                            &(_gop)->status, __func__)
>> +
>> +static inline void
>> +gnttab_map_grant_retry_eagain(struct gnttab_map_grant_ref *op)
>> +{
>> +    BUG_ON((HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, op, 1)));
>> +    if (op->status == GNTST_eagain)
>> +        gnttab_retry_eagain_map(op);
>> +}
>> +
>> +static inline void
>> +gnttab_batch_copy_retry_eagain(struct gnttab_copy *batch, unsigned count)
>> +{
>> +    unsigned i;
>> +    struct gnttab_copy *op;
>> +
>> +    BUG_ON(HYPERVISOR_grant_table_op(GNTTABOP_copy, batch, count));
>> +    for (i = 0, op = batch; i < count; i++, op++)
>> +        if (op->status == GNTST_eagain)
>> +            gnttab_retry_eagain_copy(op);
>> +}
>> +
>> int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
>> 		    struct gnttab_map_grant_ref *kmap_ops,
>> 		    struct page **pages, unsigned int count);
>> diff --git a/include/xen/interface/grant_table.h b/include/xen/interface/grant_table.h
>> index 7da811b..66cb734 100644
>> --- a/include/xen/interface/grant_table.h
>> +++ b/include/xen/interface/grant_table.h
>> @@ -520,6 +520,7 @@ DEFINE_GUEST_HANDLE_STRUCT(gnttab_get_version);
>> #define GNTST_permission_denied (-8) /* Not enough privilege for operation.  */
>> #define GNTST_bad_page         (-9) /* Specified page was invalid for op.    */
>> #define GNTST_bad_copy_arg    (-10) /* copy arguments cross page boundary */
>> +#define GNTST_eagain          (-12) /* Retry.                                */
>> 
>> #define GNTTABOP_error_msgs {                   \
>>     "okay",                                     \
>> @@ -533,6 +534,7 @@ DEFINE_GUEST_HANDLE_STRUCT(gnttab_get_version);
>>     "permission denied",                        \
>>     "bad page",                                 \
>>     "copy arguments cross page boundary"        \
>> +    "retry"                                     \
>> }
>> 
>> #endif /* __XEN_PUBLIC_GRANT_TABLE_H__ */
>> -- 
>> 1.7.9.5
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
