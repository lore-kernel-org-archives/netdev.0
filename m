From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [cavium] weirdness in cnnic_alloc_aligned_dma()
Date: Sat, 12 Dec 2015 18:41:28 +0000
Message-ID: <20151212184128.GP20997@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:47690 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725AbbLLSld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2015 13:41:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IMO
                ptr =
                    (void *)__get_free_pages(GFP_KERNEL,
                                             get_order(size));
                if ((unsigned long)ptr & 0x07) {
                        free_pages((unsigned long)ptr, get_order(size));
                        ptr = NULL;
                        /* Increment the size required if the first
                         * attempt failed.
                         */
                        if (!retries)
                                size += 7;
                }

in drivers/net/ethernet/cavium/liquidio/octeon_main.h:cnnic_alloc_aligned_dma()
takes defensive programming a bit too far - "if the page returned by
__get_free_pages() is not 64bit-aligned" is not going to trigger until
we start to support an architecture with page size lower than 8 bytes,
which is... unlikely.

Either this code takes paranoia to a truly impressive level, or something
else had been intended.  I tried to guess what that something might've
been, but it's hard to do without seeing the history prior to the
moment when it went into mainline.  The bit in the end is particularly
interesting:
        if ((unsigned long)ptr & 0x07)
                ptr = (void *)(((unsigned long)ptr + 7) & ~(7UL));
That - after having rejected such misaligned pointers.

Something's fishy in that code...
