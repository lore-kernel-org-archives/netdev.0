From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 0/7] vxlan: clean up rx path, consolidating extension handling
Date: Tue, 16 Feb 2016 21:58:56 +0100
Message-ID: <cover.1455656217.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43137 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838AbcBPU7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 15:59:31 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id 00C368DFF6
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 20:59:30 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-84.brq.redhat.com [10.40.204.84])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1GKxTxs018384
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 15:59:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rx path of VXLAN turned over time into kind of spaghetti code. The rx
processing is split between vxlan_udp_encap_recv and vxlan_rcv but in an
artificial way: vxlan_rcv is just called at the end of vxlan_udp_encap_recv,
continuing the rx processing where vxlan_udp_encap_recv left it. There's no
clear border between those two functions.

It makes sense to combine those functions into one; this will be actually
needed for VXLAN-GPE where we'll need to skip part of the processing which
is hard to do with the current code.

However, both functions are too long already. This patchset is shortening
them, consolidating extension handling that is spread all around together
and moving it to separate functions. (Later patchsets will do more
consolidation in other parts of the functions with the final goal of merging
vxlan_udp_encap_recv and vxlan_rcv.)

In process of consolidation of the extension handling, I needed to deal with
vni field in a generic way, as its lower 8 bits mean different things for
different extensions. While cleaning up the code to strictly distinguish
between "vni" and "vni field" (which contains vni plus an additional byte),
I also converted the code not to convert endianess back and forth.

The full picture can be seen at:
https://github.com/jbenc/linux-vxlan/commits/master

Jiri Benc (7):
  vxlan: introduce vxlan_hdr
  vxlan: keep flags and vni in network byte order
  vxlan: simplify vxlan_remcsum
  vxlan: move GBP header parsing to a separate function
  vxlan: clean up extension handling on rx
  vxlan: clean up rx error path
  vxlan: treat vni in metadata based tunnels consistently

 drivers/net/vxlan.c | 228 +++++++++++++++++++++++++---------------------------
 include/net/vxlan.h |  75 ++++++++++++++---
 2 files changed, 173 insertions(+), 130 deletions(-)

-- 
1.8.3.1
