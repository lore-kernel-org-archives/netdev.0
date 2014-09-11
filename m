From: Andres Freund <andres@anarazel.de>
Subject: Re: Macvlan WARNiNGS about duplicate sysfs filenames (Was [GIT]
 Networking)
Date: Thu, 11 Sep 2014 14:51:31 +0200
Message-ID: <20140911125131.GW24649@awork2.anarazel.de>
References: <20140907.164109.1944849896872238507.davem@davemloft.net>
 <20140908212514.GA2348@awork2.anarazel.de>
 <CAHA+R7NCwhMaWX0Mhr7AqHH4x5RZ6TEEiJB7906yVzQouXD3Lg@mail.gmail.com>
 <20140909234806.GG24649@awork2.anarazel.de>
 <20140909235534.GH24649@awork2.anarazel.de>
 <CAChDUfQtoi2ZeeqdHE_RghyUxdE4TBBOGcnyRmfFTthUVskWpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Alexander Y. Fomichev" <git.user@gmail.com>,
	Vlad Yasevich <vyasevic@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAChDUfQtoi2ZeeqdHE_RghyUxdE4TBBOGcnyRmfFTthUVskWpw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014-09-10 13:32:00 +0400, Alexander Y. Fomichev wrote:
> > I've reproduced the problem on another machine where it's perfectly
> > reproducible (except being about mv-bond0).
> 
> did you mean this is a macvlan which has bond as a real device?

Only on the other machine where I tried it. It's not dependent on that.

Here's a reproducer running in a stock kernel:
# ip netns add testns
# ip link add link eth0 name eth0-mv1 netns testns type macvlan
# readlink -f /sys/class/net/eth0/upper_eth0-mv1
/sys/devices/virtual/net/eth0-mv1
# ls -l /sys/devices/virtual/net/eth0-mv1
ls: cannot access /sys/devices/virtual/net/eth0-mv1: No such file or directory
# ip netns exec testns readlink -f /sys/class/net/eth0-mv1/lower_eth0
/sys/devices/pci0000:00/0000:00:1c.4/0000:03:00.0/net/eth0
# ip netns exec testns ls -l /sys/devices/pci0000:00/0000:00:1c.4/0000:03:00.0/net/eth0
ls: cannot access /sys/devices/pci0000:00/0000:00:1c.4/0000:03:00.0/net/eth0: No such file or directory
# ip netns exec testns ip link delete eth0-mv1
# ip link add link eth0 name eth0-mv1 netns testns type macvlan
RTNETLINK answers: File exists

Afaics the behaviour with the broken symlinks is old, and the actual
root cause for the bug. The new thing is that it causes re-adding the
same interface to fail.

Note that the issue is *not* reproducible when moving the interface into
the namespace after creation. So I guess that's the problem.

> hmm... current implementation of bonding unconditionally
> refuses to switch ns due to NETIF_F_NETNS_LOCAL flag afaik,
> macvlan steals flags from lowerdev so it should behave the same.
> just to clarify: custom patches?

No custom patches. And this really isn't related to bonding - the only
reason bond0 was mentioned was because one of the machines I could
reboot used bonding. As seen above it's independant of that.

> btw, could i ask you to try attached patch?

I'll try later. Thought it made sense to give you the above reproducer
alone.

Greetings,

Andres Freund
