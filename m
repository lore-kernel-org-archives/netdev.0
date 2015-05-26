From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH/RFC net-next] rocker: by default accept untagged packets
Date: Tue, 26 May 2015 02:04:00 -0700
Message-ID: <CAE4R7bBYK0zJbb_q0BUowh_jrrCMapVq8xouD5bv56hPXYGsWQ@mail.gmail.com>
References: <1432601703-26774-1-git-send-email-simon.horman@netronome.com>
	<CAE4R7bAEQDE0QCnfVet29BZ574vVFqBoXv_EbyhYXYvBqo_xEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [209.85.220.181] ([209.85.220.181]:35806 "EHLO
	mail-qk0-f181.google.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752641AbbEZMrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 08:47:52 -0400
Received: by qkdn188 with SMTP id n188so87381868qkd.2
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 05:46:51 -0700 (PDT)
In-Reply-To: <CAE4R7bAEQDE0QCnfVet29BZ574vVFqBoXv_EbyhYXYvBqo_xEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 26, 2015 at 12:28 AM, Scott Feldman <sfeldma@gmail.com> wrote:
> On Mon, May 25, 2015 at 5:55 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
>> This will occur anyway if the 8021q module is loaded as it will
>> call rocker_port_vlan_rx_add_vid for vlan 0. This code is here
>> to handle the case where the 8021q module is not loaded.
>>
>> This patch also handles the case where the 8021q is unloaded
>> removing all VLANs from all ports.
>>
>> This change should not affect bridging, although the rules are
>> harmlessly installed anyway. This is in keeping with the behaviour
>> for VLANs when the 8021q modules is loaded.
>>
>> To aid implementation of the above provide a helper
>> and use it to replace some existing code.
>>
>> Signed-off-by: Simon Horman <simon.horman@netronome.com>

[cut]

>
> Hi Simon,
>
> Thanks for looking into this one.  I looked at your patch and the code
> and I think we can streamline it a little bit more.  For the
> no-8021q-module case we use rocker_port_vlan_add() and
> rocker_port_vlan_del() to add/del bridge vlans.  We should be able to
> move those functions up in the file so they can be called from
> rocker_port_vlan_rx_add_vid() and rocker_port_vlan_rx_kill_vid(),
> passing trans=SWITCHDEV_TRANS_NONE, but only if vid != 0.  Next, like
> in your patch, we need to call rocker_port_vlan_add() in
> rocker_port_open(), passing in vid=0 for untagged.  And in
> rocker_port_stop(), call rocker_port_vlan_del(), again passing in
> vid=0.
>
> To summarize:
>
> Call rocker_port_vlan_add() from:
>
> 1) rocker_port_open with vid=0
> 2) rocker_port_vlans_add()                             // bridge vlan
> 3) rocker_port_vlan_rx_add_vid() if vid != 0       // 8021q vlan
>
> Call rocker_port_vlan_del() from:
>
> 1) rocker_port_stop with vid=0
> 2) rocker_port_vlans_del()                              // bridge vlan
> 3) rocker_port_vlan_rx_kill_vid() if vid != 0        // 8021q vlan
>
> Does this look right?


Hmmmm...things get simpler if we removed support for 8021q module in
rocker driver by removing NETIF_F_HW_VLAN_CTAG_FILTER.  That gets rid
of rocker_port_vlan_rx_add_vid() and rocker_port_vlan_rx_kill_vid().
Leaving us with the bridge VLAN interface to add/del/show vlans on the
port.  I'm wondering if we can also avoid setting up untagged traffic
on the port during port open by requiring a explicit command on the
port from the user:

bridge vlan add vid 0 dev DEV master self        // enable untagged
traffic on port

Do you have a requirement for 8021q module?  I'm leaning towards a
clean break from 8021q and using just the built-in bridge VLAN
support.  I'm curious if others have an opinion about 8021q module
used with switchdev devices.

-scott
