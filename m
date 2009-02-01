From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH v3 0/4] virtio_net: Add MAC and VLAN filtering
Date: Sun, 01 Feb 2009 13:05:04 -0700
Message-ID: <20090201200504.8183.58421.stgit@debian.lart>
References: <200901301533.52115.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:10250 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752837AbZBAUHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 15:07:50 -0500
In-Reply-To: <200901301533.52115.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds infrastructure for a new control virtqueue and
makes use of it to support set_rx_mode, unicast and multicast address
lists, and supporting a hypervisor based VLAN filter.  The goal is to
make the virtio-net device support more of the features of a physical
NIC and allow the hypervisor to discard packets we don't want.

This version incorporates further suggestions from Rusty.  The
send_command() helper function now takes a scatterlist pointer so
that we're not limited to using it in for commands that take only
take one or no data args.  The caller now needs to specify how
many entries are out/in, and the helper function adds the header
and status.  We'll now BUG if send_command is called without the vq
available, but set_rx_mode needs a graceful exit since we can't
dynamically tell the upper netdev layers not to call in.  I left the
MAC_SET_TABLE call using two scatter entries even though it could
now be done with one, and are allocated as one.  The F_CTRL_MAC
feature is now folded into F_CTRL_RX, but I left the separate class
for it.  VLAN_ENABLE is now gone.  I was concerned that we needed
some way to disable VLAN filtering, but after looking at e1000, I
think it's probably sufficient for the backend to prioritize promisc
over VLAN as a way to disable it.  I switched errors to dev_warn, but
left them as the caller's responsibility so we can get useful error
messages.  Thanks for the comments, please provide more ;^)  Thanks,

Alex

---

Alex Williamson (4):
      virtio_net: Add support for VLAN filtering in the hypervisor
      virtio_net: Add a MAC filter table
      virtio_net: Add a set_rx_mode interface
      virtio_net: Add a virtqueue for outbound control commands


 drivers/net/virtio_net.c   |  166 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/virtio_net.h |   67 ++++++++++++++++++
 2 files changed, 230 insertions(+), 3 deletions(-)

-- 
Alex Williamson
