From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [patch net-next 0/9] Introduce devlink interface and first
 drivers to use it
Date: Tue, 23 Feb 2016 00:12:15 -0500
Message-ID: <20160223051214.GP33942@gospo.home.greyhouse.net>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.161.182]:33375 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757151AbcBWFMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 00:12:20 -0500
Received: by mail-yw0-f182.google.com with SMTP id u200so138282706ywf.0
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 21:12:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 22, 2016 at 07:31:55PM +0100, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> There a is need for some userspace API that would allow to expose things
> that are not directly related to any device class like net_device of
> ib_device, but rather chip-wide/switch-ASIC-wide stuff.
> 
> Use cases:
> 1) get/set of port type (Ethernet/InfiniBand)
> 2) setting up port splitters - split port into multiple ones and squash again,
>    enables usage of splitter cable
> 3) setting up shared buffers - shared among multiple ports within
>    one chip (work in progress)
> 4) configuration of switch wide properties - resources division etc - This will
>    allow to pass configuration that is unacceptable to be passed as
>    a module option.

I'm generally a fan of use cases #3 and #4 (as we have previously
discussed), but I'm not sure I agree that the implementation for #2
right now.

I'm not sure I would like userspace to have control over whether or not
a port should be split or not when the hardware can be queried to
determine this.

> First patch of this set introduces a new generic Netlink based interface,
> called "devlink". It is similar to nl80211 model and it is heavily
> influenced by it, including the API definition. The devlink introduction patch
> implements use cases 1) and 2). Other 2 are in development atm and will
> be addressed by follow-ups.
> 
> It is very convenient for drivers to use devlink, as you can see in other
> patches in this set.
> 
> Counterpart for devlink is userspace tool for now called "dl". Command line
> interface and outputs are derived from "ip" tool so it should be easy
> for users to get used to it.
> 
> It is available here as a standalone tool for now:
> https://github.com/jpirko/devlink
> After this is merge in kernel, I will include the "dl" or "devlink" tool
> into iproute2 toolset.
> 
> Port type setting example:
> 	myhost:~$ dl help
> 	Usage: dl [ OPTIONS ] OBJECT { COMMAND | help }
> 	where  OBJECT := { dev | port | monitor }
> 	       OPTIONS := { -v/--verbose }
> 
> 	myhost:~$ dl dev help
> 	Usage: dl dev show [DEV]
> 	Usage: dl dev set DEV [ name NEWNAME ]
> 	
> 	myhost:~$ dl dev show
> 	0: devlink0: bus pci dev 0000:01:00.0
> 	
> 	myhost:~$ dl port help
> 	Usage: dl port show [DEV/PORT_INDEX]
> 	Usage: dl port set DEV/PORT_INDEX [ type { eth | ib | auto} ]
> 	Usage: dl port split DEV/PORT_INDEX count
> 	Usage: dl port unsplit DEV/PORT_INDEX
> 	
> 	myhost:~$ dl port show
> 	devlink0/1: type ib ibdev mlx4_0
> 	devlink0/2: type ib ibdev mlx4_0
> 	
> 	myhost:~$ sudo dl port set devlink0/1 type eth
> 	
> 	myhost:~$ dl port show
> 	devlink0/1: type eth netdev ens4
                             ^^^^^^^^^^^
> 	devlink0/2: type ib ibdev mlx4_0
                            ^^^^^^^^^^^^
I think my only other question about this implementation is whether or
not one would really want to have the true netdev/ibdev names mapped
here.

Would be as reasonable to simply specify the type (and there may be more
types within ethernet that could be useful in multi-chip configurations)
and then let normal infrastructure that exists today figure out how to
map the names for the netdevs to the devices?

> 	myhost:~$ sudo dl port set devlink0/2 type auto
> 	
> 	myhost:~$ dl port show
> 	devlink0/1: type eth netdev ens4
> 	devlink0/2: type ib(auto) ibdev mlx4_0
> 
> Port splitting example:
> 	myswitch:~$ dl port
> 	devlink0/1: type eth netdev eth0
> 	devlink0/3: type eth netdev eth1
> 	devlink0/5: type eth netdev eth2
> 	...
> 	devlink0/63: type eth netdev eth31
> 	
> 	myswitch:~$ sudo dl port split devlink0/1 2
> 	
> 	myswitch:~$ dl port
> 	devlink0/3: type eth netdev eth1
> 	devlink0/5: type eth netdev eth2
> 	...
> 	devlink0/63: type eth netdev eth31
> 	devlink0/1: type eth netdev eth0 split_group 16
> 	devlink0/2: type eth netdev eth32 split_group 16
> 	
> 	myswitch:~$ sudo dl port unsplit devlink0/1
> 	
> 	myswitch:~$ dl port
> 	devlink0/3: type eth netdev eth1
> 	devlink0/5: type eth netdev eth2
> 	...
> 	devlink0/63: type eth netdev eth31
> 	devlink0/1: type eth netdev eth0
> 
> Ido Schimmel (4):
>   mlxsw: spectrum: Unmap local port from module during teardown
>   mlxsw: spectrum: Store local port to module mapping during init
>   mlxsw: spectrum: Mark unused ports using NULL
>   mlxsw: spectrum: Introduce port splitting
> 
> Jiri Pirko (5):
>   Introduce devlink infrastructure
>   mlx4: Implement devlink interface
>   mlx4: Implement port type setting via devlink interface
>   mlxsw: Implement devlink interface
>   mlxsw: core: Add devlink port splitter callbacks
> 
>  MAINTAINERS                                    |   8 +
>  drivers/infiniband/hw/mlx4/main.c              |   7 +
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   8 +-
>  drivers/net/ethernet/mellanox/mlx4/intf.c      |   9 +
>  drivers/net/ethernet/mellanox/mlx4/main.c      | 129 +++-
>  drivers/net/ethernet/mellanox/mlx4/mlx4.h      |   2 +
>  drivers/net/ethernet/mellanox/mlxsw/core.c     |  56 +-
>  drivers/net/ethernet/mellanox/mlxsw/core.h     |   2 +
>  drivers/net/ethernet/mellanox/mlxsw/port.h     |   2 +
>  drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 238 ++++++-
>  drivers/net/ethernet/mellanox/mlxsw/spectrum.h |   8 +-
>  drivers/net/ethernet/mellanox/mlxsw/switchx2.c |  20 +
>  include/linux/mlx4/driver.h                    |   3 +
>  include/net/devlink.h                          | 156 +++++
>  include/uapi/linux/devlink.h                   |  73 ++
>  net/Kconfig                                    |   7 +
>  net/core/Makefile                              |   1 +
>  net/core/devlink.c                             | 887 +++++++++++++++++++++++++
>  18 files changed, 1557 insertions(+), 59 deletions(-)
>  create mode 100644 include/net/devlink.h
>  create mode 100644 include/uapi/linux/devlink.h
>  create mode 100644 net/core/devlink.c
> 
> -- 
> 2.5.0
> 
