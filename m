From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: fix a dst leak in tunnels
Date: Thu, 16 Jan 2014 17:29:02 -0800
Message-ID: <1389922142.31367.445.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389919279.31367.439.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140116.171303.2113967209121208034.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, maze@google.com,
	cwang@twopensource.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:55099 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbaAQB3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 20:29:06 -0500
Received: by mail-yk0-f172.google.com with SMTP id 200so349668ykr.3
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 17:29:05 -0800 (PST)
In-Reply-To: <20140116.171303.2113967209121208034.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-16 at 17:13 -0800, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 16 Jan 2014 16:41:19 -0800
> 
> > This patch :
> > 
> > 1) Remove a dst leak if DST_NOCACHE was set on dst
> >    Fix this by holding a reference only if dst really cached.
> 
> Can you explain this problem a little bit more?
> 
> Why do we have to handle DST_NOCACHE specially?  We hold a reference
> and dst_release() knows what to do with DST_NOCACHE routes.
> 
> Or is it semantically undesirable for tunnels to cache these routes?
> If so, why do we leave sockets caching DST_NOCACHE routes just fine?

Previous code was doing in the callers of __tunnel_dst_set() a
dst_clone(dst)

Then, we were doing in __tunnel_dst_set() :

       if (dst && (dst->flags & DST_NOCACHE))
               dst = NULL;

When setting dst to NULL here, we forgot to release the reference we
took in callers.

After my patch, we instead do the dst_clone(dst) only in the case we are
not clearing dst :

+       if (dst) {
+               if (dst->flags & DST_NOCACHE)
+                       dst = NULL;
+               else
+                       dst_clone(dst);
+       }
