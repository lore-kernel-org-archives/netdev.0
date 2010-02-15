From: Florian Westphal <fw@strlen.de>
Subject: xfrm: add x86 CONFIG_COMPAT support
Date: Mon, 15 Feb 2010 17:46:28 +0100
Message-ID: <1266252393-20911-1-git-send-email-fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:40211 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751730Ab0BOQq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 11:46:29 -0500
Received: id: fw by Chamillionaire.breakpoint.cc authenticated by fw with local
	(easymta 1.00 BETA 1)
	id 1Nh45c-0006bm-Rp
	for netdev@vger.kernel.org; Mon, 15 Feb 2010 17:46:28 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At the moment it is not possible to use the xfrm netlink interface on
x86_64 with a 32bit userland.

The problem exists because a few structures, e.g. struct xfrm_usersa_info,
have different sizes in user/kernelspace (3 byte padding on x86, 7
byte on x86_64) due to different alignment requirements of "u64".

The following patch set aims to resolve this.

The first two patches add necessary CONFIG_COMPAT_NETLINK_MESSAGES
infrastructure to the netlink in/output path.

Patch 3 is a refactoring patch to split functionality (especially
nlmsg allocation and adding data to the nlmsg) in order to
re-use code and ease review.

Patch 4 adds CONFIG_COMPAT_FOR_U64_ALIGNMENT support to xfrm.

Patch 5 sets CMSG_MSG_COMPAT in sock_aio_write(), depending on
is_compat_task().  If patch 5 is deemed too ugly, just pretend it
doesn't exist; userspace can be patched to use sendmsg instead of
write() to avoid this problem.

 include/linux/netlink.h  |    1
 net/netlink/af_netlink.c |   11
 net/socket.c             |    4
 net/xfrm/Kconfig         |    1
 net/xfrm/xfrm_user.c     |  524 ++++++++++++++++++++++++++++++++++++++++++-----
 5 files changed, 488 insertions(+), 53 deletions(-)
