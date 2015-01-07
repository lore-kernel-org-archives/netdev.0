From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2 0/7] Involve
	rhashtable_lookup_insert routine
Date: Wed, 7 Jan 2015 13:41:51 +0800
Message-ID: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net
To: <tgraf@suug.ch>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The series aims to involve rhashtable_lookup_insert() to guarantee
that the process of lookup and insertion of an object from/into hash
table is finished atomically, allowing rhashtable's users not to
introduce an extra lock during search and insertion. For example,
tipc socket is the first user benefiting from this enhancement. 

v2 changes:
 - fix the issue of waking up worker thread under a wrong condition in
   patch #2, which is pointed by Thomas.
 - move a comment from rhashtable_inser() to rhashtable_wakeup_worker()
   according to Thomas's suggestion in patch #2.
 - indent the third line of condition statement in
   rhashtable_wakeup_worker() to inner bracket in patch #2.
 - drop patch #3 of v1 series
 - fix an issue of being unable to remove an object from hash table in
   certain special case in patch #4.
 - involve a new patch #5 to avoid unnecessary wakeup for worker queue
   thread
 - involve a new patch #6 to initialize atomic "nelems" variable
 - adjust "nelem_hint" value from 256 to 192 avoiding to unnecessarily
   to shrink hash table from the beginning phase in patch #7.

v1 changes:
 But before rhashtable_lookup_insert() is involved, the following
 optimizations need to be first done:
- simplify rhashtable_lookup by reusing rhashtable_lookup_compare()
- introduce rhashtable_wakeup_worker() to further reduce duplicated
  code in patch #2
- fix an issue in patch #3
- involve rhashtable_lookup_insert(). But in this version, we firstly
  use rhashtable_lookup() to search duplicate key in both old and new
  bucket table; secondly introduce another __rhashtable_insert() helper
  function to reduce the duplicated code between rhashtable_insert()
  and rhashtable_lookup_insert().
- add patch #5 into the series as it depends on above patches. But in
  this version, no change is made comparing with its previous version.

Ying Xue (7):
  rhashtable: optimize rhashtable_lookup routine
  rhashtable: introduce rhashtable_wakeup_worker helper function
  rhashtable: involve rhashtable_lookup_insert routine
  rhashtable: future table needs to be traversed when remove an object
  rhashtable: avoid unnecessary wakeup for worker queue
  rhashtable: initialize atomic nelems variable
  tipc: convert tipc reference table to use generic rhashtable

 include/linux/rhashtable.h |    3 +-
 lib/rhashtable.c           |  182 +++++++++++------
 net/tipc/Kconfig           |   12 --
 net/tipc/config.c          |   24 +--
 net/tipc/core.c            |   10 +-
 net/tipc/core.h            |    3 -
 net/tipc/socket.c          |  480 ++++++++++++++++----------------------------
 net/tipc/socket.h          |    4 +-
 8 files changed, 306 insertions(+), 412 deletions(-)

-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
