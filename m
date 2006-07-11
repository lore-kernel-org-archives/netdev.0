From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Patch 6/6] per task delay accounting taskstats interface: fix
 clone skbs for each listener
Date: Tue, 11 Jul 2006 03:05:24 -0700
Message-ID: <20060711030524.39abc3d5.akpm@osdl.org>
References: <1152591838.14142.114.camel@localhost.localdomain>
	<1152592599.14142.136.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jlan@sgi.com, csturtiv@sgi.com,
	pj@sgi.com, balbir@in.ibm.com, sekharan@us.ibm.com,
	hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:58758 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750905AbWGKKGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2006 06:06:07 -0400
To: nagar@watson.ibm.com
In-Reply-To: <1152592599.14142.136.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Jul 2006 00:36:39 -0400
Shailabh Nagar <nagar@watson.ibm.com> wrote:

>  	down_write(&listeners->sem);
>  	list_for_each_entry_safe(s, tmp, &listeners->list, list) {
> -		ret = genlmsg_unicast(skb, s->pid);
> +		skb_next = NULL;
> +		if (!list_islast(&s->list, &listeners->list)) {
> +			skb_next = skb_clone(skb_cur, GFP_KERNEL);

If we do a GFP_KERNEL allocation with this semaphore held, and the
oom-killer tries to kill something to satisfy the allocation, and the
killed task gets stuck on that semaphore, I wonder of the box locks up.

Probably it'll work out OK if the semaphore is taken after that task has
had some resources torn down.
