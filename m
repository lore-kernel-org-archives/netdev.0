From: Amir Vadai <amirv.mellanox@gmail.com>
Subject: Re: How to load config info before loading firmware?
Date: Sun, 29 Jun 2014 17:45:21 +0300
Message-ID: <53B02681.3080304@gmail.com>
References: <539F1503.7050602@candelatech.com>
Reply-To: amirv@mellanox.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, tzahio@mellanox.com,
	Shannon Nelson <shannon.nelson@intel.com>
To: Ben Greear <greearb@candelatech.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:48776 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbaF2OpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2014 10:45:24 -0400
Received: by mail-wg0-f52.google.com with SMTP id b13so7031289wgh.35
        for <netdev@vger.kernel.org>; Sun, 29 Jun 2014 07:45:23 -0700 (PDT)
In-Reply-To: <539F1503.7050602@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/16/2014 7:02 PM, Ben Greear wrote:
> It would be nice to be able to configure some info before
> loading firmware on at least the ath10k NIC.  The problem is,
> there is no debugfs available before loading firmware, ethtool
> would at best require restarting the NIC/firmware, and loading
> binary config blobs attached to firmware is unpleasant.
> 
> Module parameters are generally frowned upon and may be difficult
> to implement properly if we have multiple NICs with different
> desired configuration in a single machine.
> 
> Are there any suggestions on how to do this sort of config?
> 
> Any other drivers currently allowing such things?
> 
> Thanks,
> Ben
> 

Hi,

Yes, we're hitting the same problem in our drivers (mlx4_en, mlx4_core
and mlx4_ib).
There are some settings that need to be set before our NIC is
initialized, and currently the only way to pass it is using module
parameters.
As you, I need to understand if this is a common problem to other
vendors, or something we need to solve in the scope of our driver.

We're scratching our heads for months now to find a solution.
Shannon Nelson from Intel suggested in the past [1] to use a mechanism
similar to request_firmware() to load persistent configuration. It was
rejected by Greg K-H, saying it is abusing the request_firmware() and
shouldn't use "configuration files" for kernel.
Greg suggested to use configfs for that.

It seems that there is a need for a generic solution to have persistent
configurations (like module param), while fixing the problems of module
params, in which the most important as I see it is to have configuration
for a device and not for a driver - could have few
  NIC's with different configurations using the same driver.

We started playing with a POC to use configfs for that, in a similar way
usb gadgets are doing.

For example: the user wants to set a parameter ('dmfs' for instance) on
a device (identified by 11:22:33) that uses the device driver mlx4_core.

# mkdir /sys/kernel/config/devices/mlx4.11:22:33
# ls /sys/kernel/config/devices/mlx4.11:22:33/
dmfs port_type
# echo 1 > /sys/kernel/config/devices/mlx4.11:22:33/dmfs
# modprobe mlx4_core

Explanation: when mkdir is called in config/devices, the device
configuration API will call request_module('dev_c_mlx4') - name of
module is extracted from the directory name.
dev_c_mlx4 will specify the configfs tree for this type of device,  do
the necessary validations on user inputs and supply a query function to
the main driver (mlx4_core) to access those parameters.

This is the general scheme of the solution we thought of.
I would be happy to get feedback about this approach before starting to
do a more in depth design.

Thanks,
Amir

[1] - https://lkml.org/lkml/2013/1/10/606
