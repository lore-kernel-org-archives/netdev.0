From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH net-next 5/5] rocker: remove support for legacy VLAN ndo
 ops
Date: Thu, 04 Jun 2015 00:43:22 +0900
Message-ID: <556F209A.6090304@gmail.com>
References: <1433183947-13095-1-git-send-email-sfeldma@gmail.com> <1433183947-13095-6-git-send-email-sfeldma@gmail.com> <556D363A.5010005@lab.ntt.co.jp> <20150601.222442.1854333703599698362.davem@davemloft.net> <CAE4R7bBL+=-akoNLPqPae=zrYe3DH59t=8UK_T7KhcHSNaKUtw@mail.gmail.com> <556D96ED.9010309@mojatatu.com> <CAE4R7bAXA27cqBLv6MP0kak-L=1bXUoZPw7vxUyYpP=-dk=eAg@mail.gmail.com> <556DE0CD.9080000@cumulusnetworks.com> <CAE4R7bCPKcCYcHZ3WhkvjpioPhJP12Q35zRsq=t5gAO7JOZ94Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>
To: Scott Feldman <sfeldma@gmail.com>,
	roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:32899 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569AbbFCPnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 11:43:31 -0400
Received: by pdbqa5 with SMTP id qa5so10197818pdb.0
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 08:43:30 -0700 (PDT)
In-Reply-To: <CAE4R7bCPKcCYcHZ3WhkvjpioPhJP12Q35zRsq=t5gAO7JOZ94Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/06/03 (=E6=B0=B4) 4:01, Scott Feldman wrote:
> On Tue, Jun 2, 2015 at 9:58 AM, roopa <roopa@cumulusnetworks.com> wro=
te:
>> On 6/2/15, 7:30 AM, Scott Feldman wrote:
>>>
>>> On Tue, Jun 2, 2015 at 4:43 AM, Jamal Hadi Salim <jhs@mojatatu.com>=
 wrote:
>>>>
>>>> On 06/02/15 03:10, Scott Feldman wrote:
>>>>
>>>>
>>>>> Actually, we're now consistent with bridge man page which says ma=
ster
>>>>> is the default.
>>>>>
>>>>> Want we want, I believe, is to adjust what the man page says (and=
 the
>>>>> bridge vlan command itself), by making the default master and sel=
f.
>>>>> The kernel and driver are fine, it's the default in the bridge co=
mmand
>>>>> that needs adjusting.  Once we do this, we'll be back to transpar=
ent
>>>>> with software-only bridge.
>>>>>
>>>> Question to ask when looking at something of this nature:
>>>> Will it work with no suprises if you used today's unmodified app?
>>>> The default behavior shouldnt change and unfortunately it does her=
e.
>>>
>>> The default behavior does change, yes, but there shouldn't be any
>>> surprises even if using today's unmodified app.  The reason why is =
no
>>> in-kernel driver is using ndo_bridge_setlink for VLAN setup.  The
>>> three drivers that have ndo_bridge_setlink use if to set hwmode to
>>> VEBA|VEB.  For VLAN setup, they use the (default master) bridge's
>>> ndo_bridge_setlink->ndo_vlan_rx_add_vid.  If the default changes fr=
om
>>> master to master|self, the bridge's
>>> ndo_bridge_setlink->ndo_vlan_rx_add_vid is still called for those
>>> driver's using ndo_vlan_rx_add_vid, and if they implement
>>> ndo_bridge_setlink, they'll get called a second time but will noop
>>> because there will be no IFLA_BRIDGE_MODE (hwmode) attr to process.
>>>
>>> So it comes down to two choices:
>>>
>>> 1) break ABI, which is inconsequential for in-kernel drivers and
>>> preserve (iproute2) command transparency, or
>>>
>>> 2) embrace existing behavior which is consistent with man pages but
>>> breaks command transparency for any driver implementing
>>> ndo_bridge_setlink for VLAN setup, which currently is just rocker. =
 I
