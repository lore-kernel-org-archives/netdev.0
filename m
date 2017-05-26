From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Fri, 26 May 2017 11:59:26 +0300
Message-ID: <CALzJLG98D=3yMJV_q4sjVNG41AERFRU+6rwqQJsxnRuVeDTPdA@mail.gmail.com>
References: <20170523114404.20387-1-saeedm@mellanox.com> <20170523114404.20387-5-saeedm@mellanox.com>
 <20170524165059.42lmrwzzcxvi2sf7@ast-mbp> <AM4PR0501MB1940885C2F1CEF4DDE4EA8D1DBFF0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170526030701.du4345mbprhcwjyi@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Ilan Tayari <ilant@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "jsorensen@fb.com" <jsorensen@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35834 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425885AbdEZI7r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 04:59:47 -0400
Received: by mail-qk0-f195.google.com with SMTP id k74so455184qke.2
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 01:59:47 -0700 (PDT)
In-Reply-To: <20170526030701.du4345mbprhcwjyi@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 26, 2017 at 6:07 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Thu, May 25, 2017 at 05:20:04AM +0000, Ilan Tayari wrote:
>>
>> If you do want this, then splitting some of the logic to a
>> separate kernel object will not gain anything useful (logic would stay
>> the same), and just pollute the exported symbol table and open up the door
>> for issues of inter-module compatibility and so on.
>
> in other words instead of properly designing inter-module api
> you just want to add everything into one giant 'driver'
> because it's easier to do so. Understandable, but it leads
> to unmaintainable device infrastructure long term.
>

What is wrong with giant 'driver'  ? :-)
BTW making the fpga a separate module is as easy as adding one line to
the make file
and moving the entry points functions (fpga_init/cleanup) form mlx5
init flow into a "mlx5_interface" instance and register it with the
mlx5_core.

But again i don't see a point of doing so, the code will still look
the same and sit in the same places.

so one giant ko file or small separate modules is basically the same,
from my point of view. modular design have nothing to do with the
compilation output binary, it should be considered regardless of the
compiler output.

Which we tried to not far a go to break the driver into sub-module
directories, each with its own responsibility, but it was too late for
that.

And for FPGA support, we did it correctly this time, all the new code
is under mlx5/core/fgpa ..
if you don't like core/fpga, ok just simply "CONFIG_MLX5_FPGA = no"
and all of that code/directory will disappear from your ko file and
will not be touched in compilation time, and the core code will still
look the same.

>> Furthermore, the next patchset will introduce IPSec offload capabilities
>> Which are declared in netdev->hw_features. Those cannot be modified
>> after the netdevice is created, so all the extra logic has to be
>> integrated into the mlx5 ethernet driver. This is another reason why
>> a separate driver is a bad idea.
>
> that increases my concerns even more.
> ipsec offload is a new feature for new hw, yet you're trying to
> hide it in the mlx5 'driver'.
>

Well, this is a well known dilemma, if one has a new feature and has no sandbox
area to put it in the first phase, it is better to start from the most
common place
for that feature which is the originating place, before defining
APIs/infrastructures,
until the feature is complete and every body is happy about it.

Same was done for GRO, XDP , you name it ..

nothing is being hidden here, we are adding new HW offloads, not that
different from
csum offloads, which no one can live without these days, and i believe
in few years IPSec and TLS and security offloads will be no less
important than csum offloads.

Someone has to start somewhere and we choose to start in our driver,
if you have a better IPSec generic interface that allows modular
module separation we are happy to hear about it.

> mlx5 already supports cx4/cx4-lx/cx5 and not even released cx6.

I will take this as a complement ;-), please see more info below.

> All of them have different feature sets.

Not different feature sets, but i expect some changes through out the
evolution of the ConnectX chip , and those changes can be:
1. internal bug fixes/internal improvements.
2. new extra features from the previous generation.

But the chip is the same chip, i.e same driver works on all of the
chips with the basic/standard feature set.

> The only common piece is driver/fw cmd interface and _some_ aspects
> of rx/tx descriptors. Everything else is different.

