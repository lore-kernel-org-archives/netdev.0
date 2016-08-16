From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH 0/5] Make /sys/class/net per net namespace objects belong to container
Date: Tue, 16 Aug 2016 15:33:10 -0700
Message-ID: <1471386795-32918-1-git-send-email-dmitry.torokhov@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are objects in /sys hierarchy (/sys/class/net/) that logically belong
to a namespace/container. Unfortunately all sysfs objects start their life
belonging to global root, and while we could change ownership manually,
keeping tracks of all objects that come and go is cumbersome. It would
be better if kernel created them using correct uid/gid from the beginning.

This series changes kernfs to allow creating object's with arbitrary
uid/gid, adds get_ownership() callback to ktype structure so subsystems
could supply their own logic (likely tied to namespace support) for
determining ownership of kobjects, and adjusts sysfs code to make use of
this information. Lastly net-sysfs is adjusted to make sure that objects in
net namespace are owned by the root user from the owning user namespace.

Note that we do not adjust ownership of objects moved into a new namespace
(as when moving a network device into a container) as userspace can easily
do it.

Thanks!

Dmitry Torokhov (5):
  kernfs: allow creating kernfs objects with arbitrary uid/gid
  sysfs, kobject: allow creating kobject belonging to arbitrary users
  kobject: kset_create_and_add() - fetch ownership info from parent
  driver core: set up ownership of class devices in sysfs
  net-sysfs: make sure objects belong to contrainer's owner

 drivers/base/core.c         |  9 +++++++++
 fs/kernfs/dir.c             | 29 ++++++++++++++++++++++++++---
 fs/kernfs/file.c            |  8 ++++++--
 fs/kernfs/inode.c           |  2 +-
 fs/kernfs/kernfs-internal.h |  2 ++
 fs/kernfs/symlink.c         | 11 ++++++++++-
 fs/sysfs/dir.c              |  7 ++++++-
 fs/sysfs/file.c             | 33 +++++++++++++++++++++------------
 fs/sysfs/group.c            | 23 +++++++++++++++++------
 fs/sysfs/sysfs.h            |  3 ++-
 include/linux/device.h      |  5 +++++
 include/linux/kernfs.h      | 28 +++++++++++++++++++---------
 include/linux/kobject.h     |  4 ++++
 kernel/cgroup.c             |  4 +++-
 lib/kobject.c               | 28 +++++++++++++++++++++++++++-
 net/core/net-sysfs.c        | 44 +++++++++++++++++++++++++++++++++++++++++++-
 16 files changed, 201 insertions(+), 39 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
