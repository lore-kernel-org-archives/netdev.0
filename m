From: Julian Anastasov <ja@ssi.bg>
Subject: Re: kernel policy routing table src ip not respected since 2.6.37
 and commit 9fc3bbb4a752
Date: Tue, 15 Oct 2013 11:51:04 +0300 (EEST)
Message-ID: <alpine.LFD.2.03.1310151144580.1562@ssi.bg>
References: <CAK3+h2zGFnbC-hpPB8fPX7TC3rKCWbPYVY4WW4HDYbN+LXNXXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, jsing@google.com
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:53361 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752178Ab3JOIvS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 04:51:18 -0400
In-Reply-To: <CAK3+h2zGFnbC-hpPB8fPX7TC3rKCWbPYVY4WW4HDYbN+LXNXXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 14 Oct 2013, Vincent Li wrote:

> I had a simple bash script to test if the policy routing table src ip
> is respected or not, git bisect found the  commit 9fc3bbb4a752 to
> change the policy routing table source ip behavior.
> 
> commit 9fc3bbb4a752f108cf096d96640f3b548bbbce6c
> Author: Joel Sing <jsing@google.com>
> Date:   Mon Jan 3 20:24:20 2011 +0000
> 
>     ipv4/route.c: respect prefsrc for local routes
> 
>     The preferred source address is currently ignored for local routes,
>     which results in all local connections having a src address that is the
>     same as the local dst address. Fix this by respecting the preferred source
>     address when it is provided for local routes.
> 
> test script:
> 
> #!/bin/bash
> ip addr add 10.1.1.1/24 dev eth0
> ip addr add 10.1.1.2/24 dev eth0
> ip rule add priority 245 table 245
> ip route add 10.1.1.0/24 dev eth0  proto kernel  scope link  src
> 10.1.1.2 table 245 <===source ip 10.1.1.2 to be preferred
> 
> ip addr show dev eth0
> ip route list table main
> ip route list table 245
> 
> 
> tcpdump -nn -i eth0 host 10.1.1.9 and icmp &
> 
> ping 10.1.1.9
> 
> 
> 
> --before commit 9fc3bbb4a752
> 
> the source is from ip 10.1.1.2 as expected
> 
> --after commit 9fc3bbb4a752
> 
> the source is from ip 10.1.1.1 which not expected since I have high
> priority table 245 with source ip 10.1.1.2
> 
> is this regression of commit 9fc3bbb4a752 ?

	Hm, it works here on 3.11.3. ARP request uses
10.1.1.2 and ICMP packet has such source. May be something with
the ping tool you are using? Check 'strace ping -c 1 10.1.1.9', may
be it binds to first device IP?

Regards

--
Julian Anastasov <ja@ssi.bg>
