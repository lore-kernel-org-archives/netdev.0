From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [GIT net-next] Open vSwitch
Date: Wed, 6 Aug 2014 15:55:05 -0700
Message-ID: <CAADnVQJmPcwk0hg_8q4E_pmgyVtkytjcmo14nxSRHQFzixLT7A@mail.gmail.com>
References: <CALnjE+rAXDpzkL9H9EAHKZ0yGCW3HHu+LgihwOj5Yx_5SASzsA@mail.gmail.com>
	<20140803.212131.1256448650945676000.davem@davemloft.net>
	<CALnjE+oEKGakFMZvSBir3OUmMdQmZdF2+YEy5kDV=P=_BNKU4Q@mail.gmail.com>
	<20140804.124246.819301748264471598.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:42980 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417AbaHFWzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 18:55:06 -0400
Received: by mail-yk0-f182.google.com with SMTP id q9so2218311ykb.27
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 15:55:05 -0700 (PDT)
In-Reply-To: <20140804.124246.819301748264471598.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 4, 2014 at 12:42 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin Shelar <pshelar@nicira.com>
> Date: Mon, 4 Aug 2014 12:35:59 -0700
>
>> On Sun, Aug 3, 2014 at 9:21 PM, David Miller <davem@davemloft.net> wrote:
>>> An attacker can construct a packet sequence such that every mask cache
>>> lookup misses, making the cache effectively useless.
>>
>> Yes, but it does work in normal traffic situations.
>
> You're basically just reiterating the point I'm trying to make.
>
> Your caches are designed for specific configuration and packet traffic
> pattern cases, and can be easily duped into a worse case performance
> scenerio by an attacker.
>
> Caches, basically, do not work on the real internet.
>
> Make the fundamental core data structures fast and scalable enough,
> rather than bolting caches (which are basically hacks) on top every
> time they don't perform to your expectations.
>
> What if you made the full flow lookup fundamentally faster?  Then an

I suspect that the flow lookup in ovs is as fast as it can be, yet
ovs is still dos-able, since kernel datapath (flow lookup and action)
is considered to be first level cache for user space. By design flow
miss is always punted to userspace. Therefore netperf TCP_CRR test
from a VM is not cheap for host userspace component. Mega-flows and
multiple upcall pids are partially addressing this fundamental
problem. Consider simple distributed virtual bridge with VMs
distributed across multiple hosts. Mega-flow mask that selects dmac
can solve CRR case for well behaving VMs, but rogue VM that spams
random dmac will keep taxing host userspace. So we'd need to add
another flow mask to match the rest of traffic unconditionally and
drop it. Now consider virtual bridge-router-bridge topology (two
subnets and router using openstack names). Since VMs on the same
host may be in different subnets their macs can be the same, so
'mega-flow mask dmac' approach won't work and CRR test again is
getting costly to userspace. We can try to use 'in_port + dmac'
mask, but as network topology grows the flow mask tricks get out
of hand. Situation is worse when ovs works as gateway and receives
internet traffic. Since flow miss goes to userspace remote attacker
can find a way to saturate gateway cpu with certain traffic.
I guess none of this is new to ovs and there is probably a solution
that I don't know about.
