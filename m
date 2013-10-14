From: Vincent Li <vincent.mc.li@gmail.com>
Subject: kernel policy routing table src ip not respected since 2.6.37 and
 commit 9fc3bbb4a752
Date: Mon, 14 Oct 2013 09:13:42 -0700
Message-ID: <CAK3+h2zGFnbC-hpPB8fPX7TC3rKCWbPYVY4WW4HDYbN+LXNXXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: jsing@google.com
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:59378 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754841Ab3JNQNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 12:13:44 -0400
Received: by mail-oa0-f46.google.com with SMTP id g12so450859oah.5
        for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 09:13:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I had a simple bash script to test if the policy routing table src ip
is respected or not, git bisect found the  commit 9fc3bbb4a752 to
change the policy routing table source ip behavior.

commit 9fc3bbb4a752f108cf096d96640f3b548bbbce6c
Author: Joel Sing <jsing@google.com>
Date:   Mon Jan 3 20:24:20 2011 +0000

    ipv4/route.c: respect prefsrc for local routes

    The preferred source address is currently ignored for local routes,
    which results in all local connections having a src address that is the
    same as the local dst address. Fix this by respecting the preferred source
    address when it is provided for local routes.

test script:

#!/bin/bash
ip addr add 10.1.1.1/24 dev eth0
ip addr add 10.1.1.2/24 dev eth0
ip rule add priority 245 table 245
ip route add 10.1.1.0/24 dev eth0  proto kernel  scope link  src
10.1.1.2 table 245 <===source ip 10.1.1.2 to be preferred

ip addr show dev eth0
ip route list table main
ip route list table 245


tcpdump -nn -i eth0 host 10.1.1.9 and icmp &

ping 10.1.1.9



--before commit 9fc3bbb4a752

the source is from ip 10.1.1.2 as expected

--after commit 9fc3bbb4a752

the source is from ip 10.1.1.1 which not expected since I have high
priority table 245 with source ip 10.1.1.2

is this regression of commit 9fc3bbb4a752 ?

Vincent
