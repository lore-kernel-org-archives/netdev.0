From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 0/2] Netns performance improvements
Date: Tue, 5 Jul 2016 22:51:03 +0200
Message-ID: <20160705205103.GE620@orbyte.nwl.cc>
References: <1467729773-16751-1-git-send-email-phil@nwl.cc>
 <87twg4ywjz.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:43968 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151AbcGEUvG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 16:51:06 -0400
Content-Disposition: inline
In-Reply-To: <87twg4ywjz.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Thanks for your quick and insightful reply rightfully pointing out the
lack of rationale behind this change. So let me try to catch up:

On Tue, Jul 05, 2016 at 09:44:00AM -0500, Eric W. Biederman wrote:
> Phil Sutter <phil@nwl.cc> writes:
> 
> > Stress-testing OpenStack Neutron revealed poor performance of 'ip netns'
> > when dealing with a high amount of namespaces. The cause of this lies in
> > the combination of how iproute2 mounts NETNS_RUN_DIR and the netns files
> > therein and the fact that systemd makes all mount points of the system
> > shared.
> 
> So please tell me.  Given that it was clearly a deliberate choice in the
> code to make these directories shared, and that this is not a result
> of a systemd making all directories shared by default.  Why is it
> better to these directories non-shared?

NETNS_RUN_DIR itself is kept shared as it was intended by you (I hope).
The only difference is that we should avoid it being in the same group
as the parent mount point. Otherwise, all netns mount points will occur
twice.

Regarding the shared state of the netns mount points, I have actually no
idea what's the benefit, as there won't be any child mount points and
therefore no propagation should occur. Or am I missing something?

> This may be the appropriate change but saying you stress testing things
> and have a problem but do not describe how large a scale you had a
> problem, or anything else to make your problem reproducible by anyone
> else makes it difficult to consider the merits of this change.
> 
> Sometimes things are a good default policy but have imperfect scaling on
> extreme workloads.
> 
> My experience with the current situtation with ip netns is that it
> prevents a whole lot of confusion by making the network namespace names
> visible whichever mount namespace your processes are running in.

The only functional difference I noticed was the no longer twice
appearing netns mount points. They are still visible in all namespaces
though, just as before.

Here's the script I wrote to benchmark 'ip netns':

| #!/bin/bash
| 
| IP=${IP:-/usr/sbin/ip}
| echo "using ip at $IP"
| 
| # make sure we start at a clean state
| for netns in $(ls /run/netns/* 2>/dev/null); do
|         $IP netns del ${netns##*/}
| done
| umount /run/netns
| 
| echo "creating 100 mount ns"
| touch /tmp/stay_alive
| for ((i = 0; i < 100; i++)); do
|         unshare -m --propagation unchanged bash -c \
| 		"while [[ -e /tmp/stay_alive ]]; do sleep 1; done" &
| done
| # give a little time for unshare to complete
| sleep 3
| 
| nscount=1000
| 
| echo -en "\ncreating $nscount netns"
| time (for ((i = 0; i < $nscount; i++)); do $IP netns add test$i; done)
| 
| echo -en "\ndeleting $nscount netns"
| time (for ((i = 0; i < $nscount; i++)); do $IP netns del test$i; done)
| 
| echo "removing mount ns again"
| rm /tmp/stay_alive
| wait

So basically it creates 100 idle mount namespaces, then times
adding/removing 1000 network namespaces. I called it three times:
without any patch, with just patch 1 and with both patches applied. Here
are the results:

| # IP=/tmp/base/ip /vmshare/reproducer/ip_netns_bench.sh
| using ip at /tmp/base/ip
| creating 100 mount ns
| 
| creating 1000 netns
| real	0m8.110s
| user	0m1.143s
| sys	0m6.235s
| 
| deleting 1000 netns
| real	0m15.347s
| user	0m0.957s
| sys	0m11.359s
| removing mount ns again

| # IP=/tmp/p1/ip /vmshare/reproducer/ip_netns_bench.sh
| using ip at /tmp/p1/ip
| creating 100 mount ns
| 
| creating 1000 netns
| real	0m7.956s
| user	0m0.987s
| sys	0m4.896s
| 
| deleting 1000 netns
| real	0m7.407s
| user	0m1.165s
| sys	0m3.418s
| removing mount ns again

| # IP=/tmp/p2/ip /vmshare/reproducer/ip_netns_bench.sh
| using ip at /tmp/p2/ip
| creating 100 mount ns
| 
| creating 1000 netns
| real	0m7.843s
| user	0m0.977s
| sys	0m4.915s
| 
| deleting 1000 netns
| real	0m6.407s
| user	0m1.006s
| sys	0m3.057s
| removing mount ns again

As you can see, the biggest improvement comes during deletion and from
patch 1. Though the second patch lowers the total time to delete the
namespaces by another second, which is still relatively much in
comparison to the low total time.

Cheers, Phil
