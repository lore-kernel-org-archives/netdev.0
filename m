From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: IPV6 RFC3542 compliance [PATCH]
Date: Tue, 7 Jun 2005 00:40:28 -0700
Message-ID: <OF2D6866A4.ACD65B11-ON88257019.0027E8B0-88257019.002A2862@us.ibm.com>
References: <20050607.160521.73986501.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050607.160521.73986501.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> We can still keep old binaries if we renumber.
> This is important point.
> e.g. people, including myself, can keep using old binaries on new 
kernels.

> --yoshfuji

But old binaries won't work with just that change
(and making them work is independent of changing
the numbers).

For example, old binary:

IPV6_RTHDR is value 5

it does:
        on=1; setsockopt(s, SOL_IPV6, 5, &on);
and later a recvmsg() where it looks for
cmsg_type == IPV6_RTHDR (5).

In the new API, the equivalent:

IPV6_RTHDR 728
IPV6_RECVRTHDR 729

        old binary calls with "5", which you want
to work, but returns cmsg_type "728" (app doesn't
find a "5").

        The boolean socket option in the new API
cannot be equal to the cmsg_type, because IPV6_RTHDR
and IPV6_RECVRTHDR do different things as socket
options (and both are there).
        So, no old binary can work unless the kernel
"knows" it's talking to an old binary, and it
returns a different (wrong, under the new API)
cmsg_type for that option. But the putcmsg() are
done in receive processing, so you'd need a flag
to tell you which you had, and a map for old and
new cmsg_type's.
        But the number changes don't help here,
because an old binary will call with argument
size of int, a new binary will have an argument
greater (barring bugs). So, you can tell without
number changes, but you still have all the ugly
code to return old and new data for old and new
binaries.
        And if the caller doesn't change the source,
it'll recompile fine but give incorrect results 
(EINVAL on the setsockopt call) when s/he gets
the new definition of IPV6_RTHDR, but still calls
it with a boolean argument value.

I'm suggesting we bypass the ugly binary support
and get EINVAL when run now; trivial source fix,
and they have a working binary again.

                                        +-DLS
