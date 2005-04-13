From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] IPV6_CHECKSUM socket option can corrupt kernel memory
Date: Tue, 12 Apr 2005 22:07:06 -0700
Message-ID: <OF6FA75422.9DE2DCAA-ON88256FE2.001AD3C6-88256FE2.001C1E12@us.ibm.com>
References: <20050413.130535.121024536.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050413.130535.121024536.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

netdev-bounce@oss.sgi.com wrote on 04/12/2005 09:05:35 PM:

> In article 
<OF0A4F590E.3F5A449F-ON88256FE2.000E49F8-88256FE2.000F289A@us.ibm.
> com> (at Tue, 12 Apr 2005 19:45:34 -0700), David Stevens 
<dlstevens@us.ibm.com> says:

> BTW, I remember that my first intention was that we restrict "checksum"
> should be placed within the first fragment.
> In this sense, rp->offset + 1 < len does not make sense to me,
> if there's more fragments.

These aren't fragments in the packet sense, of course. These are
just different buffers. The packet on the wire in my test case was
66 bytes on an Ethernet (and checksum offset of 20). POSIX has no
restriction on what the offset is (other than being in the packet),
and it's not clear to me you can determine easily what boundaries
sendmsg chooses for allocating the kernel buffers, if there is any
legitimate case where the nr_frags is nonzero, since it writes as
much of the data as it can in the existing skb before allocating
the new memory fragments. So, if nr_frags can ever be nonzero, I
think IPV6_CHECKSUM has to support it.

Flushing the pending packets on error fixes the panic by itself, so
the nr_frags==0 case should work with only that portion of the patch.
Ordinary sendmsgs will work without corrupting memory with that fix,
as long as MSG_MORE, corking, or any other methods cannot result in
the checksum offset being in a memory fragment when nr_frags != 0. I
don't know if that can happen in other cases or not, but it sendmsg
certainly supports allocating new nr_frags. It was easy to fix and
nr_frags != 0 can corrupt memory with even small packets, which is
why I left that in the patch.

                                                        +-DLS
