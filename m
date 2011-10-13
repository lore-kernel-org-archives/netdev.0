From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/5] Better namespace handling for /sys/class/net/bonding_masters
Date: Thu, 13 Oct 2011 00:47:46 -0700
Message-ID: <m1hb3dbae5.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Tejun Heo <htejun@gmail.com>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Greg Kroah-Hartman <gregkh@suse.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When I was looking at another sysfs issue that Al pointed out (since
fixed) I realized that I had implemented a trivial code size but overly
clever way to handle /sys/class/net/bonding_masters.

This patchset removes the support for untagged entries in tagged
directories (that is currently used to support bonding_masters)
and replaces it with support for tagged sysfs attributes.

In the process this fixes a small misfeature in how bonding_masters
derives the network namespace we are dealing with.  This change
allows bonding_masters to derive the network namespace from the
copy of bonding_masters we open instead of magically from current.

The final patch of this patchset adds sanity checks to sysfs.  To
ensure that we don't accidentally mishandle tagged sysfs entities.

I have tested this code against 3.1-rc9 on my laptop with a mostly yes
config and I am not seeing any problems.  The loud screaming warnings I
have added in the last patch should catch any corner cases in how people
use sysfs that I might have overlooked.

Greg, Dave I'm don't know whose tree to merge this through as this code
is equally device-core and networking.  I am hoping that we can get this
improvement merged for 3.2.

Farther out the simplifications introduced in this patchset make it much
easier to implement sysfs directories that can scale when there are
enormous numbers of entries in them.

Eric W. Biederman (5):
      sysfs: Implement support for tagged files in sysfs.
      class: Implement support for class attrs in tagged sysfs directories.
      bonding: Use a per netns implementation of /sys/class/net/bonding_masters.
      sysfs: Remove support for tagged directories with untagged members.
      sysfs: Reject with a warning invalid uses of tagged directories.

---
 drivers/base/class.c             |   17 ++++++++++-
 drivers/net/bonding/bond_main.c  |    7 +---
 drivers/net/bonding/bond_sysfs.c |   45 +++++++++++++++++++++---------
 drivers/net/bonding/bonding.h    |    7 +++-
 fs/sysfs/dir.c                   |   20 +++++++++++--
 fs/sysfs/file.c                  |   56 ++++++++++++++++++++++++++++++++++---
 fs/sysfs/inode.c                 |    2 -
 include/linux/device.h           |    2 +
 include/linux/sysfs.h            |    1 +
 9 files changed, 124 insertions(+), 33 deletions(-)

Eric
