From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH net-next 5/5] rocker: remove support for legacy VLAN ndo
 ops
Date: Fri, 05 Jun 2015 00:04:45 +0900
Message-ID: <5570690D.3000807@gmail.com>
References: <1433183947-13095-1-git-send-email-sfeldma@gmail.com> <1433183947-13095-6-git-send-email-sfeldma@gmail.com> <556D363A.5010005@lab.ntt.co.jp> <20150601.222442.1854333703599698362.davem@davemloft.net> <CAE4R7bBL+=-akoNLPqPae=zrYe3DH59t=8UK_T7KhcHSNaKUtw@mail.gmail.com> <556D96ED.9010309@mojatatu.com> <CAE4R7bAXA27cqBLv6MP0kak-L=1bXUoZPw7vxUyYpP=-dk=eAg@mail.gmail.com> <556DE0CD.9080000@cumulusnetworks.com> <CAE4R7bCPKcCYcHZ3WhkvjpioPhJP12Q35zRsq=t5gAO7JOZ94Q@mail.gmail.com> <556F209A.6090304@gmail.com> <556F4A51.3030908@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Scott Feldman <sfeldma@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35343 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069AbbFDPEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 11:04:48 -0400
Received: by padjw17 with SMTP id jw17so31375789pad.2
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 08:04:48 -0700 (PDT)
In-Reply-To: <556F4A51.3030908@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/06/04 (=E6=9C=A8) 3:41, roopa wrote:
> On 6/3/15, 8:43 AM, Toshiaki Makita wrote:
>> On 15/06/03 (=E6=B0=B4) 4:01, Scott Feldman wrote:
>>> On Tue, Jun 2, 2015 at 9:58 AM, roopa <roopa@cumulusnetworks.com> w=
rote:
>>>> On 6/2/15, 7:30 AM, Scott Feldman wrote:
>>>>>
>>>>> On Tue, Jun 2, 2015 at 4:43 AM, Jamal Hadi Salim <jhs@mojatatu.co=
m>
>>>>> wrote:
>>>>>>
>>>>>> On 06/02/15 03:10, Scott Feldman wrote:
>>>>>>
>>>>>>
>>>>>>> Actually, we're now consistent with bridge man page which says
>>>>>>> master
>>>>>>> is the default.
>>>>>>>
>>>>>>> Want we want, I believe, is to adjust what the man page says (a=
nd
>>>>>>> the
>>>>>>> bridge vlan command itself), by making the default master and s=
elf.
>>>>>>> The kernel and driver are fine, it's the default in the bridge
>>>>>>> command
>>>>>>> that needs adjusting.  Once we do this, we'll be back to transp=
arent
>>>>>>> with software-only bridge.
>>>>>>>
>>>>>> Question to ask when looking at something of this nature:
>>>>>> Will it work with no suprises if you used today's unmodified app=
?
>>>>>> The default behavior shouldnt change and unfortunately it does h=
ere.
>>>>>
>>>>> The default behavior does change, yes, but there shouldn't be any
>>>>> surprises even if using today's unmodified app.  The reason why i=
s no
>>>>> in-kernel driver is using ndo_bridge_setlink for VLAN setup.  The
>>>>> three drivers that have ndo_bridge_setlink use if to set hwmode t=
o
>>>>> VEBA|VEB.  For VLAN setup, they use the (default master) bridge's
>>>>> ndo_bridge_setlink->ndo_vlan_rx_add_vid.  If the default changes =
from
>>>>> master to master|self, the bridge's
>>>>> ndo_bridge_setlink->ndo_vlan_rx_add_vid is still called for those
>>>>> driver's using ndo_vlan_rx_add_vid, and if they implement
>>>>> ndo_bridge_setlink, they'll get called a second time but will noo=
p
>>>>> because there will be no IFLA_BRIDGE_MODE (hwmode) attr to proces=
s.
>>>>>
>>>>> So it comes down to two choices:
>>>>>
>>>>> 1) break ABI, which is inconsequential for in-kernel drivers and
>>>>> preserve (iproute2) command transparency, or
>>>>>
>>>>> 2) embrace existing behavior which is consistent with man pages b=
ut
>>>>> breaks command transparency for any driver implementing
>>>>> ndo_bridge_setlink for VLAN setup, which currently is just rocker=
=2E  I
>>>>> can see the DSA going down this path also based on another concur=
rent
>>>>> thread.
>>>>>
>>>>> We're at option 2) right now.
>>>>>
>>>>>> It is not just iproute2 - since this is breaking ABI expectation=
s.
>>>>>> Looking at some app i wrote a while back based on analyzing kern=
el
>>>>>> expectations at the time, I see the following logic:
>>>>>>
>>>>>> user can set master or self on command line.
>>>>>> ...
>>>>>> ....
>>>>>> if (user DID NOT set master_on || user set self on)
>>>>>>      then set self to on
>>>>>>
>>>>>> iow, current behavior:
>>>>>>    01: master is only set if user explicitly asked.
>>>>>>    11: master|self when user explicitly sets both
>>>>>>    10: self is on by default when the user doesnt specify anythi=
ng
>>>>>>    00: and the last option is to have none set which is not
>>>>>>        possible since we have defaults.
>>>>>>
>>>>>> cheers,
>>>>>> jamal
>>>>>>
>>>>>>
>>>>>> So this is very similar to iproute2 - if nothing is set
>>>>>> it defaults to self.
>>>>>
>>>>> Ha, you're giving the behavior for "bridge fdb" command, where se=
lf is
>>>>> the default.
>>>>
>>>>
>>>> Oh...i did not realize this was the case either. Thats unfortunate=
=2E
>>>>
>>>>>
>>>>> For "bridge link" and "bridge vlan", the default is master. The u=
ser
>>>>> must explicitly specify "self" to act on the device side of the p=
ort.
>>>>>
>>>>> It's unfortunate the iproute2 defaults aren't consistent between
>>>>> commands.  Maybe someone knows the history here and can explain.
>>>>>
>>>>>
>>>>
>>>> scott, this brings back the discussion you and i had over the reve=
rt
>>>> of my
>>>> patches.. (commit id's at the end of this email)...
>>>> which used to seamlessly offload to switchdev from bridge driver i=
f
>>>> the port
>>>> was a switch port (similar to stp state offload).
>>>
>>> Your patch tried to do the same thing that the bridge's
>>> ndo_bridge_setlink/dellink is doing which is using the handler for
>>> MASTER to also set SELF stuff, when SELF was not specified.  I don'=
t
>>> feel we should be overriding the application defaults in the kernel=
;
>>> instead, we should change the application if we want different
>>> behavior.  The kernel should treat the two sides of the port
>>> independent (that's the basic algo in rtnetlink.c handlers for
>>> MASTER/SELF things).  When you start doing kernel SELF things in th=
e
>>> MASTER path, the application has lost the ability to address each s=
ide
>>> of the port independently.
>>>
>>>> 'self' used to exist before switchdev infra came in. My suggestion
>>>> was to
>>>> use it where required...but not build the switchdev api on the
>>>> presence of
>>>> 'self'. switchdev layer should be consistent across...all fib/fdb/=
neigh
>>>> layers.
>>>
>>> I don't understand why you're bringing up fib/neigh because there i=
s
>>> no master|self form for those.
>>>
>>> The master|self objects are bridge fdb, settings, and vlans.  To be
>>> clear, they are PF_BRIDGE handlers for:
>>>
>>> PF_BRIDGE:RTM_NEWNEIGH: add fdb entry
>>> PF_BRIDGE:RTM_DELNEIGH: del fdb entry
>>> PF_BRIDGE:RTM_SETLINK: set bridge setting or add VLAN
>>> PF_BRIDGE:RTM_DELLINK: del VLAN
>>>
>>> The net/core/rtnetlink.c code for these _is_ consistent right now.
>>> They all perform this same basic algorithm:
>>>
>>>      handler()
>>>          if (!flags || flags & MASTER)
>>>              if (master && master->op->foo)
>>>                  master->op->foo();
>>>          if (flags & SELF)
>>>              if (port->op->foo)
>>>                  port->op->foo();
>>>
>>> This lets the application set MASTER and/or SELF to address one or
>>> both sides of the port.  The kernel only provides the mechanism; th=
e
>>> application decides which sides to address.
>>>
>>> Where we got into trouble is in the case of
>>> PF_BRIDGE:RTM_SETLINK/RTM_DELLINK where the master->op->foo handler
>>> calls into the member port's ndo_vlan_rx_add_vid(), which is really=
 a
>>> SELF operation because it's setting the VLAN for the device-side of
>>> the port.  Setting the VLAN on the device side should have only bee=
n
>>> done if SELF was specified.
>>
>> Bridge's vlan_filtering is handled in master->op->foo(), not in
>> port->op->foo().
>> Can't we introduce another switchdev handler that performs MASTER
>> operation instead of calling SELF operation?
>>
>> br_afspec()
>>  nbp_vlan_add()
>>   netdev_switch_port_vlan_add()
>>    rocker->ndo_switch_port_vlan_add() <- only used for MASTER operat=
ion
>>
>> I'm wondering why SELF operation (rocker->ndo_bridge_setlink()) does
>> what should be done in MASTER operation.
> yes, this is what i have been alluding to (and I had commits which di=
d
> this but got reverted).

If SELF operation support is needed, then my suggetion is maybe the sam=
e=20
as yours.

I mean,

(a). bridge vlan add vid VID dev DEV
(b). bridge vlan add vid VID dev DEV self

(a) should work anyway, IMHO.
If only (b) works and (a) does not work, then it does not look=20
transparent (this is current behavior).
Maybe it's possible both (a) and (b) work in the same way for=20
switchdev... (I presume this is your proposal).

But actually I would be a bit suprised if (b) works in the same way as=20
(a), since the only usage of "bridge vlan self" used to be for bridge=20
device itself.. i.e.,

   bridge vlan add vid VID dev br0 self

Toshiaki Makita
