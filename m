From: Evgeniy Polyakov <zbe@ioremap.net>
Subject: [0/9] pohmelfs: The Great Southern Trendkill release.
Date: Fri, 26 Dec 2008 17:18:41 +0300
Message-ID: <1230301130-1325-1-git-send-email-zbe@ioremap.net>
Cc: linux-kernel@vger.kernel.org, pohmelfs@ioremap.net,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavolo.yandex.ru ([87.250.244.45]:31844 "EHLO cavolo.yandex.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752302AbYLZO27 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Dec 2008 09:28:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

POHMELFS stands for Parallel Optimized Host Message Exchange Layered File System.

This is a high performance network filesystem with local coherent cache of
data and metadata. Its main goal is distributed parallel processing of data.

POHMELFS is a kernel client for the developed distributed parallel internet
filesystem. As it exists today, it is a high-performance parallel network
filesystem with ability to balance reading from multiple hosts and simultaneously
write data to multiple hosts.

Main design goal of this filesystem is to implement very fast and scalable
network filesystem with local writeback cache of data and metadata, which
greatly speeds up every IO operation compared to traditional writethrough
based network filesystems.

Read balancing and writing to multiple hosts features can be used to improve
parallel multithreaded read-mostly data processing workload and organize
fault-tolerant systems. POHMELFS as a network client does not support data
synchrnonization between the nodes, so this task should be implemented in
servers. POHMELFS and multiple-server-write can be used as backup solution
for the physically distributed network servers.

Currently development is concentrated on the distributed object-based
server development implemeneted with distributed hash table design approach
in mind, which main goals it completely transparent from client point of
view node management, full absence of any controlling central servers
(points of failure), transaction/history based object storage.

POHMELFS utilizes writeback cache, which is built on top of MO(E)SI-like
coherency protocol. It uses scalable cached read/write locking. No additional
requests are performed if lock is granted to the filesystem. The same protocol
is used by the server to on-demand flushing of the client's cache (for
example when server wants to update local data or send some new content
into the clients caches).

POHMELFS is able to encrypt data channel or perform strong data checksumming.
Algorithms used by the filesystems are autoconfigured during startup and
mount may fail (depending on options) if server does not support requested
algorithms.

Autoconfiguration also involve sending information about size of the exported
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

One can grab sources from archive or GIT tree (web interface).

1. POHMELFS homepage.
http://www.ioremap.net/projects/pohmelfs

2. POHMELFS archive.
http://www.ioremap.net/archive/pohmelfs/

3. POHMELFS git tree.
http://www.ioremap.net/cgi-bin/gitweb.cgi

4. POHMELFS maillist.
pohmelfs @ ioremap.net

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

.../filesystems/pohmelfs/design_notes.txt          |   70 +
 Documentation/filesystems/pohmelfs/info.txt        |   86 +
 .../filesystems/pohmelfs/network_protocol.txt      |  227 +++
 fs/Kconfig                                         |    2 +
 fs/Makefile                                        |    1 +
 fs/pohmelfs/Kconfig                                |   23 +
 fs/pohmelfs/Makefile                               |    3 +
 fs/pohmelfs/config.c                               |  478 +++++
 fs/pohmelfs/crypto.c                               |  880 +++++++++
 fs/pohmelfs/dir.c                                  | 1139 +++++++++++
 fs/pohmelfs/inode.c                                | 2085 ++++++++++++++++++++
 fs/pohmelfs/lock.c                                 |  186 ++
 fs/pohmelfs/mcache.c                               |  171 ++
 fs/pohmelfs/net.c                                  | 1180 +++++++++++
 fs/pohmelfs/netfs.h                                |  934 +++++++++
 fs/pohmelfs/path_entry.c                           |  356 ++++
 fs/pohmelfs/trans.c                                |  704 +++++++
 mm/filemap.c                                       |    2 +
 18 files changed, 8527 insertions(+), 0 deletions(-)


