From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [call for review] netdev-related stuff in vfs.git
Date: Sat, 11 Apr 2015 22:17:42 +0100
Message-ID: <20150411211742.GJ889@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37854 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755871AbbDKVRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 17:17:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several commits sitting in vfs.git that probably ought to go in
via net-next.git.  First of all, there's merge with vfs.git#iocb - that's
Christoph's aio rework, which has triggered conflicts with the ->sendmsg()
and ->recvmsg() patches a while ago.  It's not so much Christoph's stuff
that ought to be in net-next, as (pretty simple) conflict resolution on merge.
The next chunk is switch to {compat_,}import_iovec/import_single_range - new
safer primitives for initializing iov_iter.  The primitives themselves come
from vfs/git#iov_iter (and they are used quite a lot in vfs part of queue),
conversion of net/socket.c syscalls belongs in net-next, IMO.  Next there's
afs and rxrpc stuff from dhowells.  And then there's sanitizing kernel_sendmsg
et.al.  + missing inlined helper for "how much data is left in msg->msg_iter" -
this stuff is used in e.g.  cifs stuff, but it belongs in net-next.

That pile is pullable from
git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git for-davem

I'll post the individual patches in there in followups; could you take a look
and tell if everything in there is OK with you?

Shortlog:
Al Viro (9):
      saner iov_iter initialization primitives
      Merge branch 'iocb' into for-davem
      Merge branch 'iov_iter' into for-davem
      net: switch sendto() and recvfrom() to import_single_range()
      net: switch importing msghdr from userland to {compat_,}import_iovec()
      switch kernel_sendmsg() and kernel_recvmsg() to iov_iter_kvec()
      get rid of the size argument of sock_sendmsg()
      Merge remote-tracking branch 'dh/afs' into for-davem
      new helper: msg_data_left()

Christoph Hellwig (5):
      fs: remove ki_nbytes
      fuse: handle synchronous iocbs internally
      fs: don't allow to complete sync iocbs through aio_complete
      fs: split generic and aio kiocb
      fs: move struct kiocb to fs.h

David Howells (5):
      RxRPC: Fix the conversion to iov_iter
      RxRPC: Don't call skb_add_data() if there's no data to copy
      RxRPC: Use iov_iter_count() in rxrpc_send_data() instead of the len argument
      AFS: afs_send_empty_reply() doesn't require an iovec array
      RxRPC: Handle VERSION Rx protocol packets

Nathaniel Wesley Filardo (1):
      kafs: Add more "unified AFS" error codes

Diffstat without #iocb part:
 crypto/algif_hash.c     |  4 +-
 crypto/algif_skcipher.c |  4 +-
 drivers/vhost/net.c     |  4 +-
 fs/afs/misc.c           | 16 +++++++-
 fs/afs/rxrpc.c          |  5 +--
 include/linux/net.h     |  2 +-
 include/linux/socket.h  |  5 +++
 include/linux/uio.h     | 14 +++++++
 include/net/compat.h    |  2 +-
 include/rxrpc/packet.h  |  3 +-
 lib/iov_iter.c          | 57 ++++++++++++++++++++++++++++
 net/compat.c            | 18 ++++-----
 net/core/datagram.c     |  2 +-
 net/ipv4/tcp.c          |  8 ++--
 net/rxrpc/ar-input.c    | 23 +++++++++++-
 net/rxrpc/ar-internal.h |  2 +
 net/rxrpc/ar-local.c    | 98 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/rxrpc/ar-output.c   | 53 +++++++++++++-------------
 net/socket.c            | 96 +++++++++++++++++-------------------------------
 net/sunrpc/svcsock.c    |  2 +-
 20 files changed, 296 insertions(+), 122 deletions(-)

