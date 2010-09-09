From: Andy Grover <andy.grover-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: net-next pull request: RDS
Date: Thu, 09 Sep 2010 11:51:08 -0700
Message-ID: <4C892C9C.4060304@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: RDS Devel <rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Sorry for the "release late, release seldom". We've made a lot of 
changes since spring but it never really stabilized..

Summary:
   * Add atomic operations (cswp and fadd) and masked versions
   * New RDS_RDMA_SILENT flag will try to execute RDMA op without
     causing an interrupt on the target machine
   * Massive performance improvements on big boxes (Chris Mason)
   * Many rmmod refcounting fixes (Zach Brown)
   * Do much more from tasklets instead of the worker thread
   * Add rds.h to kernel exported headers list
   * Other cleanups

Thanks -- Regards -- Andy

------
The following changes since commit db40980fcdb560d7992b0511df16cdd3f7e381f3:
   Eric Dumazet (1):
         net: poll() optimizations

are available in the git repository at:

   git://oss.oracle.com/git/agrover/linux-2.6.git for-davem

Andy Grover (66):
       RDS: Fix BUG_ONs to not fire when in a tasklet
       RDS: Rewrite rds_send_drop_to() for clarity
       RDS: Fix locking in send on m_rs_lock
       RDS: move rds_shutdown_worker impl. to rds_conn_shutdown
       RDS: cleanup: remove "== NULL"s and "!= NULL"s in ptr comparisons
       RDS: break out rdma and data ops into nested structs in rds_message
       RDS: cleanup/fix rds_rdma_unuse
       RDS: Explicitly allocate rm in sendmsg()
       RDS: fold rdma.h into rds.h
       RDS: make m_rdma_op a member of rds_message
       RDS: make sure all sgs alloced are initialized
       RDS: Clear up some confusing code in send_remove_from_sock
       RDS: Implement atomic operations
       RDS: Base init_depth and responder_resources on hw values
       RDS: Do not mask address when pinning pages
       RDS: Whitespace
       RDS: inc_purge() transport function unused - remove it
       RDS/IB: eliminate duplicate code
       RDS/IB: Disallow connections less than RDS 3.1
       RDS/IB: Remove dead code
       RDS/IB: Remove ib_[header/data]_sge() functions
       RDS: rewrite rds_ib_xmit
       RDS: Remove unsignaled_bytes sysctl
       RDS/IB: Make all flow control code conditional on i_flowctl
       RDS: Move loop-only function to loop.c
       RDS: Implement silent atomics
       RDS: Inline rdma_prepare into cmsg_rdma_args
       RDS: purge atomic resources too in rds_message_purge()
       RDS: Remove struct rds_rdma_op
       RDS: Rename data op members prefix from m_ to op_
       RDS: Rewrite rds_send_xmit
       RDS: Do not set op_active in r_m_copy_from_user().
       RDS: Add a warning if trying to allocate 0 sgs
       RDS: queue failure notifications for dropped atomic ops
       RDS: Move some variables around for consistency
       RDS: Add flag for silent ops. Do atomic op before RDMA
       RDS: Make sure cmsgs aren't used in improper ways
       RDS: Perform unmapping ops in stages
       RDS/IB: Do not wait for send ring to be empty on conn shutdown
       RDS: Stop supporting old cong map sending method
       RDS: Refill recv ring directly from tasklet
       RDS: Change send lock from a mutex to a spinlock
       RDS: rds_send_xmit() locking/irq fixes
       RDS: Call rds_send_xmit() directly from sendmsg()
       RDS: Bypass workqueue when queueing cong updates
       RDS: Use NOWAIT in message_map_pages()
       RDS: Fix locking in send on m_rs_lock
       RDS: rds_message_unmapped() doesn't need to check if queue active
       RDS: Move atomic stats from general to ib-specific area
       RDS: Remove send_quota from send_xmit()
       RDS: Do wait_event_interruptible instead of wait_event
       RDS: Get pong working again
       RDS: Update comments in rds_send_xmit()
       RDS/IB: Remove unused variable in ib_remove_addr()
       RDS/IB: add _to_node() macros for numa and use {k,v}malloc_node()
       RDS: Use page_remainder_alloc() for recv bufs
       RDS: Assume recv->r_frag is always NULL in refill_one()
       RDS/IB: Remove ib_recv_unmap_page()
       RDS: whitespace
       RDS: Remove unused XLIST_PTR_TAIL and xlist_protect()
       RDS/IB: Make ib_recv_refill return void
       RDS/IB: Use SLAB_HWCACHE_ALIGN flag for kmem_cache_create()
       RDS: Implement masked atomic operations
       RDS: Add rds.h to exported headers list
       RDS: rds.h: Replace u_int[size]_t with uint[size]_t
       RDS: Remove dead struct from rds.h

