From: Rakesh Ranjan <rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 3/3] cxgb4i_v3: iscsi and libcxgbi library for handling
 common part
Date: Thu, 27 May 2010 11:35:25 +0530
Message-ID: <4BFE0BA5.70809@chelsio.com>
References: <1273944249-311-1-git-send-email-rakesh@chelsio.com> <1273944249-311-2-git-send-email-rakesh@chelsio.com> <1273944249-311-3-git-send-email-rakesh@chelsio.com> <1273944249-311-4-git-send-email-rakesh@chelsio.com> <4BFE0A3E.9020804@cs.wisc.edu>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
        NETDEVML <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        SCSIDEVML <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>,
        Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Return-path: <open-iscsi+bncCKnrzee6GxC6mfjfBBoEhX8oVw-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <4BFE0A3E.9020804-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post?hl=en_US>,
	<mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/?hl=en_US>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi?hl=en_US>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
	<mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
	<mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

On 05/27/2010 11:29 AM, Mike Christie wrote:
> On 05/15/2010 12:24 PM, Rakesh Ranjan wrote:
>> From: Rakesh Ranjan<rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
>>
>>
>> Signed-off-by: Rakesh Ranjan<rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
>> ---
>>   drivers/scsi/cxgb4i/cxgb4i_iscsi.c |  617
>> ++++++++++++++++++++++++++++++++++++
>>   drivers/scsi/cxgb4i/libcxgbi.c     |  589
>> ++++++++++++++++++++++++++++++++++
>>   drivers/scsi/cxgb4i/libcxgbi.h     |  430 +++++++++++++++++++++++++
> 
> I think the patch had some whitespace/newline issues. When I did git-am
> I got:
> 
> warning: squelched 1 whitespace error
> warning: 6 lines add whitespace errors.
> 
> I think James can just fix up when he merges with git, but in the future
> you might want to try a git-am on your patch before you send (git-am
> --whitespace=fix will fix it up for you).
> 
> 
> 
>> +
>> +int cxgbi_pdu_init(struct cxgbi_device *cdev)
>> +{
>> +    if (cdev->skb_tx_headroom>  (512 * MAX_SKB_FRAGS))
>> +        cdev->skb_extra_headroom = cdev->skb_tx_headroom;
>> +    cdev->pad_page = alloc_page(GFP_KERNEL);
>> +    if (cdev->pad_page)
>> +        return -ENOMEM;
>> +    memset(page_address(cdev->pad_page), 0, PAGE_SIZE);
>> +    return 0;
>> +
>> +    /*
>> +    if (SKB_TX_HEADROOM>  (512 * MAX_SKB_FRAGS))
>> +        skb_extra_headroom = SKB_TX_HEADROOM;
>> +    pad_page = alloc_page(GFP_KERNEL);
>> +    if (!pad_page)
>> +        return -ENOMEM;
>> +    memset(page_address(pad_page), 0, PAGE_SIZE);
>> +    return 0;*/
> 
> Clean this up.
> 
>> +
>> +void cxgbi_release_itt(struct iscsi_task *task, itt_t hdr_itt)
>> +{
>> +    struct scsi_cmnd *sc = task->sc;
>> +    struct iscsi_tcp_conn *tcp_conn = task->conn->dd_data;
>> +    struct cxgbi_conn *cconn = tcp_conn->dd_data;
>> +    struct cxgbi_device *cdev = cconn->chba->cdev;
>> +    struct cxgbi_tag_format *tformat =&cdev->tag_format;
>> +    u32 tag = ntohl((__force u32)hdr_itt);
>> +
>> +    cxgbi_tag_debug("release tag 0x%x.\n", tag);
>> +
>> +    if (sc&&
>> +        (scsi_bidi_cmnd(sc) ||
>> +         sc->sc_data_direction == DMA_FROM_DEVICE)&&
>> +            cxgbi_is_ddp_tag(tformat, tag))
> 
> The formatting is a little weird. I think you want each line to start in
> the same column instead of each getting tabbed over.
> 
> 
>> +
>> +
>> +int cxgbi_reserve_itt(struct iscsi_task *task, itt_t *hdr_itt)
>> +{
>> +    struct scsi_cmnd *sc = task->sc;
>> +    struct iscsi_conn *conn = task->conn;
>> +    struct iscsi_session *sess = conn->session;
>> +    struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
>> +    struct cxgbi_conn *cconn = tcp_conn->dd_data;
>> +    struct cxgbi_device *cdev = cconn->chba->cdev;
>> +    struct cxgbi_tag_format *tformat =&cdev->tag_format;
>> +    u32 sw_tag = (sess->age<<  cconn->task_idx_bits) | task->itt;
>> +    u32 tag;
>> +    int err = -EINVAL;
>> +
>> +    if (sc&&
>> +        (scsi_bidi_cmnd(sc) ||
>> +         sc->sc_data_direction == DMA_FROM_DEVICE)&&
>> +            cxgbi_sw_tag_usable(tformat, sw_tag)) {
> 
> 
> Same tabbing.
> 
> 
>> +    volatile unsigned int state;
> 
> I did not get why this needed to be volatile (I see it is like this in
> cxgb3i and I did not see why in there too).
> 
> 
> 
>> +
>> +static inline void cxgbi_sock_hold(struct cxgbi_sock *csk)
>> +{
>> +    atomic_inc(&csk->refcnt);
> 
> 
> We want people to use krefs instead of their own refcounting now.
> 
>> +
>> +static inline void *cplhdr(struct sk_buff *skb)
>> +{
>> +    return skb->data;
>> +}
> 
> 
> Seems kinda useless.

Hi Mike,

Thanks for the review, will send you the updated patch.

Regards
Rakesh Ranjan

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJL/guKAAoJEBqoHbxtDU4JFvQP/2uIWFmZo4nqcJ7xmEiBjnaq
BeUfjbRGaiAImEM/6OuMIB/Fm9p9NGtW0GsZdqKYSdZBmgO1kWNT1onCZgVF4eW1
Muikjo+I2wXGsWIt4ZqbZs722COC1oQHXpyulfh/6ONzeWJ3R8vos/TnCw256Wxj
HL42jIO882JCImzmP/wmdPmDlTUI/Z0UEYbu0djy20yzESo2NDHq1PYYopyXIboH
joJ/sZvK0jRYrRsDdq84XJ8CUv1yDE8m3NiMV8cV9JN1EwP/gzBrq0DXfFgpdEDU
+4/pfzzxJ5y/ekdZaSZdx9ke/n/vmamJCaQONaL2WfQaznogxqZypaoM/NRzfMlH
40KY5lqajGRnm0aEBffn8uqBzEbopYpb1m+3mzt/vDtvdBRuSJqmcPbUandTNHLe
cZQnn689GtWqJfoyVF/dfyubtAZFLu8VVZkFxx1e3UDEqVDUuwVEHXoXSt6K/SkB
UnZI7hMUYSof+WI+UEV8DR4KMsRbE1cnvXGnsXTZOMhMsU3KoMielaGTgepAbxT7
bLfaARiMwvU+vle5546uK8IuxjGH81nbUEy6R86OeS6Osv6PZFiGYP9yxjzkp4K7
NWOTnVV9qTaPPTtN9SORINPXUXuI90JgIDbh9qnfDDKl2oj5HmwBpa7S3KmMxxlI
eoAqa/9LLjrMVi5Wicv3
=TOBq
-----END PGP SIGNATURE-----

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To unsubscribe from this group, send email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi?hl=en.
