From: Brian Rak <brak@gameservers.com>
Subject: Re: Missing IPv4 routes
Date: Tue, 27 Oct 2015 16:01:36 -0400
Message-ID: <562FD820.5050901@gameservers.com>
References: <562AA7D3.9030905@vultr.com> <562AB578.9090107@gmail.com>
 <562B8856.6070501@vultr.com> <562E46BA.7060904@gmail.com>
 <562E5B69.6080108@vultr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2015.choopa.net ([208.167.225.251]:55752 "EHLO
	mail2015.choopa.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932573AbbJ0UJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 16:09:07 -0400
In-Reply-To: <562E5B69.6080108@vultr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Existing email got kinda messy, starting over again):

So, I'm having an issue with the kernel where if I add a bunch of 
routes, I see some of them go "missing".  They don't show up in the 'ip 
-4 route' list, but they do show up if I do 'ip -4 route get X'.

I managed to come up with a simple set of reproduction commands:

ip link add veth0 type veth peer name veth1
ip link set veth0 up
ip link set veth1 up

ip route add 108.61.171.119/32 dev veth0  scope link
ip route add 108.61.171.141/32 dev veth1  scope link
ip route add 108.61.171.223/32 dev veth1  scope link
ip route add 108.61.171.250/32 dev veth1  scope link
ip route add 108.61.171.247/32 dev veth1  scope link

ip route show

In the route show, you'll see 108.61.171.250/32 and 108.61.171.247/32 
missing completely.

I did a lot of bisecting, and traced it down to this commit:

commit 8be33e955cb959dabc1a6eef0b7356fe8cf73fa6
Author: Alexander Duyck <alexander.h.duyck@redhat.com>
Date:   Wed Mar 4 14:59:19 2015 -0800

     fib_trie: Fib walk rcu should take a tnode and key instead of a 
trie and a leaf

The commit immediately prior to this one 
(7289e6ddb633aaee6ccea2bd2e410654c47b29a6) works fine.

I tried the off-by-one fix from 
e55ffaf457bcc8ec4e9d9f56f955971f834d65b3, however this doesn't appear to 
help at all.   This code is a little above my head, so I don't really 
understand what exactly is broken here.
