From: Yotam Gigi <yotamg@mellanox.com>
Subject: Re: [patch net-next 0/9] mlxsw: Support firmware flash
Date: Tue, 23 May 2017 17:37:25 +0300
Message-ID: <ea7cf005-1f6c-aa87-db90-03d7c77c7d56@mellanox.com>
References: <20170523065301.1091-1-jiri@resnulli.us>
 <BLUPR0701MB2004690F775AD57D3CACB1CC8DF90@BLUPR0701MB2004.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "idosch@mellanox.com" <idosch@mellanox.com>,
        "mlxsw@mellanox.com" <mlxsw@mellanox.com>,
        Ben Hutchings <bhutchings@solarflare.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        Jiri Pirko <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr30047.outbound.protection.outlook.com ([40.107.3.47]:57720
        "EHLO EUR03-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S965197AbdEWOhf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 10:37:35 -0400
In-Reply-To: <BLUPR0701MB2004690F775AD57D3CACB1CC8DF90@BLUPR0701MB2004.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2017 04:18 PM, Mintz, Yuval wrote:
>> Add support for device firmware flash on mlxsw spectrum. The firmware files
>> are expected to be in the Mellanox Firmware Archive version 2 (MFA2)
>> format.
>>
>> The firmware flash can be triggered via "ethtool -f" or on driver initialization
>> time if the device firmware version does not meet the minimum firmware
>> version supported by the driver.
>>
>> Currently, to activate the newly flashed firmware, the user needs to reboot
>> his system.
>>
>> The first patch introduces the mlxfw module, which implements common
>> logic needed for the firmware flash process on Mellanox products, such as
>> the
>> MFA2 format parsing and the firmware flash state machine logic. As the
>> module implements common logic which will be needed by various different
>> Mellanox drivers, it defines a set of callbacks needed to interact with the
>> specific device.
>>
>> Patches 1-5 implement the needed mlxfw callbacks in the mlxsw spectrum
>> driver.
>>
>> Patches 6-8 add the "ethtool -f" and the boot-time firmware upgrade on the
>> mlxsw spectrum driver.
> When we tried using `ethtool -E' for qed we got burned for trying to use the magic
> value [1]. When we suggested extending it to allow some private data indications,
> Ben claimed that this entire ethtool infrastructure is a thing of the past,
> and we should try using MTD instead - a claim no one bothered to counter.
>
> Creating proprietary file-formats, filling them with metadata and
> complementary driver state-machines could easily overcome the original
> obstacle we faced. But it raises the question of whether these APIs are
> valid or obsolete.

The metadata in our format is needed to allow us to hold several firmware images
for several spectrum silicon variants in one file, hence the metadata is used by
the driver and does not get transferred to the device. Our code can only be used
to transfer firmware to the device, and cannot be used to configure the device.


>
> [1] http://marc.info/?l=linux-netdev&m=146093513926921&w=4
> [2] http://marc.info/?l=linux-netdev&m=146514461214421&w=2
>
>> Patch 9 adds a fix needed for new firmware versions.
>>
>> Ido Schimmel (1):
>>   mlxsw: spectrum_router: Adjust RIF configuration for new firmware
>>     versions
>>
>> Yotam Gigi (8):
>>   Add the mlxfw module for Mellanox firmware flash process
>>   mlxsw: reg: Add Management Component Query Information register
>>   mlxsw: reg: Add Management Component Control register
>>   mlxsw: reg: Add Management Component Data Access register
>>   mlxsw: spectrum: Add the needed callbacks for mlxfw integration
>>   mlxsw: spectrum: Implement the ethtool flash_device callback
>>   mlxsw: core: Create the mlxsw_fw_rev struct
>>   mlxsw: spectrum: Validate firmware revision on init
>>
>>  MAINTAINERS                                        |   8 +
>>  drivers/net/ethernet/mellanox/Kconfig              |   1 +
>>  drivers/net/ethernet/mellanox/Makefile             |   1 +
>>  drivers/net/ethernet/mellanox/mlxfw/Kconfig        |   6 +
>>  drivers/net/ethernet/mellanox/mlxfw/Makefile       |   2 +
>>  drivers/net/ethernet/mellanox/mlxfw/mlxfw.h        | 102 ++++
>>  drivers/net/ethernet/mellanox/mlxfw/mlxfw_fsm.c    | 273 +++++++++
>>  drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.c   | 620
>> +++++++++++++++++++++
>>  drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.h   |  66 +++
>>  .../net/ethernet/mellanox/mlxfw/mlxfw_mfa2_file.h  |  60 ++
>>  .../ethernet/mellanox/mlxfw/mlxfw_mfa2_format.h    | 103 ++++
>>  .../net/ethernet/mellanox/mlxfw/mlxfw_mfa2_tlv.h   |  98 ++++
>>  .../ethernet/mellanox/mlxfw/mlxfw_mfa2_tlv_multi.c | 126 +++++
>> .../ethernet/mellanox/mlxfw/mlxfw_mfa2_tlv_multi.h |  71 +++
>>  drivers/net/ethernet/mellanox/mlxsw/Kconfig        |   1 +
>>  drivers/net/ethernet/mellanox/mlxsw/core.h         |  12 +-
>>  drivers/net/ethernet/mellanox/mlxsw/reg.h          | 219 ++++++++
>>  drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 266 +++++++++
>>  .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  22 +
>>  19 files changed, 2052 insertions(+), 5 deletions(-)  create mode 100644
>> drivers/net/ethernet/mellanox/mlxfw/Kconfig
>>  create mode 100644 drivers/net/ethernet/mellanox/mlxfw/Makefile
>>  create mode 100644 drivers/net/ethernet/mellanox/mlxfw/mlxfw.h
>>  create mode 100644 drivers/net/ethernet/mellanox/mlxfw/mlxfw_fsm.c
>>  create mode 100644 drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.c
>>  create mode 100644 drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.h
>>  create mode 100644
>> drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2_file.h
>>  create mode 100644
>> drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2_format.h
>>  create mode 100644
>> drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2_tlv.h
>>  create mode 100644
>> drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2_tlv_multi.c
>>  create mode 100644
>> drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2_tlv_multi.h
>>
>> --
>> 2.9.3
