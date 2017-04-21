From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: macvlan: Fix device ref leak when purging bc_queue
Date: Fri, 21 Apr 2017 12:23:54 -0700
Message-ID: <CAF2d9jis_NcDO4bfOuf1OxPf_1XvOJQA1eo0OKW5SEk2O-Ny0A@mail.gmail.com>
References: <1492618528011.11322@Dell.com> <20170420125512.GA9113@gondor.apana.org.au>
 <1492704599476.84165@Dell.com> <20170421044029.GA11695@gondor.apana.org.au> <1492785652578.53801@Dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: herbert@gondor.apana.org.au, David Miller <davem@davemloft.net>,
        Clifford.Wichmann@dell.com, linux-netdev <netdev@vger.kernel.org>
To: Joe.Ghalam@dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:34342 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424969AbdDUTYx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:24:53 -0400
Received: by mail-io0-f173.google.com with SMTP id a103so131694819ioj.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:24:53 -0700 (PDT)
In-Reply-To: <1492785652578.53801@Dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 21, 2017 at 7:40 AM,  <Joe.Ghalam@dell.com> wrote:
> That's not true. macvlan_dellink() unregisters the queue, and macvlan_process_broadcast() will never get called. Please note that I'm not speculating. I have traced enabled on the dev_put and dev_hold, and I'm reporting a real, reproducible issue.
> Her is a sequence of calls logged, when the issue happens. macvlan_process_broadcast() never happens.
>
> Apr 19 04:35:39 OS10 kernel: e101-001-0.v257: dev_put 16 dst_destroy
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_hold 15 dev_get_by_index
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 16 do_ip_setsockopt
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_hold 15 dst_alloc
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 16 dst_destroy
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_hold 15 macvlan_broadcast_enqueue
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 16 macvlan_process_broadcast
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_hold 15 macvlan_broadcast_enqueue
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 16 macvlan_process_broadcast
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_hold 15 macvlan_broadcast_enqueue    <---insert
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 16 neigh_destroy
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 15 neigh_destroy
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 14 neigh_destroy
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 13 dst_destroy
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 12 dst_destroy
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 11 __netdev_adjacent_dev_remove <--- macvlan_dellink()
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 10 __netdev_adjacent_dev_remove <--- macvlan_dellink()
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 9 neigh_parms_release
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 8 neigh_parms_release
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 7 in6_dev_finish_destroy
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 6 rx_queue_release
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 5 netdev_queue_release
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 4 rollback_registered_many
> Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 3 free_fib_info_rcu
>
May be the system is busy and snapshot is too small, and eventually
process_broadcast() should get called. Deleting a slave does nothing
about cancelling the work-queue so it would happen eventually.

The change that Herbert proposed is correct. When packets are enqueued
for processing later a dev reference is taken and it's removed when
it's processed when it gets scheduled. The backlog is per port so it
makes sense to remove reference(s) before purging the queue prior to
deleting the port.

> ________________________________________
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Sent: Thursday, April 20, 2017 9:40 PM
> To: Ghalam, Joe
> Cc: davem@davemloft.net; Wichmann, Clifford; netdev@vger.kernel.org
> Subject: Re: macvlan: Fix device ref leak when purging bc_queue
>
> On Thu, Apr 20, 2017 at 04:09:56PM +0000, Joe.Ghalam@dell.com wrote:
>> I agree with this change, but the same purge would be needed for the macvlan_dellink() call also.
>
> I don't think that's necessary because as long as the master
> device is still around it will continue to process the broadcast
> queue, thus removing any reference counts held.
>
> It's only when the queue is purged that we run into trouble.
>
> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
