From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC Patch net-next 4/4] net_sched: make ingress qdisc lockless
Date: Sun, 12 Jan 2014 07:30:14 -0500
Message-ID: <52D28AD6.4080304@mojatatu.com>
References: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com> <1389291593-2494-5-git-send-email-xiyou.wangcong@gmail.com> <1389313313.31367.74.camel@edumazet-glaptop2.roam.corp.google.com> <CAM_iQpUj9kg=15K3yyOWuMEaxWQC2TUStAMjHrn+ixbGyYHK0Q@mail.gmail.com> <20140109164936.4b17cf38@nehalam.linuxnetplumber.net> <52CF4795.106@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	John Fastabend <john.fastabend@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.r.fastabend@intel.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:42293 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280AbaALMaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 07:30:18 -0500
Received: by mail-ig0-f172.google.com with SMTP id k19so1362783igc.5
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 04:30:17 -0800 (PST)
In-Reply-To: <52CF4795.106@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/14 20:06, John Fastabend wrote:

> Just to re-iterate you need to go through each and every qdisc,
> classifier, action and verify it is safe to run in parallel. Take
> a look at how the skb lists are managed in the qdiscs. If we want
> to do this we need to make these changes in some coherent way
> because it touches lots of pieces.
>

Indeed. Everything assumes the global qdisc lock is protecting them.
Actually actions are probably the best at the moment because
the lock is very fine grained to just the action instance
and it protects both control and data paths.
But filters have stuff littered everywhere.  Egress qdiscs
as you mention have queues at multi levels etc.

> Also your stats are going to get hosed none of the bstats, qstats
> supports this.

Stats are probably the easiest to "fix".
Didnt Eric (or somebody else) fix netdev level stats to use seq counts?
Would that idea not be applicable here?

>I'll send out the classifier set later tonight
> if you want. I got stalled going through the actions.
>

The thing to note is:
actions can be shared across filters, netdevices and cpus.
By default they are not shared across filters and netdevices that is
a config option. You still have to worry about sharing across cpus
which will happen because a flow can be shared across cpus.
You could probably get rid of the lock if you can show
that you can make data and control path mutually exclusive
(rtnl will protect control path).

> Finally any global state in those qdiscs is going to drive performance
> down so many of them would likely need to be redesigned.
>

I feel like per-cpu qdiscs is the best surgery at the moment.

cheers,
jamal
