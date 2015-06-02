From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 5/5] rocker: remove support for legacy VLAN ndo
 ops
Date: Tue, 02 Jun 2015 09:58:53 -0700
Message-ID: <556DE0CD.9080000@cumulusnetworks.com>
References: <1433183947-13095-1-git-send-email-sfeldma@gmail.com> <1433183947-13095-6-git-send-email-sfeldma@gmail.com> <556D363A.5010005@lab.ntt.co.jp> <20150601.222442.1854333703599698362.davem@davemloft.net> <CAE4R7bBL+=-akoNLPqPae=zrYe3DH59t=8UK_T7KhcHSNaKUtw@mail.gmail.com> <556D96ED.9010309@mojatatu.com> <CAE4R7bAXA27cqBLv6MP0kak-L=1bXUoZPw7vxUyYpP=-dk=eAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:37373 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759522AbbFBQ64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 12:58:56 -0400
Received: by igbsb11 with SMTP id sb11so93008681igb.0
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 09:58:55 -0700 (PDT)
In-Reply-To: <CAE4R7bAXA27cqBLv6MP0kak-L=1bXUoZPw7vxUyYpP=-dk=eAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/2/15, 7:30 AM, Scott Feldman wrote:
> On Tue, Jun 2, 2015 at 4:43 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 06/02/15 03:10, Scott Feldman wrote:
>>
>>
>>> Actually, we're now consistent with bridge man page which says master
>>> is the default.
>>>
>>> Want we want, I believe, is to adjust what the man page says (and the
>>> bridge vlan command itself), by making the default master and self.
>>> The kernel and driver are fine, it's the default in the bridge command
>>> that needs adjusting.  Once we do this, we'll be back to transparent
>>> with software-only bridge.
>>>
>> Question to ask when looking at something of this nature:
>> Will it work with no suprises if you used today's unmodified app?
>> The default behavior shouldnt change and unfortunately it does here.
> The default behavior does change, yes, but there shouldn't be any
> surprises even if using today's unmodified app.  The reason why is no
> in-kernel driver is using ndo_bridge_setlink for VLAN setup.  The
> three drivers that have ndo_bridge_setlink use if to set hwmode to
> VEBA|VEB.  For VLAN setup, they use the (default master) bridge's
> ndo_bridge_setlink->ndo_vlan_rx_add_vid.  If the default changes from
> master to master|self, the bridge's
> ndo_bridge_setlink->ndo_vlan_rx_add_vid is still called for those
> driver's using ndo_vlan_rx_add_vid, and if they implement
> ndo_bridge_setlink, they'll get called a second time but will noop
> because there will be no IFLA_BRIDGE_MODE (hwmode) attr to process.
>
> So it comes down to two choices:
>
> 1) break ABI, which is inconsequential for in-kernel drivers and
> preserve (iproute2) command transparency, or
>
> 2) embrace existing behavior which is consistent with man pages but
> breaks command transparency for any driver implementing
> ndo_bridge_setlink for VLAN setup, which currently is just rocker.  I
> can see the DSA going down this path also based on another concurrent
> thread.
>
> We're at option 2) right now.
>
>> It is not just iproute2 - since this is breaking ABI expectations.
>> Looking at some app i wrote a while back based on analyzing kernel
>> expectations at the time, I see the following logic:
>>
>> user can set master or self on command line.
>> ...
>> ....
>> if (user DID NOT set master_on || user set self on)
>>     then set self to on
>>
>> iow, current behavior:
>>   01: master is only set if user explicitly asked.
>>   11: master|self when user explicitly sets both
>>   10: self is on by default when the user doesnt specify anything
>>   00: and the last option is to have none set which is not
>>       possible since we have defaults.
>>
>> cheers,
>> jamal
>>
>>
>> So this is very similar to iproute2 - if nothing is set
>> it defaults to self.
> Ha, you're giving the behavior for "bridge fdb" command, where self is
> the default.

Oh...i did not realize this was the case either. Thats unfortunate.

>
> For "bridge link" and "bridge vlan", the default is master.  The user
> must explicitly specify "self" to act on the device side of the port.
>
> It's unfortunate the iproute2 defaults aren't consistent between
> commands.  Maybe someone knows the history here and can explain.
>
>

scott, this brings back the discussion you and i had over the revert of 
my patches.. (commit id's at the end of this email)...
which used to seamlessly offload to switchdev from bridge driver if the 
port was a switch port (similar to stp state offload).

'self' used to exist before switchdev infra came in. My suggestion was 
to use it where required...but not build the switchdev api on the 
presence of 'self'. switchdev layer should be consistent across...all 
fib/fdb/neigh layers.

I was at some point going to try to propose restore of my patches (with 
proper error handling etc), and looking at where this conversation is 
going.....it appears that it is going to be difficult.



commit 8508025c598bdee33d9afa153e9c00c7771e7d63
Author: Scott Feldman <sfeldma@gmail.com>
Date:   Sun May 10 09:48:03 2015 -0700

     bridge: revert br_dellink change back to original

     This is revert of:

     commit 68e331c785b8 ("bridge: offload bridge port attributes to 
switch asic
     if feature flag set")

     Restore br_dellink back to original and don't call into SELF port 
driver.
     rtnetlink.c:bridge_dellink() already does a call into port driver 
for SELF.

     bridge vlan add/del cmd defaults to MASTER.  From man page for 
bridge vlan
     add/del cmd:

            self   the vlan is configured on the specified physical device.
                   Required if the device is the bridge device.

            master the vlan is configured on the software bridge (default).

     Signed-off-by: Scott Feldman <sfeldma@gmail.com>
     Acked-by: Jiri Pirko <jiri@resnulli.us>
     Signed-off-by: David S. Miller <davem@davemloft.net>

commit 41c498b9359e360f08723b7605ec0c40926ec415
Author: Scott Feldman <sfeldma@gmail.com>
Date:   Sun May 10 09:47:59 2015 -0700

     bridge: restore br_setlink back to original

     This is revert of:

     commit 68e331c785b8 ("bridge: offload bridge port attributes to 
switch asic
     if feature flag set")

     Restore br_setlink back to original and don't call into SELF port 
driver.
     rtnetlink.c:bridge_setlink() already does a call into port driver 
for SELF.

     bridge set link cmd defaults to MASTER.  From man page for bridge 
link set
     cmd:

            self   link setting is configured on specified physical device

            master link setting is configured on the software bridge 
(default)

     The link setting has two values: the device-side value and the software
     bridge-side value.  These are independent and settable using the bridge
     link set cmd by specifying some combination of [master] | [self].
     Furthermore, the device-side and bridge-side settings have their own
     initial value, viewable from bridge -d link show cmd.

     Restoring br_setlink back to original makes rocker (the only 
in-kernel user
     of SELF link settings) work as first implement: two-sided values.

     It's true that when both MASTER and SELF are specified from the 
command,
     two netlink notifications are generated, one for each side of the 
settings.
     The user-space app can distiquish between the two notifications by
     observing the MASTER or SELF flag.

     Signed-off-by: Scott Feldman <sfeldma@gmail.com>
