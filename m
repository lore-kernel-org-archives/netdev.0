From: "Liu Dave-R63238" <DaveLiu@freescale.com>
Subject: Net: ucc_geth ethernet driver optimization space
Date: Wed, 27 May 2009 13:08:07 +0800
Message-ID: <D7CCA83BB0796C49BC0BB53B6AB1208934920A@zch01exm21.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:34769 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756476AbZE0FIL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 01:08:11 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Guys,

The ucc_geth ethernet driver have dozens of strong sync read/write
operation, such as in_be32/16/8, out_be32/16/8.

all of them is sync read/write, it is very expensive for performance.

For the critical patch, we can remove some unnecessary in_be(x),
out_be(x) with normal memory operation, and keep some necessary
memory barrier.

eg: BD access in the interrupt handler and start_xmit.

The BD operation only need the memory barrier between length/buffer
and status.

struct buffer descriptor {
	u16 status;
	u16 length;
	u32 buffer;
} __attribute__ ((packed));

struct buffer descriptor *BD;

BD->length = xxxx;
BD->buffer = yyyy;
wmb();
BD->status = zzzz;

For powerpc, eieio is enough for 60x, mbar 1 is enough for e500.
Of couse, also need the memory clobber to avoid the compiler
reorder between them.

Thanks, Dave


