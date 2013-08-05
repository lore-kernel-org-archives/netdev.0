From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: low latency/busy poll feedback and bugs
Date: Mon, 5 Aug 2013 16:22:57 -0500
Message-ID: <20130805212257.GB6904@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: eliezer.tamir@linux.intel.com, netdev@vger.kernel.org
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:41761 "EHLO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754212Ab3HEVXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 17:23:00 -0400
Received: by mail-oa0-f42.google.com with SMTP id i18so7589267oag.29
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 14:23:00 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did a little testing of the new low latency/busy poll sockets today
and found a few things that surprised me and at least one bug.

1) I'm testing with a Mellanox ConnectX-3 card.  Currently polling
with mlx4_en is broken when GRO is enabled.  In
mlx4_en_process_rx_cq() when GRO is enabled skb_mark_napi_id() is
never called.  It appears like low latency sockets with GRO is
supposed to work because the following code checks that we are not
ll_polling:

 /* This packet is eligible for GRO if it is:
   * - DIX Ethernet (type interpretation)
   * - TCP/IP (v4)
   * - without IP options
   * - not an IP fragment
   * - no LLS polling in progress
   */
  if (!mlx4_en_cq_ll_polling(cq) &&
      (dev->features & NETIF_F_GRO)) {

However since we never call skb_mark_napi_id() mlx4_en_cq_ll_polling()
will never be true.

2) Why is LowLatencyRxPackets reported as a TcpExt stat?  Perhaps I've
been confused and misguided but I've always assumed those are
statistics related to TCP and this feature is protocol neutral.  I'm
not entirely sure where it should be moved to perhaps IpExt?

3) I don't know if this was intentional, an oversight, or simply a
missing feature but UDP multicast currently is not supported.  In
order to add support I believe you would need to call
sk_mark_napi_id() in __udp4_lib_mcast_deliver().  Assuming there isn't
some intentional reason this wasn't done I'd be happy to test this and
send a patch.

--
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
