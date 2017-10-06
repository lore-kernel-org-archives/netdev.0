From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][for-next 0/9] Mellanox, mlx5 updates 2017-10-06
Date: Fri,  6 Oct 2017 16:37:40 -0700
Message-ID: <20171006233749.25545-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49732 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752278AbdJFXiK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 19:38:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave and Doug,

This series includes some shared code updates for kernel 4.15 to both
net-next and rdma-next trees.

The series includes mlx5 low level flow steering updates and optimizations
to support firmware command parallelism for flow steering requests from
Maor Gottlieb and two other small fixes from Matan and Maor.

One fix from Matan adds error handling for when the destination
list of the flow steering rule is full.

Maor introduced a patch to avoid NULL pointer dereference on steering cleanup.

Then Some refactoring patches needed by the series for code sharing purposes.
and split the Flow Table Entry (FTE) and Flow Group (FG) creation code to two parts:
    1) Object allocation - allocate the steering node and initialize
    its resources.

    2) The firmware command execution.

This change will give us the ability to take write lock on the 
parent node (e.g. FG for FTE creating) only on the software data struct allocation
and creation part of the procedure where the synchronization is really required,
and will allow us to execute multiple firmware commands simultaneously and overcome the 
firmware bottleneck.

Refactor the locking scheme of the mlx5 core flow steering as follows:

1) Replace the mutex lock with readers-writers semaphore and take
    the write lock only when necessary (e.g. allocating a new flow
    table entry index or adding a node to the parent's children list).
    When we try to find a suitable child in the parent's children list
    (e.g. search for flow group with the same match_criteria of the rule)
    then we only take the read lock.

2) Add versioning mechanism - each steering entity (FT, FG, FTE, DST)
    will have an incremental version. The version is increased when the 
    entity is changed (e.g. when a new FTE was added to FG - the FG's
    version is increased).
    Versioning is used in order to determine if the last traverse of an
    entity's children is valid or a rescan under write lock is required.

Last patch adds FGs and FTEs memory pool, It is useful because these objects 
are not small and could be allocated/deallocated many times.

This support improves the insertion rate of steering rules
from ~5k/sec to ~40k/sec.

Please pull and let me knwo if there's any problem.

Thanks,
Saeed

---

The following changes since commit e19b205be43d11bff638cad4487008c48d21c103:

  Linux 4.14-rc2 (2017-09-24 16:38:56 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mellanox/linux.git tags/mlx5-updates-2017-10-06

for you to fetch changes up to a369d4ac4dff92129ea0dfa3d66f45a830e29098:

  net/mlx5: Add FGs and FTEs memory pool (2017-09-26 20:52:05 +0300)

----------------------------------------------------------------
Maor Gottlieb (8):
      net/mlx5: Avoid NULL pointer dereference on steering cleanup
      net/mlx5: Move the entry index allocator to flow group
      net/mlx5: Export building of matched flow groups list
      net/mlx5: Refactor FTE and FG creation code
      net/mlx5: Replace fs_node mutex with reader/writer semaphore
      net/mlx5: Support multiple updates of steering rules in parallel
      net/mlx5: Allocate FTE object without lock
      net/mlx5: Add FGs and FTEs memory pool

Matan Barak (1):
      net/mlx5: Fix creating a new FTE when an existing but full FTE exists

 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 853 ++++++++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |  11 +-
 2 files changed, 547 insertions(+), 317 deletions(-)
