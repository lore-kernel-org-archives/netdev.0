From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 00/11] udp: full early demux for unconnected sockets
Date: Fri, 22 Sep 2017 14:58:44 -0700
Message-ID: <1506117524.29839.176.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1506114055.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36328 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752472AbdIVV6q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 17:58:46 -0400
Received: by mail-pf0-f196.google.com with SMTP id f84so964426pfj.3
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 14:58:46 -0700 (PDT)
In-Reply-To: <cover.1506114055.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-09-22 at 23:06 +0200, Paolo Abeni wrote:
> This series refactor the UDP early demux code so that:
> 
> * full socket lookup is performed for unicast packets
> * a sk is grabbed even for unconnected socket match
> * a dst cache is used even in such scenario
> 
> To perform this tasks a couple of facilities are added:
> 
> * noref socket references, scoped inside the current RCU section, to be
>   explicitly cleared before leaving such section
> * a dst cache inside the inet and inet6 local addresses tables, caching the
>   related local dst entry
> 
> The measured performance gain under small packet UDP flood is as follow:
> 
> ingress NIC	vanilla		patched		delta
> rx queues	(kpps)		(kpps)		(%)
> [ipv4]
> 1		2177		2414		10
> 2		2527		2892		14
> 3		3050		3733		22


This is a clear sign your program is not using latest SO_REUSEPORT +
[ec]BPF filter [1]

return socket[RX_QUEUE# | or CPU#];

If udp_sink uses SO_REUSEPORT with no extra hint, socket selection is
based on a lazy hash, meaning that you do not have proper siloing.

return socket[hash(skb)];

Multiple cpus can then :
 - compete on grabbing same socket refcount
 - compete on grabbing the receive queue lock
 - compete for releasing lock and socket refcount
 - skb freeing done on different cpus than where allocated.

You are adding complexity to the kernel because you are using a
sub-optimal user space program, favoring false sharing.

First solve the false sharing issue.

Performance with 2 rx queues should be almost twice the performance with
1 rx queue.

Then we can see if the gains you claim are still applicable.

Thanks

PS: Wei Wan is about to release the IPV6 changes so that the big
differences you showed are going to disappear soon.

Refs [1]

tools/testing/selftests/net/reuseport_bpf.c

6a5ef90c58daada158ba16ba330558efc3471491 Merge branch 'faster-soreuseport'
3ca8e4029969d40ab90e3f1ecd83ab1cadd60fbb soreuseport: BPF selection functional test
538950a1b7527a0a52ccd9337e3fcd304f027f13 soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF
e32ea7e747271a0abcd37e265005e97cc81d9df5 soreuseport: fast reuseport UDP socket selection
ef456144da8ef507c8cf504284b6042e9201a05c soreuseport: define reuseport groups
