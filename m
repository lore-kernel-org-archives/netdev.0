From: Felix Radensky <felix@allot.com>
Subject: Re: [PATCH]sk98lin ethtool support
Date: Tue, 30 Dec 2003 14:29:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FF16FC3.4000004@allot.com>
References: <1072779867.3632.38.camel@l5ac210.l5.laser5.co.jp>
 <3FF16F18.7060303@pro-linux.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: krishnakumar@naturesoft.net, mlindner@syskonnect.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-reply-to: <3FF16F18.7060303@pro-linux.de>
To: Mirko Lindner <demon@pro-linux.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks, Krishna and Mirco. That would be a great addition to the driver.

I think having most driver info available via ethtool is a very important,
at least for systems with multiple different NICs, as this allows 
information
gathering via single, consistent interface.

Felix.

Mirko Lindner wrote:

> Thanks. I'll complete the support as soon I'm back in the office. All 
> driver statistics are also available in the the proc system under 
> /proc/net/sk98lin/
>
> Mirko
>
>
> Krishnakumar. R wrote:
>
>> Hi,
>>
>> The following patch introduces the ethtool support for the sk98lin
>> driver. Only 4 operations are supported
>> for now.
>>
>> The patch is against vanilla 2.6.0.
>>
>> As I dont have the hardware with me,
>> I could do only compilation test.
>> It compiles fine as inbuilt into the kernel.
>>
>> If you find this okay,
>> please consider it for the inclusion in the mainline driver source. 
>> (Enquiries were there for this feature,
>>  Felix's mail to netdev.)
>>
>> Regards,
>> KK.
>>
>> Diffstat output
>> ---------------
>> h/skdrv1st.h |    1 +
>> skge.c       |   57
>> ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>> 2 files changed, 57 insertions(+), 1 deletion(-)
>>
>> The patch
>> ---------
>>
>> --- linux-2.6.0/drivers/net/sk98lin/h/skdrv1st.orig.h    2003-12-30
>> 12:07:26.000000000 +0900
>> +++ linux-2.6.0/drivers/net/sk98lin/h/skdrv1st.h    2003-12-30
>> 12:08:23.000000000 +0900
>> @@ -143,6 +143,7 @@
>>  #include <linux/slab.h>
>>  #include <linux/interrupt.h>
>>  #include <linux/pci.h>
>> +#include <linux/ethtool.h>
>>  #include <asm/byteorder.h>
>>  #include <asm/bitops.h>
>>  #include <asm/io.h>
>> --- linux-2.6.0/drivers/net/sk98lin/skge.orig.c    2003-12-30
>> 12:04:25.000000000 +0900
>> +++ linux-2.6.0/drivers/net/sk98lin/skge.c    2003-12-30 
>> 13:11:17.000000000
>> +0900
>> @@ -415,6 +415,7 @@
>>   *        <linux/slab.h>
>>   *        <linux/interrupt.h>
>>   *        <linux/pci.h>
>> + *        <linux/ethtool.h>
>>   *        <asm/byteorder.h>
>>   *        <asm/bitops.h>
>>   *        <asm/io.h>
>> @@ -567,6 +568,8 @@
>>  static void    StartDrvCleanupTimer(SK_AC *pAC);
>>  static void    StopDrvCleanupTimer(SK_AC *pAC);
>>  static int    XmitFrameSG(SK_AC*, TX_PORT*, struct sk_buff*);
>> +static void    SkGetDrvInfo (struct SK_NET_DEVICE *dev, struct
>> ethtool_drvinfo *info);
>> +static SK_U32    SkGetRxCsum(struct SK_NET_DEVICE *dev);
>>  
>>
>> /******************************************************************************* 
>>
>>   *
>> @@ -599,7 +602,12 @@
>>  /* local variables
>> **********************************************************/
>>  static uintptr_t TxQueueAddr[SK_MAX_MACS][2] = {{0x680, 0x600},{0x780,
>> 0x700}};
>>  static uintptr_t RxQueueAddr[SK_MAX_MACS] = {0x400, 0x480};
>> -
>> +static struct ethtool_ops SKEthtoolOps = {
>> +    .get_drvinfo        = SkGetDrvInfo,   
>> +    .get_rx_csum        = SkGetRxCsum,
>> +    .get_tx_csum        = ethtool_op_get_tx_csum,
>> +    .get_sg             = ethtool_op_get_sg,
>> +};
>>  
>>
>> /***************************************************************************** 
>>
>>   *
>> @@ -704,6 +712,7 @@
>>          dev->set_mac_address =    &SkGeSetMacAddr;
>>          dev->do_ioctl =        &SkGeIoctl;
>>          dev->change_mtu =    &SkGeChangeMtu;
>> +        dev->ethtool_ops =     &SKEthtoolOps;
>>          dev->flags &=         ~IFF_RUNNING;
>>  
>>  #ifdef SK_ZEROCOPY
>> @@ -948,6 +957,52 @@
>>     
>>  } /* FreeResources */
>>  
>> +
>> +/***************************************************************************** 
>>
>> + *
>> + *     SkGetDrvInfo - Get the information about the driver (ethtool).
>> + *
>> + * Description:
>> + *    This function would give the driver name, version, bus info and
>> register
>> + *    length to the ethtool query.
>> + *
>> + * Returns: N/A
>> + *   
>> + */
>> +static void SkGetDrvInfo(struct SK_NET_DEVICE *dev, struct
>> ethtool_drvinfo *info)
>> +{
>> +DEV_NET *pNet;
>> +SK_AC *pAC;
>> +
>> +    pNet = (DEV_NET *) dev->priv;
>> +    pAC = pNet->pAC;
>> +    strcpy (info->driver, pAC->Name);
>> +    strcpy (info->version, pAC->Pnmi.pDriverVersion);
>> +    strcpy (info->bus_info, pci_name(pAC->PciDev));
>> +} /* SkGetDrvInfo */
>> +
>> +
>> +
>> +/***************************************************************************** 
>>
>> + *
>> + *     SkGetRxCsum - Get whether RX Check sum support is there or not.
>> + *
>> + * Description:
>> + *    This function would give whether the driver has rx check sum 
>> feature
>> + *    supported or not.
>> + *
>> + * Returns: 1 if Rx Check sum is supported.
>> + *        0 if Rx Check sum is not supported.       
>> + */   
>> +static SK_U32     SkGetRxCsum(struct SK_NET_DEVICE *dev)
>> +{
>> +#ifdef USE_SK_RX_CHECK   
>> +    return 1;
>> +#else +    return 0;
>> +#endif
>> +} /* SkGetRxCsum */
>> +
>>  MODULE_AUTHOR("Mirko Lindner <mlindner@syskonnect.de>");
>>  MODULE_DESCRIPTION("SysKonnect SK-NET Gigabit Ethernet SK-98xx
>> driver");
>>  MODULE_LICENSE("GPL");
>>
>>
>
