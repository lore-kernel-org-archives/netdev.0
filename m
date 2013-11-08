From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: iproute2: potential upgrade regression with 58a3e827
Date: Fri, 08 Nov 2013 13:36:44 -0800
Message-ID: <87k3gi4lub.fsf@xmission.com>
References: <527D2768.1030403@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: shemminger@osdl.org, netdev@vger.kernel.org
To: Chris J Arges <chris.j.arges@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:36156 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757565Ab3KHVg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 16:36:57 -0500
In-Reply-To: <527D2768.1030403@canonical.com> (Chris J. Arges's message of
	"Fri, 08 Nov 2013 12:03:20 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris J Arges <chris.j.arges@canonical.com> writes:

> Hi,
> The commit
> https://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/commit/?id=58a3e8270fe72f8ed92687d3a3132c2a708582dd
> could be potentially introducing a regression on an upgrade.
>
> I've noticed that upgrading iproute while there are active namespaces
> could cause the following error:
> seting the network namespace failed: Invalid argument
>
> Here's a test case:
> Build and install iproute2 with 4395d48c78a77a99c5a8618403211032356fe552
>
> In one terminal run:
> ip netns add netns_old
> ip link add name if_old type veth peer name if_old_peer
> ip link set dev if_old_peer netns netns_old
> ip netns exec netns_old bash
>
> Build and install iproute2 with 58a3e8270fe72f8ed92687d3a3132c2a708582dd
>
> In the same terminal as you typed the original commands run:
> ip netns add netns_one
> ip link add name if_one type veth peer name if_one_peer
> ip link set dev if_one_peer netns netns_one
> ip netns exec netns_one bash
> ip netns exec netns_old bash
>
> You'll get:
> seting the network namespace failed: Invalid argument
>
> If you just run the above without transitioning to the code in 58a3e827,
> then it works.

ip netns exec is fundamentally designed to run code that knows nothing
about network namespaces without modification.  If we can make network
namespace aware code work that is great but the entire point of ip netns
exec is to remove the need to convert every network aware program in
linux to be network namespace aware.

Shared subtree support that is added in 58a3e827 should make things a
little better, by letting changes that happen in the initial mount
namespace propogate into children running inside of ip netns exec.

It appears that somehow you wound up in a mount namespace where the
mount of netns_one did not propagate too.  Which is weird.  I expect
we are missing an error message somewhere.

So far nothing allows network namespaces added like:
ip netns exec ns1 ip netns add ns2
to propogate up to the initial mount namespace and that will definitely
cause problems, but not the problem you are seeing.

Shrug.  I will be happy to review patches to make this better but I
don't care enough to investigate.  If you aren't up to writing patches
to make ip netns work inside of ip netns exec I recommend you don't do
that then.

Eric
