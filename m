From: Wei Liu <liuw@liuw.name>
Subject: Re: [Xen-devel] [PATCH 5/6] xen-netback: coalesce slots before copying
Date: Mon, 25 Mar 2013 15:47:34 +0000
Message-ID: <CAOsiSVUNO0FQkfJWjv9bcoMgKNnHu4XYciz61hG3YNFzZNxK3w@mail.gmail.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
 <1364209702-12437-6-git-send-email-wei.liu2@citrix.com> <5150699C.6080209@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:44541 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758200Ab3CYPsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 11:48:06 -0400
Received: by mail-wi0-f175.google.com with SMTP id c10so4992254wiw.14
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 08:48:04 -0700 (PDT)
In-Reply-To: <5150699C.6080209@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 25, 2013 at 3:13 PM, David Vrabel <david.vrabel@citrix.com> wrote:
> On 25/03/13 11:08, Wei Liu wrote:
>> This patch tries to coalesce tx requests when constructing grant copy
>> structures. It enables netback to deal with situation when frontend's
>> MAX_SKB_FRAGS is larger than backend's MAX_SKB_FRAGS.
>>
>> It defines max_skb_slots, which is a estimation of the maximum number of slots
>> a guest can send, anything bigger than that is considered malicious. Now it is
>> set to 20, which should be enough to accommodate Linux (16 to 19).
>
> This maximum needs to be defined as part of the protocol and added to
> the interface header.
>

No, this is not part of the protocol and not a hard limit. It is
configurable by system administrator.

>> Also change variable name from "frags" to "slots" in netbk_count_requests.
>
> I think this renaming should have been done as a separate patch.
>

The frag -> slot thing only make sense after this patch. If I do this,
I will need to partially reverted what I've done in a previous patch
(like the frag -> slot in comment below you pointed out). :-(

>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -47,11 +47,26 @@
>>  #include <asm/xen/hypercall.h>
>>  #include <asm/xen/page.h>
>>
>> +/*
>> + * This is an estimation of the maximum possible frags a SKB might
>> + * have, anything larger than this is considered malicious. Typically
>> + * Linux has 16 to 19.
>> + */
>
> Do you mean "max possible /slots/" a packet might have?
>

Yes.

>> @@ -968,48 +987,114 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
> [...]
>> +                             /* Poison these fields, corresponding
>> +                              * fields for head tx req will be set
>> +                              * to correct values after the loop.
>> +                              */
>> +                             netbk->mmap_pages[pending_idx] = (void *)(~0UL);
>> +                             pending_tx_info[pending_idx].head =
>> +                                     INVALID_PENDING_RING_IDX;
>
> Do you need to poison both values?
>

Just for safety. I have BUG_ON in the release path to check for possible error.

>> +
>> +                             if (unlikely(!first)) {
>
> This isn't unlikely is it?
>

For big packet the chance is 1 in max_skb_slots, so 5% (1/20) in default case.

>> +                                     first = &pending_tx_info[pending_idx];
>> +                                     start_idx = index;
>> +                                     head_idx = pending_idx;
>> +                             }
>
> Instead of setting first here why not move the code below here?
>

Because first->req.size needs to be set to dst_offset, it has to be
here anyway. So I put other fields here as well.

>> +             first->req.offset = 0;
>> +             first->req.size = dst_offset;
>> +             first->head = start_idx;
>> +             set_page_ext(page, netbk, head_idx);
>> +             netbk->mmap_pages[head_idx] = page;
>> +             frag_set_pending_idx(&frags[shinfo->nr_frags], head_idx);
>
>> @@ -1548,13 +1649,34 @@ static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx,
> [...]
>> +             /* Setting any number other than
>> +              * INVALID_PENDING_RING_IDX indicates this slot is
>> +              * starting a new packet / ending a previous packet.
>> +              */
>> +             pending_tx_info->head = 0;
>
> This doesn't look needed.  It will be initialized again when reusing t
> his pending_tx_info again, right?
>

Yes, it is needed. Otherwise netback responses to invalid tx_info and
cause netfront to crash before coming into the re-initialization path.


Wei.
