From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PATCH] net: Cache align dst refcnt
Date: Tue, 17 Dec 2013 10:29:11 -0800
Message-ID: <1387304951.19078.282.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1312171013050.5720@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f44.google.com ([209.85.216.44]:42220 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932176Ab3LQS3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 13:29:16 -0500
Received: by mail-qa0-f44.google.com with SMTP id i13so2917883qae.10
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 10:29:15 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1312171013050.5720@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-17 at 10:15 -0800, Tom Herbert wrote:
> ipv4_dst_check is coming up very high in perf top for TCP_RR tests and
> it really is not doing much interesting. Looks like we have false
> sharing with dst->refcnt. This patch cache aligns refcnt. There were
> already some comments in the code that refcnt needs to be cache aligned.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/net/dst.h | 11 +++--------
>  1 file changed, 3 insertions(+), 8 deletions(-)

This is not needed. I wonder how you tested this.

Problem was solved in commit 5635c10d976716
("net: make sure struct dst_entry refcount is aligned on 64 bytes")

If this BUILD_BUG_ON() doesn't work for you, we should investigate !

static inline void dst_hold(struct dst_entry *dst)
{
        /*
         * If your kernel compilation stops here, please check
         * __pad_to_align_refcnt declaration in struct dst_entry
         */
        BUILD_BUG_ON(offsetof(struct dst_entry, __refcnt) & 63);
        atomic_inc(&dst->__refcnt);
}

Thanks
