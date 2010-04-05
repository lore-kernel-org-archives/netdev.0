From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v3 0/4] xfrm: add x86 CONFIG_COMPAT support
Date: Tue,  6 Apr 2010 00:27:07 +0200
Message-ID: <1270506431-25578-1-git-send-email-fw@strlen.de>
Cc: johannes@sipsolutions.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:60848 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756545Ab0DEW2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 18:28:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

3rd version of xfrm x86-compat patch set.

No changes since v2, except patch 5/5, which I dropped from the set.

This has the consequence that compat support is restricted to
applications that use sendmsg() to talk to the kernel (e.g. iproute2
would work); because write() will not go through the socket compat
layer (and thus, the MSG_CMSG_COMPAT won't be set on messages sent
by means of write() ).

I sent a patch that solved this by adding a sys_compat_write syscall
and a ->compat_aio_write() to struct file_operations to the
vfs mailing list, but that patch was ignored by the vfs people,
and the x86 folks did not exactly like the idea either.

So this leaves three alternatives:
1 - drop the whole idea and keep the current status.
2 - Add new structure definitions (with new numbering) that would work
    everywhere, keep the old ones for backwards compatibility (This
    was suggested by Arnd Bergmann).
3 - apply this patch set and tell userspace to move the sendmsg() when
    they want to work with xfrm on x86_64 with 32 bit userland.

Other than that, I am out of ideas.

Patch set description:

At the moment it is not possible to use the xfrm netlink interface on
x86_64 with a 32bit userland.

The problem exists because a few structures, e.g. struct xfrm_usersa_info,
have different sizes in user/kernelspace (3 byte padding on x86, 7
byte on x86_64) due to different alignment requirements of "u64".

First two patches add necessary CONFIG_COMPAT_NETLINK_MESSAGES
infrastructure to netlink in/output path.

Patch 3 is a refactoring patch to split functionality (especially
nlmsg allocation and adding data to the nlmsg) in order to
re-use code and ease review.

Patch 4 adds CONFIG_COMPAT_FOR_U64_ALIGNMENT support to xfrm.

Florian Westphal (4):
      netlink: append NLMSG_DONE to compatskb, too
      netlink: store MSG_CMSG_COMPAT flag in netlink_skb_parms
      xfrm: split nlmsg allocation and data copying
      xfrm: CONFIG_COMPAT support for x86 architecture

 include/linux/netlink.h  |    1 +
 net/netlink/af_netlink.c |   11 +
 net/xfrm/Kconfig         |    1 +
 net/xfrm/xfrm_user.c     |  508 ++++++++++++++++++++++++++++++++++++++++------
 4 files changed, 460 insertions(+), 61 deletions(-)
