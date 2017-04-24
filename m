From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: cpsw regression in mainline with "cpsw/netcp: cpts depends on posix_timers"
Date: Mon, 24 Apr 2017 20:12:08 +0200
Message-ID: <CAK8P3a2ybR29txotehP5uKtstucxW_ZYZXArMroSEbmV=Y--7A@mail.gmail.com>
References: <20170424165104.GC3780@atomide.com> <CAK8P3a3kvMubq5Mtu3XKnityAgRv5R35dMtTX=BO8Qv_iX9=VQ@mail.gmail.com>
 <20170424174413.GD3780@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        Networking <netdev@vger.kernel.org>, linux-omap@vger.kernel.org
To: Tony Lindgren <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33894 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S972521AbdDXSMJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 14:12:09 -0400
In-Reply-To: <20170424174413.GD3780@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 7:44 PM, Tony Lindgren <tony@atomide.com> wrote:
> * Arnd Bergmann <arnd@arndb.de> [170424 10:38]:
>> On Mon, Apr 24, 2017 at 6:51 PM, Tony Lindgren <tony@atomide.com> wrote:
>> > Hi,
>> >
>> > Looks like commit 07fef3623407 ("cpsw/netcp: cpts depends on posix_timers")
>> > in mainline started triggering the following oops at least on j5eco-evm.
>> >
>> > Adding CONFIG_PTP_1588_CLOCK to .config solves it, but the oops hints
>> > something is wrong with the dependencies.. CONFIG_TI_CPTS defaults to N
>> > and not selecting it causes the oops.
>> >
>> > Any ideas what's needed to properly fix this?
>>
>> Does your configuration have POSIX_TIMERS enabled? If not, then CPTS
>> is now also disabled. There are two issues here that we need to solve:
>>
>> a) find out why POSIX_TIMERS got disabled, and make sure it's always
>>     turned on for normal users
>
> $ make omap2plus_defconfig
> ...
> CONFIG_POSIX_TIMERS=y
> # CONFIG_PTP_1588_CLOCK is not set
>
> So CONFIG_TI_CPTS is unselectable.

Ok, so at least this one is easy to understand, it's a direct consequence
of my change, as nothing else will select CONFIG_PTP_1588_CLOCK
now.

My first try would be this one:

diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index 9e631952b86f..8042a7626056 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -76,7 +76,7 @@ config TI_CPSW
 config TI_CPTS
  bool "TI Common Platform Time Sync (CPTS) Support"
  depends on TI_CPSW || TI_KEYSTONE_NETCP
- depends on PTP_1588_CLOCK
+ depends on POSIX_TIMERS
  ---help---
   This driver supports the Common Platform Time Sync unit of
   the CPSW Ethernet Switch and Keystone 2 1g/10g Switch Subsystem.
@@ -87,6 +87,7 @@ config TI_CPTS_MOD
  tristate
  depends on TI_CPTS
  default y if TI_CPSW=y || TI_KEYSTONE_NETCP=y
+ imply PTP_1588_CLOCK
  default m

 config TI_KEYSTONE_NETCP

>> b) find out what's wrong with the driver when CPTS is disabled. This would
>>     be an existing problem that you just never saw because CPTS was
>>     always enabled so far.
>
> See a) above, yes seems there are two problems here.

Ok.

       Arnd
