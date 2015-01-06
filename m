From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 0/5] Involve
	rhashtable_lookup_insert routine
Date: Tue, 6 Jan 2015 15:23:18 +0800
Message-ID: <1420529003-22244-1-git-send-email-ying.xue@windriver.com>
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

Ying Xue (5):
  rhashtable: optimize rhashtable_lookup routine
  rhashtable: introduce rhashtable_wakeup_worker helper function
  rhashtable: use future table size to make expansion decision
  rhashtable: involve rhashtable_lookup_insert routine
  tipc: convert tipc reference table to use generic rhashtable

 include/linux/rhashtable.h |    1 +
 lib/rhashtable.c           |  162 ++++++++++-----
 net/tipc/Kconfig           |   12 --
 net/tipc/config.c          |   24 +--
 net/tipc/core.c            |   10 +-
 net/tipc/core.h            |    3 -
 net/tipc/socket.c          |  480 ++++++++++++++++----------------------------
 net/tipc/socket.h          |    4 +-
 8 files changed, 296 insertions(+), 400 deletions(-)

-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
