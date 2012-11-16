From: ANNIE LI <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH 1/4] xen/netback: implements persistent grant
 with one page pool.
Date: Fri, 16 Nov 2012 17:55:41 +0800
Message-ID: <50A60D9D.80601@oracle.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>  <1352963066-570-1-git-send-email-annie.li@oracle.com>  <1352970612.3499.43.camel@zakaz.uk.xensource.com>  <50A5A285.1030805@oracle.com> <1353058074.3499.166.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27442 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600Ab2KPJzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 04:55:50 -0500
In-Reply-To: <1353058074.3499.166.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012-11-16 17:27, Ian Campbell wrote:
> On Fri, 2012-11-16 at 02:18 +0000, ANNIE LI wrote:
>> In this patch,
>> The maximum of memory overhead is about
>>
>> (XEN_NETIF_TX_RING_SIZE+XEN_NETIF_RX_RING_SIZE)*PAGE_SIZE  (plus size of grant_ref_t and handle)
>> which is about 512 PAGE_SIZE. Normally, without heavy network offload, this maximum can not be reached.
>>
>> In next patch of splitting tx/rx pool, the maximum is about
> "about" or just "is"?

For only grant pages, it is this value. I took into account other 
element of grant_ref_t and map(change to handle in future)....

>
>>   (256+512)PAGE_SIZE.
> IOW 3MB.
>
>>>> +
>>>> +       return NULL;
>>>> +}
>>>> +
>>>> @@ -1338,7 +1497,11 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
>>>>                   gop->source.domid = vif->domid;
>>>>                   gop->source.offset = txreq.offset;
>>>>
>>>> -               gop->dest.u.gmfn = virt_to_mfn(page_address(page));
>>>> +               if (!vif->persistent_grant)
>>>> +                       gop->dest.u.gmfn = virt_to_mfn(page_address(page));
>>>> +               else
>>>> +                       gop->dest.u.gmfn = (unsigned long)page_address(page);
>>> page_address doesn't return any sort of frame number, does it? This is
>>> rather confusing...
>> Yes. I only use dest.u.gmfn element to save the page_address here for
>> future memcpy, and it does not mean to use frame number actually. To
>> avoid confusion, here I can use
>>
>> gop->dest.u.gmfn = virt_to_mfn(page_address(page));
>>
>> and then call mfn_to_virt when doing memcpy.
> It seems a bit odd to be using the gop structure in this way when you
> aren't actually doing a grant op on it.
>
> While investigating I noticed:
> +static int
> +grant_memory_copy_op(unsigned int cmd, void *vuop, unsigned int count,
> +                    struct xen_netbk *netbk, bool tx_pool)
> ...
> +       struct gnttab_copy *uop = vuop;
>
> Why void *vuop? Why not struct gnttab_copy * in the parameter?

Sorry, my mistake.

>
> I also noticed your new grant_memory_copy_op() seems to have unbatched
> the grant ops in the non-persistent case, which is going to suck for
> performance in non-persistent mode. You need to pull the conditional and
> the HYPERVISOR_grant_table_op outside the loop and pass it full array
> instead of doing them one at a time.

This still connects with netback per-VIF implementation.
Currently, these could not be pulled out outside since netback queue may 
contains persistent and nonpersistent in the same queue. I did consider 
to implement per-VIF first and then the persistent grant,
but thinking of it is part of wei's patch combined with other patches, 
and finally decided to implement per-VIF later.

But this does limit implementation of persistent grant.

Thanks
Annie
>
> Ian
>
