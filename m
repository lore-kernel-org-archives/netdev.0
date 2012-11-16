From: ANNIE LI <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH 1/4] xen/netback: implements persistent grant
 with one page pool.
Date: Fri, 16 Nov 2012 10:18:45 +0800
Message-ID: <50A5A285.1030805@oracle.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>  <1352963066-570-1-git-send-email-annie.li@oracle.com> <1352970612.3499.43.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41584 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145Ab2KPCSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 21:18:54 -0500
In-Reply-To: <1352970612.3499.43.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012-11-15 17:10, Ian Campbell wrote:
> On Thu, 2012-11-15 at 07:04 +0000, Annie Li wrote:
>> This patch implements persistent grant in netback driver. Tx and rx
>> share the same page pool, this pool will be split into two parts
>> in next patch.
>>
>> Signed-off-by: Annie Li<annie.li@oracle.com>
>> ---
>>   drivers/net/xen-netback/common.h    |   18 +++-
>>   drivers/net/xen-netback/interface.c |   22 ++++
>>   drivers/net/xen-netback/netback.c   |  212 +++++++++++++++++++++++++++++++----
>>   drivers/net/xen-netback/xenbus.c    |   14 ++-
>>   4 files changed, 239 insertions(+), 27 deletions(-)
>>
>> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
>> index 94b79c3..a85cac6 100644
>> --- a/drivers/net/xen-netback/common.h
>> +++ b/drivers/net/xen-netback/common.h
>> @@ -45,8 +45,19 @@
>>   #include<xen/grant_table.h>
>>   #include<xen/xenbus.h>
>>
>> +#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
>> +#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
>> +#define MAXIMUM_OUTSTANDING_BLOCK_REQS \
> BLOCK?

Oh, an error when splitting the patch, will fix it, thanks.

>
>> +                       (XEN_NETIF_TX_RING_SIZE + XEN_NETIF_RX_RING_SIZE)
>> +
>>   struct xen_netbk;
>>
>> +struct persistent_entry {
>> +       grant_ref_t forgranted;
>> +       struct page *fpage;
>> +       struct gnttab_map_grant_ref map;
>> +};
> Isn't this duplicating a bunch of infrastructure which is also in
> blkback? Can we put it into some common helpers please?

Yes,

"struct gnttab_map_grant_ref map" can be changed to handle like blkback to keep same as blkback, and share them in common helpers.


>
>> +
>>   struct xenvif {
>>          /* Unique identifier for this interface. */
>>          domid_t          domid;
>> @@ -75,6 +86,7 @@ struct xenvif {
>>
>>          /* Internal feature information. */
>>          u8 can_queue:1;     /* can queue packets for receiver? */
>> +       u8 persistent_grant:1;
>>
>>          /*
>>           * Allow xenvif_start_xmit() to peek ahead in the rx request
>> @@ -98,6 +110,9 @@ struct xenvif {
>>          struct net_device *dev;
>>
>>          wait_queue_head_t waiting_to_free;
>> +
>> +       struct persistent_entry *persistent_gnt[MAXIMUM_OUTSTANDING_BLOCK_REQS];
> What is the per-vif memory overhead of this array?
In this patch,
The maximum of memory overhead is about

(XEN_NETIF_TX_RING_SIZE+XEN_NETIF_RX_RING_SIZE)*PAGE_SIZE  (plus size of grant_ref_t and handle)
which is about 512 PAGE_SIZE. Normally, without heavy network offload, this maximum can not be reached.

In next patch of splitting tx/rx pool, the maximum is about (256+512)PAGE_SIZE.

>
>> +static struct persistent_entry*
>> +get_per_gnt(struct persistent_entry **pers_entry,
>> +           unsigned int count, grant_ref_t gref)
>> +{
>> +       int i;
>> +
>> +       for (i = 0; i<  count; i++)
>> +               if (gref == pers_entry[i]->forgranted)
>> +                       return pers_entry[i];
> Isn't this linear scan rather expensive? I think Roger implemented some
> sort of hash lookup for blkback which I think is required here too (and
> should be easy if you make that code common).

Agree, thanks.

>
>> +
>> +       return NULL;
>> +}
>> +
>> @@ -1338,7 +1497,11 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
>>                  gop->source.domid = vif->domid;
>>                  gop->source.offset = txreq.offset;
>>
>> -               gop->dest.u.gmfn = virt_to_mfn(page_address(page));
>> +               if (!vif->persistent_grant)
>> +                       gop->dest.u.gmfn = virt_to_mfn(page_address(page));
>> +               else
>> +                       gop->dest.u.gmfn = (unsigned long)page_address(page);
> page_address doesn't return any sort of frame number, does it? This is
> rather confusing...

Yes. I only use dest.u.gmfn element to save the page_address here for 
future memcpy, and it does not mean to use frame number actually. To 
avoid confusion, here I can use

gop->dest.u.gmfn = virt_to_mfn(page_address(page));

and then call mfn_to_virt when doing memcpy.


>
>> @@ -453,7 +460,12 @@ static int connect_rings(struct backend_info *be)
>>                  val = 0;
>>          vif->csum = !val;
>>
>> -       /* Map the shared frame, irq etc. */
>> +       if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-persistent-grants",
>> +                        "%u",&val)<  0)
>> +               val = 0;
>> +       vif->persistent_grant = !!val;
>> +
>> +/* Map the shared frame, irq etc. */
> Please run the patches through checkpatch.pl

Yes, I run checkpatch.pl before posting them. The only warning exists in 
initial code netfront.c, it is a printk code in xennet_tx_buf_gc, I did 
not fix that.

Thanks
Annie
>
>>          err = xenvif_connect(vif, tx_ring_ref, rx_ring_ref, evtchn);
>>          if (err) {
>>                  xenbus_dev_fatal(dev, err,
>> --
>> 1.7.3.4
>>
>
