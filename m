From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 0/3] tun: fix aio
Date: Mon, 20 Apr 2009 14:25:27 +0300
Message-ID: <20090420112527.GA6692@dhcp-1-124.tlv.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60282 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753266AbZDTL0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 07:26:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tun device currently fills in aio_read/aio_write, however the implementation
corrupts the input iovec through const struct iovec *. As a side effect,
attempts to use io_submit/io_getevents on a tun/tap device result in EINVAL
(after actually sending/consuming a packet).

The following patches make tun_chr_aio_read and tun_chr_aio_write not modify
the iovec so that io_submit/io_getevents succeed, becoming functionally
equivalent to write/read on the device.  I am working on another patch set
supporting zero-copy transmit over tun, which will rely on this functionality,
but I think the patches might be already useful by themself. What do you think?
Please review.

Note: I started out just allocating and copying the iovec rather than adding
yet another skb-iterating routine, but this turned out to add small but
measurable overhead on data path: tx time per packet jumped from 6500 to 6700 ns
(let me know if you want to see that version of the patch).

Michael S. Tsirkin (3):
  net: skb_copy_datagram_const_iovec()
  tun: fix tun_chr_aio_read so that aio works
  tun: fix tun_chr_aio_write so that aio works

 drivers/net/tun.c      |   24 ++++++----
 include/linux/skbuff.h |    8 +++-
 include/linux/socket.h |    6 ++-
 net/core/datagram.c    |  112 +++++++++++++++++++++++++++++++++++++++++++++---
 net/core/iovec.c       |   33 +++++++++++++-
 5 files changed, 161 insertions(+), 22 deletions(-)
