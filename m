From: Darryl Miles <darryl-mailinglists@netbauds.net>
Subject: Re: TCP SACK issue, hung connection, tcpdump included
Date: Thu, 02 Aug 2007 17:58:48 +0100
Message-ID: <46B20D48.7060704@netbauds.net>
References: <46AC2CBE.5010500@netbauds.net> <20070729064511.GA18718@1wt.eu> <Pine.LNX.4.64.0707291052300.10340@kivilampi-30.cs.helsinki.fi> <20070729085427.GA22784@1wt.eu> <Pine.LNX.4.64.0707291208230.10340@kivilampi-30.cs.helsinki.fi> <20070729160721.GA31276@1wt.eu> <46AEC286.2030302@netbauds.net> <Pine.LNX.4.64.0708021056560.8788@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-1.netbauds.net ([62.232.161.102]:46739 "EHLO
	mail-1.netbauds.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486AbXHBQ72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 12:59:28 -0400
Received: from host217-43-20-243.range217-43.btcentralplus.com ([217.43.20.243]:39115
	"EHLO [172.16.32.4]" smtp-auth: "darryl" TLS-CIPHER: "DHE-RSA-AES256-SHA
	keybits 256/256 version TLSv1/SSLv3" TLS-PEER-CN1: <none>
	rhost-flags-OK-OK-OK-FAIL) by mail-1.netbauds.net with ESMTPSA
	id S610350AbXHBQ6t (ORCPT <rfc822;netdev@vger.kernel.org> + 1 other);
	Thu, 2 Aug 2007 17:58:49 +0100
In-Reply-To: <Pine.LNX.4.64.0708021056560.8788@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:
> On Tue, 31 Jul 2007, Darryl L. Miles wrote:
>=20
>> I've been able to capture a tcpdump from both ends during the proble=
m and its
>> my belief there is a bug in 2.6.20.1 (at the client side) in that it=
 issues a
>> SACK option for an old sequence which the current window being adver=
tised is
>> beyond it.  This is the most concerning issue as the integrity of th=
e sequence
>> numbers doesn't seem right (to my limited understanding anyhow).
>=20
> You probably didn't check the reference I explicitly gave to those wh=
o=20
> are not familiar how DSACK works, just in case you didn't pick it up =
last=20
> time, here it is again for you: RFC2883...=20

I've now squinted the D-SACK RFC and understand a little about this,
however the RFC does make the claim "This extension is compatible with
current implementations of the SACK option in TCP.  That is, if one of
the TCP end-nodes does not implement this D-SACK extension and the othe=
r
TCP end-node does, we believe that this use of the D-SACK extension by
one of the end nodes will not introduce problems."

What if it turns out that is not true for a large enough number of SACK
implementations out there; in the timeframe that SACK was supported but
D-SACK was not supported.  Would it be possible to clearly catagorise a=
n
implementation to be:

  * 100% SACK RFC compliant.  SACK works and by virtue of the mandatory
requirements written into the previous SACK RFCs then this
implementation would never see a problem with receiving D-SACK even
through the stack itself does not support D-SACK.

  * Mostly SACK RFC compliant.  SACK works but if it saw D-SACK it woul=
d
have a problems dealing with it, possibly resulting in fatal TCP
lockups.  Are there SACK implementation mandatory requirements in place
for to be able to clearly draw the line and state that the 2.6.9 SACK
implementation was not RFC compliant.

  * 100% SACK and D-DACK RFC compliant.  Such an implementation was=20
written to support D-SACK on top of SACK.



So if there is a problem whos fault would it be:

  * The original SACK RFCs for not specifying a mandatory course of
action to take which D-SACK exploits.  Thus making the claim in RFC2883=
=20
unsound.

  * The older linux kernel for not being 100% SACK RFC compliant in its
implementation ?  Not a lot we can do about this now, but if we're able
to identify there maybe backward compatibility issues with the same
implementation thats a useful point to take forward.

  * The newer linux kernel for enabling D-SACK by default when RFC2883
doesn't even claim a cast iron case for D-SACK to be compatible with an=
y
100% RFC compliant SACK implementation.


Does TCP support the concept of vendor dependent options, that would be
TCP options which are in a special range that would both identify the
vendor and the vendors-specific option id.  Such a system would allow
Linux to implement a <D-SACK Ok> option, even if the RFC claims one is
not needed.  This would allow moving forward through this era until suc=
h
point in time when it was officially agreed it was just a linux problem=
=20
or an RFC problem.  If its an RFC problem then IANA (or whoever) would=20
issue a generic TCP option for it.

If the dump on this problem really does identify a risk/problem when as
its between 2 version of linux a vendor specific option also makes sens=
e.

I don't really want to switch new useful stuff off by default (so it
never gets used), I'm all for experimentation but not to the point of
failure between default configurations of widely distributed version of=
=20
the kernel.


