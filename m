From: "Daniel Bonekeeper" <thehazard@gmail.com>
Subject: Re: Sockets inside the kernel or userspace ?
Date: Fri, 30 Jun 2006 04:45:54 -0400
Message-ID: <e1e1d5f40606300145j36878666ga28c35526f6519ef@mail.gmail.com>
References: <e1e1d5f40606300032t7162e165qaa915658e0a71386@mail.gmail.com>
	 <20060630075749.GA30936@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:63143 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S932146AbWF3Ipz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 04:45:55 -0400
Received: by py-out-1112.google.com with SMTP id t32so577158pyc
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2006 01:45:54 -0700 (PDT)
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
In-Reply-To: <20060630075749.GA30936@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for the thoughts, Evgeniy !

Well... I was thinking in developing something like that (nothing
actually very usefull, just a little "something" to get me more
comfortable with fs and net development):

1) Inside a gigabit LAN there will be, let's say, 10 machines, that
are meant to be used as filesystem nodes. Those machines have a daemon
running in userspace ( "dfsd" ) and have one or more partitions of
physical(s) HD(s) dedicated to the "filesystem cluster". So, let's
suppose that on every node we have a /dev/hdb5 with 20GB unused,
dedicated to the cluster ( "/usr/bin/dfsd -p /dev/hda5" ). This is to
keep things simple (since we can have raw access to the partition),
but we could use files on the local filesystem too.

2) On the master machine, the DFS kernel module (which declares a
block device like /dev/dfs1) uses broadcast packages (something like
DHCP) to retrieve the list of active nodes on the LAN. So, with 10
machines with 20GB each, we have 200GB of distributed storage over the
network. To keep things simple, let's say that they are addressed in a
serial fashion (requests from 0-20GB goes to the node1, 20-40GB to
node2, etc). The module is responsible for keeping a pool of TCP
connections with the nodes' daemons, for sending, receiving and
parsing the data, etc. At this point, no security measures are taken
(encryption, etc).

At this point, I think that we should be able to create a reiserfs fs
on the device and get it running (even if far slower than a local
disk). The second part of the project, which would involve more
serious stuff, could be:

3) Redundancy - minimizing the storage capacity, but being able to
safely continue to work if one of the nodes are down. Actually I don't
have any clue on how to achieve this without drastically diminish the
storage capacity, but probably there is some clever way out there =]

4) No masters - each node can have access to the filesystem (the block
device) as if it was a NFS mountpoint (this could be useful somehow to
actual clusters, where you could not only share the processor, but
also the HD of the nodes as a single huge / mountpoint). In this
model, there would be no userspace stuff at all.

What you think ?

Daniel


On 6/30/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> On Fri, Jun 30, 2006 at 03:32:28AM -0400, Daniel Bonekeeper (thehazard@gmail.com) wrote:
> > Let's suppose that I'm writing a experimental distributed filesystem
> > that needs to open a TCP socket to another machines on the LAN, keep a
> > pool of connections and be always aware of new data arriving (like a
> > userspace select()). What's the best approach to implement this ? Is
> > it better to keep all the TCP socket stuff in userspace and use an
> > interface like netlink to talk with it ? Or, since we're talking about
> > a filesystem (where performance is a must), is it better to keep it in
> > kernel mode ?
>
> It depends on your design.
> NFS uses in-kernel sockets, but userspace can easily fill 1Gbit link too.
> FS must eliminate as much coping as possible, but without deep digging
> into the socket code you will get copy both in kernelspace (one copy
> from socket queue into you buffer) and userspace (the same copy, but
> using slower copy_to_user(), depending on the size of each copy it can
> make noticeble difference), but with kernel socket you get your data
> in the fs/vfs cache already, but with userspace you must copy it back
> into the kernel using slow copy_from_user(), but if data is supposed to
> be somehow (heavily) processed before reaching the harddrive (for
> example compressed or encrypted), cost of processing can fully hide cost
> of the copy itself, so userspace is much more preferable in that
> situation due to it's much more convenient development process.
>
> --
>         Evgeniy Polyakov
>


-- 
What this world needs is a good five-dollar plasma weapon.
