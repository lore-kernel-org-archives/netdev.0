From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 11/18] switchdev: remove old netdev_switch_port_bridge_setlink
Date: Mon, 30 Mar 2015 13:20:23 -0700
Message-ID: <CAE4R7bBWby3tDdzV+Hwvc_bzB3E-zNoHUQUX8OfF205Vyw-77g@mail.gmail.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
	<1427704836-8776-12-git-send-email-sfeldma@gmail.com>
	<55194E63.5010100@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:33427 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753997AbbC3UUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 16:20:24 -0400
Received: by qcbjx9 with SMTP id jx9so82232784qcb.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 13:20:23 -0700 (PDT)
In-Reply-To: <55194E63.5010100@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2015 at 6:23 AM, roopa <roopa@cumulusnetworks.com> wrote:
> On 3/30/15, 1:40 AM, sfeldma@gmail.com wrote:
>>
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> New attr-based bridge_setlink can recurse lower devs and recover on err,
>> so
>> remove old wrapper.  Also, restore br_setlink back to original and don't
>> call
>> into SELF port driver.  rtnetlink.c:bridge_setlink already does a call
>> into
>> port driver for SELF.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>
> removing this now requires every vlan add to be a two step process, why ?

No, that's not true.  You want to use
ndo_vlan_rx_add_vid/ndo_vlan_rx_kill_vid in your port driver, and then
using either vlan driver standalone or the bridge driver vlan support
will work.

Try it.  Implement ndo_vlan_rx_add_vid in your port driver and verify
you get called to add VLAN to port with either:

    bridge vlan add dev swp1 vid 10

    -or-

    vconfig add swp1 10

Same for deleting a VLAN, either of these two commands call into the
port driver ndo_vlan_rx_kill_vid:

    bridge vlan del dev swp1 vid 10

    -or-

    vconfig rem swp1 10


> bridge vlan add dev swp1 vid 10
> bridge vlan add dev swp1 vid 10 self

Not necessary.  The first command is sufficient if using
ndo_vlan_rx_add_vid.  If you want the self version to work, add
ndo_bridge_setlink/dellink ops to your port driver.

> and userspace will get two notifications.

Single command (as shown in my examples) generates one user notification.
