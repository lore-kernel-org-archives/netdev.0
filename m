From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next 0/3] r8152: configuration setting
Date: Thu, 08 Sep 2016 09:54:51 +0200
Message-ID: <87vay6hlmc.fsf@miraculix.mork.no>
References: <1394712342-15778-215-Taiwan-albertk@realtek.com>
        <87h99rizsi.fsf@miraculix.mork.no>
        <0835B3720019904CB8F7AA43166CEEB2010259B5@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
        Oliver Neukum <oliver@neukum.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60236 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752942AbcIHHzS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 03:55:18 -0400
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2010259B5@RTITMBSV03.realtek.com.tw>
        (Hayes Wang's message of "Thu, 8 Sep 2016 02:44:21 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hayes Wang <hayeswang@realtek.com> writes:

> Bj=C3=B8rn Mork [mailto:bjorn@mork.no]
>> Sent: Wednesday, September 07, 2016 9:51 PM
> [...]
>> So this adds a lot of code to work around the issues you introduced by
>> unnecessarily blacklisting the CDC ECM configuration earlier, and still
>> makes the r8152 driver handle the device even in ECM mode.
>
> I suggest to use vendor mode only, but some people ask me to
> submit such patches. If these patches are rejected, I have
> enough reasons to tell them it is unacceptable rather than
> I don't do it.
>
>> Just remove the completely unnecessary blacklist, and let the cdc_ether
>> driver handle the device if the user selects the ECM configuration.
>> That't how the USB system works.  There is no need for any code in r8152
>> to do that.
>
> The pure cdc_ether driver couldn't change the speed of the
> ethernet, because it doesn't know how to access the PHY of
> the device. Therefore, I add relative code in r8152 driver.

Yes, I see that.  But is that strictly necessary? Couldn't you just say:
"CDC ECM is supported by cdc_ether and therefore limited to the features
implemented by cdc_ether.  If you want feature X, then please use our
vendor specific mode with the r8152 driver?"

As for the dynamic switching of multi-configuration USB devices:  This
is not special for your device.  It is very common for e.g. LTE modems
to provide 2 or more configurations, allowing the user to select between
for example

 1: ECM class + ACM class functions
 2: MBIM class function
 3: vendor specific functions

Each USB configuation comes with a set of descriptors identifying the
functions, and USB interface drivers attach to the functions they
support.  The user can dynamically switch the device from e.g. cfg #1 to
cfg #3 by writing "3" to /sys/bus/usb/devices/<port>/bConfigurationValue
This will cause the ECM and ACM USB interfaces to disappear, and the
associated class drivers will unbind, and new vendor specific USB
interfaces appear instead, causing a matching vendor specific driver to
load and bind.

Naturally, end users will not switch configurations all the time.  They
will select the configuration providing the set of functions they want.
If this is different from the default configuration  selected by the
Linux USB core, then that's a simple udev rule to update the
bConfigurationValue sysfs attribute on device disceovery.

This is how the USB core works by *default*, as long as you do not
deliberately break it by blacklisting any functions or forcing a
specific configuration.

You are overdesigning to solve a non-existing problem.



Bj=C3=B8rn
