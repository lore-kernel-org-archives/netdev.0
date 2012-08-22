From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: dev: fix the incorrect hold of net namespace's lo
 device
Date: Wed, 22 Aug 2012 10:39:46 +0200
Message-ID: <1345624786.5158.759.camel@edumazet-glaptop>
References: <1345624262-6554-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40941 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354Ab2HVIj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 04:39:56 -0400
Received: by bkwj10 with SMTP id j10so196733bkw.19
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 01:39:55 -0700 (PDT)
In-Reply-To: <1345624262-6554-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 16:31 +0800, Gao feng wrote:
> in dst_dev_event,we get the still referenced dst entries
> from dst_garbage list,and call dst_ifdown to change these
> dst entries' device to the net namesapce's lo device.
> 
> when we moving a net device(A) to another net namespace,
> because free_fib_info_rcu is called after a grace period,
> we may call dst_dev_event before free_fib_info_rcu putting
> dst_entry into the dst_garbage list.
> 
> so in dst_dev_event, we can't see these dst entries through
> dst_garbage list, and without changing their device to the
> old net namespace's lo device. after a grace period, these
> dst entries which dst->dev is device A will in the dst_garbage
> list, and the device A will belong to the new net namespcae.
> 
> then we exit from this new net namespace, the dst_dev_event
> is called again,it will get these dst entries from dst_garbage
> list,and call dst_ifdown to hold the new net namespace's lo
> device incorrectly and put the device A.
> 
> so it will tigger the emg message in netdev_wait_allrefs like
> below.
> unregister_netdevice: waiting for lo to become free. Usage count = 1
> 
> fix this problem by adding rcu_barrier() in dst_dev_event
> when event is NETDEV_UNREGISTER.
> with this,dst_ifdown will be called after the dst_garbage list
> beeing updated.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  net/core/dst.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/core/dst.c b/net/core/dst.c
> index 56d6361..38c2199 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -375,6 +375,7 @@ static int dst_dev_event(struct notifier_block *this, unsigned long event,
>  
>  	switch (event) {
>  	case NETDEV_UNREGISTER:
> +		rcu_barrier();
>  	case NETDEV_DOWN:
>  		mutex_lock(&dst_gc_mutex);
>  		for (dst = dst_busy_list; dst; dst = dst->next) {


Did you miss http://patchwork.ozlabs.org/patch/176517/  or is this patch
an alternative ?

rcu_barrier() at this place will kill some workloads.
