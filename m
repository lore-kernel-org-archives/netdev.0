From: Thomas Graf <tgraf@redhat.com>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Wed, 19 May 2010 22:49:51 +0200
Message-ID: <1274302191.3148.2.camel@lsx.localdomain>
References: <20100519075721.GA23926@gondor.apana.org.au>
	 <1274256582.2766.5.camel@edumazet-laptop>
	 <1274257089.2766.7.camel@edumazet-laptop>
	 <20100519120547.GB26584@hmsreliant.think-freely.org>
	 <20100519125543.GA26519@hmsreliant.think-freely.org>
	 <20100519180053.GC26519@hmsreliant.think-freely.org>
Reply-To: tgraf@redhat.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26714 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753060Ab0ESUuP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 May 2010 16:50:15 -0400
In-Reply-To: <20100519180053.GC26519@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-05-19 at 14:00 -0400, Neil Horman wrote: 
> I'm currently testing this, unfortunately, and its not breaking anything, but it
> doesn't allow cgroups to classify frames comming from tun interfaces.  I'm still
> investigating, but I think the issue is that, because we call local_bh_disable
> with this patch, we wind up raising the count at SOFTIRQ_OFFSET in preempt_count
> for the task.  Since the cgroup classifier has this check:
> 
> if (softirq_count() != SOFTIRQ_OFFSET))
> 	return -1;
> 
> We still fail to classify the frame.  the cgroup classifier is assuming that any
> frame arriving with a softirq count of 1 means we came directly from the
> dev_queue_xmit routine and is safe to check current().  Any less than that, and
> something is wrong (as we at least need the local_bh_disable in dev_queue_xmit),
> and any more implies that we have nested calls to local_bh_disable, meaning
> we're really handling a softirq context.

It is a hack but the only method to check for softirq context I found. I
would favor using a flag if there was one.

