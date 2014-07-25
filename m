From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: How to load config info before loading firmware?
Date: Fri, 25 Jul 2014 17:36:26 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418ACFE74E@fmsmsx115.amr.corp.intel.com>
References: <539F1503.7050602@candelatech.com> <53B02681.3080304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"tzahio@mellanox.com" <tzahio@mellanox.com>
To: "amirv@mellanox.com" <amirv@mellanox.com>,
	Ben Greear <greearb@candelatech.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56288 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752559AbaGYRge convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 13:36:34 -0400
In-Reply-To: <53B02681.3080304@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Amir Vadai [mailto:amirv.mellanox@gmail.com]
> Sent: Sunday, June 29, 2014 7:45 AM
> 
> On 6/16/2014 7:02 PM, Ben Greear wrote:
> > It would be nice to be able to configure some info before
> > loading firmware on at least the ath10k NIC.  The problem is,
> > there is no debugfs available before loading firmware, ethtool
> > would at best require restarting the NIC/firmware, and loading
> > binary config blobs attached to firmware is unpleasant.
> >
> > Module parameters are generally frowned upon and may be difficult
> > to implement properly if we have multiple NICs with different
> > desired configuration in a single machine.
> >
> > Are there any suggestions on how to do this sort of config?
> >
> > Any other drivers currently allowing such things?
> >
> > Thanks,
> > Ben
> >
> 
> Hi,
> 
> Yes, we're hitting the same problem in our drivers (mlx4_en, mlx4_core
> and mlx4_ib).
> There are some settings that need to be set before our NIC is
> initialized, and currently the only way to pass it is using module
> parameters.
> As you, I need to understand if this is a common problem to other
> vendors, or something we need to solve in the scope of our driver.
> 
> We're scratching our heads for months now to find a solution.
> Shannon Nelson from Intel suggested in the past [1] to use a mechanism
> similar to request_firmware() to load persistent configuration. It was
> rejected by Greg K-H, saying it is abusing the request_firmware() and
> shouldn't use "configuration files" for kernel.
> Greg suggested to use configfs for that.
> 
> It seems that there is a need for a generic solution to have persistent
> configurations (like module param), while fixing the problems of module
> params, in which the most important as I see it is to have
> configuration
> for a device and not for a driver - could have few
>   NIC's with different configurations using the same driver.
> 
> We started playing with a POC to use configfs for that, in a similar
> way
> usb gadgets are doing.
> 
> For example: the user wants to set a parameter ('dmfs' for instance) on
> a device (identified by 11:22:33) that uses the device driver
> mlx4_core.
> 
> # mkdir /sys/kernel/config/devices/mlx4.11:22:33
> # ls /sys/kernel/config/devices/mlx4.11:22:33/
> dmfs port_type
> # echo 1 > /sys/kernel/config/devices/mlx4.11:22:33/dmfs
> # modprobe mlx4_core
> 
> Explanation: when mkdir is called in config/devices, the device
> configuration API will call request_module('dev_c_mlx4') - name of
> module is extracted from the directory name.
> dev_c_mlx4 will specify the configfs tree for this type of device,  do
> the necessary validations on user inputs and supply a query function to
> the main driver (mlx4_core) to access those parameters.
> 
> This is the general scheme of the solution we thought of.
> I would be happy to get feedback about this approach before starting to
> do a more in depth design.
> 
> Thanks,
> Amir
> 
> [1] - https://lkml.org/lkml/2013/1/10/606

Thanks, Amir, for pointing this discussion at me.  Sorry I'm so late at getting back, I was on vacation, etc...

Yes, the configfs constructs are part of the "correct" solution as GregKH pointed out to us.  This can take care of several of the situations we had thought about, but not all.  This works fine for the port-specific configurations where the driver creates the port instance, and then userland has some opportunity to configure via udev event driven scripts before enabling the communication link.  This doesn't work for configuration info needed before the driver can create a configfs object.

The real problem we were trying to solve with our (ab)use of the request_firmware() infrastructure was how to do very early driver configuration.  There are some early driver initialization steps (PCI setup options, interrupt reservations, certain HW init) that could use configuration information long before the udev, sysfs, network stack, or other connections can be made.  This is what the module parameters historically gave us.  With the de-emphasis of module parameters, we're lacking a similar early configuration opportunity.

In our case, we found ways to work around and do without it, tho' we're still missing a couple of things.  Perhaps forcing a change in design models is a good thing, but I believe there are still valid situations where this kind of early config would be beneficial.  

sln
