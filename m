From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: container userspace tools
Date: Fri, 10 Oct 2008 13:01:05 +0200
Message-ID: <48EF35F1.2060308@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Containers <containers@lists.osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:59789 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759163AbYJJLBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 07:01:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I saw different emails from people asking for user space tools for the 
containers, so I made a library and a set of command line tools.
This component is called "lxc" which stands for "LinuX Container".

The package can be found in the download area of:
    http://sourceforge.net/projects/lxc

There is a cvs repository at:
    http://lxc.cvs.sourceforge.net/lxc

The API is exported in the "lxc.h" header file.

It is not perfect, but it is very light and I hope that will make the 
life easier for the kernel hackers.
It can be used to create virtual private server and to "boot" a minimal 
distro like "debian minimal".

It takes into account the control groups and the checkpoint/restart API 
... in a very optimistic way :)
It should be used with the kernel coming from the git tree, 
git://git.kernel.org/pub/scm/linux/kernel/git/daveh/linux-2.6-lxc.git
But the latest -mm should be ok, some commands will just fail (eg. 
checkpoint/restart).

How to use it ?
--------------------

(for checkpointr/restart see the end of the explanation for this very 
specific, experimental use case).

A container should be created before with (or without) a configuration file.

The configuration file has the following format (all fields are optional):

# set the hostname for the container
lxc.utsname = myhostname
lxc.network.type = veth
lxc.network.link = br0
lxc.network.flags = up
lxc.network.name = eth0
lxc.network.hwaddr = 4a:49:43:49:79:bf
lxc.network.ipv4 = 1.2.3.5/24
lxc.network.ipv6 = 2003:db8:1:0:214:1234:fe0b:3597
lxc.mount = fstab
lxc.rootfs = rootfs
lxc.cgroup.cpuset.cpus = 1
lxc.cgroup.cpu.shares = 512

This is an example, but the configuration file can be much more simple 
or complex. In this example the configuration assume the host is 
configured with a bridge, the liblxc does not configure anything not 
related to the container, so it is up to the user/administrator to setup 
a bridge in this case. If the bridge is a problem, different network 
configurations exist to have a container to communicate with the outside 
world.
The network can be specified with several ip addresses, or either if 
there is only one physical network device, it is possible to specify 
multiple network devices for the container. To do that just replicate 
the network sections as follow:

lxc.network.type = veth
lxc.network.link = br0
lxc.network.flags = up
lxc.network.name = eth0
lxc.network.ipv4 = 192.168.9.100/24
lxc.network.type = veth
lxc.network.link = br0
lxc.network.flags = up
lxc.network.name = eth1
lxc.network.ipv4 = 192.168.10.100/24

The more there are informations in the configuration file, the more the 
container is isolated. eg. if the network section is removed from the 
configuration file, the network won't be virtualized, the same for the 
ustname.

Step 1 : create the container named 'foo' with the configuration file 
'lxc.conf'

        lxc-create -n foo -f lxc.conf

If no configuration file is specified, the container will be created 
with default configuration, that is to say, pid namespace, mount 
namespace and ipc namespace. The other resources,  network, file system, 
utsname, won't be virtualized.

Step 2 : launch a command inside

        lxc-execute -n foo /bin/bash
            or
        lxc-start -n foo /bin/bash

The differences between lxc-execute and lxc-start are, lxc-execute 
creates an intermediate process for the pid namespace in order to 
support daemons and it mounts /proc and /sys.

Step 3 : Stop the container (from outside of the container)

        lxc-stop -n foo

Step 4 : Destroy the container

        lxc-destroy -n foo

ps: it is not mandatory to destroy the container, you can keep the 
configuration and execute/start the command again. That means after a 
reboot, the container configuration is still available.

These are the minimal steps to use a container, but there are some other 
useful commands:
    lxc-freeze / lxc-unfreeze => stop / resume all processes running 
inside the container
    lxc-monitor                    => follow the different states of the 
container
    lxc-wait                          => wait for a specific state 
before exiting (useful for scripting)
    lxc-ps                              => show all non-virtualized pids 
of a container
    lxc-info                           => show the state of the container
    lxc-cgroup                      => get/set cgroup info for this 
container

Checkpoint/Restart:
--------------------------

    The checkpoint / restart is currently *very* experimental, and takes 
into account only one task. For this reason the **lxc-start**  command 
*must* be used.

    The easiest way is specifying a container with the minimal isolation 
for the minimal CR :)

       lxc-create -n ckpt

       lxc-start -n ckpt ./myverysimpleprogram

       lxc-checkpoint -n ckpt -s > myckptfile

       lxc-restart -n ckpt < myckptfile

ps: you have just to create one time the container.

The lxc-checkpoint command will do freeze - checkpoint - unfreeze, if 
the '-s' option is set, the container is stopped after the checkpoint.

I hope that will make people to have fun with the containers and the new 
kernel features.

Thanks.
  -- Daniel
