From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: reset owner sk for data chunks on out queues
 when migrating a sock
Date: Sun, 29 Oct 2017 12:07:44 +0900 (KST)
Message-ID: <20171029.120744.1870385633519634914.davem@davemloft.net>
References: <38df739211708b6a1e983809f7e17539111718c7.1509128009.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com, dvyukov@google.com, chunwang@redhat.com,
        syzkaller@googlegroups.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43972 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751524AbdJ2DHv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 23:07:51 -0400
In-Reply-To: <38df739211708b6a1e983809f7e17539111718c7.1509128009.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 28 Oct 2017 02:13:29 +0800

> Now when migrating sock to another one in sctp_sock_migrate(), it only
> resets owner sk for the data in receive queues, not the chunks on out
> queues.
> 
> It would cause that data chunks length on the sock is not consistent
> with sk sk_wmem_alloc. When closing the sock or freeing these chunks,
> the old sk would never be freed, and the new sock may crash due to
> the overflow sk_wmem_alloc.
> 
> syzbot found this issue with this series:
> 
>   r0 = socket$inet_sctp()
>   sendto$inet(r0)
>   listen(r0)
>   accept4(r0)
>   close(r0)
> 
> Although listen() should have returned error when one TCP-style socket
> is in connecting (I may fix this one in another patch), it could also
> be reproduced by peeling off an assoc.
> 
> This issue is there since very beginning.
> 
> This patch is to reset owner sk for the chunks on out queues so that
> sk sk_wmem_alloc has correct value after accept one sock or peeloff
> an assoc to one sock.
> 
> Note that when resetting owner sk for chunks on outqueue, it has to
> sctp_clear_owner_w/skb_orphan chunks before changing assoc->base.sk
> first and then sctp_set_owner_w them after changing assoc->base.sk,
> due to that sctp_wfree and it's callees are using assoc->base.sk.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable, thank you.
