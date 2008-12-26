From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: [0/7] Distributed storage release.
Date: Fri, 26 Dec 2008 14:56:09 +0300
Message-ID: <1230292576-23963-1-git-send-email-zbr@ioremap.net>
Cc: linux-kernel@vger.kernel.org, dst@ioremap.net,
	netdev@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavolo.yandex.ru ([87.250.244.45]:19123 "EHLO cavolo.yandex.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754291AbYLZL43 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Dec 2008 06:56:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

This is a maintenance distributed storage release, which includes a
rebase against the 2.6.28 kernel tree only.

DST is a network block device storage, which can be used to organize
exported storages on the remote nodes into the local block device.

Its main goal of the project is to allow creation of the block devices
on top of different network media and connect physically distributed devices
into single storage using existing network infrastructure and not
introducing new limitations into the protocol and network usage model.

DST works on top of any network media and protocol, it is just a matter
of configuration utility to understand the correct addresses. The most
common example is TCP over IP allows to pass through firewalls and
created remote backup storage in the different datacenter. DST requires
single port to be enabled on the exporting node and outgoing connections
on the local node.

DST works with in-kernel client and server, which improves the performance
eliminating unneded data copies and allows not to depend on the version
of the external IO components. It requires userspace configuration utility
though.

DST uses transaction model, when each store has to be explicitly acked
from the remote node to be considered as successfully written. There
may be lots of in-flight transactions. When remote host does not ack
the transaction it will be resent predefined number of times with specified
timeouts between them. All those parameters are configurable. Transactions
are marked as failed after all resends completed unsuccessfully, having
long enough resend timeout and/or large number of resends allows not to
return error to the higher (FS usually) layer in case of short network
problems or remote node outages. In case of network RAID setup this means
that storage will not degrade until transactions are marked as failed, and
thus will not force checksum recalculation and data rebuild. In case of
connection failure DST will try to reconnect to the remote node automatically.
DST sends ping commands at idle time to detect if remote node is alive.

Because of transactional model it is possible to use zero-copy sending
without worry of data corruption (which in turn could be detected by the
strong checksums though).

DST may fully encrypt the data channel in case of untrusted channel and implement
strong checksum of the transferred data. It is possible to configure algorithms
and crypto keys, they should match on both sides of the network channel.
Crypto processing does not introduce noticeble performance overhead, since DST
uses configurable pool of threads to perform crypto processing.
Kernel does not yet support pool of threads, so this part is embedded into the DST.

DST utilizes memory pool model of all its transaction allocations (it is the
only additional allocation on the client) and server allocations (bio pools,
while pages are allocated from the slab).

At startup DST performs a simple negotiation with the export node to determine
access permissions and size of the exported storage. It can be extended if
new parameters should be autonegotiated.

DST carries block IO flags in the protocol, which allows to transparently implement
barriers and sync/flush operations. Those flags are used in the export node where
IO against the local storage is performed, which means that sync write will be sync
on the remote node too, which in turn improves data integrity and improved resistance
to errors and data corruption during power outages or storage damages.

Patches were split on per-file basis, so tree in the middle of the series will not
compile, which should not be a problem, since kconfig/makefile changes are introduced
in the latest patch.

There is an open maillist for DST development and discussion at dst @ ioremap.net

Short list of supported features:
    * Kernel-side client and server. No need for any special tools for data processing
    	(like special userspace applications) except for configuration.
    * Bullet-proof memory allocations via memory pools for all temporary objects
    	(transaction and so on). All clients structures are allocated as single transaction
	from the memory pool and except this there is no allocation overhead. Network adds
	own though. Server uses memory pools too, but number of allocations is higher
	(bio, transaction and pages for IO).
    * Zero-copy sending (except header) if supported by device using sendpage().
    * Failover recovery in case of broken link (reconnection if remote node is down).
    * Full transaction support (resending of the failed transactions on timeout of after
    	reconnect to failed node).
    * Dynamically resizeable pool of threads used for data receiving and crypto processing.
    * Initial autoconfiguration. Ability to extend it with additional attributes if needed.
    * Support for barriers and other block io request flags.
    * Support for any kind of network media (not limited to tcp or inet protocols) higher
    	MAC layer (socket layer). Out of the box kernel-side IPv6 support (needs to extend
	configuration utility, check how it was done in POHMELFS).
    * Security attributes for local export nodes (list of allowed to connect addresses with
    	permissions). Read-only connections.
    * Ability to use any supported cryptographically strong checksums.
    	Ability to encrypt data channel.
    * Keepalive messages to early detect failed nodes.

1. DST homepage.
http://www.ioremap.net/projects/dst

2. DST archive.
http://www.ioremap.net/archive/dst/

3. GIT trees.
http://www.ioremap.net/cgi-bin/gitweb.cgi

4. DST mail list.
dst @ ioremap.net

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

 drivers/block/Kconfig           |    2 +
 drivers/block/Makefile          |    2 +
 drivers/block/dst/Kconfig       |   71 +++
 drivers/block/dst/Makefile      |    3 +
 drivers/block/dst/crypto.c      |  731 +++++++++++++++++++++++++++++
 drivers/block/dst/dcore.c       |  972 +++++++++++++++++++++++++++++++++++++++
 drivers/block/dst/export.c      |  664 ++++++++++++++++++++++++++
 drivers/block/dst/state.c       |  839 +++++++++++++++++++++++++++++++++
 drivers/block/dst/thread_pool.c |  345 ++++++++++++++
 drivers/block/dst/trans.c       |  335 ++++++++++++++
 include/linux/connector.h       |    4 +-
 include/linux/dst.h             |  587 +++++++++++++++++++++++
 12 files changed, 4554 insertions(+), 1 deletions(-)
