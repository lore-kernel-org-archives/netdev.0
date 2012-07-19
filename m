From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH RESEND net/for-next V1 0/1] changes IPoIB neighbour handling
Date: Thu, 19 Jul 2012 19:15:01 +0300
Message-ID: <1342714502-11301-1-git-send-email-ogerlitz@mellanox.com>
Cc: linux-rdma@vger.kernel.org, erezsh@mellanox.com,
	netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: roland@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:44510 "HELO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751872Ab2GSQPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 12:15:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding netdev, as of the high relevancy, see V0 @
http://marc.info/?l=linux-rdma&m=134191474831867&w=2

changes from V0:

- following feedback from Mike and Dave, changed the ipoib_neigh hash table 
  to allow for lock-free read side, the model follows the RCU based implementation 
  in net/core/neighbour.c

- since RCU hash table uses unidirectional collision list, now ipoib_neigh_free 
  needs to do a linked search in order to find the deleted neighbour predecessor 
  in order to link it to the neighbour successor.

- different implementation of hash lookup in ipoib_neigh_get (read-side) 
  vs ipoib_neigh_alloc and ipoib_neigh_free (write-side)

- path_free and ipoib_mcast_free now make use of the ipoib_del_neighs_by_gid helper 
  function in order to delete neighbours related to that path or mcast. This new helper 
  scans the hash table and deletes neighbours with the given GID. It had to be done 
  this way of as  of the unidrectional nature of the linking which by itself 
  arises from the lock free requirement made here...

- a completion mechanism was added to prevent freeing the IPoIB netdevice priv 
  data structure before the RCU based code freed all the neighbours.

Again, the patch was made over net-next as of few IPoIB changes that 
took place there and the parallel submission of the eIPoIB driver. 

Or.

Shlomo Pongratz (1):
  IB/ipoib: break linkage to neighbouring system

 drivers/infiniband/ulp/ipoib/ipoib.h           |   59 ++-
 drivers/infiniband/ulp/ipoib/ipoib_cm.c        |   16 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c      |  638 +++++++++++++++++------
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |   57 +--
 4 files changed, 535 insertions(+), 235 deletions(-)

Cc: Shlomo Pongratz <shlomop@mellanox.com>
