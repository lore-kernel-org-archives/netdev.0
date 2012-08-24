From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 1/2] ipv6: do not hold route table lock when send ndisc
 probe
Date: Fri, 24 Aug 2012 17:15:24 +0800
Message-ID: <1345799724.11584.15.camel@cr0>
References: <1345187499-16929-1-git-send-email-amwang@redhat.com>
	 <CAATkVEzKuTeUbU75B6EoSfFvGVsz_eK47XNWmsP5KcCvjTDEDA@mail.gmail.com>
	 <1345520643.12468.6.camel@cr0>
	 <1345738232.5904.1244.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Debabrata Banerjee <dbavatar@gmail.com>, netdev@vger.kernel.org,
	"Banerjee, Debabrata" <dbanerje@akamai.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31404 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752282Ab2HXJPm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2012 05:15:42 -0400
In-Reply-To: <1345738232.5904.1244.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-23 at 18:10 +0200, Eric Dumazet wrote:
> On Tue, 2012-08-21 at 11:44 +0800, Cong Wang wrote:
> > Hi, Debabrata,
> > 
> > Could you help to test the attached patch below?
> > 
> > Thanks!
> > 
> 
> Hard to comment on your patch since its not inlined.
> 
> +               nw = kmalloc(sizeof(*nw), GFP_ATOMIC);
> +               if (nw) {
> +                       memcpy(&nw->target, &neigh->primary_key, sizeof(struct in6_addr));
> +                       addrconf_addr_solict_mult(&nw->target, &nw->mcaddr);
> +                       nw->dev = rt->dst.dev;
> +                       INIT_WORK(&nw->work, queue_ndisc);
> +                       schedule_work(&nw->work);
> +               }
> 
> You cant do that without taking extra reference on dev,
> and release it in queue_ndisc()
> 
> This also will add interesting side effects at device dismantle.
> 

Right... If we call dev_hold() in the work, it is possible that the work
is still not scheduled to running when we unregister the device. What's
more, we can't flush work here as we are holding a read lock.

Hmm.