So thats the technical approaches I can come up with to discuss.  Does
Ilpo have a particular vested interest in D-SACK that should be disclos=
ed?


> However, if DSACKs really
> bother you still (though it shouldn't :-)), IIRC I also told you how
> you're able to turn it off (tcp_dsack sysctl) but I assure you that i=
t's
> not a bug but feature called DSACK [RFC2883], there's _absolutely_=20
nothing
> wrong with it, instead, it would be wrong to _not_ send the below=20
snd_una
> SACK in this scenario when tcp_dsack set to 1.

So it is necessary to turn off a TCP option (that is enabled by default=
)
to be sure to have reliable TCP connections (that don't lock up) in the
bugfree Linux networking stack ?  This is absurd.

If such an option causes such a problem; then that option should not be
enabled by default.  If however the problem is because of a bug then le=
t
us continue to try to isolate the cause rather than wallpaper over the
cracks with the voodoo of turning things that are enabled by default of=
f.

It only makes sense to turn options off when there is a 3rd party
involved (or other means beyond your control) which is affecting
function, the case here is that two Linux kernel stacks are affected an=
d
no 3rd party device has been shown to be affecting function.


>> There is another concern of why the SERVER performed a retransmissio=
n in the
>> first place, when the tcpdump shows the ack covering it has been see=
n.
>=20
> There are only three possible reasons to this thing:
> 1) The ACK didn't reach the SERVER (your logs prove this to not be th=
e=20
> case)
> 2) The ACK got discarded by the SERVER

I'd thought about that one, its a possibility.  The server in question
does have period of high UDP load on a fair number of UDP sockets at
once (a few 1000).  Both systems have 2Gb of RAM.  The server has maybe
just 250Mb of RSS of all apps combined.

> 3) The SERVER (not the client) is buggy and sends an incorrect=20
> retransmission

This was my initial stab at the cause, simply due to the sequence like
this (from when the lockup starts) :

03:58:56.731637 IP (tos 0x10, ttl  64, id 53311, offset 0, flags [DF],
proto 6, length: 64) CLIENT.43726 > SERVER.ssh: . [tcp sum ok]
2634113543:2634113543(0) ack 617735600 win 501 <nop,nop,timestamp
819458962 16345815,nop,nop,sack sack 1 {617733440:617734888} >

03:58:57.322800 IP (tos 0x0, ttl  50, id 28689, offset 0, flags [DF],
proto 6, length: 1500) SERVER.ssh > CLIENT.43726: .
617733440:617734888(1448) ack 2634113543 win 2728 <nop,nop,timestamp
16346718 819458864>

The client sent a SACK.  But from understanding more about D-SACK, this
is a valid D-SACK response, but it appears to confuse the older Linux
kernel at the server end.


> ...So we have just two options remaining...
>=20
>> I have made available the full dumps at:
>>
>> http://darrylmiles.org/snippets/lkml/20070731/
>=20
> Thanks about these... Based on a quick check, it is rather clear that=
 the=20
