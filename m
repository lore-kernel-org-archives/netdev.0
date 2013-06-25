From: Nicolas Schichan <nschichan@freebox.fr>
Subject: Re: freeze with interface rename & SIOCGIFNAME
Date: Tue, 25 Jun 2013 18:27:43 +0200
Message-ID: <51C9C4FF.1020706@freebox.fr>
References: <51C9BB9C.4050405@freebox.fr> <1372176951.3301.103.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns0.vlq16.iliad.fr ([213.36.7.21]:60287 "EHLO
	ns0.vlq16.iliad.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424Ab3FYQ1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 12:27:44 -0400
In-Reply-To: <1372176951.3301.103.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/25/2013 06:15 PM, Eric Dumazet wrote:
> Nice catch !
>
> Please add a helper so that we can use it as well from
> sock_getbindtodevice(), and submit an official patch ?

Sure, I'll do that.

> int netdev_get_name(char *name, int ifindex)
> {
> 	struct net_device *dev;
> 	unsigned int seq;
>
> retry:
>          seq = read_seqcount_begin(&devnet_rename_seq);

raw_seqcount_begin is required here here. read_seqcount_begin will spin 
forever as the s->sequence & 1 check will always be true in 
__read_seqcount_begin(). This will incur some unneed work if a rename is in 
progress, but that's better than locking the system up.

>          rcu_read_lock();
>          dev = dev_get_by_index_rcu(net, ifindex);
>          if (!dev) {
>                  rcu_read_unlock();
>                  return -ENODEV;
>          }
>
>          strcpy(name, dev->name);
>          rcu_read_unlock();
>          if (read_seqcount_retry(&devnet_rename_seq, seq)) {
> 		cond_resched();
>                  goto retry;
> 	}
> }
>
>
> Thanks !
>
>
>
>


-- 
Nicolas Schichan
Freebox SAS
