From: Olivier Brunel <jjk@jjacky.com>
Subject: Bug w/ (policy) routing
Date: Sat, 31 Dec 2016 00:00:06 +0100
Message-ID: <20161231000006.17677918@jjacky.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 23-29-69-116.static.gorillaservers.com ([23.29.69.116]:43291
        "EHLO mail.jjacky.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
        with ESMTP id S1754025AbcL3XIF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 18:08:05 -0500
Received: by mail.jjacky.com (OpenSMTPD) with ESMTP id 46a0ced9
        for <netdev@vger.kernel.org>;
        Fri, 30 Dec 2016 23:01:41 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

(Please cc me as I'm not subscribed to the list, thanks.)

I'm trying to set things up using some policy routing, and having some
weird issues I can't really explain. It looks to me like there might be
a bug somewhere...

This is done under Arch Linux 64bits, iproute2 4.9.0 (`ip -V` says ip
utility, iproute2-ss161212), kernel 4.8.13

Basically here's what I could reduce it to:
- create a new network namespace, create a pair of veth devices: one in
there, one sent back to the original namespace
- I'm giving them IPs 10.4.0.1 (original namespace) & 10.4.0.2 (new
namespace)
- in that new namespace, I'm trying to add a route to 10.4.0.1, but
  inside a new table. I also want a default route via 10.4.0.1 on the
  table main. It seems to work, only not really...

It's not very easy to describe so hopefully this will make things
clearer:

$ sudo unshare -n sh
sh-4.4# ip rule add table 50 prio 50
sh-4.4# ip link add test type veth peer name test2
sh-4.4# ip addr add 10.4.0.2 dev test
sh-4.4# ip link set dev test up
sh-4.4# ip link set netns 1 dev test2
# back in original namespace, we add 10.4.0.1 to test2 and bring it up

sh-4.4# ip route add 10.4.0.1 dev test table 50
sh-4.4# ip route add default via 10.4.0.1 dev test
sh-4.4# ip route flush cache
sh-4.4# ip rule
0:	from all lookup local 
50:	from all lookup 50 
32766:	from all lookup main 
32767:	from all lookup default 
sh-4.4# ip route show table 50
10.4.0.1 dev test scope link 
sh-4.4# ip route get 10.4.0.1
10.4.0.1 via 10.4.0.1 dev test table local src 10.4.0.2 
    cache 
# !?? why isn't table 50 used as, I believe, it should. And why
does adding a rule "fixes" it :

sh-4.4# ip rule add prio 55555
sh-4.4# ip route get 10.4.0.1
10.4.0.1 dev test table 50 src 10.4.0.2 
    cache 
# deleting the new rule makes no difference. It could even have been
done right after adding it. It's like it just triggered something
(reload, cache flushed, ...)
As seen I did flush cached routes as mentionned in the man page, I don't
know of anything else that would need done to "refresh" things?

Any ideas as to why this is happening? Should this work as I expect it,
or is there anything I'm doing wrong?

Thanks,
