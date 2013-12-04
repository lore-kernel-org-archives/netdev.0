From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH openvswitch v3] netlink: Implement & enable memory mapped
 netlink i/o
Date: Wed, 4 Dec 2013 14:20:53 -0800
Message-ID: <CAEP_g=8jMEsrOEpU=LTsfp93RaOowR5DfRB=dzQ-OJEsAVmm0g@mail.gmail.com>
References: <1d9af26b2798901c68ae9aef704d6313b71d3287.1386069453.git.tgraf@redhat.com>
 <20131204163328.GE30874@nicira.com> <529F6475.3090903@redhat.com>
 <20131204180818.GB16940@nicira.com> <529FA334.4050202@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Pfaff <blp@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>, ffusco@redhat.com,
	fleitner@redhat.com, Cong Wang <xiyou.wangcong@gmail.com>
To: Thomas Graf <tgraf@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:51430 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753128Ab3LDWVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 17:21:15 -0500
Received: by mail-ie0-f170.google.com with SMTP id qd12so28255022ieb.15
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 14:21:13 -0800 (PST)
In-Reply-To: <529FA334.4050202@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 4, 2013 at 1:48 PM, Thomas Graf <tgraf@redhat.com> wrote:
> On 12/04/2013 07:08 PM, Ben Pfaff wrote:
>> if one can come up with a
>> good heuristic to decide which sockets should be mmaped.  One place
>> one could start would be to mmap the sockets that correspond to
>> physical ports.
>
>
> That sounds reasonable, e.g. I would assume ports connected to tap
> devices to produce only a limited number of upcalls anyway.
>
> We can also consider enabling/disabling mmaped rings on demand based
> on upcall statistics.

If enabling rings on demand can be done cleanly that might be best
solution. To me, it seems difficult to generalize the upcall
characteristics based on port type.

>> Maybe you mean that we should only create 16 or 32 Netlink sockets,
>> and divide the datapath ports among those sockets.  OVS once used this
>> approach.  We stopped using it because it has problems with fairness:
>> if two ports are assigned to one socket, and one of those ports has a
>> huge volume of new flows (or otherwise sends a lot of packets to
>> userspace), then it can drown out the occasional packet from the other
>> port.  We keep talking about new, more flexible approaches to
>> achieving fairness, though, and maybe some of those approaches would
>> allow us to reduce the number of sockets we need, which would make
>> mmaping all of them feasible.
>
>
> I can see the fairness issue. It will result in a large amount of open
> file descriptors though. I doubt this will scale much beyond 16K ports,
> correct?

16K ports/sockets would seem to be a good upper bound. However, there
are a couple of factors that might affect that number in the future.
The first is that port might not be fine-grained enough - for example,
on an uplink port it would be better to look at MAC or IP address to
enforce fairness, which would tend to expand the number of sockets
necessary (although there obviously won't be a 1:1 mapping, which
means that we might have to come up with a more clever assignment
algorithm). The second is that Alex has been working on a userspace
mechanism for enforcing fairness (you probably have seen his recent
patches on the mailing list), which could reduce the number of unique
queues from the kernel.
