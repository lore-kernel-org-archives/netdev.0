From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [RFC net-next 0/3] devconf: New infrastructure for setting pre-load parameters for a module
Date: Thu,  8 Jan 2015 17:16:57 +0200
Message-ID: <1420730220-20224-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, shannon.nelson@intel.com,
	Doug Ledford <dledford@redhat.com>, greearb@candelatech.com
To: "David S. Miller" <davem@davemloft.net>, gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54585 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753567AbbAHPTC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2015 10:19:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
   =20
When configuring a device at an early boot stage, most kernel drivers
use module parameters (the parameters' settings can be determined in
modprobe.d config files).
These parameters are difficult to manage, and one of the reasons is tha=
t
module parameters are set per driver and not per device (NICs using the
same driver cannot be set with different configurations).
=46urthermore, using other existing configuration tools like ethtool,
ifconfig, ip link commands or sysfs entries is not applicable, since
they all rely on having a netdev already set up.

In the past, 'request_firmware' solution for configuration parameters
was suggested by Shannon Nelson from Intel[1]. The idea was rejected by
Greg KH, who claimed it was abusive of the request_firmware mechanism.
Greg suggested using configfs for device configuration instead (as done
by the USB gadget driver).

As a solution, we introduce a new kernel infrastructure using configfs
to allow the configuration of the device. The goal is to set low-level
device functionality that needs to be sorted out before a module is
loaded.

Configfs Solution:
----------------------
The implemented configfs solution is composed of one generic module
('devconf') that can load configuration modules per driver.
The devconf should be loaded at a very early boot stage, before other
kernel modules are loaded (or compiled as in-tree). After configfs is
mounted, it creates a new directory under configfs, called 'devices'.

In the example presented below, systemd mechanism is being used, but th=
e
configuration can also work with older init systems.

1. A systemd service, scheduled by the OS to run before kernel modules
are loaded, creates a directory under 'devices' with the name of the dr=
iver.
The devconf module will try to load a configuration module for this
driver (if exists).

2. Drivers using this mechanism will be made of two parts:
a configuration module and the driver itself.

3. Later on, when the OS loads the driver, it uses the configuration
sub-tree.

To avoid dependencies between the modules, in case the configuration
module does not exist or is not loaded, the driver will use default
values.

Example:
--------
The below mlx4_core configuration file is only an example. Since the
infrastructure is generic, each vendor can choose how to identify its
devices (for example: bdf, mac address, uuid etc.).

If /etc/devconf.d/mlx4_core.conf is as follows (see below), systemd
service will use it to run the following commands (see below).

mlx4_core.conf file:
--------------------
[pdevs]
	[0000:00:08.0]
		dmfs =3D 0
		[ports]
			[1]
			type =3D 2
			[2]
			type =3D2
	[0000:00:04.0]
		dmfs =3D 0
		[ports]
			[1]
			type =3D 5
			[2]
			type =3D1

Systemd commands:
-----------------
$ mkdir /sys/kernel/config/devices/mlx4_core

devconf module will try to load dev_c_mlx4.ko

$ mkdir /sys/kernel/config/devices/mlx4_core/pdevs
$ mkdir /sys/kernel/config/devices/mlx4_core/pdevs/0000:00:08.0
$ mkdir /sys/kernel/config/devices/mlx4_core/pdevs/0000:00:08.0/ports
$ mkdir /sys/kernel/config/devices/mlx4_core/pdevs/0000:00:08.0/ports/1
$ mkdir /sys/kernel/config/devices/mlx4_core/pdevs/0000:00:08.0/ports/2

$ echo 5 > /sys/kernel/config/devices/mlx4_core/pdevs/0000:00:08.0/port=
s/1/type
$ echo 1 > /sys/kernel/config/devices/mlx4_core/pdevs/0000:00:08.0/port=
s/2/type
$ echo 0 > /sys/kernel/config/devices/mlx4_core/pdevs/0000:00:08.0/dmfs
[...]

