From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 0/8] net: dsa: Multi-queue awareness
Date: Wed, 30 Aug 2017 17:18:44 -0700
Message-ID: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
Cc: jiri@resnulli.us, jhs@mojatatu.com, davem@davemloft.net,
        xiyou.wangcong@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33573 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750814AbdHaA0k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 20:26:40 -0400
Received: by mail-wm0-f68.google.com with SMTP id m85so2858413wma.0
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 17:26:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is sent as reference, especially because the last patch
is trying not to be creating too many layer violations, but clearly there
are a little bit being created here anyways.

Essentially what I am trying to achieve is that you have a stacked device which
is multi-queue aware, that applications will be using, and for which they can
control the queue selection (using mq) the way they want. Each of each stacked
network devices are created for each port of the switch (this is what DSA
does). When a skb is submitted from say net_device X, we can derive its port
number and look at the queue_mapping value to determine which port of the
switch and queue we should be sending this to. The information is embedded in a
tag (4 bytes) and is used by the switch to steer the transmission.

These stacked devices will actually transmit using a "master" or conduit
network device which has a number of queues as well. In one version of the
hardware that I work with, we have up to 4 ports, each with 8 queues, and the
master device has a total of 32 hardware queues, so a 1:1 mapping is easy. With
another version of the hardware, same number of ports and queues, but only 16
hardware queues, so only a 2:1 mapping is possible.

In order for congestion information to work properly, I need to establish a
mapping, preferably before transmission starts (but reconfiguration while
interfaces are running would be possible too) between these stacked device's
queue and the conduit interface's queue.

Comments, flames, rotten tomatoes, anything!

Florian Fainelli (8):
  net: dsa: Allow switch drivers to indicate number of RX/TX queues
  net: dsa: tag_brcm: Set output queue from skb queue mapping
  net: dsa: bcm_sf2: Advertise number of egress queues
  net: dsa: bcm_sf2: Configure IMP port TC2QOS mapping
  net: dsa: bcm_sf2: Fix number of CFP entries for BCM7278
  net: dsa: Expose dsa_slave_dev_check and dsa_slave_dev_port_num
  net: dsa: tag_brcm: Indicate to master netdevice port + queue
  net: systemport: Establish DSA network device queue mapping

 drivers/net/dsa/bcm_sf2.c                  |  16 +++++
 drivers/net/dsa/bcm_sf2.h                  |   1 +
 drivers/net/dsa/bcm_sf2_cfp.c              |   8 +--
 drivers/net/ethernet/broadcom/bcmsysport.c | 100 +++++++++++++++++++++++++++--
 drivers/net/ethernet/broadcom/bcmsysport.h |  11 +++-
 include/net/dsa.h                          |  19 ++++++
 net/dsa/slave.c                            |  22 +++++--
 net/dsa/tag_brcm.c                         |   8 ++-
 8 files changed, 170 insertions(+), 15 deletions(-)

-- 
1.9.1
