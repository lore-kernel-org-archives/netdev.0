From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: Driver profiles RFC
Date: Wed, 9 Aug 2017 14:43:07 +0300
Message-ID: <8c2cd3d2-70a8-b583-28af-6c0b1b6f82c0@mellanox.com>
References: <6d8560fa-8346-0c43-272d-d39be65ea82f@mellanox.com>
 <CAJieiUjvVaurfLGw4HCwfu-wwNpHkBH6Vq7APNj+vzu4CuNLdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, ivecera@redhat.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
        mlxsw <mlxsw@mellanox.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0089.outbound.protection.outlook.com ([104.47.2.89]:9568
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752260AbdHILnR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Aug 2017 07:43:17 -0400
In-Reply-To: <CAJieiUjvVaurfLGw4HCwfu-wwNpHkBH6Vq7APNj+vzu4CuNLdA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/08/2017 07:08 PM, Roopa Prabhu wrote:
> On Tue, Aug 8, 2017 at 6:15 AM, Arkadi Sharshevsky <arkadis@mellanox.com> wrote:
>> Drivers may require driver specific information during the init stage.
>> For example, memory based shared resource which should be segmented for
>> different ASIC processes, such as FDB and LPM lookups.
>>
>> The current mlxsw implementation assumes some default values, which are
>> const and cannot be changed due to lack of UAPI for its configuration
>> (module params is not an option). Those values can greatly impact the
>> scale of the hardware processes, such as the maximum sizes of the FDB/LPM
>> tables. Furthermore, those values should be consistent between driver
>> reloads.
>>
>> The interface called DPIPE [1] was introduced in order to provide
>> abstraction of the hardware pipeline. This RFC letter suggests solving
>> this problem by enhancing the DPIPE hardware abstraction model.
>>
>> DPIPE Resource
>> ==============
>>
>> In order to represent ASIC wide resources space a new object should be
>> introduced called "resource". It was originally suggested as future
>> extension in [1] in order to give the user visibility about the tables
>> limitation due to some shared resource. For example FDB and LPM share
>> a common hash based memory. This abstraction can be also used for
>> providing static configuration for such resources.
>>
>> Resource
>> --------
>> The resource object defines generic hardware resource like memory,
>> counter pool, etc. which can be described by name and size. The resource
>> can be nested, for example the internal ASIC's memory can be split into
>> two parts, as can be seen in the following diagram:
>>
>>                     +---------------+
>>                     |  Internal Mem |
>>                     |               |
>>                     |   Size: 3M*   |
>>                     +---------------+
>>                       /           \
>>                      /             \
>>                     /               \
>>                    /                 \
>>                   /                   \
>>          +--------------+      +--------------+
>>          |    Linear    |      |     Hash     |
>>          |              |      |              |
>>          |   Size: 1M   |      |   Size: 2M   |
>>          +--------------+      +--------------+
>>
>> *The number are provided as an example and do not reflect real ASIC
>>  resource sizes
>>
>> Where the hash portion is used for FDB/LPM table lookups, and the linear
>> one is used by the routing adjacency table. Each resource can be described
>> by a name, size and list of children. Example for dumping the described
>> above structure:
>>
>> #devlink dpipe resource dump tree pci/0000:03:00.0 Mem
>> {
>>     "resource": {
>>        "pci/0000:03:00.0": [{
>>             "name": "Mem",
>>             "size": 3M,
>>             "resource": [{
>>                       "name": "Mem_Linear",
>>                       "size": "1M",
>>                      }, {
>>                       "name": "Mem_Hash",
>>                       "size": "2MK",
>>                      }
>>               }]
>>         }]
>>      }
>> }
>>
>> Each DPIPE table can be connected to one resource.
>>
>> Driver <--> Devlink API
>> =======================
>> Each driver will register his resources with default values at init in
>> a similar way to DPIPE table registration. In case those resources already
>> exist the default values are discarded. The user will be able to dump and
>> update the resources. In order for the changes to take place the user will
>> need to re-initiate the driver by a specific devlink knob.
>>
>> The above described procedure will require extra reload of the driver.
>> This can be improved as a future optimization.
>>
>> UAPI
>> ====
>> The user will be able to update the resources on a per resource basis:
>>
>> $devlink dpipe resource set pci/0000:03:00.0 Mem_Linear 2M
>>
>> For some resources the size is fixed, for example the size of the internal
>> memory cannot be changed. It is provided merely in order to reflect the
>> nested structure of the resource and to imply the user that Mem = Linear +
>> Hash, thus a set operation on it will fail.
>>
>> The user can dump the current resource configuration:
>>
>> #devlink dpipe resource dump tree pci/0000:03:00.0 Mem
>>
>> The user can specify 'tree' in order to show all the nested resources under
>> the specified one. In case no 'resource name' is specified the TOP hierarchy
>> will be dumped.
>>
>> After successful resource update the drivers hould be re-instantiated in
>> order for the changes to take place:
>>
>> $devlink reload pci/0000:03:00.0
>>
>> User Configuration
>> ------------------
>> Such an UAPI is very low level, and thus an average user may not know how to
>> adjust this sizes according to his needs. The vendor can provide several
>> tested configuration files that the user can choose from. Each config file
>> will be measured in terms of: MAC addresses, L3 Neighbors (IPv4, IPv6),
>> LPM entries (IPv4,IPv6) in order to provide approximate results. By this an
>> average user will choose one of the provided ones. Furthermore, a more
>> advanced user could play with the numbers for his personal benefit.
>>
>> Reference
>> =========
>> [1] https://emea01.safelinks.protection.outlook.com/?url=https%3A%2F%2Fnetdevconf.org%2F2.1%2Fpapers%2Fdpipe_netdev_2_1.odt&data=02%7C01%7Carkadis%40mellanox.com%7Cc64b0d54e3e94d07b64c08d4de77bf8b%7Ca652971c7d2e4d9ba6a4d149256f461b%7C0%7C0%7C636378053281241266&sdata=9u%2BFwGF%2FjkmNogPF7Cm%2FfwJsaPVkr%2BC3%2F8x1IVbszRg%3D&reserved=0
>>
> 
> Thanks for sending this out. There is very much a need for this.
> and agree, user-space app config can translate to what values they want and
>  kernel api can be a low level api.
> 
> But how about we align these resource limits with the kernel resource limits ?
> For example we usually map l3 hw neighbor limits to kernel software gc_thresh
> values (which are configurable via sysctl). This is one way to give
> user immediate
> feedback on resource full errors. It would be nice if we can introduce
> limits for routes and
> mac addresses. Defaults could be what they are today but user
> configurable ...like I said,
> neighbor subsystem already allows this.
> 

Hi Roopa, thanks for the feedback.

Regarding aligning the hardware tables sizes with the kernel software
limits. The hardware resources (internal memory) are much more limited
than the software one. Please consider the following scenario:

1. User adds limit to neighbor table (as you suggested), which uses the
   hash memory portion.
2. User adds many routes, the routes uses the hash memory resource as well,
   potentially.
3. The kernel adds some neighbors dynamically, the neighbor offloading
   fails due to lack of this shared resource, the user get confused because
   its lower then what he configured in 1).

Thus providing max size on specific table is not well defined due to
limited
shared resource. Thus, the feedback the user gets can be not very accurate.
Furthermore, guessing the resource partitioning based only on the subset of
tables which use it makes me little bit uncomfortable.

The proposed API aims at solving this issue by providing abstraction for
this hw behavior, and provide the connection with the hardware table, thus
providing more accurate and well defined description of the system.

I totally agree that this API should be enhanced in order provide the
occupancy of the this 'resource'. For example, the user first observe the
tables and sees the resource<->table mapping, then see the resource
occupancy:

#devlink dpipe resource occupancy pci/0000:03:00.0 Mem

By this the user can understand the offloading limitation, and maybe figure
out that he should change the partitioning.

Thanks,
Arkadi
