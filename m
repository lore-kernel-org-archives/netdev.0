From: "Moffett, Kyle D" <Kyle.D.Moffett@boeing.com>
Subject: Understanding the et1011c PHY driver
Date: Wed, 23 Mar 2011 16:14:11 -0500
Message-ID: <091F7EC1-5D33-4C90-AFC1-D6E24EF3EEC6@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Chaithrika U S <chaithrika@ti.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:53982 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524Ab1CWVqI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 17:46:08 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm currently working on some PHY layer refactoring I'd like to propose to
support some of our custom hardware, and I'm trying to understand what the
heck the ET1011C PHY driver is doing so I can fix it up to match.

Specifically, the et1011c_read_status() code does this:

  int ret;
  u32 val;
  static int speed;
  ret = genphy_read_status(phydev);

  if (speed != phydev->speed) {
          speed = phydev->speed;
          val = phy_read(phydev, ET1011C_STATUS_REG);
          if ((val & ET1011C_SPEED_MASK) == ET1011C_GIGABIT_SPEED) {
                  val = phy_read(phydev, ET1011C_CONFIG_REG);
                  val &= ~ET1011C_TX_FIFO_MASK;
                  phy_write(phydev, ET1011C_CONFIG_REG, val\
                                  | ET1011C_GMII_INTERFACE\
                                  | ET1011C_SYS_CLK_EN\
                                  | ET1011C_TX_FIFO_DEPTH_16);
          }
  }
  return ret;

There are so many things wrong with this code that it's not even funny.
There's a static variable promising terrible terrible things should you
have more than 1 such PHY in a system.  The "GMII_INTERFACE" and
"SYS_CLK_EN" bits should only ever be modified as a board-specific PHY
fixup, because the PHY driver has no hope of getting it right in general.
The FIFO depth bits are "changed" to the default value after a reset,
and they are not touched anywhere else in the code.

On top of that, I don't see anywhere that the code would ever undo any
of these changes if the interface dropped from 1000BaseT down to 100BaseT
without a reset.  Looking at the datasheet, it does not even appear that
any of those changes *should* be different between gigabit/non-gigabit.

Then the et1011c_config_aneg() function is customized to do an extra PHY
reset before calling genphy_config_aneg(), which I suspect is only
necessary because of the other abominations above.

As far as I can tell, this PHY *SHOULD* be handled entirely by the genphy
driver with just a small board-specific phy_register_fixup() that gets
run after every reset of the PHY.

I'm looking forward to hearing your opinions on this driver.

Cheers,
Kyle Moffett
