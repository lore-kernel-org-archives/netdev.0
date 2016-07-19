From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH 2/3] staging/rtl8192e: use s8 instead of char
Date: Tue, 19 Jul 2016 11:46:04 -0400
Message-ID: <wrfjy44xvdfn.fsf@redhat.com>
References: <20160719153403.2967812-1-arnd@arndb.de>
	<20160719153403.2967812-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Mateusz Kulikowski <mateusz.kulikowski@gmail.com>,
	devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39092 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753219AbcGSPqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2016 11:46:06 -0400
In-Reply-To: <20160719153403.2967812-2-arnd@arndb.de> (Arnd Bergmann's message
	of "Tue, 19 Jul 2016 17:33:01 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> writes:
> Compiling the rtlwifi drivers for ARM with gcc -Wextra warns about lots of
> incorrect code that results from 'char' being unsigned here, e.g.
>
> staging/rtl8192e/rtl8192e/r8192E_phy.c:1072:36: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> staging/rtl8192e/rtl8192e/r8192E_phy.c:1104:36: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> staging/rtl8192e/rtl8192e/rtl_core.c:1987:16: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> staging/rtl8192e/rtl8192e/rtl_dm.c:782:37: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> staging/rtl8192e/rtl819x_TSProc.c:326:14: error: comparison is always true due to limited range of data type [-Werror=type-limits]
> staging/rtl8192e/rtllib_softmac_wx.c:465:16: error: comparison is always false due to limited range of data type [-Werror=type-limits]
>
> This patch changes all uses of 'char' in this driver that refer to
> 8-bit integers to use 's8' instead, which is signed on all architectures.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/staging/rtl8192e/rtl8192e/r8192E_dev.c | 8 ++++----
>  drivers/staging/rtl8192e/rtl8192e/r8192E_phy.c | 2 +-
>  drivers/staging/rtl8192e/rtl8192e/rtl_core.c   | 6 +++---
>  drivers/staging/rtl8192e/rtl8192e/rtl_core.h   | 8 ++++----
>  drivers/staging/rtl8192e/rtl819x_TSProc.c      | 2 +-
>  5 files changed, 13 insertions(+), 13 deletions(-)
>

Most of this looks fine to me. One issue stands out which I don't think
is right:

> diff --git a/drivers/staging/rtl8192e/rtl819x_TSProc.c b/drivers/staging/rtl8192e/rtl819x_TSProc.c
> index 2c8a526773ed..e0a2fe5e6148 100644
> --- a/drivers/staging/rtl8192e/rtl819x_TSProc.c
> +++ b/drivers/staging/rtl8192e/rtl819x_TSProc.c
> @@ -323,7 +323,7 @@ bool GetTs(struct rtllib_device *ieee, struct ts_common_info **ppTS,
>  	if (ieee->current_network.qos_data.supported == 0) {
>  		UP = 0;
>  	} else {
> -		if (!IsACValid(TID)) {
> +		if (!IsACValid((s8)TID)) {
>  			netdev_warn(ieee->dev, "%s(): TID(%d) is not valid\n",
>  				    __func__, TID);
>  			return false;

TID is a 4-bit field, it should never go negative. The cast to s8 seems
wrong to me, if anything it should be using u8. I do realize the macro
IsACValid checks against negative too, but that just looks silly to me.

Cheers,
Jes