> SERVER is for some reason discarding the packets it's receiving:
>=20
> 04:11:26.833935 IP CLIENT.43726 > SERVER.ssh: P 4239:4287(48) ack 281=
76 win 501 <nop,nop,timestamp 819646456 16345815>
> 04:11:27.132425 IP SERVER.ssh > CLIENT.43726: . 26016:27464(1448) ack=
 4239 win 2728 <nop,nop,timestamp 17096579 819458864>
> 04:11:27.230081 IP CLIENT.43726 > SERVER.ssh: . ack 28176 win 501 <no=
p,nop,timestamp 819646555 16345815,nop,nop
>=20
> Notice, (cumulative) ack field didn't advance though new data arrived=
, and=20
> for the record, it's in advertised window too. There are no DSACK in =
here=20
> so your theory about below snd_una SACK won't help to explain this on=
e=20
> at all... We'll just have to figure out why it's discarding it. And=20
> there's even more to prove this...

Agreed on this.  However discarding data is allowed (providing it is
intentional discarding not a bug where the TCP stack is discarding=20
segments it shouldn't), TCP should recover providing sufficient packets=
=20
get through.

So the SNMP data would show up intentional discards (due to=20
memory/resource issues).  So I'll get some of those too.


>> ...SNIPPED...MORE SIGNS OF UNEXPLAINED DISCARDING BY THE SERVER...
>=20
> There was one bad checksum btw:
>=20
>> 03:58:56.365662 IP (tos 0x10, ttl  64, id 28685, offset 0, flags [DF=
],=20
>> proto 6, length: 764) SERVER.ssh > CLIENT.43726: P [bad tcp cksum 66=
62=20
>> (->ef2b)!] 617734888:617735600(712) ack 2634113543 win 2728=20
>> <nop,nop,timestamp 16345815 819458859>

I noticed this one too, but discarded the "[bad tcp cksum 6662
->ef2b)!]" as bogus on the basis of the following packet turning up at
the client:

03:58:56.422019 IP (tos 0x0, ttl  50, id 28685, offset 0, flags [DF],
proto 6, length: 764) SERVER.ssh > CLIENT.43726: P [tcp sum ok]
617734888:617735600(712) ack 2634113543 win 2728 <nop,nop,timestamp
16345815 819458859>

=46orgive me if I am mistaken, but while the server reports a checksum
error, the client did not.  I took this to be a misreporting by tcpdump
at the server, probably due to the "e1000" network card checksum
offloading (I'd guess this level of card does offloading, I've never=20
audited the driver before).  If you search both dumps for the timestamp=
s=20
"16345815 819458859" two packets were sent by the server and two=20
received by the server with those timestamps.



>> There are some changes in 2.6.22 that appear to affect TCP SACK hand=
ling
>> does this fix a known issue ?
>=20
> There is no such "known issue" :-)... This issue has nothing to do wi=
th=20
> TCP SACK handling, since that code _won't_ be reached... We could ver=
ify=20
> that from the timestamps. But if you still insist that SACK under snd=
_una=20
> is the issue, please turn tcp_dsack to 0 on the CLIENT, you will not =
get=20
> them after that and you can be happy as your out-of-window SACK "issu=
e"
> is then fixed :-)...=20

I had thrown up one interpretation of events for others to comment, so
thanks for your comments and viewpoint on the issue.


> ...Seriously, somebody else than me is probably better in suggesting =
what=20
> could cause the discarding at the SERVER in this case. SNMP stuff Dav=
e was=20
> asking could help, you can find them from /proc/net/{netstat,snmp}...


The SNMP stats aren't so useful right now as
the box has been rebooted since then but I shall attempt to capture
/proc/net/* data, cause the problem, then capture /proc/net/* data agai=
n
if those numbers can help.


Darryl
