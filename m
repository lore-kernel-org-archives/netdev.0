From: Eric Dumazet <edumazet@google.com>
Subject: Re: circular locking dependency splat due to f9eb8aea2a1e
Date: Wed, 8 Jun 2016 13:30:21 -0700
Message-ID: <CANn89iLquP-_fsFrSOUqxtg3YCYNuXgqO+TCYMcxc8foChB8jA@mail.gmail.com>
References: <471b265b-d938-fd3c-7de6-91cc232b4e2b@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:33810 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932233AbcFHUaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 16:30:23 -0400
Received: by mail-yw0-f172.google.com with SMTP id c72so18796365ywb.1
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 13:30:23 -0700 (PDT)
In-Reply-To: <471b265b-d938-fd3c-7de6-91cc232b4e2b@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 8, 2016 at 11:17 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> Getting the below splat with ping in a VRF. git bisect points to:
>
> dsa@kenny:~/kernel-2.git$ git bisect good
> f9eb8aea2a1e12fc2f584d1627deeb957435a801 is the first bad commit
> commit f9eb8aea2a1e12fc2f584d1627deeb957435a801
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Mon Jun 6 09:37:15 2016 -0700
>
>     net_sched: transform qdisc running bit into a seqcount
>
>     Instead of using a single bit (__QDISC___STATE_RUNNING)
>     in sch->__state, use a seqcount.
>
>     This adds lockdep support, but more importantly it will allow us
>     to sample qdisc/class statistics without having to grab qdisc root lock.
>
>     Signed-off-by: Eric Dumazet <edumazet@google.com>
>     Cc: Cong Wang <xiyou.wangcong@gmail.com>
>     Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
>
> [   49.036323] ======================================================
> [   49.038300] [ INFO: possible circular locking dependency detected ]
> [   49.040313] 4.7.0-rc1+ #252 Not tainted
> [   49.041502] -------------------------------------------------------
> [   49.043518] ping/2143 is trying to acquire lock:
> [

It looks VRF was already lacking annotation for busylock then ?

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 1b214ea4619a5838d6478a2835f8e73da85bef78..3c1c414623196f2bd8bf99c1d84563a54b3f6822
100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -635,6 +635,9 @@ static void vrf_dev_uninit(struct net_device *dev)
        dev->dstats = NULL;
 }

+static struct lock_class_key vrf_tx_busylock;
+static struct lock_class_key vrf_qdisc_running_key;
+
 static int vrf_dev_init(struct net_device *dev)
 {
        struct net_vrf *vrf = netdev_priv(dev);
@@ -658,6 +661,8 @@ static int vrf_dev_init(struct net_device *dev)
        /* similarly, oper state is irrelevant; set to up to avoid confusion */
        dev->operstate = IF_OPER_UP;

+       dev->qdisc_tx_busylock = &vrf_tx_busylock;
+       dev->qdisc_running_key = &vrf_qdisc_running_key;
        return 0;

 out_rth:
