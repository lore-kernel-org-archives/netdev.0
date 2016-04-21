From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [RFC PATCH v3 0/2] ppp: add rtnetlink support
Date: Thu, 21 Apr 2016 18:22:48 +0200
Message-ID: <cover.1461251392.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-ppp@vger.kernel.org, David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	walter harms <wharms@bfs.de>
To: netdev@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PPP devices lack the ability to be customised at creation time. In
particular they can't be created in a given netns or with a particular
name. Moving or renaming the device after creation is possible, but
creates undesirable transient effects on servers where PPP devices are
constantly created and removed, as users connect and disconnect.
Implementing rtnetlink support solves this problem.

The rtnetlink handlers implemented in this series are minimal, and can
only replace the PPPIOCNEWUNIT ioctl. The rest of PPP ioctls remains
necessary for any other operation on channels and units.
It is perfectly possible to mix PPP devices created by rtnl
and by ioctl(PPPIOCNEWUNIT). Devices will behave in the same way.

If necessary, rtnetlink support could be extended to provide some of
the functionalities brought by ppp_net_ioctl() and ppp_ioctl(). This
would let external programs, like "ip link", set or retrieve PPP device
information. However, I haven't made my mind on the usefulness of this
approach, so this isn't implemented in this series.


This series doesn't try to invert lock ordering between ppp_mutex and
rtnl_lock. mutex_trylock() is used instead, which greatly simplifies
things.
A user visible difference brought by this series is that old PPP
interfaces (those created with ioctl(PPPIOCNEWUNIT)), can now be
removed by "ip link del", just like new rtnl based PPP devices.


Changes since v2:
  - Define ->rtnl_link_ops for ioctl based PPP devices, so they can
    handle rtnl messages just like rtnl based ones (suggested by
    Stephen Hemminger).
  - Move back to original lock ordering between ppp_mutex and rtnl_lock
    to simplify patch series. Handle lock inversion issue using
    mutex_trylock() (suggested by Stephen Hemminger).
  - Do file descriptor lookup directly in ppp_nl_newlink(), to simplify
    ppp_dev_configure().

Changes since v1:
  - Rebase on net-next.
  - Invert locking order wrt. ppp_mutex and rtnl_lock and protect
    file->private_data with ppp_mutex.


Guillaume Nault (2):
  ppp: define reusable device creation functions
  ppp: add rtnetlink device creation support

 drivers/net/ppp/ppp_generic.c | 315 ++++++++++++++++++++++++++++++------------
 include/uapi/linux/if_link.h  |   8 ++
 2 files changed, 235 insertions(+), 88 deletions(-)

-- 
2.8.1

