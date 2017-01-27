From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 1/4] mlx5: Make building eswitch configurable
Date: Fri, 27 Jan 2017 22:59:35 +0200
Message-ID: <CALzJLG8CgNy6pLJqx7r5XATuaHzPCUV0KmVnd7-_cfC_BdSoQw@mail.gmail.com>
References: <20170126233241.2268449-1-tom@herbertland.com> <20170126233241.2268449-2-tom@herbertland.com>
 <CALzJLG-=Mzm+ko-=Ycu2vE6kdvX9zGF5XAP+z4hRv6sgX3G__w@mail.gmail.com> <CALx6S378XJXTku5t2dtWLLCTVDCqiPeVx8si+SPa98E9fYZ=PQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33402 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751165AbdA0VA1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 16:00:27 -0500
Received: by mail-qt0-f196.google.com with SMTP id n13so48521892qtc.0
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 12:59:56 -0800 (PST)
In-Reply-To: <CALx6S378XJXTku5t2dtWLLCTVDCqiPeVx8si+SPa98E9fYZ=PQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2017 at 8:33 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Fri, Jan 27, 2017 at 10:19 AM, Saeed Mahameed
> <saeedm@dev.mellanox.co.il> wrote:
>> On Fri, Jan 27, 2017 at 1:32 AM, Tom Herbert <tom@herbertland.com> wrote:
>>> Add a configuration option (CONFIG_MLX5_CORE_ESWITCH) for controlling
>>> whether the eswitch code is built. Change Kconfig and Makefile
>>> accordingly.
>>>
>>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>>> ---
>>>  drivers/net/ethernet/mellanox/mlx5/core/Kconfig   | 11 +++
>>>  drivers/net/ethernet/mellanox/mlx5/core/Makefile  |  6 +-
>>>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 92 +++++++++++++++++------
>>>  drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   | 39 +++++++---
>>>  drivers/net/ethernet/mellanox/mlx5/core/eq.c      |  4 +-
>>>  drivers/net/ethernet/mellanox/mlx5/core/main.c    | 16 ++--
>>>  drivers/net/ethernet/mellanox/mlx5/core/sriov.c   |  6 +-
>>>  7 files changed, 125 insertions(+), 49 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
>>> index ddb4ca4..27aae58 100644
>>> --- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
>>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
>>> @@ -30,3 +30,14 @@ config MLX5_CORE_EN_DCB
>>>           This flag is depended on the kernel's DCB support.
>>>
>>>           If unsure, set to Y
>>> +
>>> +config MLX5_CORE_EN_ESWITCH
>>> +       bool "Ethernet switch"
>>> +       default y
>>> +       depends on MLX5_CORE_EN
>>> +       ---help---
>>> +         Say Y here if you want to use Ethernet switch (E-switch). E-Switch
>>> +         is the software entity that represents and manages ConnectX4
>>> +         inter-HCA ethernet l2 switching.
>>> +
>>> +         If unsure, set to Y
>>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>>> index 9f43beb..17025d8 100644
>>> --- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>>> @@ -5,9 +5,11 @@ mlx5_core-y := main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
>>>                 mad.o transobj.o vport.o sriov.o fs_cmd.o fs_core.o \
>>>                 fs_counters.o rl.o lag.o dev.o
>>>
>>> -mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o eswitch_offloads.o \
>>> +mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o \
>>>                 en_main.o en_common.o en_fs.o en_ethtool.o en_tx.o \
>>>                 en_rx.o en_rx_am.o en_txrx.o en_clock.o vxlan.o \
>>> -               en_tc.o en_arfs.o en_rep.o en_fs_ethtool.o en_selftest.o
>>> +               en_tc.o en_arfs.o en_fs_ethtool.o en_selftest.o
>>>
>>>  mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
>>> +
>>> +mlx5_core-$(CONFIG_MLX5_CORE_EN_ESWITCH) += eswitch.o eswitch_offloads.o en_rep.o
>>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>>> index e829143..1db4d98 100644
>>> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>>> @@ -38,7 +38,9 @@
>>>  #include <linux/bpf.h>
>>>  #include "en.h"
>>>  #include "en_tc.h"
>>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>>  #include "eswitch.h"
>>> +#endif
>>
>> Wouldn't it be cleaner if we left the main code (en_main.c) untouched
>> and kept this
>> #include "eswitch.h" and instead of filling the main flow code with
>> #ifdefs, in eswitch.h
>> we can create eswitch mock API functions when
>> CONFIG_MLX5_CORE_EN_ESWITCH is not enabled ? the main flow will be
>> clean from ifdefs and will complie with mock functions.
>>
>> we did this with accelerated RFS feature. look for "#ifndef
>> CONFIG_RFS_ACCEL" in en.h
>>
> There are still occurrences of CONFIG_RFS_ACCEL in en_main.c and
> main.c. For eswitch its a header problem, not everything related to
> eswitch was extracted out of main though backend functions. There is a
> lot of code that related to eswitch that is intertwined with the core
> code.
>

Interesting, i just did a quick look and it seems to me all eswitch
logic in en_main.c can be kept untouched if we have the right mock
functions, on the other hand it seems that there are a lot of
eswitch functions to mock, i am not sure it is a good thing anymore,
let's leave it as is for now.
