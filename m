From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: net: Add network priority cgroup
Date: Wed, 09 Nov 2011 13:10:34 -0800
Message-ID: <4EBAEC4A.6040102@intel.com>
References: <1320868655-32592-1-git-send-email-nhorman@tuxdriver.com> <CAA93jw7G90kGBu2JnaEdWv3J0OSPO8eg55TMrZZCWPD-pdRf_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Love, Robert W" <robert.w.love@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:56380 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754031Ab1KIVKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 16:10:36 -0500
In-Reply-To: <CAA93jw7G90kGBu2JnaEdWv3J0OSPO8eg55TMrZZCWPD-pdRf_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/9/2011 12:27 PM, Dave Taht wrote:
> On Wed, Nov 9, 2011 at 8:57 PM, Neil Horman <nhorman@tuxdriver.com> w=
rote:
>>
>> Data Center Bridging environments are currently somewhat limited in =
their
>> ability to provide a general mechanism for controlling traffic prior=
ity.
>=20
>=20
>=20
>>
>> Specifically they are unable to administratively control the priorit=
y at which
>> various types of network traffic are sent.
>>
>> Currently, the only ways to set the priority of a network buffer are=
:
>>
>> 1) Through the use of the SO_PRIORITY socket option
>> 2) By using low level hooks, like a tc action
>>
> 2), above is a little vague.
>=20
> There are dozens of ways to control the relative priorities of networ=
k
> streams in addition to priority notably diffserv, various forms of
> fair queuing, and active queue management tecniques like RED, Blue,
> etc.
>=20

Maybe dozens of ways to control traffic using various combinations of
qdiscs but I think for classification we have a small set of reasonably
defined mechanisms.

 - tc filter/action
 - netfilter infrastructure think CLASSIFY (iptables/ebtables)
 - socket options SO_PRIORITY and SO_TOS

By the way setting the tos bits also sets the sk->priority. What other
classifications did I miss?

> The priority field within the Linux skb is used for multiple purposes
> - in addition to SO_PRIORITY it is also used for queue selection
> within tc for a variety of queuing disciplines. Certain bands are
> reserved for vlan and wireless queueing, (these features are rarely
> used)
>=20
> Twiddling with it on one level or creating a controller for it can an=
d
> will still be messed up by attempts to sanely use it elsewhere in the
> stack.
>=20

The skb->priority is used by some qdiscs and also with vlan egress_maps=
=2E

Without knowing the wireless situation it seems you can either not mana=
ge
priority over wireless links if this is a problem or perhaps we can cle=
an
up the wireless queueing and integrate it with the appropriate qdisc.

Could the wireless skb->priority usage be tied into mqprio?

>>
>> (1) is difficult from an administrative perspective because it requi=
res that the
>> application to be coded to not just assume the default priority is s=
ufficient,
>> and must expose an administrative interface to allow priority adjust=
ment.  Such
>> a solution is not scalable in a DCB environment
>>
>=20
> Nor any other complex environment. Or even a simple one.
>=20
>>
>> (2) is also difficult, as it requires constant administrative oversi=
ght of
>> applications so as to build appropriate rules to match traffic belon=
ging to
>=20
> Yes, your description of option 2, as simplified above, is difficult.
>=20
> However certain algorithms are intended to improve fairness between
> flows that do not require as much oversight and classification.
>=20
> However, even when RED or a newer queue management algorithm such as
> QFQ or DRR is applied, classes of traffic exist that benefit from mor=
e
> specialized diffserv or diffserv-like behavior.
>=20
> However, the evidence for something more complex in server
> environments than simple priority management is compelling at this
> point.
>=20
>> various classes, so that priority can be appropriately set. It is fu=
rther
>> limiting when DCB enabled hardware is in use, due to the fact that t=
c rules are
>> only run after a root qdisc has been selected (DCB enabled hardware =
may reserve
>> hw queues for various traffic classes and needs the priority to be s=
et prior to
>> selecting the root qdisc)
>>
>=20
> Multiple applications (somewhat) rightly set priorities according to
> their view of the world.
>=20
> background traffic and immediate traffic often set the appropriate
> diffserv bits, other traffic can do the same, and at least a few apps
> set the priority field also in the hope that that will do some good,
> and perhaps more should.

These patches do not overwrite existing priorities. So applications
that manage the priority can continue to do this.

>=20
>=20
>>
>> I've discussed various solutions with John Fastabend, and we saw a c=
group as
>> being a good general solution to this problem.  The network priority=
 cgroup
>=20
> Not if you are wanting to apply queue management further down the sta=
ck!
>=20

I don't follow? Here your saying that you have a queue management that =
the
QOS layer is unaware of? OK so any qdisc or priority mechanism is going=
 to
interfere with 'further down the stack'.

>>
>> allows for a per-interface priority map to be built per cgroup.  Any=
 traffic
>> originating from an application in a cgroup, that does not explicitl=
y set its
>> priority with SO_PRIORITY will have its priority assigned to the val=
ue
>> designated for that group on that interface.
>=20
>> This allows a user space daemon,
>> when conducting LLDP negotiation with a DCB enabled peer to create a=
 cgroup
>> based on the APP_TLV value received and administratively assign appl=
ications to
>> that priority using the existing cgroup utility infrastructure.
>=20
> I would like it if the many uses of the priority field were reduced t=
o
> one use per semantic grouping.
>=20
> You are adding a controller to something that is already
> ill-controlled and ill-defined, overly overloaded and both under and
> over used, to be managed in userspace by code to designed later, and
> then re-mapped once it exits a vm into another host or hardware queue
> management system which may or may not share similar assumptions.
>=20

I don't think its ill-defined or ill-controlled. The priority can be
set by well defined mechanisms. We provide another mechanism to set
the priority without having to modify existing applications and a
mechanism for administrators/tools to set dynamically.

Overloaded perhaps the egress_map is a bit of an overloading of this.
But its existed for a long time.

IMHO hardware queue management systems should be integrated into the
qdisc layer if possible. DCB enabled hardware had similar problems
trying to do hardware queue management without involving the OS and
had to add hacks into select_queue() or hard coded traffic types
into the base drivers to work around this. 'mqprio' and dev support
for traffic classes was my take at a generic mechanism to expose this
to the OS.


> Don't get me wrong, I LIKE the controller idea, but think the priorit=
y
> field needs to be un-overloaded first to avoid ill-effects elsewhere
> in the users of the down-stream subsystems.
>=20

But doesn't this help the down-stream subsystems as well? The priority
will eventually be pushed down the stack.

>> Tested by John and myself, with good results
>=20
> With what?
>=20

I tested this with mqprio using the net_prio cgroups to set the priorit=
y
and using mqprio to bind hardware queue sets to each priority. Then
I used netperf, ping, and the cg* tools to test I/O.

As a side note I expect you could also use this in conjunction with
the vlan egress_map to push applications onto 802.1Q priorities.

>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>> CC: John Fastabend <john.r.fastabend@intel.com>
>> CC: Robert Love <robert.w.love@intel.com>
>> CC: "David S. Miller" <davem@davemloft.net>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20
>=20
> --
> Dave T=E4ht
> SKYPE: davetaht
>=20
> http://www.bufferbloat.net
