From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware
 forwarded packets
Date: Tue, 24 Mar 2015 11:08:33 -0700
Message-ID: <CAE4R7bDrvmZbUJ_KM6wuF3-MdWUSLL=6=Z6kJPNubNW0F_aV1Q@mail.gmail.com>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com>
	<20150320.163655.474336751434677390.davem@davemloft.net>
	<550C92F3.50302@cumulusnetworks.com>
	<20150320220946.GB31769@lunn.ch>
	<20150323002215.GA6074@roeck-us.net>
	<550F6D7D.7030403@gmail.com>
	<550F8102.7040701@roeck-us.net>
	<550F8600.2020300@gmail.com>
	<550F8987.5070600@roeck-us.net>
	<5510498D.5010001@cumulusnetworks.com>
	<CAE4R7bCcMtrKmiGaLqVMfERQxYZW3WD1vF2rts9+CE7ZZ0_BVQ@mail.gmail.com>
	<55116303.4090000@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: roopa <roopa@cumulusnetworks.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	David Miller <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:34918 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309AbbCXSIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 14:08:50 -0400
Received: by qgf74 with SMTP id 74so1448730qgf.2
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 11:08:50 -0700 (PDT)
In-Reply-To: <55116303.4090000@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2015 at 6:13 AM, Guenter Roeck <linux@roeck-us.net> wrote:
> On 03/23/2015 10:59 PM, Scott Feldman wrote:
>>
>> On Mon, Mar 23, 2015 at 10:12 AM, roopa <roopa@cumulusnetworks.com> wrote:
>>>
>>> On 3/22/15, 8:33 PM, Guenter Roeck wrote:
>>>>
>>>>
> [ ... ]
>
>>>
>>> yep, so my first RFC listed three ways to do this,
>>> 1) flag on the bridge port
>>> 2) check if the port being forwarded to is a switch port, using
>>>              - the offload flag
>>>              - the parent id (as john fastabend pointed out)
>>> 3) A per packet flag which switch driver sets indicating that the packet
>>> is
>>> hw forwarded.
>>>      This is because we have run into cases where we want to move to
>>> software
>>> forwarding
>>>      of certain packets like igmp reports.  (I will get some more details
>>> on
>>> the particular igmp problem).
>>>      In such case, hardware punts the igmp packet to cpu and cpu will do
>>> the
>>> forwarding.
>>>      I think we may hit more cases like this in the future.
>>>
>>> my RFC v1 was based on 1). RFC v2 was based on 3) above.
>>>
>>> But, for now, agree that we can just support the more common case using
>>> 2).
>>> And, we can move to 3) in the future if needed.
>>
>>
>> Roopa, I think it may be possible to do this without any changes to
>> the bridge code or switchdev code by dropping duplicate pkts in the
>> swdev driver itself.  The skb is marked with skb_iif set to ifindex of
>> ingress port, so when the driver goes to egress a pkt on the port, if
>> the skb_iif is one of the other device ports, we can assume the device
>> did the fwd already so we can drop the duplicate pkt.  Below is the
>> change to rocker.  The driver can get as fancy as it wants in its test
>> to drop or not.  This solution works for mixed offload and
>> non-offloaded ports in a bridge, or ports from different offload
>> devices in the same bridge.
>>
>> Yes, the bridge is spending overhead to clone pkts to flood to its
>> ports.  IGMP snooping mitigates this for mcast.  BR_FLOOD can be
>> turned off on the bridge ports to mitigate this for unknown unicast
>> floods.  So what's left is bcasts.
>>
> You would still want the soft bridge code to flood from non-switch ports
> to switch ports and vice versa, as well as across multiple switches.
> So I am not entirely sure I understand how turning off BR_FLOOD would help.

Ya, you're right, turning off BR_FLOOD wouldn't help for those cases.
