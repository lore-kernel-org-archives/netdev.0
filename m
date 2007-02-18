From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Converting network devices from class devices causes namespace pollution
Date: Sun, 18 Feb 2007 08:55:20 -0700
Message-ID: <m1lkiv8npz.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:56079 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357AbXBRPzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Feb 2007 10:55:51 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I believe the culprit is 43cb76d91ee85f579a69d42bc8efc08bac560278.

For some reason network devices are now showing up under the pci
device tree, in directories that have something other than network
devices.

# ls -l /sys/class/net/eth0
lrwxrwxrwx 1 root root 0 Feb 17 23:19 /sys/class/net/eth0 -> ../../devices/pci0000:00/0000:00:0a.0/eth0

# ls /sys/devices/pci0000\:00/0000\:00\:0a.0/
broken_parity_status  device  eth0        modalias  resource   subsystem         uevent
class                 driver  irq         msi_bus   resource0  subsystem_device  vendor
config                enable  local_cpus  power     resource1  subsystem_vendor

User space is allowed to rename network devices to anything any name
not currently taken by another network device.

However when I now do something like:

ip link set eth0 name irq

The rename half happens (because it is legal), but sysfs can't support
it because of the ridiculous directory eth0 is in.  After that
point things go hideously wrong.

The current situation is hideous namespace pollution, and breaks user
space, and is only likely only a matter of time before we have a
reasonable instead of an strained conflict of names.

Is there any simple fix or do we need to revert the change away
from class_device?

Eric