Chris Mason (17):
       RDS: Use a generation counter to avoid rds_send_xmit loop
       rds: switch to rwlock on bind_lock
       rds: per-rm flush_wait waitq
       rds: rcu-ize rds_ib_get_device()
       rds: Use RCU for the bind lookup searches
       rds: don't let RDS shutdown a connection while senders are present
       rds: Fix RDMA message reference counting
       RDS: use locking on the connection hash list
       rds: use RCU to protect the connection hash
       rds: Fix reference counting on the for xmit_atomic and xmit_rdma
       RDS/IB: Add caching of frags and incs
       RDS: use friendly gfp masks for prefill
       rds: recycle FMRs through lockless lists
       rds: more FMRs are faster
       RDS: use delayed work for the FMR flushes
       RDS: properly use sg_init_table
       RDS: flush fmrs before allocating new ones

Tina Yang (1):
       RDS: Fix corrupted rds_mrs

Zach Brown (23):
       RDS/IB: rds_ib_cm_handle_connect() forgot to unlock c_cm_lock
       RDS/IB: get the xmit max_sge from the RDS IB device on the connection
       RDS/IB: add refcount tracking to struct rds_ib_device
       RDS: introduce rds_conn_connect_if_down()
       RDS/IB: disconnect when IB devices are removed
       rds: remove unused rds_send_acked_before()
       rds: block ints when acquiring c_lock in rds_conn_message_info()
       rds: fix rds_send_xmit() serialization
       RDS/IB: wait for IB dev freeing work to finish during rmmod
       RDS/IB: destroy connections on rmmod
       RDS/IB: create a work queue for FMR flushing
       RDS: return to a single-threaded krdsd
       RDS/IB: always process recv completions
       RDS: remove __init and __exit annotation
       RDS/IB: track signaled sends
       RDS/IB: print IB event strings as well as their number
       RDS/IB: protect the list of IB devices
       RDS: lock rds_conn_count decrement in rds_conn_destroy()
       RDS: remove old rs_transport comment
       RDS: have sockets get transport module references
       RDS: don't call rds_conn_shutdown() from rds_conn_destroy()
       RDS: cancel connection work structs as we shut down
       RDS/IB: print string constants in more places

  include/linux/Kbuild     |    1 +
  include/linux/rds.h      |  106 +++++---
  net/rds/af_rds.c         |   26 ++-
  net/rds/bind.c           |   82 +++---
  net/rds/cong.c           |    8 +-
  net/rds/connection.c     |  157 ++++++++---
  net/rds/ib.c             |  194 +++++++++++---
  net/rds/ib.h             |  100 ++++----
  net/rds/ib_cm.c          |  183 +++++++++----
  net/rds/ib_rdma.c        |  314 +++++++++++++++++-----
  net/rds/ib_recv.c        |  549 ++++++++++++++++++++++---------------
  net/rds/ib_send.c        |  682 
+++++++++++++++++++++++++++-------------------
  net/rds/ib_stats.c       |    2 +
  net/rds/ib_sysctl.c      |   17 +-
  net/rds/info.c           |   12 +-
  net/rds/iw.c             |    4 +-
  net/rds/iw.h             |   11 +-
  net/rds/iw_cm.c          |   14 +-
  net/rds/iw_rdma.c        |    1 -
  net/rds/iw_recv.c        |   24 +-
  net/rds/iw_send.c        |   93 ++++---
  net/rds/iw_sysctl.c      |    4 +-
  net/rds/loop.c           |   31 ++-
  net/rds/message.c        |  118 +++++----
  net/rds/page.c           |    5 +-
  net/rds/rdma.c           |  339 +++++++++++++++--------
  net/rds/rdma.h           |   85 ------
  net/rds/rdma_transport.c |   42 +++-
  net/rds/rds.h            |  187 +++++++++++---
  net/rds/recv.c           |    9 +-
  net/rds/send.c           |  544 ++++++++++++++++++++++---------------
  net/rds/stats.c          |    6 +-
  net/rds/sysctl.c         |    4 +-
  net/rds/tcp.c            |    8 +-
  net/rds/tcp.h            |    9 +-
  net/rds/tcp_connect.c    |    2 +-
  net/rds/tcp_listen.c     |    6 +-
  net/rds/tcp_recv.c       |   14 +-
  net/rds/tcp_send.c       |   66 +----
  net/rds/threads.c        |   69 +----
  net/rds/transport.c      |   19 +-
  net/rds/xlist.h          |   80 ++++++
  42 files changed, 2614 insertions(+), 1613 deletions(-)
  delete mode 100644 net/rds/rdma.h
  create mode 100644 net/rds/xlist.h
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
