From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Sockets inside the kernel or userspace ?
Date: Fri, 30 Jun 2006 13:12:44 +0400
Message-ID: <20060630091244.GA3606@2ka.mipt.ru>
References: <e1e1d5f40606300032t7162e165qaa915658e0a71386@mail.gmail.com> <20060630075749.GA30936@2ka.mipt.ru> <e1e1d5f40606300145j36878666ga28c35526f6519ef@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:40355 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751539AbWF3JMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 05:12:38 -0400
To: Daniel Bonekeeper <thehazard@gmail.com>
Content-Disposition: inline
In-Reply-To: <e1e1d5f40606300145j36878666ga28c35526f6519ef@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2006 at 04:45:54AM -0400, Daniel Bonekeeper (thehazard@gmail.com) wrote:
> 1) Inside a gigabit LAN there will be, let's say, 10 machines, that
> are meant to be used as filesystem nodes. Those machines have a daemon
> running in userspace ( "dfsd" ) and have one or more partitions of
> physical(s) HD(s) dedicated to the "filesystem cluster". So, let's
> suppose that on every node we have a /dev/hdb5 with 20GB unused,
> dedicated to the cluster ( "/usr/bin/dfsd -p /dev/hda5" ). This is to
> keep things simple (since we can have raw access to the partition),
> but we could use files on the local filesystem too.
>
> 2) On the master machine, the DFS kernel module (which declares a
> block device like /dev/dfs1) uses broadcast packages (something like
> DHCP) to retrieve the list of active nodes on the LAN. So, with 10
> machines with 20GB each, we have 200GB of distributed storage over the
> network. To keep things simple, let's say that they are addressed in a
> serial fashion (requests from 0-20GB goes to the node1, 20-40GB to
> node2, etc). The module is responsible for keeping a pool of TCP
> connections with the nodes' daemons, for sending, receiving and
> parsing the data, etc. At this point, no security measures are taken
> (encryption, etc).

At this point you can mount all remote nodes on one master and export it
over NFS. It is not distributed FS.

> At this point, I think that we should be able to create a reiserfs fs
> on the device and get it running (even if far slower than a local
> disk). The second part of the project, which would involve more
> serious stuff, could be:
> 
> 3) Redundancy - minimizing the storage capacity, but being able to
> safely continue to work if one of the nodes are down. Actually I don't
> have any clue on how to achieve this without drastically diminish the
> storage capacity, but probably there is some clever way out there =]

Several nodes have the same data, so if one of them has failed, one can
continue data processing. That means either tree-like strucrure where
local master replicate data between the nodes, or fully distributed fs
(below).

> 4) No masters - each node can have access to the filesystem (the block
> device) as if it was a NFS mountpoint (this could be useful somehow
> tlly o
> actual clusters, where you could not only share the processor, but
> also the HD of the nodes as a single huge / mountpoint). In this
> model, there would be no userspace stuff at all.

Fully distributed mode does not even suppose some "master node"
existense, since it will quickly became a bottleneck.
Each node might have some list of nodes it synchronizes with, so if one
of the node is turned off, others still have valid data and machine
which requested the data can "reconnect" to another node and get it's
data. This involves interesting CS thoughts about interconnects (trees,
rings, multidimentional torus and so on) and other components of the
system.

-- 
	Evgeniy Polyakov
