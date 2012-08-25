From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [REVIEW][PATCH 0/15] userns subsystem conversions
Date: Sat, 25 Aug 2012 16:54:59 -0700
Message-ID: <87lih2h6i4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patchset updates all of the major linux subsystems that use uids
and gids to store them in kuid_t and kgid_t types.

This update allows some of the subsystems to work in all user namespaces
while other subsystems were updated to only work in the initial user
namespace.

kuid_t and kgid_t values have been pushed as deeply into the code as
possible to allow type checking to find as many problems as possible.
In a couple of cases this involved taking an implicit union stored in
an unsigned int and making it an explicit union.

This patchset is based on 3.6-rc1 and strictly against:
git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-next

My intention after these patches have been reviewed is to add them to my
non-rebasing for-next branch of my user namespace tree and to merge
these changes into 3.7.

I had hoped when I converted the core kernel that I would have removed
the interactions between subsystems and would be able to merge these
changes independently through maintainer trees in a timely fashion, but
there are just enough dependencies and interactions that the changes
really all need to be in one tree to make these changes testable/usable.

Once these changes hit my for-next branch I won't be rebasing them so
if a maintainer wants to merge them to avoid conflicts feel free.

The biggest cross subystem change this round is probably the change
to have audit_get_loginuid return a kuid_t, but it certainly isn't
the only cross subsystem change.

