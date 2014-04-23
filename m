From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/5]: Preventing abuse when passing file descriptors
Date: Wed, 23 Apr 2014 14:24:47 -0700
Message-ID: <87a9bbeo2o.fsf_-_@x220.int.ebiederm.org>
References: <CALCETrWzUQ7QjykT85ExDfX-+9eDD-D-dcxofUMPvLK=ia9arg@mail.gmail.com>
	<87r44qrt8v.fsf_-_@x220.int.ebiederm.org>
	<87r44pnk3c.fsf@x220.int.ebiederm.org>
	<20140423.153216.1388028648299605195.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: vgoyal@redhat.com, ssorce@redhat.com, security@kernel.org,
	luto@amacapital.net, netdev@vger.kernel.org, serge@hallyn.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:50421 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339AbaDWVZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 17:25:20 -0400
In-Reply-To: <20140423.153216.1388028648299605195.davem@davemloft.net> (David
	Miller's message of "Wed, 23 Apr 2014 15:32:16 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Andy Lutomirski when looking at the networking stack noticed that it is
possible to trick privilged processes into calling write on a netlink
socket and send netlink messages they did not intend.

In particular from time to time there are suid applications that will
write to stdout or stderr without checking exactly what kind of file
descriptors those are and can be tricked into acting as a limited form
of suid cat.  In other conversations the magic string CVE-2014-0181 has
been used to talk about this issue.

This patchset cleans things up a bit, adds some clean abstractions that
when used prevent this kind of problem and then finally changes all of
the handlers of netlink messages that I could find that call capable to
use netlink_ns_capable or an appropriate wrapper.

The abstraction netlink_ns_capable verifies that the original creator of
the netlink socket a message is sent from had the necessary capabilities
as well as verifying that the current sender of a netlink packet has the
necessary capabilities.

The idea is to prevent file descriptor passing of any form from
resulting in a file descriptor that can do more than it can for the
creator of the file descriptor.

Eric W. Biederman (5):
      netlink:  Rename netlink_capable netlink_allowed
      net: Move the permission check in sock_diag_put_filterinfo to packet_diag_dump
      net: Add variants of capable for use on on sockets
      net: Add variants of capable for use on netlink messages
      net: Use netlink_ns_capable to verify the permisions of netlink messages

 crypto/crypto_user.c            |  2 +-
 drivers/connector/cn_proc.c     |  2 +-
 drivers/scsi/scsi_netlink.c     |  2 +-
 include/linux/netlink.h         |  7 ++++
 include/linux/sock_diag.h       |  2 +-
 include/net/sock.h              |  5 +++
 kernel/audit.c                  |  4 +--
 net/can/gw.c                    |  4 +--
 net/core/rtnetlink.c            | 20 ++++++-----
 net/core/sock.c                 | 49 +++++++++++++++++++++++++++
 net/core/sock_diag.c            |  4 +--
 net/dcb/dcbnl.c                 |  2 +-
 net/decnet/dn_dev.c             |  4 +--
 net/decnet/dn_fib.c             |  4 +--
 net/decnet/netfilter/dn_rtmsg.c |  2 +-
 net/netfilter/nfnetlink.c       |  2 +-
 net/netlink/af_netlink.c        | 75 ++++++++++++++++++++++++++++++++++++++---
 net/netlink/genetlink.c         |  2 +-
 net/packet/diag.c               |  7 +++-
 net/phonet/pn_netlink.c         |  8 ++---
 net/sched/act_api.c             |  2 +-
 net/sched/cls_api.c             |  2 +-
 net/sched/sch_api.c             |  6 ++--
 net/tipc/netlink.c              |  2 +-
 net/xfrm/xfrm_user.c            |  2 +-
 25 files changed, 177 insertions(+), 44 deletions(-)

Eric
