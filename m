From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [RFC PATCH 0/6] ppp: add rtnetlink support
Date: Tue, 5 Apr 2016 02:56:17 +0200
Message-ID: <cover.1459807527.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-ppp@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:55780 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673AbcDEA4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 20:56:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PPP devices lack the ability to be customised at creation time. In
particular they can't be created in a given netns or with a particular
name. Moving or renaming the device after creation is possible, but
creates undesirable transient effects on servers where PPP devices are
constantly created and removed, as users connect and disconnect.
Implementing rtnetlink support solves this problem.

The rtnetlink handlers implemented in this series are minimal, and can
only replace the PPPIOCNEWUNIT ioctl. The rest of PPP ioctls remains
necessary for any other operation on channels and units.
It is perfectly to possible to mix PPP devices created by rtnl
and by ioctl(PPPIOCNEWUNIT). Devices will behave in the same way,
except for a few specific cases (as detailed in patch #6).


I'm sending the series only as RFC this time, because there are a few
points I'm unsatisfied with.

First, I'm not fond of passing file descriptors as netlink attributes,
as done with IFLA_PPP_DEV_FD (which is filled with a /dev/ppp fd). But
given how PPP units work, we have to associate a /dev/ppp fd somehow.

More importantly, the locking constraints of PPP are quite problematic.
The rtnetlink handler has to associate the new PPP unit with the
/dev/ppp file descriptor passed as parameter. This requires holding the
ppp_mutex (see e8e56ffd9d29 "ppp: ensure file->private_data can't be
overridden"), while the rtnetlink callback is already protected by
rtnl_lock(). Since other parts of the module take these locks in
reverse order, most of this series deals with preparing the code for
inverting the dependency between rtnl_lock and ppp_mutex. Some more
work is needed on that part (see patch #4 for details), but I wanted
to be sure that approach it worth it before spending some more time on
it.


Other approach

I've considered another approach where no /dev/ppp file descriptor
is associated to the PPP unit at creation time. This removes all the
problems described above. The PPP interface that is created behaves
mostly like a dummy device until it gets associated with a /dev/ppp
file descriptor (using the PPPIOCATTACH ioctl).
The problem here is that, AFAIK, we can't return the unit identifier of
the new PPP device to the user space program having issued the
RTM_NEWLINK message. This identifier is required for the
ioctl(PPPIOCATTACH) call. Of course we could return such information
in an RTM_GETLINK message, but the user would need to query the device
name that was created. This would only work for users that can set the
IFLA_IFNAME attribute in their original RTM_NEWLINK message.


Patch series

Patches 1 to 3 prepare the code for inverting lock ordering between
ppp_mutex and rtnl_lock. Patch #4 does the lock inversion.
The actual infrastructure is implemented in patches #5 and #6.


Changes since v1:
  - Rebase on net-next.
  - Invert locking order wrt. ppp_mutex and rtnl_lock and protect
    file->private_data with ppp_mutex.


Guillaume Nault (6):
  ppp: simplify usage of ppp_create_interface()
  ppp: don't hold ppp_mutex before calling ppp_unattached_ioctl()
  ppp: don't lock ppp_mutex while handling PPPIOCDETACH
  ppp: invert lock ordering between ppp_mutex and rtnl_lock
  ppp: define reusable device creation functions
  ppp: add rtnetlink device creation support

 drivers/net/ppp/ppp_generic.c | 385 ++++++++++++++++++++++++++++++------------
 include/uapi/linux/if_link.h  |   8 +
 2 files changed, 286 insertions(+), 107 deletions(-)

-- 
2.8.0.rc3
