From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: [0/9] pohmelfs for drivers/staging
Date: Mon,  9 Feb 2009 17:02:33 +0300
Message-ID: <1234188162-14727-1-git-send-email-zbr@ioremap.net>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>
To: GregKH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavolo.yandex.ru ([87.250.244.45]:19472 "EHLO cavolo.yandex.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754253AbZBIONS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2009 09:13:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

POHMELFS stands for Parallel Optimized Host Message Exchange Layered File System.

This is a high performance network filesystem with local coherent cache of
data and metadata. Its main goal is distributed parallel processing of data.

POHMELFS is a kernel client for the developed distributed parallel internet
filesystem. As it exists today, it is a high-performance parallel network
filesystem with the ability to balance reading among multiple hosts and
simultaneously write data to multiple servers for redundancy.

The main design goal of this filesystem is to implement a very fast and
scalable network filesystem with local writeback cache of data and metadata,
which greatly speeds up every IO operation compared to traditional writethrough
based network filesystems. One can check recent POHMELFS, NFS and DST benchmarks
for comparison [5].

Read balancing and writing to the multiple hosts features can be used to
improve parallel multithreaded read-mostly data processing workload and
organize fault-tolerant systems. POHMELFS as a network client does not
support data synchrnonization between the nodes (after they were brought
up after the shutdown), so this task should be implemented in servers.
POHMELFS and multiple-server-write can be used as backup solution for
the physically distributed network servers.

Currently development is concentrated on the distributed object-based
server development implemeneted with distributed hash table design approach
in mind, which main goals it completely transparent from client point of
view node management, full absence of any controlling central servers
(points of failure), transaction/history based object storage [6]

POHMELFS utilizes writeback cache, which is built on top of MO(E)SI-like
coherency protocol. It uses scalable cached read/write locking. No additional
requests are performed if lock is granted to the filesystem. The same protocol
is used by the server for the on-demand flushing of the client's cache (for
example when server wants to update local data or send some new content
into the clients caches).

POHMELFS is able to encrypt data channel or perform strong data checksumming.
Algorithms used by the filesystems are autoconfigured during the startup and
mount may fail (depending on options) if server does not support requested
algorithms.

Autoconfiguration also involves sending information about size of the exported
directory specified by the server, permission, statistics about amount of inodes,
used space and so on.

POHMELFS utilizes transaction model for all its operations.
Each transction is an object, which may embed multiple commands completed
atomically. When server fails the whole transaction will be replied against it
(or different server) later. This approach allows to maintain high data integrity
and do not desynchronize filesystem state in case of network or server failures.

Basic POHMELFS features:

    * Local coherent cache for data and metadata. (Byte-range) locking. Locks were
    	prepared to be byte-range, but since all Linux filesystems lock the whole
	inode, it was decided to lock the whole object during writing. Actual
	messages being sent for locking/cache coherency protocol are byte-range,
	but because the whole inode is locked, lock is cached, so range actually
	is equal to the inode size. One can simultaneously write into the same page
	via different offsets from different client, and every time file will be
	coherent on all clients which do it and on the server itself.
    * Completely async processing of all events (hard and symlinks are the only
    	exceptions) including object creation and data reading and writing.
    * Flexible object architecture optimized for network processing. Ability to
    	create long pathes to object and remove arbitrary huge directories in
	single network command.
    * High performance is one of the main design goals.
    * Very fast and scalable multithreaded userspace server. Being in userspace it
    	works with any underlying filesystem and still is much faster than async
	in-kernel NFS one.
    * Transactions support. Full failover for all operations. Resending
    	transactions to different servers on timeout or error.
    * Client is able to switch between different servers (if one goes down, client
    	automatically reconnects to second and so on).
    * Client parallel extensions: ability to write to multiple servers and balance
    	reading between them.
    * Client dynamic server reconfiguration: ability to add/remove servers from
    	working set in run-time.
    * Strong authentification and possible data encryption in network channel.
    * Extended attributes support.
    * Read-only mounts, ability to limit maximum size of the exported directory.

This release fixes fair number of bugs introduced in the recent switch from own path
cache to dentry one. Also several long-standing coherency issues were successfully
resolved.

Since POHMELFS and its merge requests do not attract core kernel developers comments,
I ask for the drivers/staging merge and pushing it upstream in the next releases.
Current TODO entry is effectively empty (modulo bug fixes if any), but may include some
additional features requested by the users.

Development is concentrated on the distributed hash table server, which is
implemented as a userspace library suitable for the POHMELFS server usage and
external applications [6].

Patch is against vanilla tree.

One can grab sources from archive or GIT tree (web interface).

1. POHMELFS homepage.
http://www.ioremap.net/projects/pohmelfs

2. POHMELFS archive.
http://www.ioremap.net/archive/pohmelfs/

3. POHMELFS git tree.
http://www.ioremap.net/cgi-bin/gitweb.cgi

4. POHMELFS maillist.
pohmelfs@ioremap.net

5. Recent POHMELFS, NFS and DST benchmarks.
http://www.ioremap.net/node/156
http://www.ioremap.net/node/134
(the fun one which shows the power of the local metadata cache, but please note
that it was mostly done in RAM):
http://www.ioremap.net/node/153

6. The elliptics network - distributed hash table cloud
http://www.ioremap.net/taxonomy/term/17

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

 .../filesystems/pohmelfs/design_notes.txt          |   70 +
 Documentation/filesystems/pohmelfs/info.txt        |   86 +
 .../filesystems/pohmelfs/network_protocol.txt      |  227 +++
 drivers/staging/Kconfig                                         |    2 +
 drivers/staging/Makefile                                        |    1 +
 drivers/staging/pohmelfs/Kconfig                                |   23 +
 drivers/staging/pohmelfs/Makefile                               |    3 +
 drivers/staging/pohmelfs/config.c                               |  478 +++++
 drivers/staging/pohmelfs/crypto.c                               |  880 +++++++++
 drivers/staging/pohmelfs/dir.c                                  | 1093 +++++++++++
 drivers/staging/pohmelfs/inode.c                                | 1976 ++++++++++++++++++++
 drivers/staging/pohmelfs/lock.c                                 |  182 ++
 drivers/staging/pohmelfs/mcache.c                               |  171 ++
 drivers/staging/pohmelfs/net.c                                  | 1246 ++++++++++++
 drivers/staging/pohmelfs/netfs.h                                |  932 +++++++++
 drivers/staging/pohmelfs/path_entry.c                           |  114 ++
 drivers/staging/pohmelfs/trans.c                                |  715 +++++++
 mm/filemap.c                                       |    2 +
 18 files changed, 8201 insertions(+), 0 deletions(-)