Full diffstat:
 arch/s390/hypfs/inode.c                      |   2 +-
 crypto/algif_hash.c                          |   4 +-
 crypto/algif_skcipher.c                      |   6 +-
 drivers/char/mem.c                           |   2 +-
 drivers/char/tile-srom.c                     |   1 -
 drivers/infiniband/hw/ipath/ipath_file_ops.c |   1 -
 drivers/infiniband/hw/qib/qib_file_ops.c     |   1 -
 drivers/misc/mei/amthif.c                    |   1 -
 drivers/misc/mei/main.c                      |   1 -
 drivers/misc/mei/pci-me.c                    |   1 -
 drivers/scsi/sg.c                            |   2 +-
 drivers/staging/unisys/include/timskmod.h    |   1 -
 drivers/usb/gadget/function/f_fs.c           |   6 +-
 drivers/usb/gadget/legacy/inode.c            |   6 +-
 drivers/vhost/net.c                          |   4 +-
 fs/9p/vfs_addr.c                             |   2 +-
 fs/affs/file.c                               |   2 +-
 fs/afs/misc.c                                |  16 ++-
 fs/afs/rxrpc.c                               |   5 +-
 fs/afs/write.c                               |   1 -
 fs/aio.c                                     | 150 +++++++++++++++------------
 fs/bfs/inode.c                               |   1 +
 fs/block_dev.c                               |   1 -
 fs/btrfs/file.c                              |   2 +-
 fs/btrfs/inode.c                             |   2 +-
 fs/ceph/file.c                               |   3 +-
 fs/direct-io.c                               |   5 +-
 fs/ecryptfs/file.c                           |   7 --
 fs/ext2/inode.c                              |   2 +-
 fs/ext3/inode.c                              |   2 +-
 fs/ext4/file.c                               |   2 +-
 fs/ext4/indirect.c                           |   2 +-
 fs/ext4/inode.c                              |   1 -
 fs/ext4/page-io.c                            |   1 -
 fs/f2fs/data.c                               |   2 +-
 fs/fat/inode.c                               |   1 -
 fs/fuse/cuse.c                               |   2 +-
 fs/fuse/dev.c                                |   1 -
 fs/fuse/file.c                               |  55 ++++++----
 fs/fuse/fuse_i.h                             |   1 +
 fs/gfs2/aops.c                               |   2 +-
 fs/gfs2/file.c                               |   1 -
 fs/hfs/inode.c                               |   2 +-
 fs/hfsplus/inode.c                           |   2 +-
 fs/jfs/inode.c                               |   2 +-
 fs/nfs/direct.c                              |   4 +-
 fs/nfs/file.c                                |   1 -
 fs/nilfs2/inode.c                            |   2 +-
 fs/ntfs/file.c                               |   1 -
 fs/ntfs/inode.c                              |   1 -
 fs/ocfs2/aops.c                              |   1 +
 fs/ocfs2/aops.h                              |   2 +-
 fs/ocfs2/file.c                              |   8 +-
 fs/pipe.c                                    |   1 -
 fs/read_write.c                              |  35 ++-----
 fs/reiserfs/inode.c                          |   2 +-
 fs/splice.c                                  |   1 -
 fs/ubifs/file.c                              |   1 -
 fs/udf/file.c                                |   4 +-
 fs/udf/inode.c                               |   2 +-
 fs/xfs/xfs_aops.c                            |   1 -
 fs/xfs/xfs_file.c                            |   1 -
 include/linux/aio.h                          |  70 +------------
 include/linux/fs.h                           |  22 ++++
 include/linux/net.h                          |   2 +-
 include/linux/socket.h                       |   5 +
 include/linux/uio.h                          |  14 +++
 include/net/compat.h                         |   2 +-
 include/net/sock.h                           |   1 -
 include/rxrpc/packet.h                       |   3 +-
 kernel/printk/printk.c                       |   4 +-
 kernel/sysctl.c                              |   1 +
 lib/iov_iter.c                               |  57 ++++++++++
 mm/filemap.c                                 |   1 -
 mm/page_io.c                                 |   3 +-
 mm/shmem.c                                   |   2 +-
 net/compat.c                                 |  18 ++--
 net/core/datagram.c                          |   2 +-
 net/ipv4/raw.c                               |   1 -
 net/ipv4/tcp.c                               |   8 +-
 net/rxrpc/ar-input.c                         |  23 +++-
 net/rxrpc/ar-internal.h                      |   2 +
 net/rxrpc/ar-local.c                         |  98 +++++++++++++++++
 net/rxrpc/ar-output.c                        |  53 +++++-----
 net/socket.c                                 | 100 +++++++-----------
 net/sunrpc/svcsock.c                         |   2 +-
 sound/core/pcm_native.c                      |   2 +-
 87 files changed, 494 insertions(+), 387 deletions(-)