>>> can see the DSA going down this path also based on another concurre=
nt
>>> thread.
>>>
>>> We're at option 2) right now.
>>>
>>>> It is not just iproute2 - since this is breaking ABI expectations.
>>>> Looking at some app i wrote a while back based on analyzing kernel
>>>> expectations at the time, I see the following logic:
>>>>
>>>> user can set master or self on command line.
>>>> ...
>>>> ....
>>>> if (user DID NOT set master_on || user set self on)
>>>>      then set self to on
>>>>
>>>> iow, current behavior:
>>>>    01: master is only set if user explicitly asked.
>>>>    11: master|self when user explicitly sets both
>>>>    10: self is on by default when the user doesnt specify anything
>>>>    00: and the last option is to have none set which is not
>>>>        possible since we have defaults.
>>>>
>>>> cheers,
>>>> jamal
>>>>
>>>>
>>>> So this is very similar to iproute2 - if nothing is set
>>>> it defaults to self.
>>>
>>> Ha, you're giving the behavior for "bridge fdb" command, where self=
 is
>>> the default.
>>
>>
>> Oh...i did not realize this was the case either. Thats unfortunate.
>>
>>>
>>> For "bridge link" and "bridge vlan", the default is master.  The us=
er
>>> must explicitly specify "self" to act on the device side of the por=
t.
>>>
>>> It's unfortunate the iproute2 defaults aren't consistent between
>>> commands.  Maybe someone knows the history here and can explain.
>>>
>>>
>>
>> scott, this brings back the discussion you and i had over the revert=
 of my
>> patches.. (commit id's at the end of this email)...
>> which used to seamlessly offload to switchdev from bridge driver if =
the port
>> was a switch port (similar to stp state offload).
>
> Your patch tried to do the same thing that the bridge's
> ndo_bridge_setlink/dellink is doing which is using the handler for
> MASTER to also set SELF stuff, when SELF was not specified.  I don't
> feel we should be overriding the application defaults in the kernel;
> instead, we should change the application if we want different
> behavior.  The kernel should treat the two sides of the port
> independent (that's the basic algo in rtnetlink.c handlers for
> MASTER/SELF things).  When you start doing kernel SELF things in the
> MASTER path, the application has lost the ability to address each sid=
e
> of the port independently.
>
>> 'self' used to exist before switchdev infra came in. My suggestion w=
as to
>> use it where required...but not build the switchdev api on the prese=
nce of
>> 'self'. switchdev layer should be consistent across...all fib/fdb/ne=
igh
>> layers.
>
> I don't understand why you're bringing up fib/neigh because there is
> no master|self form for those.
>
> The master|self objects are bridge fdb, settings, and vlans.  To be
> clear, they are PF_BRIDGE handlers for:
>
> PF_BRIDGE:RTM_NEWNEIGH: add fdb entry
> PF_BRIDGE:RTM_DELNEIGH: del fdb entry
> PF_BRIDGE:RTM_SETLINK: set bridge setting or add VLAN
> PF_BRIDGE:RTM_DELLINK: del VLAN
>
> The net/core/rtnetlink.c code for these _is_ consistent right now.
> They all perform this same basic algorithm:
>
>      handler()
>          if (!flags || flags & MASTER)
>              if (master && master->op->foo)
>                  master->op->foo();
>          if (flags & SELF)
>              if (port->op->foo)
>                  port->op->foo();
>
> This lets the application set MASTER and/or SELF to address one or
> both sides of the port.  The kernel only provides the mechanism; the
> application decides which sides to address.
>
> Where we got into trouble is in the case of
> PF_BRIDGE:RTM_SETLINK/RTM_DELLINK where the master->op->foo handler
> calls into the member port's ndo_vlan_rx_add_vid(), which is really a
> SELF operation because it's setting the VLAN for the device-side of
> the port.  Setting the VLAN on the device side should have only been
> done if SELF was specified.

Bridge's vlan_filtering is handled in master->op->foo(), not in=20
port->op->foo().
Can't we introduce another switchdev handler that performs MASTER=20
operation instead of calling SELF operation?

br_afspec()
  nbp_vlan_add()
   netdev_switch_port_vlan_add()
    rocker->ndo_switch_port_vlan_add() <- only used for MASTER operatio=
n

I'm wondering why SELF operation (rocker->ndo_bridge_setlink()) does=20
what should be done in MASTER operation.

Toshiaki Makita
