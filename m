From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Driver profiles RFC
Date: Tue, 8 Aug 2017 16:15:41 +0300
Message-ID: <6d8560fa-8346-0c43-272d-d39be65ea82f@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ivecera@redhat.com,
        roopa@cumulusnetworks.com, Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        john.fastabend@gmail.com, Andrew Lunn <andrew@lunn.ch>,
        Jiri Pirko <jiri@resnulli.us>, mlxsw <mlxsw@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0046.outbound.protection.outlook.com ([104.47.2.46]:6752
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751925AbdHHNPw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Aug 2017 09:15:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers may require driver specific information during the init stage.
For example, memory based shared resource which should be segmented for
different ASIC processes, such as FDB and LPM lookups.

The current mlxsw implementation assumes some default values, which are
const and cannot be changed due to lack of UAPI for its configuration
(module params is not an option). Those values can greatly impact the
scale of the hardware processes, such as the maximum sizes of the FDB/LPM
tables. Furthermore, those values should be consistent between driver
reloads.

The interface called DPIPE [1] was introduced in order to provide
abstraction of the hardware pipeline. This RFC letter suggests solving
this problem by enhancing the DPIPE hardware abstraction model.

DPIPE Resource
==============

In order to represent ASIC wide resources space a new object should be
introduced called "resource". It was originally suggested as future
extension in [1] in order to give the user visibility about the tables
limitation due to some shared resource. For example FDB and LPM share
a common hash based memory. This abstraction can be also used for
providing static configuration for such resources.

Resource
--------
The resource object defines generic hardware resource like memory,
counter pool, etc. which can be described by name and size. The resource
can be nested, for example the internal ASIC's memory can be split into
two parts, as can be seen in the following diagram:

                    +---------------+
                    |  Internal Mem |
                    |               |
                    |   Size: 3M*   |
                    +---------------+
                      /           \
                     /             \
                    /               \
                   /                 \
                  /                   \
         +--------------+      +--------------+
         |    Linear    |      |     Hash     |
         |              |      |              |
         |   Size: 1M   |      |   Size: 2M   |
         +--------------+      +--------------+

*The number are provided as an example and do not reflect real ASIC
 resource sizes

Where the hash portion is used for FDB/LPM table lookups, and the linear
one is used by the routing adjacency table. Each resource can be described
by a name, size and list of children. Example for dumping the described
above structure:

#devlink dpipe resource dump tree pci/0000:03:00.0 Mem
{
    "resource": {
       "pci/0000:03:00.0": [{
            "name": "Mem",
            "size": 3M,
            "resource": [{
                      "name": "Mem_Linear",
                      "size": "1M",
                     }, {
                      "name": "Mem_Hash",
                      "size": "2MK",
		     }
              }]
        }]
     }
}

Each DPIPE table can be connected to one resource.

Driver <--> Devlink API
=======================
Each driver will register his resources with default values at init in
a similar way to DPIPE table registration. In case those resources already
exist the default values are discarded. The user will be able to dump and
update the resources. In order for the changes to take place the user will
need to re-initiate the driver by a specific devlink knob.

The above described procedure will require extra reload of the driver.
This can be improved as a future optimization.

UAPI
====
The user will be able to update the resources on a per resource basis:

$devlink dpipe resource set pci/0000:03:00.0 Mem_Linear 2M

For some resources the size is fixed, for example the size of the internal
memory cannot be changed. It is provided merely in order to reflect the
nested structure of the resource and to imply the user that Mem = Linear +
Hash, thus a set operation on it will fail.

The user can dump the current resource configuration:

#devlink dpipe resource dump tree pci/0000:03:00.0 Mem

The user can specify 'tree' in order to show all the nested resources under
the specified one. In case no 'resource name' is specified the TOP hierarchy
will be dumped.

After successful resource update the drivers hould be re-instantiated in
order for the changes to take place:

$devlink reload pci/0000:03:00.0

User Configuration
------------------
Such an UAPI is very low level, and thus an average user may not know how to
adjust this sizes according to his needs. The vendor can provide several
tested configuration files that the user can choose from. Each config file
will be measured in terms of: MAC addresses, L3 Neighbors (IPv4, IPv6),
LPM entries (IPv4,IPv6) in order to provide approximate results. By this an
average user will choose one of the provided ones. Furthermore, a more
advanced user could play with the numbers for his personal benefit.

Reference
=========
[1] https://netdevconf.org/2.1/papers/dpipe_netdev_2_1.odt
