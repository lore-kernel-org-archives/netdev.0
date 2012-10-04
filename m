From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 0/3] virtio-net: inline header support
Date: Thu, 04 Oct 2012 17:14:36 +0930
Message-ID: <87lifm1y1n.fsf@rustcorp.com.au>
References: <cover.1348824232.git.mst@redhat.com> <87vces2gxq.fsf@rustcorp.com.au> <87mx033u74.fsf@codemonkey.ws> <87391u3o67.fsf@rustcorp.com.au> <87wqz6kgg4.fsf@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sasha Levin <levinsasha928@gmail.com>,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, avi@redhat.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Thomas Lendacky <tahm@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51463 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932379Ab2JDICR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2012 04:02:17 -0400
In-Reply-To: <87wqz6kgg4.fsf@codemonkey.ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anthony Liguori <anthony@codemonkey.ws> writes:
>> lguest fix is pending in my queue.  lkvm and qemu are broken; lkvm isn't
>> ever going to be merged, so I'm not sure what its status is?  But I'm
>> determined to fix qemu, and hence my torture patch to make sure this
>> doesn't creep in again.
>
> There are even more implementations out there and I'd wager they all
> rely on framing.

Worse, both virtio_blk (for scsi commands) and virtio_scsi explicitly
and inescapably rely on framing.  The spec conflicts clearly with
itself.

Such layering violations are always a mistake, but I can't blame anyone
else for my lack of attention :(

Here's the spec change:
commit 7e74459bb966ccbaad9e4bf361d1178b7f400b79
Author: Rusty Russell <rusty@rustcorp.com.au>
Date:   Thu Oct 4 17:11:27 2012 +0930

No longer assume framing is independent of messages.  *sniff*

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

--- virtio-spec.txt	2012-10-04 17:13:04.988259234 +0930
+++ virtio-spec.txt.new	2012-10-04 17:12:54.624258969 +0930
@@ -880,19 +880,19 @@
 
   Message Framing
 
-The descriptors used for a buffer should not effect the semantics
-of the message, except for the total length of the buffer. For
-example, a network buffer consists of a 10 byte header followed
-by the network packet. Whether this is presented in the ring
-descriptor chain as (say) a 10 byte buffer and a 1514 byte
-buffer, or a single 1524 byte buffer, or even three buffers,
-should have no effect.
+Unless stated otherwise, it is expected that headers within a
+message are contained within their own descriptors. For example,
+a network buffer consists of a 10 or 12 byte header followed by
+the network packet. An implementation should expect that this
+header will be within the first descriptor, and that the
+remainder of the data will begin on the second descriptor.
 
-In particular, no implementation should use the descriptor
-boundaries to determine the size of any header in a request.[footnote:
-The current qemu device implementations mistakenly insist that
-the first descriptor cover the header in these cases exactly, so
-a cautious driver should arrange it so.
+[footnote:
+It was previously asserted that framing should be independent of
+message contents, yet invariably drivers layed out messages in
+reliable ways and devices assumed it. In addition, the
+specifications for virtio_blk and virtio_scsi require intuiting
+field lengths from frame boundaries.
 ]
 
   Device Improvements
