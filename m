From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: RFC: ethtool: add device-specific feature support in a generic
 fashion
Date: Sat, 12 Dec 2009 18:33:19 -0800
Message-ID: <1260671599.2142.79.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, mchan@broadcom.com,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	linville@tuxdriver.com, shemminger@linux-foundation.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40907 "HELO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752310AbZLMCdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2009 21:33:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a follow-up to my first RFC, getting opinions where the best
place to put device-specific feature toggling would be.  The feedback I
received was to look at doing this in ethtool.  Below is a high-level
design of what I'd like to do, and wanted to vet this with the community
to see if this is aligned with what people would like to see.

The general idea is to have a generic framework in ethtool to enumerate
device-specific commands.  A sample structure that would represent each
of these commands is:

	enum oem_cmds {
		OEM_CMD_0 = 0,
		OEM_CMD_1,
		OEM_CMD_2,
	...
	etc.
	...
	};

	struct oem_feature_cmd {
		/* Description of the feature */
		char *description;

		/* Does the feature toggling requires a device reset */
		u8 require_reset;

		/* The command-line name for the command */
		char *oem_cmd_name;

		/* The command number assigned to this */
		u32 oem_cmd;

		/* value for the command */
		u32 oem_cmd_val;
	};

Now underlying drivers would implement as many of these commands as
needed, and assign strings to each.  These strings, in oem_cmd_name,
would be used by ethtool in userspace to parse the command line
properly.

The reason I included a field that indicates whether a reset is required
or not is to support features that require multiple commands to be
synchronously programmed.  An example is ixgbe's Flow Director.  FDIR
has a number of knobs, specifically what filtering mode to use (hash or
perfect match), number of filters to use, and how often to sample Tx
packets (assumes hash mode).  This way a user could set all three
options, then issue "ethtool -r ethX" to apply them.

An example of features ixgbe could implement, using the above framework,
would be:

	- oem_cmd = OEM_CMD1
		- oem_cmd_name = "fdir_filter_mode"
		- require_reset = 1
		- description = "Set filtering mode for Flow Director. 0 = off, 1 =
hash (default), 2 = perfect"

	- oem_cmd = OEM_CMD2
		- oem_cmd_name = "fdir_num_filters"
		- require_reset = 1
		- description = "How many filters to support: 0 = 2k perfect/8k hash
(default), 1 = 4k perfect/16k hash, 2 = 8k perfect/32k hash"

	- oem_cmd = OEM_CMD3
		- oem_cmd_name = "num_vfs"
		- require_reset = 1
		- description = "Number of Virtual Functions to enable.  This only
takes effect when SR-IOV is enabled."

	- oem_cmd = OEM_CMD4
		- oem_cmd_name = "enable_sriov"
		- require_reset = 0
		- description = "Enables SR-IOV in the device."

The general flow would be ethtool would read all commands the underlying
device supports, then would use that to parse the command line.
Assuming the command parses correctly, the configuration would then be
sent through the ioctl() to the driver.

This framework is a basic substitute for module parameters, which our
upstream drivers do not include.  The advantage here is any commands
that a driver wishes to add, to enable a new feature in hardware, would
not require ethtool to change.  The command is simply added to the
driver, and this framework will pick up the new command.

Any comments, questions, or suggestions are much appreciated.

Cheers,
-PJ Waskiewicz