Eric W. Biederman (15):
      userns: Enable building of pf_key sockets when user namespace support is enabled.
      userns: Make credential debugging user namespace safe.
      userns: Convert security/keys to the new userns infrastructure
      userns: net: Call key_alloc with GLOBAL_ROOT_UID, GLOBAL_ROOT_GID instead of 0, 0
      userns: Convert ipc to use kuid and kgid where appropriate
      userns: Convert audit to use kuid and kgid where appropriate
      userns: Convert taskstats to handle the user and pid namespaces.
      userns: Convert bsd process accounting to use kuid and kgid where appropriate
      userns: Convert process event connector to handle kuids and kgids
      userns: Convert debugfs to use kuid/kgid where appropriate.
      userns: Teach trace to use from_kuid
      userns: Convert drm to use kuid and kgid and struct pid where appropriate
      userns: Add basic quota support
      userns: Convert vfs posix_acl support to use kuid and kgid where appripriate.
      userns: Convert configfs to use kuid and kgid where appropriate

 drivers/connector/cn_proc.c       |   18 +++-
 drivers/gpu/drm/drm_fops.c        |    3 +-
 drivers/gpu/drm/drm_info.c        |    5 +-
 drivers/gpu/drm/drm_ioctl.c       |    4 +-
 drivers/tty/tty_audit.c           |   16 ++--
 fs/9p/acl.c                       |    8 +-
 fs/btrfs/acl.c                    |    8 +-
 fs/configfs/inode.c               |    4 +-
 fs/debugfs/inode.c                |   26 +++--
 fs/ext2/acl.c                     |   32 ++++--
 fs/ext3/acl.c                     |   32 ++++--
 fs/ext4/acl.c                     |   31 ++++--
 fs/generic_acl.c                  |    4 +-
 fs/gfs2/acl.c                     |   14 ++--
 fs/gfs2/quota.c                   |   44 +++++---
 fs/jffs2/acl.c                    |    4 +-
 fs/jfs/acl.c                      |    4 +-
 fs/jfs/xattr.c                    |    4 +-
 fs/nfs/nfs3acl.c                  |    4 +-
 fs/nfsd/vfs.c                     |    8 +-
 fs/ocfs2/acl.c                    |    4 +-
 fs/ocfs2/file.c                   |    6 +-
 fs/ocfs2/quota_global.c           |   34 +++++--
 fs/ocfs2/quota_local.c            |   12 ++-
 fs/posix_acl.c                    |   30 +++---
 fs/proc/base.c                    |   12 ++-
 fs/quota/dquot.c                  |   43 ++++----
 fs/quota/netlink.c                |   11 ++-
 fs/quota/quota.c                  |   44 +++++---
 fs/quota/quota_tree.c             |   20 +++-
 fs/quota/quota_v1.c               |    8 +-
 fs/quota/quota_v2.c               |   14 ++-
 drivers/connector/cn_proc.c       |   18 +++-
 drivers/gpu/drm/drm_fops.c        |    3 +-
 drivers/gpu/drm/drm_info.c        |    5 +-
 drivers/gpu/drm/drm_ioctl.c       |    4 +-
 drivers/tty/tty_audit.c           |   16 ++--
 fs/9p/acl.c                       |    8 +-
 fs/btrfs/acl.c                    |    8 +-
 fs/configfs/inode.c               |    4 +-
 fs/debugfs/inode.c                |   26 +++--
 fs/ext2/acl.c                     |   32 ++++--
 fs/ext3/acl.c                     |   32 ++++--
 fs/ext4/acl.c                     |   31 ++++--
 fs/generic_acl.c                  |    4 +-
 fs/gfs2/acl.c                     |   14 ++--
 fs/gfs2/quota.c                   |   44 +++++---
 fs/jffs2/acl.c                    |    4 +-
 fs/jfs/acl.c                      |    4 +-
 fs/jfs/xattr.c                    |    4 +-
 fs/nfs/nfs3acl.c                  |    4 +-
 fs/nfsd/vfs.c                     |    8 +-
 fs/ocfs2/acl.c                    |    4 +-
 fs/ocfs2/file.c                   |    6 +-
 fs/ocfs2/quota_global.c           |   34 +++++--
 fs/ocfs2/quota_local.c            |   12 ++-
 fs/posix_acl.c                    |   30 +++---
 fs/proc/base.c                    |   12 ++-
 fs/quota/dquot.c                  |   43 ++++----
 fs/quota/netlink.c                |   11 ++-
 fs/quota/quota.c                  |   44 +++++---
 fs/quota/quota_tree.c             |   20 +++-
 fs/quota/quota_v1.c               |    8 +-
 fs/quota/quota_v2.c               |   14 ++-
 fs/reiserfs/xattr_acl.c           |    4 +-
 fs/xattr.c                        |    7 ++
 fs/xattr_acl.c                    |   96 +++++++++++++++--
 fs/xfs/xfs_acl.c                  |    4 +-
 fs/xfs/xfs_quotaops.c             |   18 ++--
 fs/xfs/xfs_trans_dquot.c          |    8 +-
 include/drm/drmP.h                |    4 +-
 include/linux/audit.h             |   12 ++-
 include/linux/init_task.h         |    2 +-
 include/linux/ipc.h               |    9 +-
 include/linux/key.h               |    9 +-
 include/linux/posix_acl.h         |    8 ++-
 include/linux/posix_acl_xattr.h   |   18 +++-
 include/linux/quota.h             |   91 +++++++++++++++-
 include/linux/quotaops.h          |   18 +++-
 include/linux/sched.h             |    2 +-
 include/linux/tsacct_kern.h       |    8 +-
 include/linux/tty.h               |    4 +-
 include/net/netlabel.h            |    2 +-
 include/net/xfrm.h                |   23 ++--
 init/Kconfig                      |   18 ---
 ipc/msg.c                         |   14 ++-
 ipc/sem.c                         |   13 ++-
 ipc/shm.c                         |   19 ++--
 ipc/util.c                        |   35 ++++---
 ipc/util.h                        |    2 +-
 kernel/acct.c                     |    4 +-
 kernel/audit.c                    |   42 +++++---
 kernel/audit.h                    |    4 +-
 kernel/audit_watch.c              |    2 +-
 kernel/auditfilter.c              |  142 +++++++++++++++++++++----
 kernel/auditsc.c                  |  214 +++++++++++++++++++------------------
 kernel/cred.c                     |   10 ++-
 kernel/taskstats.c                |   23 +++-
 kernel/trace/trace.c              |    3 +-
 kernel/trace/trace.h              |    2 +-
 kernel/tsacct.c                   |   12 ++-
 net/core/dev.c                    |    2 +-
 net/dns_resolver/dns_key.c        |    3 +-
 net/netlabel/netlabel_unlabeled.c |    2 +-
 net/netlabel/netlabel_user.c      |    2 +-
 net/rxrpc/ar-key.c                |    6 +-
 net/xfrm/xfrm_policy.c            |    8 +-
 net/xfrm/xfrm_state.c             |    6 +-
 net/xfrm/xfrm_user.c              |   12 +-
 security/keys/internal.h          |    6 +-
 security/keys/key.c               |   23 ++---
 security/keys/keyctl.c            |   50 +++++----
 security/keys/keyring.c           |    4 +-
 security/keys/permission.c        |   14 +--
 security/keys/proc.c              |   44 ++++----
 security/keys/process_keys.c      |   15 ++--
 security/keys/request_key.c       |    6 +-
 85 files changed, 1056 insertions(+), 564 deletions(-)
