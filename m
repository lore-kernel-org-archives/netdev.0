From: Joe Stringer <joestringer@nicira.com>
Subject: Re: OVS VXLAN decap rule has full match on TTL for the outer headers?
Date: Fri, 13 Nov 2015 00:14:44 -0800
Message-ID: <CAOftzPjio364zHUXSpK3uFDu+DiSc=5ae1WVjg9C+8485rpBsw@mail.gmail.com>
References: <56435508.9070802@mellanox.com> <CAEh+42jT44TQUcX=KOh9j495ObAJrQ1F_8YQF5Lz6CJUNkuh=w@mail.gmail.com>
 <CAJ3xEMhopRFPJFj4k41X6dKWz7Ok1Jqvtht7YS=59e3ceRf-qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>,
	Joe Stringer <joestringer@nicira.com>,
	Jesse Gross <jesse@nicira.com>,
	Haggai Eran <haggaie@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ilya Lesokhin <ilyal@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f194.google.com ([209.85.160.194]:34520 "EHLO
	mail-yk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753278AbbKMIPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 03:15:04 -0500
Received: by ykay124 with SMTP id y124so12667513yka.1
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2015 00:15:03 -0800 (PST)
In-Reply-To: <CAJ3xEMhopRFPJFj4k41X6dKWz7Ok1Jqvtht7YS=59e3ceRf-qg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11 November 2015 at 22:34, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Thu, Nov 12, 2015 at 12:44 AM, Jesse Gross <jesse@kernel.org> wrote:
>> On Wed, Nov 11, 2015 at 6:47 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>>> Hi Joe/Jesse,
>>>
>>> We've noticed that VXLAN decap rules set by OVS in the below trivial VXLAN
>>> config contain full match on TTL=64 for the outer headers, can you explain
>>> the reasoning behind it? is that justa typo in dumping the flow?
>>
>> Looking at the code, this does indeed seem to be the case. To the best
>> of my knowledge, there was no particular reasoning behind it - it
>> simply was never an issue so the wildcard generation wasn't improved.
>
> so all of the multi-million vxlan packets that were ever decapsulatd by OVS
> arrived with TTL=X=64, this is impossible... when tunneled traffic goes
> through routers, they change TTL of the outer packet, right?
>
> so if the was a router between my hosts, the packet would arrive with TTL-63, we
> still miss something here.

I don't follow the logic. You observed one flow which matched on
TTL=64, therefore all vxlan packets terminated at OVS have TTL=64?

If OVS received packets with different TTLs, they would miss and
ovs-vswitchd would generate flows to match that traffic too. If that
becomes an issue, presumably the wildcard generation can be improved.

> 08:09:32.704276 00:02:c9:e9:bf:32 > f4:52:14:01:da:82, ethertype IPv4
> (0x0800), length 148: (tos 0x0, ttl 64, id 31703, offset 0, flags
> [DF], proto UDP (17), length 134)
>     192.168.31.17.51757 > 192.168.31.18.4789: [no cksum] UDP, length 106
> 08:09:32.704323 f4:52:14:01:da:82 > 00:02:c9:e9:bf:32, ethertype IPv4
> (0x0800), length 148: (tos 0x0, ttl 64, id 45301, offset 0, flags
> [DF], proto UDP (17), length 134)
>     192.168.31.18.53633 > 192.168.31.17.4789: [no cksum] UDP, length 106
>
>
>>> I also noticed that on my systems (upstream kernel 4.3.0-rc6+, veth
>>> emulating a VM network 192.168.52/24 and host network 192.168.31/24, ovs
>>> user-space 2.3.2) something is broken in the encap rule reporting, traffic
>>> goes fine (below)
>
>> That is pretty strange, I have never seen that before. It seems that
>> the key to be set is being reported as UNSPEC, which is weird if
>> traffic is flowing normally. I guess you could try a newer version of
>> userspace but I'm not aware of any patches that went in that would
>> have fixed a bug in this area.
>
> Seems as clear regression here w.r.t inter-operability between OVS user/kernel,
> user space 2.3.2 which is listed in the web site as the latest release
> on the LTS branch reports junk,
> user space 2.0.90 crashes...

I agree that this UNSPEC issue on v2.3 could do with a bit of a closer
look. I'll see if I can find some time for it. Alternatively if you're
willing and have bandwith, I'd be curious if it's related to the
masked set field feature introduced in Linux-4.0.

OVS 2.0.90 isn't an actual version number, it typically means master
at some point between v2.0 and v2.1 (unknown), and furthermore it
sounds like that issue is fixed in v2.3 so upgrading is the best
option.

> looking in the kernel logs when I did the runs with 2.3.2 I do see
> this prints few times
>
> openvswitch: netlink: Key type 62 is out of range max 26

This particular issue looks like the experimental MPLS support in
OVS2.3.x which was later reshuffled when it was merged upstream. At
that time there was no way to silently probe for features, so the MPLS
feature probe ends up causing a log message like this when you pair
OVS 2.3.x with any kernel module that didn't also have the same
experimental MPLS support (which, I'm not sure if there's any official
version released anywhere). It is harmless.

> and later the below "Dropping previously announced user features" warning

In this case it looks like you created the datapath using a newer
version of the userspace utilities, then without deleting the
datapath, attempted to reuse the datapath with an older version of the
userspace utilities. This is fine, but it warns you because it drops
particular user features which the newer userspace supported (because
the older userspace doesn't support them). Sure, it's not the most
graceful, but it doesn't look fatal in and of itself. Comment from the
code below for context:

/* An outdated user space instance that does not understand
* the concept of user_features has attempted to create a new
* datapath and is likely to reuse it. Drop all user features.
*/

> So I now moved to 2.4.0, and things aren't much better... can you give
> a quick try on
> your systems for upstream kernel against upstream OVS w.r.t to simple
> VXLAN config?

What do you mean by "not much better"? Do you mean that you still
observe one of the above three issues, or you see a different issue?
In particular I'd be curious if you observe the UNSPEC issue.

FWIW I've been regularly running a very trivial vxlan test with the
upstream (master) OVS and at least v4.3, and I haven't noticed
anything particularly unusual. That said I haven't been looking
closely for strange behaviour either.
