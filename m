From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH next 1/3] ipvlan: Defer multicast / broadcast processing
 to a work-queue
Date: Fri, 24 Apr 2015 17:59:37 -0500
Message-ID: <1429916377.6379.29.camel@redhat.com>
References: <1429824589-23663-1-git-send-email-maheshb@google.com>
	 <1429906542.6379.16.camel@redhat.com>
	 <CAF2d9jgUccznBGtouWs37Pttzbh3uFX3OdSsZ1dz0GS16ofv-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50134 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756343AbbDXW6b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Apr 2015 18:58:31 -0400
In-Reply-To: <CAF2d9jgUccznBGtouWs37Pttzbh3uFX3OdSsZ1dz0GS16ofv-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-24 at 15:40 -0700, Mahesh Bandewar wrote:
> On Fri, Apr 24, 2015 at 1:15 PM, Dan Williams <dcbw@redhat.com> wrote:
> > On Thu, 2015-04-23 at 14:29 -0700, Mahesh Bandewar wrote:
> >> Processing multicast / broadcast in fast path is performance draining
> >> and having more links means more clonning and bringing performance
> >> down further.
> >>
> >> Broadcast; in particular, need to be given to all the virtual links.
> >> Earlier tricks of enabling broadcast bit for IPv4 only interfaces are not
> >> really working since it fails autoconf. Which means enabling braodcast
> >> for all the links if protocol specific hacks do not have to be added into
> >> the driver.
> >>
> >> This patch defers all (incoming as well as outgoing) multicast traffic to
> >> a work-queue leaving only the unicast traffic in the fast-path. Now if we
> >> need to apply any additional tricks to further reduce the impact of this
> >> (multicast / broadcast) type of traffic, it can be implemented while
> >> processing this work without affecting the fast-path.
> >
> > These patches appear to work for me for the L2 + DHCP use-case, however
> > I experienced some quite odd behavior when pinging the ipvlan interface
> > from another machine.  I did this:
> >
> > ip link add link eno1 type ipvlan mode l2
> > ip netns add ipv
> > ip link set dev ipvlan0 netns ipv
> > ip netns exec ipv /sbin/dhclient -B -4 -1 -v
> > -pf /run/dhclient-ipvlan0.pid -C adafdasdfasf ipvlan0
> > ip netns exec ping 4.2.2.1 <success>
> >
> > However, when pinging from another machine, I got very inconsistent ping
> > replies:
> >
> > 64 bytes from 192.168.1.38: icmp_seq=1 ttl=64 time=11.4 ms
> > 64 bytes from 192.168.1.38: icmp_seq=16 ttl=64 time=64.9 ms
> > 64 bytes from 192.168.1.38: icmp_seq=25 ttl=64 time=87.9 ms
> > 64 bytes from 192.168.1.38: icmp_seq=30 ttl=64 time=242 ms
> > 64 bytes from 192.168.1.38: icmp_seq=35 ttl=64 time=40.1 ms
> > 64 bytes from 192.168.1.38: icmp_seq=36 ttl=64 time=60.9 ms
> >
> We know that there is that PAUSE frame leak but that should not cause
> this behavior if those are present in your network. The sched_work()
> which is wrong (as pointed by Eric) especially when the machine is
> busy and that might trigger something like this. Almost every 10th -
> 15th ping packet seems to be processed correctly.
> 
> I did get consistent results as opposed what you have shown here, but
> will dig some more to see if something obviously wrong here.
> 
> > But I cannot reproduce that in a second run (though I haven't rebooted
> > to test cleanly again).
> >
> > And oddly, the dhclient process takes a consistent 5% CPU and wireshark
> > running on eno1 (not even the ipvlan interface) jumps to 100% CPU along
> > with the dumpcap process taking another 25%, none of which are normal.
> > This is a 4-core i4790 box, so something is wrong here; is something
> > holding onto a spinlock for way too long?
> >
> > But at least it handles the packets ok, so I say progress!  Happy to
> > help track down the CPU usage issue if you want to give me patches to
> > test.
> >
> Which patch(es) you are referring to?

None that yet exist; simply that if any of the issues I described
triggered thoughts or patches on your end, I'm happy to test them.  I
will try to characterize the issues I have seen more next week and
report back.

Dan
