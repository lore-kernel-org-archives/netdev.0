From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 7/7] switchdev: update documentation on FDB ageing_time
Date: Sat, 19 Sep 2015 18:21:48 -0700
Message-ID: <55FE0A2C.9040205@cumulusnetworks.com>
References: <1442606151-50429-1-git-send-email-sfeldma@gmail.com> <1442606151-50429-8-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com,
	Wilson Kok <wkok@cumulusnetworks.com>
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36048 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753424AbbITBVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 21:21:51 -0400
Received: by padhk3 with SMTP id hk3so83264337pad.3
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 18:21:50 -0700 (PDT)
In-Reply-To: <1442606151-50429-8-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/18/15, 12:55 PM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> ---
>   Documentation/networking/switchdev.txt |   24 ++++++++++++------------
>   1 file changed, 12 insertions(+), 12 deletions(-)
>
> diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
> index 476df04..67e43ee 100644
> --- a/Documentation/networking/switchdev.txt
> +++ b/Documentation/networking/switchdev.txt
> @@ -239,20 +239,20 @@ The driver should initialize the attributes to the hardware defaults.
>   FDB Ageing
>   ^^^^^^^^^^
>   
> -There are two FDB ageing models supported: 1) ageing by the device, and 2)
> -ageing by the kernel.  Ageing by the device is preferred if many FDB entries
> -are supported.  The driver calls call_switchdev_notifiers(SWITCHDEV_FDB_DEL,
> -...) to age out the FDB entry.  In this model, ageing by the kernel should be
> -turned off.  XXX: how to turn off ageing in kernel on a per-port basis or
> -otherwise prevent the kernel from ageing out the FDB entry?
> -
> -In the kernel ageing model, the standard bridge ageing mechanism is used to age
> -out stale FDB entries.  To keep an FDB entry "alive", the driver should refresh
> -the FDB entry by calling call_switchdev_notifiers(SWITCHDEV_FDB_ADD, ...).  The
> +The bridge will skip ageing FDB entries marked with NTF_EXT_LEARNED and it is
> +the responsibility of the port driver/device to age out these entries.  If the
> +port device supports ageing, when the FDB entry expires, it will notify the
> +driver which in turn will notify the bridge with SWITCHDEV_FDB_DEL.  If the
> +device does not support ageing, the driver can simulate ageing using a
> +garbage collection timer to monitor FBD entries.  Expired entries will be
> +notified to the bridge using SWITCHDEV_FDB_DEL.  See rocker driver for
> +example of driver running ageing timer.
We do rely on the bridge driver ageing out entries. We have gone from 
hardware ageing to ageing in the switch driver to ultimately ageing in 
the bridge driver.  :). And we keep the fdb entries in the bridge driver 
"alive" by using 'NTF_USE' from the user-space driver.

> +
> +To keep an NTF_EXT_LEARNED entry "alive", the driver should refresh the FDB
> +entry by calling call_switchdev_notifiers(SWITCHDEV_FDB_ADD, ...).  The
>
Even with your current patches, looks like the switch driver will need 
to refresh the entries anyways to keep the "last-used" time to now.
In which case is there much value in switch driver doing the ageing ?.

I am thinking keeping the default behavior of the bridge driver to age 
and anything else configurable might be a better option.

Thanks,
Roopa
