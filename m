From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 4/8] enic: alloc/free rx_cpu_rmap
Date: Tue, 10 Jun 2014 19:00:35 +0400
Message-ID: <53971D93.7070508@cogentembedded.com>
References: <1402338773-5996-1-git-send-email-_govind@gmx.com> <1402338773-5996-5-git-send-email-_govind@gmx.com> <539600A8.3010703@cogentembedded.com> <alpine.LNX.2.03.1406101900400.2499@ws.cisco>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ssujith@cisco.com,
	gvaradar@cisco.com, benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:50430 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbaFJPAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 11:00:35 -0400
Received: by mail-lb0-f178.google.com with SMTP id w7so3980631lbi.37
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 08:00:34 -0700 (PDT)
In-Reply-To: <alpine.LNX.2.03.1406101900400.2499@ws.cisco>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/10/2014 05:52 PM, Govindarajulu Varadarajan wrote:

> >> @@ -1192,6 +1195,33 @@ static void enic_calc_int_moderation(struct enic
>>> *enic, struct vnic_rq *rq)
>>>       pkt_size_counter->small_pkt_bytes_cnt = 0;
>>>   }
>>>
>>> +#ifdef CONFIG_RFS_ACCEL
>>> +static void enic_free_rx_cpu_rmap(struct enic *enic)
>>> +{
>>> +    free_irq_cpu_rmap(enic->netdev->rx_cpu_rmap);
>>> +    enic->netdev->rx_cpu_rmap = NULL;
>>> +}
>>> +
>>> +static inline void enic_set_rx_cpu_rmap(struct enic *enic)

>>   No need to use *inline* in a .c file, the compiler should figure it out.

> Yes, I agree.

>>> +{
>>> +    int i, res;
>>> +
>>> +    if (vnic_dev_get_intr_mode(enic->vdev) == VNIC_DEV_INTR_MODE_MSIX) {
>>> +        enic->netdev->rx_cpu_rmap = alloc_irq_cpu_rmap(enic->rq_count);
>>> +        if (unlikely(!enic->netdev->rx_cpu_rmap))
>>> +            return;
>>> +        for (i = 0; i < enic->rq_count; i++) {
>>> +            res = irq_cpu_rmap_add(enic->netdev->rx_cpu_rmap,
>>> +                           enic->msix_entry[i].vector);
>>> +            if (unlikely(res)) {
>>> +                enic_free_rx_cpu_rmap(enic);
>>> +                return;
>>> +            }
>>> +        }
>>> +    }
>>> +}

>>   It's better to do the following here:

>> #else
>> static void enic_free_rx_cpu_rmap(struct enic *enic)
>> {
>> }
>> static void enic_set_rx_cpu_rmap(struct enic *enic)
>> {
>> }

> How about

> static void enic_free_rx_cpu_rmap(struct enic *enic)
> {
> #ifdef CONFIG_RFS_ACCEL
> ...
> ...
> #endif
> }

> I prefer this over yours because, if I use yours tools like cscope finds two
> definitions of function enic_free_rx_cpu_rmap. Which makes code walk through
> little bit difficult.

    #ifdef's in the function bodies are generally frowned upon. See 
Documentation/SubmittingPatches section 2 item (2).

> Thanks
> Govind

>>> +#endif
>>> +
>>>   static int enic_poll_msix(struct napi_struct *napi, int budget)
>>>   {
>>>       struct net_device *netdev = napi->dev;
>>> @@ -1267,6 +1297,9 @@ static void enic_free_intr(struct enic *enic)
>>>       struct net_device *netdev = enic->netdev;
>>>       unsigned int i;
>>>
>>> +#ifdef CONFIG_RFS_ACCEL
>>> +    enic_free_rx_cpu_rmap(enic);
>>> +#endif

>>   ... so that you can avoid #ifdef's at the call sites.

WBR, Sergei
