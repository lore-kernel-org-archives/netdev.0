From: David Lamparter <equinox@diac24.net>
Subject: Identifying network namespaces (was: Network namespace manipulation
 with file descriptors)
Date: Wed, 18 May 2011 14:43:07 +0200
Message-ID: <20110518124307.GD3762520@jupiter.n2.diac24.net>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	jamal <hadi@cyberus.ca>, Daniel Lezcano <daniel.lezcano@free.fr>,
	Linux Containers <containers@lists.osdl.org>,
	Renato Westphal <renatowestphal@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1tyd7p7tq.fsf@fess.ebiederm.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 06, 2011 at 07:23:29PM -0700, Eric W. Biederman wrote:
> Today there are something things you can use namespaces to implement but
> the userspace code is unnecessarily complex and fragile because of
> limitations of the kernel interfaces.

(I hope I'm not duplicating stuff here, maybe this is already taken care
of...)

There still is the unresolved issue of identifying and/or equality
testing network namespaces. The problems I see are the following:

Problems
========

-   there is no simple list of the existing namespaces
 
  most importantly, network namespaces can be abused very sneakily to
  provide trojans or other malicious software with a covert
  communication channel.

  Just create a macvlan device on the local ethernet, shift it into a
  new namespace, grab an IP - and the admin of the host will be left
  dumbfounded with his plain old netstat or ss as to where those weird
  packets are coming from.

  (Granted, this needs root privileges and you can still see everything
  in /proc/<pid>/net/{tcp,udp,...})

-   processes cannot easily be cross referenced with each other

  in the case of user space stuff running astray - like management
  software crashing, routing daemons screwing up, etc. - it becomes
  fairly difficult to shut down a network namespace (or even reaquire
  physical devices that have been reassigned)

-   namespaces cannot adequately be identified to the user

  for debugging, some kernel messages become useless. most prominently,
  "unregister_netdevice: waiting for lo to become free. Usage count = 123"
  could certainly use some clarification, *which* lo is meant...

So, considering this set of premises (feedback welcome) I looked for
some suitable means of identification. I discarded going for any process
identifiers since Eric's patches allow for network namespaces without
any process holding a reference, using bind mounts instead.

Solution?
=========

I do think I found another identifier suitable for both exporting a full 
list and providing "getid" functionality: the "lo" interface index.
I am not fully sure on the rules here, but to my understanding the lo
interface index should be constant for the lifetime of a network
namespace, and furthermore the interface index namespace is global to
the kernel.

This can already be used right now:
- you can identify the init namespace since its lo index is 1
- you can use netlink (or SIOCGIFINDEX, ew.) to get your own ID
- as soon as you have the means to attach to a namespace, you
  automatically also have the means to get its ID

What might need to be added:
1) a list of lo indices
2) a way to get a hold of the namespace using its lo index
3) maybe dmesg output on creation/destruction for the abuse case above
4) possibly a file in /proc/<pid>/net that just contains the lo index,
  for ease of use

3) and 4) should be trivial; 1) and 2) could be solved by having a
directory in /proc (?) that has all the network namespace "files" with
their lo indices as names.


So, ... Opinions?


-David
