From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [tipc] dest_name_check() is racy (potential security hole)
Date: Sun, 6 Apr 2014 05:39:34 +0100
Message-ID: <20140406043934.GW18016@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Maloy <jon.maloy@ericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:44216 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbaDFEjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Apr 2014 00:39:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	dest_name_check() is called by tipc sendmsg(2).  What it does ends
with
        if (!m->msg_iovlen || (m->msg_iov[0].iov_len < sizeof(hdr)))
                return -EMSGSIZE;
        if (copy_from_user(&hdr, m->msg_iov[0].iov_base, sizeof(hdr)))
                return -EFAULT;
        if ((ntohs(hdr.tcm_type) & 0xC000) && (!capable(CAP_NET_ADMIN)))
                return -EACCES;

        return 0;
IOW, it checks that iovec we'd been given is large enough to contain
struct tipc_cfg_msg_hdr and that non-priveleged sender doesn't have
->tcm_type in that header with bits 14 or 15 set.

According to the comment in front of it, it "prevents restricted configuration
commands from being issued by unauthorized users".  Makes sense, right?
Except that it obviously doesn't provide any security whatsoever, because
the value we'd read from the iovec is immediately discarded and later
we reread it again.

There is nothing to stop the caller from spawning a threar that would flip
the bits in question back and forth, while the parent keeps calling sendmsg().
Sooner or later we will have dest_name_check() pick the harmless value,
with subsequent memcpy_fromiovecend() picking the modified one.

AFAICS, that part of dest_name_check() must be delayed until tipc_msg_build(),
when we read that header for real.  Brute-force way to do that would be to
pass a flag to tipc_msg_build() ("do we want to check tcm_type?") and have it
set on call chains coming from tipc_send2name() and tipc_multicast().

Again, in the current form the check doesn't do much good; I've no idea
how much nastiness can be achieved by fooling it, but it *can* be fooled.

Comments?
