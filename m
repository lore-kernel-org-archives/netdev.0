From: Yan Zheng <yanzheng@21cn.com>
Subject: Re: [PATCH 2/2][MCAST] Fix for add_grec(...)
Date: Thu, 10 Nov 2005 09:20:33 +0800
Message-ID: <4372A061.2030106@21cn.com>
References: <OFD5769042.0E81A890-ON882570B4.0075A92B-882570B4.00796FDC@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751376AbVKJBSp@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OFD5769042.0E81A890-ON882570B4.0075A92B-882570B4.00796FDC@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens wrote:
> Yan,
>         I think your patch has some problems.
> 
> Yan Zheng <yanzheng@21cn.com> wrote on 11/09/2005 03:58:20 AM:
> 
> 
>>+#if 0
>>    if (!*psf_list) {
>>       if (type == MLD2_ALLOW_NEW_SOURCES ||
>>           type == MLD2_BLOCK_OLD_SOURCES)
>>@@ -1474,12 +1477,15 @@ static struct sk_buff *add_grec(struct s
>>       }
>>       return skb;
>>    }
>>+#endif
> 
> 
> 
>         This code is the only place in the current code where you
> can generate a group header with an empty source list (what it is
> checking for). Your patch has added an add_grhead() for change
> and EXCLUDE records, but it isn't checking mca_crcount or isquery.
> I need to check, but I'm concerned this will create a group header
> in a report for cases where it should not.
> 
ischange implicits mca_crcount has already been ckecked in mld_send_cr(...)
Actually, check mca_crcount directly will get mode change report sent one times less 
than you intend, because mca_crcount has decreased by one before call add_grec(...).


Now We only have MLD2_MODE_IS_INCLUDE left. but "mode is include and source list is empty"
is an impossible event.
> 
> 
>>    pmr = skb ? (struct mld2_report *)skb->h.raw : NULL;
>>
>>    /* EX and TO_EX get a fresh packet, if needed */
>>-   if (truncate) {
>>-      if (pmr && pmr->ngrec &&
>>-          AVAILABLE(skb) < grec_size(pmc, type, gdeleted, sdeleted)) {
>>+   if (truncate || ischange) {
>>+      int min_len;
>>+      min_len   = truncate ? grec_size(pmc, type, gdeleted, sdeleted) : 
> 
> 
>>+           (sizeof(struct mld2_grec) + sizeof(struct in6_addr));
>>+      if (pmr && pmr->ngrec && AVAILABLE(skb) < min_len) {
>>          if (skb)
>>             mld_sendpack(skb);
>>          skb = mld_newpack(dev, dev->mtu);
> 
> 
>         This "truncate" code is to handle exclude records that may be
> truncated. It gets a new packet when adding this record and the whole
> thing won't fit in a single packet. This is not appropriate for anything
> but IS_EX and TO_EX, but "ischange" in your patch will be true for
> TO_IN. So, I think this will waste space in a report that could hold
> some of these TO_IN sources.

When type is MLD2_MODE_IS_INCLUDE, min_len is equal to "sizeof(struct mld2_grec) + 
sizeof(struct in6_addr)". it satisfies the comment above. (make sure we have room 
for group header and at least one source.)
