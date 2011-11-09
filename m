From: Dave Taht <dave.taht@gmail.com>
Subject: Re: net: Add network priority cgroup
Date: Wed, 9 Nov 2011 21:27:08 +0100
Message-ID: <CAA93jw7G90kGBu2JnaEdWv3J0OSPO8eg55TMrZZCWPD-pdRf_g@mail.gmail.com>
References: <1320868655-32592-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Robert Love <robert.w.love@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:57438 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221Ab1KIU1L convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 15:27:11 -0500
Received: by qao25 with SMTP id 25so1892254qao.19
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2011 12:27:10 -0800 (PST)
In-Reply-To: <1320868655-32592-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 9, 2011 at 8:57 PM, Neil Horman <nhorman@tuxdriver.com> wro=
te:
>
> Data Center Bridging environments are currently somewhat limited in t=
heir
> ability to provide a general mechanism for controlling traffic priori=
ty.



>
> Specifically they are unable to administratively control the priority=
 at which
> various types of network traffic are sent.
>
> Currently, the only ways to set the priority of a network buffer are:
>
> 1) Through the use of the SO_PRIORITY socket option
> 2) By using low level hooks, like a tc action
>
2), above is a little vague.

There are dozens of ways to control the relative priorities of network
streams in addition to priority notably diffserv, various forms of
fair queuing, and active queue management tecniques like RED, Blue,
etc.

The priority field within the Linux skb is used for multiple purposes
- in addition to SO_PRIORITY it is also used for queue selection
within tc for a variety of queuing disciplines. Certain bands are
reserved for vlan and wireless queueing, (these features are rarely
used)

Twiddling with it on one level or creating a controller for it can and
will still be messed up by attempts to sanely use it elsewhere in the
stack.

>
> (1) is difficult from an administrative perspective because it requir=
es that the
> application to be coded to not just assume the default priority is su=
fficient,
> and must expose an administrative interface to allow priority adjustm=
ent. =A0Such
> a solution is not scalable in a DCB environment
>

Nor any other complex environment. Or even a simple one.

>
> (2) is also difficult, as it requires constant administrative oversig=
ht of
> applications so as to build appropriate rules to match traffic belong=
ing to

Yes, your description of option 2, as simplified above, is difficult.

However certain algorithms are intended to improve fairness between
flows that do not require as much oversight and classification.

However, even when RED or a newer queue management algorithm such as
QFQ or DRR is applied, classes of traffic exist that benefit from more
specialized diffserv or diffserv-like behavior.

However, the evidence for something more complex in server
environments than simple priority management is compelling at this
point.

> various classes, so that priority can be appropriately set. It is fur=
ther
> limiting when DCB enabled hardware is in use, due to the fact that tc=
 rules are
> only run after a root qdisc has been selected (DCB enabled hardware m=
ay reserve
> hw queues for various traffic classes and needs the priority to be se=
t prior to
> selecting the root qdisc)
>

Multiple applications (somewhat) rightly set priorities according to
their view of the world.

background traffic and immediate traffic often set the appropriate
diffserv bits, other traffic can do the same, and at least a few apps
set the priority field also in the hope that that will do some good,
and perhaps more should.


>
> I've discussed various solutions with John Fastabend, and we saw a cg=
roup as
> being a good general solution to this problem. =A0The network priorit=
y cgroup

Not if you are wanting to apply queue management further down the stack=
!

>
> allows for a per-interface priority map to be built per cgroup. =A0An=
y traffic
> originating from an application in a cgroup, that does not explicitly=
 set its
> priority with SO_PRIORITY will have its priority assigned to the valu=
e
> designated for that group on that interface.

> This allows a user space daemon,
> when conducting LLDP negotiation with a DCB enabled peer to create a =
cgroup
> based on the APP_TLV value received and administratively assign appli=
cations to
> that priority using the existing cgroup utility infrastructure.

I would like it if the many uses of the priority field were reduced to
one use per semantic grouping.

You are adding a controller to something that is already
ill-controlled and ill-defined, overly overloaded and both under and
over used, to be managed in userspace by code to designed later, and
then re-mapped once it exits a vm into another host or hardware queue
management system which may or may not share similar assumptions.

Don't get me wrong, I LIKE the controller idea, but think the priority
field needs to be un-overloaded first to avoid ill-effects elsewhere
in the users of the down-stream subsystems.

> Tested by John and myself, with good results

With what?

> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: John Fastabend <john.r.fastabend@intel.com>
> CC: Robert Love <robert.w.love@intel.com>
> CC: "David S. Miller" <davem@davemloft.net>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html



--
Dave T=E4ht
SKYPE: davetaht

http://www.bufferbloat.net
