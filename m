From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC][PATCH 0/3] TCP/IP Critical socket communication mechanism
Date: Thu, 15 Dec 2005 00:44:52 -0800
Message-ID: <OFB8B21C56.4F9E9A3C-ON882570D8.002CBD7B-882570D8.002FF8B1@us.ibm.com>
References: <20051214215613.70f9cafa@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: ak@suse.de, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, mpm@selenic.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	sri@us.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422634AbVLOIoG@vger.kernel.org>
In-Reply-To: <20051214215613.70f9cafa@localhost.localdomain>
To: Stephen Hemminger <shemminger@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Also, all this stuff is just a band aid because linux OOM behavior is so
> fucked up.

In our internal discussions, characterizing this as "OOM" came
up a lot, and I don't think of it as that at all. OOM is exactly what the
scheme is trying to avoid!

The actual situation we have in mind is a swap device management system
in a cluster where a remote system tells you (via socket communication to
a user-land management app) that a swap device is going to fail over and
it'd be a good idea not to do anything that requires paging out or
swapping for a short period of time. The socket communication must work,
but the system is not at all out of memory, and the important point is
that it never will be if you limit allocations to those things that are
required for the critical socket to work (and nothing/little else).
        Receiver side allocations are unavoidable, because you don't know
if you can drop the packet or not until you look at it. Some 
infrastructure
must work. But everything else can fail or succeed based on ordinary churn
in ordinary memory pools, until the "in_emergency" condition has passed.
        The critical socket(s) simply have to be out of the zero-sum game
for the rest of the allocations, because those are the (only) path to
getting a working swap device again.

If you're out of memory without a network mechanism to get you more,
this doesn't do anything for you (and it isn't intended to). And if you
mark any socket that isn't going to get you failed over or otherwise
get you more swap, it isn't going to help you, either. It isn't a priority
scheme for low-memory, it's a failover mechanism that relies on 
networking.
There are exactly 2 priorities: critical (as in "you might as well crash 
if
these aren't satisfied") and everything else.

Doing other, more general things that handle low memory, or OOM, or 
identified
priorities are great, but the problem we're interested in solving here is
really just about making socket communication work when the alternative is
a completely dead system. I think these patches do that in a reasonable 
way.
A better solution would be great, too, if there is one. :-)

                                                        +-DLS
