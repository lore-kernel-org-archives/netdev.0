From: Brandon Streiff <brandon.streiff@ni.com>
Subject: [PATCH net-next RFC 0/9] net: dsa: PTP timestamping for mv88e6xxx
Date: Thu, 28 Sep 2017 10:25:32 -0500
Message-ID: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>,
        Brandon Streiff <brandon.streiff@ni.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series adds support for PTP timestamping through the DSA
framework, as well as an implementation for mv8e6xxx switches.

This implementation was targeted at a National Instruments platform
that uses the Marvell 88E6341 (Topaz). I've tried to enable support on
other Marvell switches where the register interfaces seemed compatible,
but I don't have the hardware to verify their operation myself.

This series probably ties in well with Richard's comment last week
("Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
traffic shapers") about figuring out proper interfaces for managing
switch-level PTP timestamps.

A couple patches that I expect may need further polishing:

- Patch #2: We expose the switch time as a PTP clock but don't support
  adjustment (max_adj=0). Our platform adjusted a systemwide oscillator
  from userspace, so we didn't need adjustment at this layer, but other
  PTP clock drivers support this and we probably should too.

- Patch #3: The GPIO config support is handled in a very simple manner.
  I suspect a longer term goal would be to use pinctrl here.

- Patch #6: the dsa_switch pointer and port index is plumbed from
  dsa_device_ops::rcv so that we can call the correct port_rxtstamp
  method. This involved instrumenting all of the *_tag_rcv functions in
  a way that's kind of a kludge and that I'm not terribly happy with.

This applies to net-next as of 14a0d032f4ec.

Feedback is appreciated.

-- brandon


Brandon Streiff (9):
  net: dsa: mv88e6xxx: add accessors for PTP/TAI registers
  net: dsa: mv88e6xxx: expose switch time as a PTP hardware clock
  net: dsa: mv88e6xxx: add support for GPIO configuration
  net: dsa: mv88e6xxx: add support for event capture
  net: dsa: forward hardware timestamping ioctls to switch driver
  net: dsa: forward timestamping callbacks to switch drivers
  ptp: add offset for reserved field to header
  net: dsa: mv88e6xxx: add rx/tx timestamping support
  net: dsa: mv88e6xxx: add workaround for 6341 timestamping

 drivers/net/dsa/mv88e6xxx/Kconfig    |  10 +
 drivers/net/dsa/mv88e6xxx/Makefile   |   2 +
 drivers/net/dsa/mv88e6xxx/chip.c     |  65 +++++
 drivers/net/dsa/mv88e6xxx/chip.h     |  71 +++++
 drivers/net/dsa/mv88e6xxx/global2.c  | 244 ++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global2.h  |  59 +++-
 drivers/net/dsa/mv88e6xxx/hwtstamp.c | 548 +++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/hwtstamp.h | 171 +++++++++++
 drivers/net/dsa/mv88e6xxx/ptp.c      | 493 +++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/ptp.h      |  99 +++++++
 include/linux/ptp_classify.h         |   1 +
 include/net/dsa.h                    |  28 +-
 net/dsa/dsa.c                        |  39 ++-
 net/dsa/slave.c                      |  67 ++++-
 net/dsa/tag_brcm.c                   |   6 +-
 net/dsa/tag_dsa.c                    |   6 +-
 net/dsa/tag_edsa.c                   |   6 +-
 net/dsa/tag_ksz.c                    |   6 +-
 net/dsa/tag_lan9303.c                |   6 +-
 net/dsa/tag_mtk.c                    |   6 +-
 net/dsa/tag_qca.c                    |   6 +-
 net/dsa/tag_trailer.c                |   6 +-
 22 files changed, 1929 insertions(+), 16 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/hwtstamp.c
 create mode 100644 drivers/net/dsa/mv88e6xxx/hwtstamp.h
 create mode 100644 drivers/net/dsa/mv88e6xxx/ptp.c
 create mode 100644 drivers/net/dsa/mv88e6xxx/ptp.h

-- 
2.1.4