I can add more to the list.
basic offloads, steering management, eswitch, HW objects and semantics
QPs/RQs/SQs/CQs/EQs and their manipulation semantics, internal page
memory management, NIC initialization and teardown flows  are the same
and many more.


> cx4-lx doesn't have infiniband and rdma, yet there is a ton of code

although it doesn't have infinband support, cx4-lx have rdma support,
you can perfectly load mlx5_ib and work with RDMA over ethernet
(RoCE).
which is 99% of the mlx5_ib&mlx5_core code. (really !)
so the ton of code is still valid for cx4-lx.

> in the driver that deals with it.
> cx5 has fancy storage interfaces for nvme, etc I don't think they
> are part of the mlx5 'driver' yet. Are you going to dump them
> in there as well?
> Take a look at the simplest feature-wise cx4-lx. It has
> eswitch which is full l2 switch with mac table, drop policy,
> counters and such. Yet kernel knows nothing about it.
> Everything is hidden in mlx5 'driver' with its own special
> interfaces to manage it.

1. eswitch is a very integral steering feature of the ConnectX family
and is valid for all ConnectX4/lx/5/6 .. cards.
2. kenrel doesn't and can't know about it since in the early days of
SRIOV implementation (what the cool kids of switchdev mode call the
legacy sriov mode) is the responsibility of the device driver and it
is an internal arch of the HCA. so it is not our fault it is hidden in
mlx5, we just went with the flow..
3. I agree with you, device driver should be as transparent as
possible to the kernel, and should provide as much info as needed to
the stack.
4. switchdev mode came to solve this exact issue, and the kernel stack
even up to user space are perfectly aware of the nic eswitch
capabilities.

being said, even if the kernel is aware or not aware of the eswitch it
doesn't mean it should or shouldn't sit in the same mlx5 ko file.

> Now you want to hide fpga with custom logic behind mlx5 'driver'
> and manage it through mlx5 interfaces?
> That's not acceptable.
> mlx fpga got to have generic kernel representation that intel
> and other fpga vendors can use.
>

quoting Ilan from his commit message:

"The FPGA is a bump-on-the-wire and thus affects operation of
the mlx5_core driver on the ConnectX ASIC."

This is not a general purpose FPGA ! it even doesn't have a PCI Id or
it is own PCI function.
it simply allows the ConnectX Chip user to inspect/inject or run user
specif login on traffic going in/out of the chip.

But i agree with you some serious API brainstorming should be
considered, but not at this stage,
this patch only tells the ConnectX card (if you have FPGA, please enable it).

> mlx5 driver has to be modularized and since it's not too late
> cx6 support has to be removed from it.
>

I agree with you on the first part, Yes i would like to better
modularize the driver, i will even consider taking it to the extreme
and have separate module for each sub mlx5 module
e.g:

mlx5_core.ko
mlx5_eswitch.ko
mlx5_vxaln.ko
mlx5_vf_repreentor.ko
mlx5_ipoib.ko
...
even mlx5_xdp.ko ( not really ;-) )

If this what it takes to more logically and modularly break mlx5/core
into hierarchical design,
Please count me in. And i would like to hear Dave explicitly say i am
ok with this first.

But, re cx6 I am not sure i can agree on this for the simple fact:

it took 3 years to get mlx5 (Cx4/lx) driver to provide similar feature
set as mlx4 (Cx3).
and it literally took 0 lines of codes 1 day of regression to test
mlx5 driver over CX5 !
Now All we need is to add the new features of CX5 on top of the
already existing driver and i will be more than happy to hear about
exciting Ideas on how to modularly do that in the same driver,
and provide clear separation (beleive me it is is to do, if i am
allowed to split the driver into directories) but i can't do it in a
completely separate driver with a base code library, it is simply
wrong and non scalable (even if someone is not careful enough it could
make a lot of dependency mess between mlx5 modules)

> Thankfully only few cx6 pci ids were added to mlx5, but driver
> knows nothing about cx6 features, so we can properly design it.
>

> Since driver/fw interface is common between cx4+ this part
> can be moved into mlx_core.ko or done as library
> the way chelsio did it in libcxgb.
>

driver/fw interfaces are not the only common part, it is all basic
standard netdev/rdma and linux networkinng stuff are the same.

-Saeed.
