From: Davide Caratti <dcaratti@redhat.com>
Subject: Re: [net-next 1/7] net/sched: Check for null dev_queue on create
 flow
Date: Fri, 27 Oct 2017 12:23:08 +0200
Message-ID: <1509099788.2880.52.camel@redhat.com>
References: <20171026171714.45087-1-jeffrey.t.kirsher@intel.com>
         <20171026171714.45087-2-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Ivan Vecera <ivecera@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48542 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751176AbdJ0KXN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Oct 2017 06:23:13 -0400
In-Reply-To: <20171026171714.45087-2-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-10-26 at 10:17 -0700, Jeff Kirsher wrote:
> From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
> 
> In qdisc_alloc() the dev_queue pointer was used without any checks
> being performed. If qdisc_create() gets a null dev_queue pointer, it
> just passes it along to qdisc_alloc(), leading to a crash. That
> happens if a root qdisc implements select_queue() and returns a null
> dev_queue pointer for an "invalid handle", for example, or if the
> dev_queue associated with the parent qdisc is null.
> 
> This patch is in preparation for the next in this series, where
> select_queue() is being added to mqprio and as it may return a null
> dev_queue.
> 
> Signed-off-by: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
> Tested-by: Henrik Austad <henrik@austad.us>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  net/sched/sch_generic.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)

hello,

I didn't notice this when I posted https://www.spinics.net/lists/netdev/ms
g462986.html , about one hour later, targeting Dave's net tree. I saw
similar issues, but in my setup dev_queue was a valid pointer, and dev was
NULL. This made qdisc_alloc() dereference NULL, when accessing dev->
members in the function body before returning the newly allocated qdisc.

So, in my understanding both tests are necessary, but a (very trivial)
conflict will be generated when these two commits will be eventually
merged together.

I like this suggestion from Ivan:

-- >8 --
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index bf8c81e07c70..6bd1ae993326 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -603,8 +603,14 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
        struct Qdisc *sch;
        unsigned int size = QDISC_ALIGN(sizeof(*sch)) + ops->priv_size;
        int err = -ENOBUFS;
-       struct net_device *dev = dev_queue->dev;
+       struct net_device *dev;
+
+       if (!dev_queue || !dev_queue->dev) {
+               err = !dev_queue ? -EINVAL : -ENOENT;
+               goto errout;
+       }

+       dev = dev_queue->dev;
        p = kzalloc_node(size, GFP_KERNEL,
                         netdev_queue_numa_node_read(dev_queue));

-- 8< --

and I volunteer for sending a v2 of 'net/sched: fix NULL pointer
dereference in qdisc_alloc()' including this, targeting 'net' tree, with
an appropriate tag. WDYT?

regards,
-- 
davide
