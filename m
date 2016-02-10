From: Stefan Agner <stefan@agner.ch>
Subject: Micrel PHY and power down mode
Date: Wed, 10 Feb 2016 11:25:46 -0800
Message-ID: <ea1cb242a247bc6665947ab9a77cb454@agner.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: david.choi@micrel.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kmu-office.ch ([178.209.48.109]:36354 "EHLO
	mail.kmu-office.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389AbcBJT2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 14:28:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Hi Florian,

We use a Micrel KSZ8041NL and we observe sometimes continuous RX errors
(PHY's RXER counter is continuously incrementing, activity LED blinks
and no communication is possible). It seems that only some PHY's are
affected (3-4%) and only in certain temperature ranges (the PHY I can
reproduce the issue here shows the problem ~30=C2=B0C). We could narrow=
 the
issue down, and realized that the problem only appears after the PHY ha=
s
been in power down mode. Since Linux calls suspend/resume when
attaching/detaching the PHY, a simple ifup/ifdown bascially can trigger
the issue.

Currently, the wakeup sequence writes the following registers
0x8000 to 0x00 (phy_attach_direct -> phy_init_hw -> genphy_soft_reset)
0x3000 to 0x00 (phy_attach_direct -> genphy_resume)

I am not sure if this sequence is really ok. It seems to me that
genphy_soft_reset clears the power down bit already, which makes
genphy_resume somewhat useless. However, altering the behavior of
genphy_soft_reset to not clear the power down bit (yet) did not resolve
the issue.

Is clearing the power down bit and generating the reset in one go
intended? I checked the datasheet, and did not found particular
information about the "resume" sequence...=20
