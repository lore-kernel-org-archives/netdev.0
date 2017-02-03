From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/19] mlxsw: Introduce TC Flower offload using
 TCAM
Date: Fri, 3 Feb 2017 07:58:01 +0100
Message-ID: <20170203065801.GB1871@nanopsycho.orion>
References: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
 <97783099-8179-30c4-878b-424c4e858dc0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, mlxsw@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, ivecera@redhat.com, jbenc@redhat.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32900 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752311AbdBCG6E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 01:58:04 -0500
Received: by mail-wm0-f68.google.com with SMTP id v77so2272590wmv.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 22:58:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <97783099-8179-30c4-878b-424c4e858dc0@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 02, 2017 at 10:40:42PM CET, f.fainelli@gmail.com wrote:
>On 02/02/2017 07:12 AM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> This patchset introduces support for offloading TC cls_flower and actions
>> to Spectrum TCAM-base policy engine.
>> 
>> The patchset contains patches to allow work with flexible keys and actions
>> which are used in Spectrum TCAM.
>> 
>> It also contains in-driver infrastructure for offloading TC rules to TCAM HW.
>> The TCAM management code is simple and limited for now. It is going to be
>> extended as a follow-up work.
>> 
>> The last patch uses the previously introduced infra to allow to implement
>> cls_flower offloading. Initially, only limited set of match-keys and only
>> a drop and forward actions are supported.
>> 
>> As a dependency, this patchset introduces parman - priority array
>> area manager - as a library.
>
>This looks really great (except all the input parameters validation
>using flow_dissector keys, but there is already a thread about that, and
>you are working with what you have)!
>
>One thing I found missing with cls_flower is the ability to specify the
>location of a rule, or if not specified have the switch driver return to
>user which rule index was selected. Should we consider adding that so we
>could finally move out of ethtool::rxfnc for NICs and other drivers?

What exactly do you mean by "location"? When you add the rule, you
specify "pref/prio". Rules with same prio have always indentical mask
and go into one hashtable. For mlxsw offload, the rule with prio goes
down to driver and the chunks of rules with same priority are arranged
in TCAM accordingly (using parman).



>
>Thanks
>
>> 
>> Jiri Pirko (19):
>>   mlxsw: item: Add 8bit item helpers
>>   mlxsw: item: Add helpers for getting pointer into payload for char
>>     buffer item
>>   mlxsw: reg: Add Policy-Engine ACL Register
>>   mlxsw: reg: Add Policy-Engine ACL Group Table register
>>   mlxsw: reg: Add Policy-Engine TCAM Allocation Register
>>   mlxsw: reg: Add Policy-Engine TCAM Entry Register Version 2
>>   mlxsw: reg: Add Policy-Engine Port Binding Table
>>   mlxsw: reg: Add Policy-Engine Rules Copy Register
>>   mlxsw: reg: Add Policy-Engine Policy Based Switching Register
>>   mlxsw: reg: Add Policy-Engine Extended Flexible Action Register
>>   mlxsw: core: Introduce flexible keys support
>>   mlxsw: core: Introduce flexible actions support
>>   mlxsw: spectrum: Introduce basic set of flexible key blocks
>>   mlxsw: resources: Add ACL related resources
>>   list: introduce list_for_each_entry_from_reverse helper
>>   lib: Introduce priority array area manager
>>   mlxsw: spectrum: Introduce ACL core with simple TCAM implementation
>>   sched: cls_flower: expose priority to offloading netdevice
>>   mlxsw: spectrum: Implement TC flower offload
>> 
>>  MAINTAINERS                                        |    8 +
>>  drivers/net/ethernet/mellanox/mlxsw/Kconfig        |    1 +
>>  drivers/net/ethernet/mellanox/mlxsw/Makefile       |    6 +-
>>  .../mellanox/mlxsw/core_acl_flex_actions.c         |  685 +++++++++++++
>>  .../mellanox/mlxsw/core_acl_flex_actions.h         |   66 ++
>>  .../ethernet/mellanox/mlxsw/core_acl_flex_keys.c   |  475 +++++++++
>>  .../ethernet/mellanox/mlxsw/core_acl_flex_keys.h   |  238 +++++
>>  drivers/net/ethernet/mellanox/mlxsw/item.h         |   98 +-
>>  drivers/net/ethernet/mellanox/mlxsw/reg.h          |  511 ++++++++-
>>  drivers/net/ethernet/mellanox/mlxsw/resources.h    |   20 +-
>>  drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   32 +-
>>  drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  106 +-
>>  drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c |  572 +++++++++++
>>  .../mellanox/mlxsw/spectrum_acl_flex_keys.h        |  109 ++
>>  .../ethernet/mellanox/mlxsw/spectrum_acl_tcam.c    | 1084 ++++++++++++++++++++
>>  .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  |  309 ++++++
>>  include/linux/list.h                               |   13 +
>>  include/linux/parman.h                             |   76 ++
>>  include/net/pkt_cls.h                              |    1 +
>>  lib/Kconfig                                        |    3 +
>>  lib/Kconfig.debug                                  |   10 +
>>  lib/Makefile                                       |    3 +
>>  lib/parman.c                                       |  294 ++++++
>>  lib/test_parman.c                                  |  395 +++++++
>>  net/sched/cls_flower.c                             |    3 +
>>  25 files changed, 5102 insertions(+), 16 deletions(-)
>>  create mode 100644 drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
>>  create mode 100644 drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
>>  create mode 100644 drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.c
>>  create mode 100644 drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.h
>>  create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
>>  create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h
>>  create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
>>  create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
>>  create mode 100644 include/linux/parman.h
>>  create mode 100644 lib/parman.c
>>  create mode 100644 lib/test_parman.c
>> 
>
>
>-- 
>Florian
