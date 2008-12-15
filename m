From: Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: hardware time stamping with optional structs in data area
Date: Mon, 15 Dec 2008 15:54:47 +0100
Message-ID: <1229352899-31330-1-git-send-email-patrick.ohly@intel.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is the third iteration of a patch series which adds a user space
API for hardware time stamping of network packets and the
infrastructure that implements that API. The igb driver is used as
example for how a network driver can use this new infrastructure.
The patches are based on net-next as of today.

This proposal is based on adding just a short flag field to struct
sk_buff itself, with the actual new information stored in the data
area if indicated by the flags. This is based on the suggestion by
Oliver Hartkopp and modelled after the way how skb_shared_info is
stored. The previous two revisions of the patch reused skb->tstamp
resp. added skb->hwtstamp.

The latest approach is more flexible: it allows adding more optional
information in the future. It turned out to be a bit harder to use by
drivers, though. The igb driver allocates the skb for incoming packets
in advance. At that time it is not yet known which packets will need
the extra space for hardware time stamps. The current example igb
patch just allocates that space for all packets, all the time. More
efficient solutions would be possible.

The functions which allocate an skb had to be modified so that
the new flags can be passed down to __netdev_alloc_skb(). I renamed
functions as necessary, so that existing code should continue to
work without changes. In sock_alloc_send_skb_flags() (formerly
known as sock_alloc_send_skb_pskb()) I removed some dead code (see
patch 04/12).

As discussed with John Stultz, the changes to clocksource.[ch]
now adds new structures as needed. John, I chose not to add new files
for these. Please let me know whether you agree with that approach,
see patch 09/12 for details.

The user space API is still as it was designed for the previous two
implementations. IMHO this shows that it was flexible enough to cope
with changes in the implementation. On the other hand some of its
aspects (user space has fine-grained control over what information
is gathered and provided by the kernel) might be seen as overkill
now that drivers can add this information more easily.

I think the API still makes sense because the additional information
might be used for optimizations in the future (drivers could
skip time stamp conversion if no-one is interested).

Also fixed in this iteration:
* comment style, too many/large inline functions (pointed out by Andrew Morton)
* __KERNEL__ instead __kernel__, user space API now in linux/net_tstamp.h (David Miller)

Bye, Patrick

 Documentation/networking/timestamping.txt          |  180 ++++++++
 Documentation/networking/timestamping/.gitignore   |    1 +
 Documentation/networking/timestamping/Makefile     |    3 +
 .../networking/timestamping/timestamping.c         |  469 ++++++++++++++++++++
 arch/x86/include/asm/socket.h                      |    3 +
 drivers/net/igb/e1000_82575.h                      |    1 +
 drivers/net/igb/e1000_defines.h                    |    1 +
 drivers/net/igb/e1000_regs.h                       |   68 +++
 drivers/net/igb/igb.h                              |    8 +
 drivers/net/igb/igb_main.c                         |  397 ++++++++++++++++-
 fs/compat_ioctl.c                                  |    1 +
 include/linux/clocksource.h                        |   99 ++++
 include/linux/clocksync.h                          |   85 ++++
 include/linux/errqueue.h                           |    1 +
 include/linux/net_tstamp.h                         |  104 +++++
 include/linux/skbuff.h                             |  196 ++++++++-
 include/linux/sockios.h                            |    3 +
 include/net/ip.h                                   |    1 +
 include/net/sock.h                                 |   57 ++-
 kernel/time/Makefile                               |    2 +-
 kernel/time/clocksource.c                          |   76 ++++
 kernel/time/clocksync.c                            |  182 ++++++++
 net/can/raw.c                                      |   14 +-
 net/compat.c                                       |   19 +-
 net/core/dev.c                                     |   36 ++-
 net/core/skbuff.c                                  |  139 +++++-
 net/core/sock.c                                    |  129 +++---
 net/ipv4/icmp.c                                    |    2 +
 net/ipv4/ip_output.c                               |   18 +-
 net/ipv4/raw.c                                     |    1 +
 net/ipv4/udp.c                                     |    4 +
 net/socket.c                                       |   86 +++-
 32 files changed, 2258 insertions(+), 128 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
