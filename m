From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 0/4] net: phy: PHY_HALTED, the return of the state
Date: Wed, 25 Oct 2017 16:21:20 -0700
Message-ID: <20171025232124.14120-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        andrew@lunn.ch, opendmb@gmail.com,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        slash.tmp@free.fr, david.daney@cavium.com, geert+renesas@glider.be
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:50090 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751775AbdJYXVi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 19:21:38 -0400
Received: by mail-qk0-f196.google.com with SMTP id q83so2172601qke.6
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 16:21:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series tries to address the shortcomings of the previously and then
quickly reverted commit 7ad813f208533cebfcc32d3d7474dc1677d1b09a ("net: phy:
Correctly process PHY_HALTED in phy_stop_machine()")

This time, the empire returns and strikes back with a few additional changes:

- catch phy_disconnect() calls without prior phy_stop() and warn when that
  happens since that means a driver is not behaving properly. This is AFAIR
  the case in which David Daney ran into

- what David also was running into is that when the PHY state machine was
  already in PHY_HALTED, its synchronous call in phy_disconnect() would make
  us re-schedule ourselves at the end. This is unnecessary, and we now take
  care of that

- finally, Geert experienced bus errors on smsc911x for a number of reasons,
  but the primary one is that the driver does not do any management of the
  PHY state machine during suspend/resume. The last patch corrects that, and
  also suggests that the driver should be fixed to properly support Wake-on-LAN
  configuration to possibly suspend the PHY.

David, Marc and Geert, I would appreciate if you could give this patch series
a spin on your respective HW and confirm that the desired functionality is
achieved.

Florian Fainelli (4):
  net: phy: Export phy_stop_machine()
  net: smsc911x: Properly manage PHY during suspend/resume
  net: phy: Force PHY_HALTED during phy_disconnect()
  net: phy: Correctly process PHY_HALTED in phy_stop_machine()

 drivers/net/ethernet/smsc/smsc911x.c |  7 +++++++
 drivers/net/phy/phy.c                | 13 +++++++++++--
 drivers/net/phy/phy_device.c         |  5 +++++
 3 files changed, 23 insertions(+), 2 deletions(-)

-- 
2.9.3
