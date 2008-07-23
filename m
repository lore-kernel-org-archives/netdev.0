From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Traffic control cgroups subsystem
Date: Wed, 23 Jul 2008 15:05:36 -0700
Message-ID: <20080723150536.ded38b22.akpm@linux-foundation.org>
References: <Pine.LNX.4.64.0807221041210.1091@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lizf@cn.fujitsu.com, kaber@trash.net, menage@google.com
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59093 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754170AbYGWWFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 18:05:51 -0400
In-Reply-To: <Pine.LNX.4.64.0807221041210.1091@ranjit.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Jul 2008 10:44:18 -0700 (PDT)
Ranjit Manomohan <ranjitm@google.com> wrote:

> [Take 3] -- Fixed additional comments from Patrick McHardy
> 
> This patch provides a simple resource controller (cgroup_tc) based on the
> cgroups infrastructure to manage network traffic. The cgroup_tc resource
> controller can be used to schedule and shape traffic belonging to the task(s)
> in a particular cgroup.
> 
> The implementation consists of two parts:
> 
> 1) A resource controller (cgroup_tc) that is used to associate packets from
>     a particular task belonging to a cgroup with a traffic control class id (
>     tc_classid). This tc_classid is propagated to all sockets created by tasks
>     in the cgroup and will be used for classifying packets at the link layer.
> 
> 2) A modified traffic control classifier (cls_flow) that can classify packets
>     based on the tc_classid field in the socket to specific destination classes.
> 
> An example of the use of this resource controller would be to limit
> the traffic from all tasks from a file_server cgroup to 100Mbps. We could
> achieve this by doing:
> 
> # make a cgroup of file transfer processes and assign it a uniqe classid
> # of 0x10 - this will be used lated to direct packets.
> mkdir -p /dev/cgroup
> mount -t cgroup tc -otc /dev/cgroup
> mkdir /dev/cgroup/file_transfer
> echo 0x10 > /dev/cgroup/file_transfer/tc.classid
> echo $PID_OF_FILE_XFER_PROCESS > /dev/cgroup/file_transfer/tasks
> 
> # Now create a HTB class that rate limits traffic to 100mbits and attach
> # a filter to direct all traffic from cgroup file_transfer to this new class.
> tc qdisc add dev eth0 root handle 1: htb
> tc class add dev eth0 parent 1: classid 1:10 htb rate 100mbit ceil 100mbit
> tc filter add dev eth0 parent 1: handle 800 protocol ip prio 1 flow map key cgroup-classid baseclass 1:10
> 
> Signed-off-by: Ranjit Manomohan <ranjitm@google.com>
> 
> ---
> diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
> index e287745..4b12372 100644
> --- a/include/linux/cgroup_subsys.h
> +++ b/include/linux/cgroup_subsys.h
> @@ -48,3 +48,9 @@ SUBSYS(devices)
>   #endif
> 
>   /* */

Your email client is performing space-stuffing.  It's easy enough to
fix at this end (s/^ / /g) but is a bit of a hassle.

> @@ -359,7 +370,12 @@ static int flow_classify(struct sk_buff *skb, struct tcf_proto *tp,
>   			classid %= f->divisor;
> 
>   		res->class   = 0;
> -		res->classid = TC_H_MAKE(f->baseclass, f->baseclass + classid);
> +
> +		if (key == FLOW_KEY_CGROUP_CLASSID)
> +			res->classid = TC_H_MAKE(f->baseclass, classid);
> +		else
> +			res->classid = TC_H_MAKE(f->baseclass,
> +						 f->baseclass + classid);

This causes a warning:

net/sched/cls_flow.c: In function 'flow_classify':
net/sched/cls_flow.c:344: warning: 'key' may be used uninitialized in this function

that warning is a non-issue if we happen to know that f->nkeys can
never be zero.  I don't know if that is guaranteed at this code site?

If so, it would be nice to suppress the warning in some fashion. 
uninitialized_var() is one way, but suitable code reorganisation is
preferred.

I note that flow_classify() has an on-stack dynamically-sized array:

		u32 keys[f->nkeys];

I hope that f->nkeys is a) small and b) not user-controllable.

