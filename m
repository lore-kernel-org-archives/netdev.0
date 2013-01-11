From: Shannon Nelson <shannon.nelson@intel.com>
Subject: [PATCH 0/3] ixgbe: request_firmware for configuration parameters
Date: Thu, 10 Jan 2013 18:02:20 -0800
Message-ID: <20130111020046.15463.72333.stgit@starfish.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, dwmw2@infradead.org,
	jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Most networking dials and knobs can be set using ethtool, ifconfig, ip link
commands, or sysfs entries, all of which can be driven by startup scripts
and other configuration tools.  However, they all depend on having a netdev
already set up, and we have some low-level device functionality that needs
to be sorted out before we start setting up MSI-x and memory allocations.

In order to do early device configuration, most kernel drivers use module
parameters whose settings can be persisted in modprobe.d config files.
However, these can be clumsy to use and manage, difficult to specify port
specific values in a multiport device, and are actively discouraged in
some circles.

In this patchset, the driver uses the existing request_firmware() and
match_token() facilities to grab an ASCII config file from userspace to
find special startup-time configuration information that needs persistence
across reboots.  The configuration strings are formed similar to the
mount options that get passed from /etc/fstab into filesystem modules.

We can assume that the driver and device will come up with sane defaults
that will make the part reasonably useful - we're not solving something
for basic usability.  This capability is for folks that need special
configurations for their virtualization server or cloud configuration or
whatever network server where they've taken the time to tune things more
specifically to their application.

We are using existing facilities so that we don't have to build any
userland utilities, and a config file format that is both humanly and
potentially mechanically editable.

After doing some digging around, it seems that the combination of ASCII
config files stored where request_firmware() can find them, plus the
kind of option configurations used in fstab for mount commands can solve
the need.  Using the lib/parser.c tools seems obvious - we don't want to
add any other parser code to the kernel, and heaven forbid someone tries to
extend any new parser into an XML solution.  Using the request_firmware()
framework also allows the configuration file to get included when building
an initrd image.

In these RFC patches for ixgbe, the configuration data would be found in
the file /lib/firmware/ixgbe.conf, and might look something like this:

	#
	# example ixgbe driver configuration
	#

		# this is a generic setting for the driver
	ixgbe allow_unsupported_sfp,debug=0xf,AtrSampleRate=0

		# msix restricted on one port for testing purposes
	00:1b:21:12:4e:60  nomsix


Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>

---

Shannon Nelson (3):
      ixgbe: add interrupt control parameters
      ixgbe: add additional parameter options
      ixgbe: replace module options with configuration through request_firmware


 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    4 
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  |    6 
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  305 +++++++++++++++++++++++--
 3 files changed, 289 insertions(+), 26 deletions(-)

-- 
======================================================================
Mr. Shannon Nelson                 LAN Access Division, Intel Corp.
shannon.nelson@intel.com                I don't speak for Intel
(503) 712-7659                    Parents can't afford to be squeamish
