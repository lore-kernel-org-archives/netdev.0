From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 5/5] rocker: remove support for legacy VLAN ndo ops
Date: Tue, 2 Jun 2015 07:30:40 -0700
Message-ID: <CAE4R7bAXA27cqBLv6MP0kak-L=1bXUoZPw7vxUyYpP=-dk=eAg@mail.gmail.com>
References: <1433183947-13095-1-git-send-email-sfeldma@gmail.com>
 <1433183947-13095-6-git-send-email-sfeldma@gmail.com> <556D363A.5010005@lab.ntt.co.jp>
 <20150601.222442.1854333703599698362.davem@davemloft.net> <CAE4R7bBL+=-akoNLPqPae=zrYe3DH59t=8UK_T7KhcHSNaKUtw@mail.gmail.com>
 <556D96ED.9010309@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:35635 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758542AbbFBObC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 10:31:02 -0400
Received: by qgg60 with SMTP id 60so59394926qgg.2
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 07:31:00 -0700 (PDT)
In-Reply-To: <556D96ED.9010309@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 2, 2015 at 4:43 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 06/02/15 03:10, Scott Feldman wrote:
>
>
>> Actually, we're now consistent with bridge man page which says master
>> is the default.
>>
>> Want we want, I believe, is to adjust what the man page says (and the
>> bridge vlan command itself), by making the default master and self.
>> The kernel and driver are fine, it's the default in the bridge command
>> that needs adjusting.  Once we do this, we'll be back to transparent
>> with software-only bridge.
>>
>
> Question to ask when looking at something of this nature:
> Will it work with no suprises if you used today's unmodified app?
> The default behavior shouldnt change and unfortunately it does here.

The default behavior does change, yes, but there shouldn't be any
surprises even if using today's unmodified app.  The reason why is no
in-kernel driver is using ndo_bridge_setlink for VLAN setup.  The
three drivers that have ndo_bridge_setlink use if to set hwmode to
VEBA|VEB.  For VLAN setup, they use the (default master) bridge's
ndo_bridge_setlink->ndo_vlan_rx_add_vid.  If the default changes from
master to master|self, the bridge's
ndo_bridge_setlink->ndo_vlan_rx_add_vid is still called for those
driver's using ndo_vlan_rx_add_vid, and if they implement
ndo_bridge_setlink, they'll get called a second time but will noop
because there will be no IFLA_BRIDGE_MODE (hwmode) attr to process.

So it comes down to two choices:

1) break ABI, which is inconsequential for in-kernel drivers and
preserve (iproute2) command transparency, or

2) embrace existing behavior which is consistent with man pages but
breaks command transparency for any driver implementing
ndo_bridge_setlink for VLAN setup, which currently is just rocker.  I
can see the DSA going down this path also based on another concurrent
thread.

We're at option 2) right now.

> It is not just iproute2 - since this is breaking ABI expectations.
> Looking at some app i wrote a while back based on analyzing kernel
> expectations at the time, I see the following logic:
>
> user can set master or self on command line.
> ...
> ....
> if (user DID NOT set master_on || user set self on)
>    then set self to on
>
> iow, current behavior:
>  01: master is only set if user explicitly asked.
>  11: master|self when user explicitly sets both
>  10: self is on by default when the user doesnt specify anything
>  00: and the last option is to have none set which is not
>      possible since we have defaults.
>
> cheers,
> jamal
>
>
> So this is very similar to iproute2 - if nothing is set
> it defaults to self.

Ha, you're giving the behavior for "bridge fdb" command, where self is
the default.

For "bridge link" and "bridge vlan", the default is master.  The user
must explicitly specify "self" to act on the device side of the port.

It's unfortunate the iproute2 defaults aren't consistent between
commands.  Maybe someone knows the history here and can explain.

-scott
