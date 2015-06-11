From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] bridge: use either ndo VLAN ops or switchdev
 VLAN ops to install MASTER vlans
Date: Thu, 11 Jun 2015 12:58:13 -0700
Message-ID: <CAE4R7bDUKhiFjVJsNRGq0TVxx9Y5mFKVo6br93dbq-ahbtrcCw@mail.gmail.com>
References: <1434050122-26405-1-git-send-email-sfeldma@gmail.com> <5579E3E7.30005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:36679 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbbFKT6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 15:58:39 -0400
Received: by qkx62 with SMTP id 62so7765675qkx.3
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 12:58:35 -0700 (PDT)
In-Reply-To: <5579E3E7.30005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2015 at 12:39 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 11/06/15 12:15, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> To maintain backward compatibility with the existing iproute2 "bridge vlan"
>> command, let bridge's setlink/dellink handler call into either the port
>> driver's 8021q ndo ops or the port driver's bridge_setlink/dellink ops.
>>
>> This allows port driver to choose 8021q ops or the newer
>> bridge_setlink/dellink ops when implementing VLAN add/del filtering on the
>> device.  The iproute "bridge vlan" command does not need to be modified.
>>
>> To summarize using the "bridge vlan" command examples, we have:
>>
>> 1) bridge vlan add|del vid VID dev DEV
>>
>> Here iproute2 sets MASTER flag.  Bridge's bridge_setlink/dellink is called.
>> Vlan is set on bridge for port.  If port driver implements ndo 8021q ops,
>> call those to port driver can install vlan filter on device.  Otherwise, if
>> port driver implements bridge_setlink/dellink ops, call those to install
>> vlan filter to device.  This option only works if port is bridged.
>>
>> 2) bridge vlan add|del vid VID dev DEV master
>>
>> Same as 1)
>>
>> 3) bridge vlan add|del vid VID dev DEV self
>>
>> Bridge's bridge_setlink/dellink isn't called.  Port driver's
>> bridge_setlink/dellink is called, if implemented.  This option works if
>> port is bridged or not.  If port is not bridged, a VLAN can still be
>> added/deleted to device filter using this variant.
>>
>> 4) bridge vlan add|del vid VID dev DEV master self
>>
>> This is a combination of 1) and 3), but will only work if port is bridged.
>
> Woah, I now realize how confused I was with how it is meant to be used,
> still am actually.

I listed it for completeness, but I'm not sure if users really need
this mode, given that this patch makes 1) do the same thing.

>
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> ---
>
> [snip]
>
>> +static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
>> +                       u16 vid, u16 flags)
>> +{
>> +     const struct net_device_ops *ops = dev->netdev_ops;
>> +     struct switchdev_obj vlan_obj = {
>> +             .id = SWITCHDEV_OBJ_PORT_VLAN,
>> +             .u.vlan = {
>> +                     .flags = flags,
>> +                     .vid_start = vid,
>> +                     .vid_end = vid,
>> +             },
>> +     };
>> +     int err;
>> +
>> +     /* If driver uses VLAN ndo ops, use 8021q to install vid
>> +      * on device, otherwise try switchdev ops to install vid.
>> +      */
>> +
>> +     if (ops->ndo_vlan_rx_add_vid) {
>> +             err = vlan_vid_add(dev, br->vlan_proto, vid);
>> +     } else {
>
> Do we need to be more restrictive here and make sure that we did not set
> BRIDGE_VLAN_INFO_UNTAGGED or BRIDGE_VLAN_INFO_PVID for this vid since
> the legacy 802.1q ndos do not make any distinction and just assume tagged?

I don't think so because we don't want to break existing users of
legacy 8021q ndos, such as the majority of NICs out there that support
VLAN filtering.  But, this extra info (PVID, untagged) is available
with the newer bridge_setlink/dellink ops so drivers can be migrated
as needed.  For switchdev, where we really want the extra info, I
think it makes sense to use newer ops exclusively.
