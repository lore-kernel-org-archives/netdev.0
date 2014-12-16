From: Erik Kline <ek@google.com>
Subject: Re: [PATCH net] net: ipv6: allow explicitly choosing optimistic addresses
Date: Tue, 16 Dec 2014 19:38:17 +0900
Message-ID: <CAAedzxqGhOFJC3DgzgHukr4xOy4YDC_ckoGq9hcLCsSxx2947A@mail.gmail.com>
References: <1418356200-7457-1-git-send-email-ek@google.com> <CAKD1Yr3+S81mKbVdQ-P6byx-e2Hfn8GJz+Jr7SLWrRjkfpD2qA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:57495 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888AbaLPKii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 05:38:38 -0500
Received: by mail-qg0-f45.google.com with SMTP id f51so9894905qge.18
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 02:38:37 -0800 (PST)
In-Reply-To: <CAKD1Yr3+S81mKbVdQ-P6byx-e2Hfn8GJz+Jr7SLWrRjkfpD2qA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2014 at 4:37 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
> On Fri, Dec 12, 2014 at 12:50 PM, Erik Kline <ek@google.com> wrote:
>>
>> @@ -1527,7 +1527,8 @@ int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
>>                 if (!net_eq(dev_net(ifp->idev->dev), net))
>>                         continue;
>>                 if (ipv6_addr_equal(&ifp->addr, addr) &&
>> -                   !(ifp->flags&IFA_F_TENTATIVE) &&
>> +                   (!(ifp->flags&IFA_F_TENTATIVE) ||
>> +                    ifp->flags&IFA_F_OPTIMISTIC) &&
>>                     (dev == NULL || ifp->idev->dev == dev ||
>>                      !(ifp->scope&(IFA_LINK|IFA_HOST) || strict))) {
>>                         rcu_read_unlock_bh();
>
> I looked at the callers of ipv6_chk_addr (lxr finds 19 files); from
> what I saw, this change will make all of them more correct except for
> ndisc_solicit. With this change, ndisc_solicit could now send
> neighbour solicitations from optimistic addresses, which is not
> allowed by the RFC.

True.  I have a version that fixes this, but ended up splitting
ipv6_chk_addr into two:

    - ipv6_chk_addr (same as today), and
    - ipv6_chk_addr_and_flags (which takes a "u32 banned_flags" argument)

The ugliness of this naming is not lost on me.  I briefly tried a
version that reuses the "strict" argument to achieve the same thing,
but that doesn't seem to be quite correct in all cases either.
