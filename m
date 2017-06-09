From: Brenden Blanco <bblanco@gmail.com>
Subject: ixgbe tx hang with XDP_TX beyond queue limit
Date: Thu, 8 Jun 2017 23:22:29 -0700
Message-ID: <20170609062228.GA14897@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33567 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751780AbdFIGXA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 02:23:00 -0400
Received: by mail-pf0-f181.google.com with SMTP id 83so25065256pfr.0
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 23:22:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am doing some XDP testing on a dual socket, combined 40 core machine
with ixgbe. I have found that with the default settings, depending on
which core a packet is received on, the xdp tx queue will hang with:

  ixgbe 0000:01:00.0 eno1: Detected Tx Unit Hang (XDP)
    Tx Queue             <38>
    TDH, TDT             <0>, <8>
    next_to_use          <8>
    next_to_clean        <0>
  tx_buffer_info[next_to_clean]
    time_stamp           <0>
    jiffies              <101f21bb8>
  ixgbe 0000:01:00.0 eno1: tx hang 1 detected on queue 38, resetting adapter
  ixgbe 0000:01:00.0 eno1: initiating reset due to tx timeout
  ixgbe 0000:01:00.0 eno1: Reset adapter

When the received core is such that the xdp queue falls beyond
MAX_TX_QUEUES, then the hang results. In other words, if I leave
`ethtool -L eno1 combined 40` (the default), and a packet is received on
core 24 or greater, it hangs. However, if I lower the tx queue count to
24 (since XDP is forced to nr_cpu_ids), or if I force the incoming
packets onto core < 24 with an ntuple filter, then no hang occurs.

I imagine that some limits on the number of queues is in order here, or
some error reporting when loading the xdp program/allocating queues.

For now I am working around by lowering the rx queue count to leave
space for the xdp queues.

Thanks,
Brenden
