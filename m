From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH/RFC net-next 0/4] Allow use of rocker ports without bridging
Date: Mon, 13 Apr 2015 08:43:16 -0700
Message-ID: <CAE4R7bANSqhUWeYarFmdOLsCbWtRFVW9jwvQufgNEb8OURJdPA@mail.gmail.com>
References: <1428907677-27204-1-git-send-email-simon.horman@netronome.com>
	<CAE4R7bA3hsRBOY9+YZXQ8b-7T_DwgzcrAM=wzYj+cyyWVkbRHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"Arad, Ronen" <ronen.arad@intel.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:33135 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932824AbbDMPnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 11:43:17 -0400
Received: by qgdy78 with SMTP id y78so2015090qgd.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 08:43:16 -0700 (PDT)
In-Reply-To: <CAE4R7bA3hsRBOY9+YZXQ8b-7T_DwgzcrAM=wzYj+cyyWVkbRHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 13, 2015 at 7:59 AM, Scott Feldman <sfeldma@gmail.com> wrote:
> On Sun, Apr 12, 2015 at 11:47 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
>> Hi,
>>
>> this short series attempts to allow rocker ports to be used when they
>> are not attached to a bridge. It attempts to make use of flow entries
>> in a rocker switch where appropriate and otherwise forwards packets up
>> to the kernel for processing.
>
> Hi Simon,
>
> Unbridged ports should be working now with current driver/device.  I
> wonder if you have an older qemu rocker device?  Use master branch of
> https://github.com/scottfeldman/qemu-rocker.git.
>
> My test setup is to IPv4 ping two hosts from two different ports.
> Something like:
>
> sw1:sw1p1:11.0.0.1/24 <----------------> h1:eth1:11.0.0.2/24
> sw1:sw1p2:12.0.0.1/24 <----------------> h2:eth1:12.0.0.2/24
>
> ARP and ping work fine.  What is your test setup?  I haven't spent a
> lot of time on unbridged port testing, since major focus has been on
> offloading bridge L2 and L3.

Ah, I think I know why it's not working for you.  You don't have the
VLAN 8021.q module loaded, do you?  I'm getting these:

[    2.871619] 8021q: 802.1Q VLAN Support v1.8
[    2.871629] 8021q: adding VLAN 0 to HW filter on device sw1p1
[    2.872097] 8021q: adding VLAN 0 to HW filter on device sw1p2

Which calls into the driver ndo_vlan ops and sets up untagged access.

But, dependence on VLAN 802.1q module is wrong I think, and we'll need
your patch (I haven't reviewed it yet, but I'm assuming it's doing
basically what loading what VLAN 802.1q driver forces).

The Spring Cleanup patchset has better setlink/dellink support so
driver can manage VLANs from bridge driver and moves away from
ndo_vlan ops used with 802.1q VLAN driver.  Ronan (Cc:d) has a VLAN
patch that builds on top of my Spring Cleanup patchset  I think the
order of changes will be to get my Spring Cleanup patchset in and then
get yours/Ronan's patches in.  And rocker can get away from using
ndo_vlan ops.

Would you verify that without your patch, and with VLAN 802.1q driver
loaded, unbridged ports are working?

-scott
