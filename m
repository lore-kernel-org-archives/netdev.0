From: Andrew Morton <akpm@linux-foundation.org>
Subject: kmap_atomic() oopses in current mainline
Date: Thu, 19 Jul 2007 01:33:04 -0700
Message-ID: <20070719013304.3c060c99.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dan.j.williams@intel.com>
To: netdev@vger.kernel.org, linux-kernel-announce@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56751 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751046AbXGSIdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 04:33:15 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I've had a handful of random mystery oopses associated with no particular
activity.  A typical trace is at:

	http://userweb.kernel.org/~akpm/dsc03659.jpg

the trace is messy and it doesn't seem to want to happen now I've turned on
frame pointers, but it looks networky to me.

So if anyone has made kmap_atomic() changes in networking recently, please
check your work.  The machine does have highmem.



The crash appears to be happening here:

        BUG_ON(!pte_none(*(kmap_pte-idx)));

which would indicate a wild value is being passing km kmap_atomic()'s
km_type arg.




I don't think the 2-year-old Vaio has offload engine support ;) Dan, this:

+		if (flags & ASYNC_TX_KMAP_DST)
+			dest_buf = kmap_atomic(dest, KM_USER0) + dest_offset;
+		else
+			dest_buf = page_address(dest) + dest_offset;
+
+		if (flags & ASYNC_TX_KMAP_SRC)
+			src_buf = kmap_atomic(src, KM_USER0) + src_offset;
+		else
+			src_buf = page_address(src) + src_offset;
+
+		memcpy(dest_buf, src_buf, len);
+
+		if (flags & ASYNC_TX_KMAP_DST)
+			kunmap_atomic(dest_buf, KM_USER0);
+
+		if (flags & ASYNC_TX_KMAP_SRC)
+			kunmap_atomic(src_buf, KM_USER0);
+

is very wrong if both ASYNC_TX_KMAP_DST and ASYNC_TX_KMAP_SRC can ever be
set.  We'll end up using the same kmap slot for both src add dest and we
get either corrupted data or a BUG.


