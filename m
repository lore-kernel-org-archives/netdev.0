From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net] tg3: prevent ifup/ifdown during PCI error recovery
Date: Mon, 01 Sep 2014 14:22:22 +0200
Message-ID: <540464FE.3090803@redhat.com>
References: <1409144492-22790-1-git-send-email-ivecera@redhat.com> <53FFBB2E.7010609@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>
To: Prashant <prashant@broadcom.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14269 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752974AbaIAMVq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Sep 2014 08:21:46 -0400
In-Reply-To: <53FFBB2E.7010609@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.8.2014 01:28, Prashant wrote:
> Ivan, thanks for the patch. Minor comments.
>
>>
>> diff --git a/drivers/net/ethernet/broadcom/tg3.c
>> b/drivers/net/ethernet/broadcom/tg3.c
>> index 3ac5d23..8d9c774 100644
>> --- a/drivers/net/ethernet/broadcom/tg3.c
>> +++ b/drivers/net/ethernet/broadcom/tg3.c
>> @@ -11617,6 +11617,9 @@ static int tg3_open(struct net_device *dev)
>>       struct tg3 *tp = netdev_priv(dev);
>>       int err;
>>
>> +    if (tp->pcierr_recovery)
>> +        return -EAGAIN;
>> +
>
> Can have a netdev_err message here indicating the pcie error recovery
> that is taking place before returning.
Sure, done. V2 sent.

Ivan
>
>>       if (tp->fw_needed) {
>>           err = tg3_request_firmware(tp);
>>           if (tg3_asic_rev(tp) == ASIC_REV_57766) {
>> @@ -11674,6 +11677,9 @@ static int tg3_close(struct net_device *dev)
>>   {
>>       struct tg3 *tp = netdev_priv(dev);
>>
>> +    if (tp->pcierr_recovery)
>> +        return -EAGAIN;
>> +
>
> netdev_err message here too.
>
>>       tg3_ptp_fini(tp);
>>
>>       tg3_stop(tp);
>> @@ -17561,6 +17567,7 @@ static int tg3_init_one(struct pci_dev *pdev,
>>       tp->rx_mode = TG3_DEF_RX_MODE;
>>       tp->tx_mode = TG3_DEF_TX_MODE;
>>       tp->irq_sync = 1;
>> +    tp->pcierr_recovery = false;
>>
>>       if (tg3_debug > 0)
>>           tp->msg_enable = tg3_debug;
>> @@ -18071,6 +18078,8 @@ static pci_ers_result_t
>> tg3_io_error_detected(struct pci_dev *pdev,
>>
>>       rtnl_lock();
>>
>> +    tp->pcierr_recovery = true;
>> +
>>       /* We probably don't have netdev yet */
>>       if (!netdev || !netif_running(netdev))
>>           goto done;
>> @@ -18195,6 +18204,7 @@ static void tg3_io_resume(struct pci_dev *pdev)
>>       tg3_phy_start(tp);
>>
>>   done:
>> +    tp->pcierr_recovery = false;
>>       rtnl_unlock();
>>   }
>>
>> diff --git a/drivers/net/ethernet/broadcom/tg3.h
>> b/drivers/net/ethernet/broadcom/tg3.h
>> index 461acca..31c9f82 100644
>> --- a/drivers/net/ethernet/broadcom/tg3.h
>> +++ b/drivers/net/ethernet/broadcom/tg3.h
>> @@ -3407,6 +3407,7 @@ struct tg3 {
>>
>>       struct device            *hwmon_dev;
>>       bool                link_up;
>> +    bool                pcierr_recovery;
>>   };
>>
>>   /* Accessor macros for chip and asic attributes
>>
