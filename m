From: "Tom Lendacky" <toml@us.ibm.com>
Subject: IPSec: Policy dst bundles exhausting storage
Date: Tue, 10 Jun 2003 18:32:00 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF5BE4EDD9.7B1D7854-ON86256D41.007F1E5C-86256D41.008145BF@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've discovered a bug in IPv6 policy bundle creation/searching
(xfrm6_policy.c: __xfrm6_bundle_create and __xfrm6_find_bundle) during some
stress testing using udp (it happens with tcp also) in tunnel mode (it
happens in transport also).  Every time a udp packet is sent a new dst
bundle is created and chained to the policy.  Eventually after enough
packets are sent, the dst_alloc fails and no more packets can be sent.  In
IPv4, the first bundle that is created is used repeatedly as it should be.
In the __xfrm6_find_bundle function, the xdst->u.rt6.rt6i_src.addr appears
to not have been set correctly (it has a value of
0000:0000:0000:0000:0000:0001:0000:0000) and never matches the fl->fl6_src
value and so a match is never found causing the creation of a new bundle.
It would appear that some values aren't being set, or set correctly, during
the __xfrm6_bundle_create function.

One other thing I did notice in both the v4 and v6 bundle create functions
is the line x->u.rt.fl = *fl.  Shouldn't this be a memcpy?

Thanks,
Tom
