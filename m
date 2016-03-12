From: yumkam@gmail.com (Yuriy M. Kaminskiy)
Subject: Re: userns, netns, and quick physical memory consumption by unprivileged user
Date: Sat, 12 Mar 2016 16:35:55 +0300
Message-ID: <m3io0riucg.fsf@gmail.com>
References: <m3d1rclioc.fsf@gmail.com> <m3r3fhhx4c.fsf@gmail.com>
	<20160311153406.GB6620@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:52910 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752720AbcCLPeD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2016 10:34:03 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1aelYG-0000A5-0a
	for netdev@vger.kernel.org; Sat, 12 Mar 2016 16:34:00 +0100
Received: from ppp37-190-56-84.pppoe.spdop.ru ([37.190.56.84])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 12 Mar 2016 16:33:59 +0100
Received: from yumkam by ppp37-190-56-84.pppoe.spdop.ru with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 12 Mar 2016 16:33:59 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/16 18:34 , Florian Westphal wrote:
> Yuriy M. Kaminskiy <yumkam@gmail.com> wrote:
>> BTW, all those hash/conntrack/etc default sizes was calculated from
>> physical memory size in assumption there will be only *one* instance of
>> those tables. Obviously, introduction of network namespaces (and
>> especially unprivileged user-ns) thrown this assumption in the window
>> (and here comes that "falling back to vmalloc" message again; in pre-netns
>> world, those tables were allocated *once* on early system startup, with
>> typically plenty of free and unfragmented memory).
>
> No idea how to fix this expect by removing conntrack support in net
> namespaces completely.

Well, it is not *only* conntrack. Conntrack eats big chunks at once, but
there are other things that eat kernel memory too: *any* iptables
rules, 'ip address', 'ip link' (at very least, 'type dummy' and
/dev/net/tun are available inside unprivileged userns/netns), 'ip
tunnel', 'ip rule', 'ip route', etc.

Just add *a lot* of them (and over several netns to avoid potential
O(n^2) behaviour on adding), and it will be painful, regardless of
memcg/ulimits/free swap/etc.

E.g. something like

  unshare -rn sh -c 'setsid sleep inf & for i in 1 1024; do
  ip li add d$i type dummy; ip li set d$i up;done'

eats ~40M kernel memory each (unswappable and not curbed by memcg),
that's way more than conntrack hashtables alone.


At *very minimum*, all that must be limited by memcg (it is not
currently!). And maybe by ulimits too (of process that created userns?
well, natural choice of RLIMIT_MEMLOCK practically forbids netns, no
chance it will fit in 64k).


Specifically with conntrack, separate limits on hash size/entries for
non-initns won't harm, but that's more of "flexibility to avoid
senseless waste of memory" (in case specific container won't use many
connection or won't use conntrack at all) than protection against abuse.


By the way, there are unrestrained kernel memory consumption in *other*
namespace types too. E.g., let's look at mount  namespace; it looks like
tmpfs contents is at least curbed by memcg [but *not* curbed by
ulimits!], however *mounts itself* are not; e.g.

  unshare -rm sh -c 'while :; do seq -f /tmp/foo%g 1 1024|
  while read d; do mkdir -p $d; mount --bind $d $d;done'

is a bit slower [try with several instances?], but end result
would be same).

> I'd disallow all write accesses to skb->nfct (NAT, CONNMARK,
> CONNSECMARK, ...) and then no longer clear skb->nfct when forwarding
> packet from init_ns to container.
>
> Containers could then still test conntrack as seen from init namespace pov
> in PREROUTING/FORWARD/INPUT (but not OUTPUT, obviously).
>
> [ OUTPUT *might* be doable as well by allowing NEW creation in output
>   but skipping nat and deferring the confirmation/commit of the new
>   entry to the table until skb leaves initns ]
>
> We could key conntrack entries to initns conntrack table
> instead of adding one new table per netns, but seems like this only
> replaces one problem with a new one (filling/blocking initns table from
> another netns).
>
> Maybe we could go with a compromise and skip/disallow conntrack in
> unpriv userns only?
