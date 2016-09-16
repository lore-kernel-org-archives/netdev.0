From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: XDP_TX bug report on mlx4
Date: Fri, 16 Sep 2016 21:03:40 +0200
Message-ID: <20160916210340.4a7cdef8@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <rana.shahot@gmail.com>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57398 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753513AbcIPTDq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 15:03:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Brenden,

I've discovered a bug with XDP_TX recycling of pages in the mlx4 driver.

If I increase the number of RX and TX queues/channels via ethtool cmd:
 ethtool -L mlx4p1 rx 10 tx 10

Then when running the xdp2 program, which does XDP_TX, the kernel will
crash with page errors, because the page refcnt goes to zero or even
minus.  I've noticed pages delivered to mlx4_en_rx_recycle() can have
a page refcnt of zero, which is wrong, they should always have 1 (for
XDP).

Debugging it further, I find that this can happen when mlx4_en_rx_recycle()
is called from mlx4_en_recycle_tx_desc().  This is the TX cleanup function,
associated with TX ring queues used for XDP_TX only. No others than the
XDP_TX action should be able to place packets into these TX rings
which call mlx4_en_recycle_tx_desc().

Do you have any idea of what could be going wrong in this case?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