dev_c_mlx4 will reject the above configuration, printing a clear messag=
e
to dmesg:
"mlx4_core: Unknown port type '5' for device 0000:00:08.0. Use 0 for
auto, 1 for IB and 2 for ETH"

The driver configuration module validates and prepares configfs sub-tre=
e
for the driver itself.
A configuration sub-tree for a specific module will be created under
/sys/kernel/config/devices/<driver name>, and propagated from a
configuration file on the OS (located under: /etc/devconf.d/).

Configfs Sub-tree Example (for mlx4_core):
------------------------------------------
$ cd /sys/kernel/config/
$ tree devices/
devices/
=E2=94=94=E2=94=80=E2=94=80 mlx4_core
    =E2=94=94=E2=94=80=E2=94=80 pdevs
	    =E2=94=9C=E2=94=80=E2=94=80 0000:00:04.0
	    =E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 dmfs
	    =E2=94=82   =E2=94=94=E2=94=80=E2=94=80 ports
	    =E2=94=82=C2=A0=C2=A0     =E2=94=9C=E2=94=80=E2=94=80 1
	    =E2=94=82=C2=A0=C2=A0     =E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=
=E2=94=80 type
	    =E2=94=82=C2=A0=C2=A0     =E2=94=94=E2=94=80=E2=94=80 2
	    =E2=94=82		=E2=94=94=E2=94=80=E2=94=80 type
	    =E2=94=94=E2=94=80=E2=94=80 0000:00:08.0
	 	=E2=94=9C=E2=94=80=E2=94=80 dmfs
	 	=E2=94=94=E2=94=80=E2=94=80 ports
	 	    =E2=94=9C=E2=94=80=E2=94=80 1
	 	    =E2=94=82 	=E2=94=94=E2=94=80=E2=94=80 type
	 	    =E2=94=94=E2=94=80=E2=94=80 2
	 		=E2=94=94=E2=94=80=E2=94=80 type

The systemd service that populates configfs is part of the sysinit
target. The service is executed after mounting configfs and before udev
load kernel modules.

To use devconf infrastructure, the following should be included:
1. Devconf systemd service
2. Configuration file in the right format under: /etc/devconf.d/

This suggested solution is generic and designed to suite any type of
device. The goal is to make this solution generic enough so all kinds o=
f
drivers are able to use it.
As a start, this RFC is being sent to the netdev mailing list for
feedback, but will eventually be submitted to the LKML mailing list as =
a
generic kernel infrastructure.

Hadar.

[1] - https://lkml.org/lkml/2013/1/10/606

Hadar Hen Zion (3):
  net/dev_c_mlx4: Support mlx4_core pre-load configuration
  devconf: Add configuration module for setting pre-load parameters
  net/mlx4_core: Set port_type value according to configuration module

 Documentation/filesystems/configfs/devconf.txt |  135 ++++++++++
 drivers/Kconfig                                |    2 +
 drivers/Makefile                               |    1 +
 drivers/devconf/Kconfig                        |    6 +
 drivers/devconf/Makefile                       |    3 +
 drivers/devconf/driver.c                       |  160 ++++++++++++
 drivers/devconf/main.c                         |  103 ++++++++
 drivers/net/ethernet/mellanox/mlx4/Kconfig     |    6 +
 drivers/net/ethernet/mellanox/mlx4/Makefile    |    4 +
 drivers/net/ethernet/mellanox/mlx4/main.c      |   55 ++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      |    1 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_conf.c |  323 ++++++++++++++++=
++++++++
 include/linux/devconf.h                        |   69 +++++
 13 files changed, 867 insertions(+), 1 deletions(-)
 create mode 100644 Documentation/filesystems/configfs/devconf.txt
 create mode 100644 drivers/devconf/Kconfig
 create mode 100644 drivers/devconf/Makefile
 create mode 100644 drivers/devconf/driver.c
 create mode 100644 drivers/devconf/main.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/mlx4_conf.c
 create mode 100644 include/linux/devconf.h

--=20
1.7.8.2
