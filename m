From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 0/3] PHC frequency fine tuning
Date: Tue,  8 Nov 2016 22:49:15 +0100
Message-ID: <cover.1478526333.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
        Jacob Keller <jacob.e.keller@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        John Stultz <john.stultz@linaro.org>,
        Manfred Rudigier <Manfred.Rudigier@omicron.at>,
        =?UTF-8?q?Stefan=20S=C3=B8rensen?=
        <stefan.sorensen@spectralink.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Ulrik De Bie <ulrik.debie-os@e2big.org>,
        intel-wired-lan@lists.osuosl.org
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35486 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753391AbcKHVtZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 16:49:25 -0500
Received: by mail-wm0-f65.google.com with SMTP id a20so14614423wme.2
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2016 13:49:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series expands the PTP Hardware Clock subsystem by adding a
method that passes the frequency tuning word to the the drivers
without dropping the low order bits.  Keeping those bits is useful for
drivers whose frequency resolution is higher than 1 ppb.

The appended script (below) runs a simple demonstration of the
improvement.  This test needs two Intel i210 PCIe cards installed in
the same PC, with their SDP0 pins connected by copper wire.  Measuring
the estimated offset (from the ptp4l servo) and the true offset (from
the PPS) over one hour yields the following statistics.

|        |   Est. Before |    Est. After |   True Before |    True After |
|--------+---------------+---------------+---------------+---------------|
| min    | -5.200000e+01 | -1.600000e+01 | -3.100000e+01 | -1.000000e+00 |
| max    | +5.700000e+01 | +2.500000e+01 | +8.500000e+01 | +4.000000e+01 |
| pk-pk: | +1.090000e+02 | +4.100000e+01 | +1.160000e+02 | +4.100000e+01 |
| mean   | +6.472222e-02 | +1.277778e-02 | +2.422083e+01 | +1.826083e+01 |
| stddev | +1.158006e+01 | +4.581982e+00 | +1.207708e+01 | +4.981435e+00 |

Here the numbers in units of nanoseconds, and the ~20 nanosecond PPS
offset is due to input/output delays on the i210's external interface
logic.

With the series applied, both the peak to peak error and the standard
deviation improve by a factor of more than two.  These two graphs show
the improvement nicely.

  http://linuxptp.sourceforge.net/fine-tuning/fine-est.png

  http://linuxptp.sourceforge.net/fine-tuning/fine-tru.png


Thanks,
Richard

Richard Cochran (3):
  ptp: Introduce a high resolution frequency adjustment method.
  ptp: igb: Use the high resolution frequency method.
  ptp: dp83640: Use the high resolution frequency method.

 drivers/net/ethernet/intel/igb/igb_ptp.c | 16 ++++++++--------
 drivers/net/phy/dp83640.c                | 14 +++++++-------
 drivers/ptp/ptp_clock.c                  |  5 ++++-
 include/linux/ptp_clock_kernel.h         |  8 ++++++++
 4 files changed, 27 insertions(+), 16 deletions(-)

-- 
2.1.4

---
#!/bin/sh

set -e
set -x

killall ptp4l || true

DUR=3600
ETHA=eth6
ETHB=eth3
DEVA=/dev/ptp`ethtool -T $ETHA | awk '/PTP/ {print $4}'`
DEVB=/dev/ptp`ethtool -T $ETHB | awk '/PTP/ {print $4}'`

testptp -d $DEVA -p 0

for x in $DEVA $DEVB; do
	testptp -d $x -f 0
	testptp -d $x -s
done

testptp -d $DEVA -L 0,2  # periodic output
testptp -d $DEVB -L 0,1  # external time stamp
testptp -d $DEVA -p 2000000000

ptp4l -m -q -2 -i $ETHA > log.master &
ptp4l -m -q -2 -i $ETHB -s > log.slave &

sleep 60
testptp -d $DEVB -e $DUR > log.pps
tail -n $DUR log.slave > log.est

killall ptp4l
