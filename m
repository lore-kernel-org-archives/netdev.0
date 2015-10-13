From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] switchdev: enforce no pvid flag in vlan ranges
Date: Mon, 12 Oct 2015 23:13:03 -0700
Message-ID: <CAE4R7bCKot=MqvjqsSifS3G5HMnFyz2axhBW4uZ5UVtgL7=-Pg@mail.gmail.com>
References: <CAE4R7bDCb6DMCYg1j5hHNV-wtgGMEQfeSnOkCiXrJH4LKxuHOA@mail.gmail.com>
 <1444651299-2813-1-git-send-email-razor@blackwall.org> <20151012173625.GA17983@ketchup.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nikolay Aleksandrov <razor@blackwall.org>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:33948 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbbJMGNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 02:13:23 -0400
Received: by obbda8 with SMTP id da8so5966005obb.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 23:13:22 -0700 (PDT)
In-Reply-To: <20151012173625.GA17983@ketchup.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 12, 2015 at 10:36 AM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> Hi guys,
>
> On Oct. Monday 12 (42) 02:01 PM, Nikolay Aleksandrov wrote:
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>
>> We shouldn't allow BRIDGE_VLAN_INFO_PVID flag in VLAN ranges.
>>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> ---
>>  net/switchdev/switchdev.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>> index 6e4a4f9ad927..256c596de896 100644
>> --- a/net/switchdev/switchdev.c
>> +++ b/net/switchdev/switchdev.c
>> @@ -720,6 +720,9 @@ static int switchdev_port_br_afspec(struct net_device *dev,
>>                       if (vlan.vid_begin)
>>                               return -EINVAL;
>>                       vlan.vid_begin = vinfo->vid;
>> +                     /* don't allow range of pvids */
>> +                     if (vlan.flags & BRIDGE_VLAN_INFO_PVID)
>> +                             return -EINVAL;
>>               } else if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END) {
>>                       if (!vlan.vid_begin)
>>                               return -EINVAL;
>> --
>> 2.4.3
>>
>
> Yes the patch looks good, but it is a minor check though. I hope the
> subject of this thread is making sense.
>
> VLAN ranges seem to have been included for an UX purpose (so commands
> look like Cisco IOS). We don't want to change any existing interface, so
> we pushed that down to drivers, with the only valid reason that, maybe
> one day, an hardware can be capable of programming a range on a per-port
> basis.
>
> So what happens is that we'll add some code to fix and check non-sense
> (e.g. range + PVID) in switchdev, bridge, and I'm sure we are missing
> other spots.
>
> Sorry for being insistent, but this still doesn't look right to me.
>
> It seems like we are bloating bridge, switchdev and drivers for the only
> reason to maintain a kernel support for something like:
>
>     # for i in $(seq 100 4000); do bridge vlan add vid $i dev swp0; done

[Adding Roopa]

(Roopa, correct me if I'm wrong).

Ref: commit # bdced7ef

IIRC, vlan ranges were introduced to reduce the volume of netlink
traffic when doing a command like your's above.  Your command would
create 3901 netlink msgs with a single IFLA_BRIDGE_VLAN_INFO, sent to
the kernel and then echoed back to user-space.  With vlan ranges, the
cmd "bridge vlan add vid 100-4000 dev swp0" would result in one
netlink msg with one IFLA_BRIDGE_VLAN_INFO.  Seems there were problems
with a getlink dump over-running the netlink msg (not using
NLM_MULTI)?   Maybe Roopa can expand on the problem that was solved.

So the bridge command, and everything below it, has this feature.  We
can't undo it...it's in the wild, so to speak  And, as mentioned
before, it's and all-or-nothing command, and the underlying switchdev
or driver code needs to deal with overlapping vlan maps.
