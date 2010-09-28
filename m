From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: Fix IPv6 PMTU disc. w/ asymmetric routes
Date: Tue, 28 Sep 2010 15:37:26 -0700
Message-ID: <AANLkTi=9THOcD9FieK3uy635C1kNDc=uEdtDe4qm1WU6@mail.gmail.com>
References: <55a4f86e1001131651j102b600fm1552a42866c3c671@mail.gmail.com>
	<1285581957-30694-1-git-send-email-zenczykowski@gmail.com>
	<20100928.135800.39205209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39924 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890Ab0I1Wh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 18:37:27 -0400
Received: by wwd20 with SMTP id 20so58738wwd.1
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 15:37:26 -0700 (PDT)
In-Reply-To: <20100928.135800.39205209.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Please handle all 4 cases just like the ipv4 routing code does:
>
> { saddr = SADDR, ifindex = dev->ifindex }
> { saddr = SADDR, ifindex = 0 }
> { saddr = INADDR_ANY, ifindex = dev->ifindex }
> { saddr = INADDR_ANY, ifindex = 0 }
>
> I believe I've specifically asked for this every time someone mentioned that they wanted to fix this issue.

I believe that is exactly what the following code fragment from the
above patch does:

+       rt6_do_pmtu_disc(daddr, saddr, net, pmtu, 0);
+       rt6_do_pmtu_disc(daddr, saddr, net, pmtu, dev->ifindex);
+       rt6_do_pmtu_disc(daddr, NULL, net, pmtu, 0);
+       rt6_do_pmtu_disc(daddr, NULL, net, pmtu, dev->ifindex);

The last two of these lines were added to the patch last time around
per your feedback - precisely to address this issue.
I reposted with those changes and you appeared to be ok with the
patch, and your only comment was to add a 'Signed-off-by' line.


Side note:
* I still think that handling the saddr == NULL ie. INADDR_ANY case is
entirely superfluous, since it doesn't actually iterate through all
possible source addresses.  With IPv6 there can be many, many possible
source addresses (just think of link local vs global public vs privacy
addresses and then tack on 6to4 and mobility, etc... for example I see
13 ipv6 addresses on eth0 on my desktop at home, 12 of them globally
reachable).
* Currently PMTU discovery is broken.  With this patch with all 4
lines we end up doing PMTU discovery per source address that isn't the
default source address.  Without those last two lines we'd just do
PMTU discovery per source address.  Not much of a difference, both
allow PMTU discovery to actually happen.

Except:

Imagine a machine with a 1500 MTU network card and 2 source addresses:
  - one default v6 native 'A'
  - one additional 6to4 address 'B'
The native address can reach the internet with a max MTU of 1500.
While due to source address based routing the 6to4 address goes
through a sit ipv4 based tunnel and thus has a max MTU of 1480 (1500 -
20 bytes IPv4 header).

Imagine a remote machine with v6 address 'Z' (our default address to
reach 'Z' is 'A').
Clearly the PMTU of A->Z is 1500, while the PMTU of B->Z is 1480.
[Assume there's nothing which would cause them to be lower.]

If you do PMTU discovery of A->Z, you will indeed get 1500, and mark
that as the PMTU of A->Z.
However if you do PMTU discovery of B->Z, you will indeed get 1480,
but you will mark that as the PMTU of both B->Z and A->Z (since A is
the default to reach Z).
Suddenly the PMTU of A->Z _needlessly and incorrectly_ dropped from
1500 to 1480 merely because of PMTU discovery being performed on B->Z.

And this is precisely why I think that adding those last two lines
that handle INADDR_ANY is actually more of a problem then solution
(indeed as far as I can tell, adding them doesn't actually fix any
problem - the code works just fine and performs PMTU discovery
correctly with just the first two lines).

Thankfully ending up with a lower MTU than actually possible is only a
slight performance problem, while not doing PMTU discovery correctly
at all (current state with asymmetric routing) is a big issue.
Hence regardless of whether this patch includes INADDR_ANY or not the
end result will still be an improvement.

> And the ipv4 side is a good guide in other ways, it uses a set of two arrays so you can just loop over them, making your rt6_do_pmtu_disc() calls along the way.

Sure, I can change it to use arrays, although I don't see any
particular improvement in performance (even if rt6_do_pmtu_disc was
inlined) or readability or anything.
