From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG] af_packet FANOUT and device dismantle
Date: Thu, 01 Sep 2016 17:04:43 -0700
Message-ID: <1472774683.5439.8.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33616 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750792AbcIBAEu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 20:04:50 -0400
Received: by mail-pf0-f170.google.com with SMTP id g202so13113716pfb.0
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 17:04:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

When you added fanout in commit dc99f600698dcac,
it seems a device dismantle is not properly handled.

packet_notifier() does properly finds all sockets attached to the
device and we call __unregister_prot_hook()

But the actual dev_remove_pack() is called when the last socket attached
to the FANOUT group is _closed_ , possibly minutes after the device
disappeared.

So we trigger the BUG_ON(!list_empty(&dev->ptype_all)); in
netdev_run_todo(), that came with linux-4.0 in 
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=7866a621043fbaca3d7389e9b9f69dd1a2e5a855

Fix would be to call dev_remote_pack() from __fanout_unlink() when
num_members becomes 0.

Let me know if you agree with this, thanks.
