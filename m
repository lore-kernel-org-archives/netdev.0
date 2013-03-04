From: Andrew Cooper <andrew.cooper3@citrix.com>
Subject: Re: [Xen-devel] [PATCH 2/8] netback: add module unload function
Date: Mon, 4 Mar 2013 20:58:17 +0000
Message-ID: <51350AE9.5000400@citrix.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com> <1360944010-15336-3-git-send-email-wei.liu2@citrix.com> <20130304205530.GC16762@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:49861 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932218Ab3CDU6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 15:58:19 -0500
In-Reply-To: <20130304205530.GC16762@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/03/13 20:55, Konrad Rzeszutek Wilk wrote:
> On Fri, Feb 15, 2013 at 04:00:03PM +0000, Wei Liu wrote:
>> Enable users to unload netback module. Users should make sure there is not vif
>> runnig.
> 'sure there are no vif's running.'

If we are picking at grammar, no apostrophe in 'vifs'

~Andrew

>
> Any way of making this VIF part be automatic? Meaning that netback
> can figure out if there are VIFs running and if so don't unload
> all of the parts and just mention that you are leaking memory.
>
> This looks quite dangerous - meaning if there are guests running and
> we for fun do 'rmmod xen_netback' it looks like we could crash dom0?
>
>> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
>> ---
>>  drivers/net/xen-netback/common.h  |    1 +
>>  drivers/net/xen-netback/netback.c |   18 ++++++++++++++++++
>>  drivers/net/xen-netback/xenbus.c  |    5 +++++
>>  3 files changed, 24 insertions(+)
>>
>> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
>> index 9d7f172..35d8772 100644
>> --- a/drivers/net/xen-netback/common.h
>> +++ b/drivers/net/xen-netback/common.h
>> @@ -120,6 +120,7 @@ void xenvif_get(struct xenvif *vif);
>>  void xenvif_put(struct xenvif *vif);
>>  
>>  int xenvif_xenbus_init(void);
>> +void xenvif_xenbus_exit(void);
>>  
>>  int xenvif_schedulable(struct xenvif *vif);
>>  
>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
>> index db8d45a..de59098 100644
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -1761,5 +1761,23 @@ failed_init:
>>  
>>  module_init(netback_init);
>>  
>> +static void __exit netback_exit(void)
>> +{
>> +	int group, i;
>> +	xenvif_xenbus_exit();
> You should check the return code of this function.
>
>> +	for (group = 0; group < xen_netbk_group_nr; group++) {
>> +		struct xen_netbk *netbk = &xen_netbk[group];
>> +		for (i = 0; i < MAX_PENDING_REQS; i++) {
>> +			if (netbk->mmap_pages[i])
>> +				__free_page(netbk->mmap_pages[i]);
>> +		}
>> +		del_timer_sync(&netbk->net_timer);
>> +		kthread_stop(netbk->task);
>> +	}
>> +	vfree(xen_netbk);
>> +}
>> +
>> +module_exit(netback_exit);
>> +
>>  MODULE_LICENSE("Dual BSD/GPL");
>>  MODULE_ALIAS("xen-backend:vif");
>> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
>> index 410018c..65d14f2 100644
>> --- a/drivers/net/xen-netback/xenbus.c
>> +++ b/drivers/net/xen-netback/xenbus.c
>> @@ -485,3 +485,8 @@ int xenvif_xenbus_init(void)
>>  {
>>  	return xenbus_register_backend(&netback_driver);
>>  }
>> +
>> +void xenvif_xenbus_exit(void)
>> +{
>> +	return xenbus_unregister_driver(&netback_driver);
>> +}
>> -- 
>> 1.7.10.4
>>
>>
>> _______________________________________________
>> Xen-devel mailing list
>> Xen-devel@lists.xen.org
>> http://lists.xen.org/xen-devel
>>
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
