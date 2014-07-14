From: Andy Green <andy.green@linaro.org>
Subject: Re: [PATCH 6/8] net: ethernet driver: Fujitsu OGMA
Date: Mon, 14 Jul 2014 18:36:11 +0800
Message-ID: <CAAfg0W5hFJwjEO+U55CfUq6B82DCmsDzbzL1-ND1R7VZCjad3Q@mail.gmail.com>
References: <1405233107-4762-1-git-send-email-mollie.wu@linaro.org>
	<20140714090628.GA7668@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mollie Wu <mollie.wu@linaro.org>,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	netdev <netdev@vger.kernel.org>,
	Patch Tracking <patches@linaro.org>,
	Jaswinder Singh <jaswinder.singh@linaro.org>,
	linux@arm.linux.org.uk, arnd@arndb.de,
	Olof Johansson <olof@lixom.net>, mark.rutland@arm.com,
	robh+dt@kernel.org, pawel.moll@arm.com,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Tetsuya Takinishi <t.takinishi@jp.fujitsu.com>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:38247 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754370AbaGNKgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 06:36:12 -0400
Received: by mail-qc0-f180.google.com with SMTP id l6so3019942qcy.39
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 03:36:12 -0700 (PDT)
In-Reply-To: <20140714090628.GA7668@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 July 2014 17:06, Tobias Klauser <tklauser@distanz.ch> wrote:
> On 2014-07-13 at 08:31:47 +0200, Mollie Wu <mollie.wu@linaro.org> wrote:
>> This driver adds support for "ogma", a Fujitsu Semiconductor Ltd IP Gigabit
>> Ethernet + PHY IP used in a variety of their ARM-based ASICs.
>>
>> This is being sent as part of a series including the arch support that uses it,
>> Fujitsu mb86s7x.
>>
>> This driver was originally written by guys inside Fujitsu as an abstracted
>> "you can build this for Windows as well" type code, I've removed all that,
>> modernized various things, added runtime_pm, and ported it to work with
>> Device Tree, using only the bindings already mentioned in
>>
>> ./Documentation/devicetree/bindings/net/ethernet.txt
>>
>> Bindings documentation is added by this patch.
>>
>> Signed-off-by: Andy Green <andy.green@linaro.org>
>> Signed-off-by: Tetsuya Takinishi <t.takinishi@jp.fujitsu.com>
>> Signed-off-by: Mollie Wu <mollie.wu@linaro.org>
>> ---
>>  .../devicetree/bindings/net/fujitsu-ogma.txt       |  43 ++
>>  drivers/net/ethernet/fujitsu/Kconfig               |  12 +
>>  drivers/net/ethernet/fujitsu/Makefile              |   1 +
>>  drivers/net/ethernet/fujitsu/ogma/Makefile         |   6 +
>>  drivers/net/ethernet/fujitsu/ogma/ogma.h           | 380 +++++++++++++
>>  .../ethernet/fujitsu/ogma/ogma_desc_ring_access.c  | 627 +++++++++++++++++++++
>>  drivers/net/ethernet/fujitsu/ogma/ogma_ethtool.c   |  95 ++++
>>  .../net/ethernet/fujitsu/ogma/ogma_gmac_access.c   | 295 ++++++++++
>>  drivers/net/ethernet/fujitsu/ogma/ogma_netdev.c    | 592 +++++++++++++++++++
>>  drivers/net/ethernet/fujitsu/ogma/ogma_platform.c  | 333 +++++++++++
>>  10 files changed, 2384 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/net/fujitsu-ogma.txt
>>  create mode 100644 drivers/net/ethernet/fujitsu/ogma/Makefile
>>  create mode 100644 drivers/net/ethernet/fujitsu/ogma/ogma.h
>>  create mode 100644 drivers/net/ethernet/fujitsu/ogma/ogma_desc_ring_access.c
>>  create mode 100644 drivers/net/ethernet/fujitsu/ogma/ogma_ethtool.c
>>  create mode 100644 drivers/net/ethernet/fujitsu/ogma/ogma_gmac_access.c
>>  create mode 100644 drivers/net/ethernet/fujitsu/ogma/ogma_netdev.c
>>  create mode 100644 drivers/net/ethernet/fujitsu/ogma/ogma_platform.c
>
> [...]
>
>> diff --git a/drivers/net/ethernet/fujitsu/ogma/ogma_platform.c b/drivers/net/ethernet/fujitsu/ogma/ogma_platform.c
>> new file mode 100644
>> index 0000000..09071da
>> --- /dev/null
>> +++ b/drivers/net/ethernet/fujitsu/ogma/ogma_platform.c
>
> [...]
>
>> +#ifdef CONFIG_PM
>> +static const struct dev_pm_ops ogma_pm_ops = {
>> +     SET_SYSTEM_SLEEP_PM_OPS(ogma_pm_suspend, ogma_pm_resume)
>> +     SET_RUNTIME_PM_OPS(ogma_runtime_suspend, ogma_runtime_resume, NULL)
>> +};
>> +#endif
>
> #ifdef CONFIG_PM can be omitted here since
> SET_{SYSTEM_SLEEP,RUNTIME}_PM_OPS will just evaluate empty if CONFIG_PM
> is not defined.
>
>> +
>> +static const struct of_device_id ogma_dt_ids[] = {
>> +     {.compatible = "fujitsu,ogma"},
>> +     { /* sentinel */ }
>> +};
>> +
>> +MODULE_DEVICE_TABLE(of, ogma_dt_ids);
>> +
>> +static struct platform_driver ogma_driver = {
>> +     .probe = ogma_probe,
>> +     .remove = ogma_remove,
>> +     .driver = {
>> +             .name = "ogma",
>> +             .of_match_table = ogma_dt_ids,
>> +#ifdef CONFIG_PM
>> +             .pm = &ogma_pm_ops,
>> +#endif
>
> With the above #ifdef CONFIG_PM removed, ogma_pm_ops will be all NULL if
> CONFIG_PM is not set. Thus, the #ifdef can be removed as well.

OK will fix, thanks.

-Andy

>> +             },
>> +};
>> +
>> +module_platform_driver(ogma_driver);
>> +
>> +MODULE_AUTHOR("Fujitsu Semiconductor Ltd");
>> +MODULE_DESCRIPTION("OGMA Ethernet driver");
>> +MODULE_LICENSE("GPL");
>> +
>> +MODULE_ALIAS("platform:ogma");
>> --
>> 1.8.1.2
