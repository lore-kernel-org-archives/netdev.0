From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP wierdness around skb_copy_and_csum_datagram_msg()
Date: Wed, 28 Sep 2016 18:24:06 -0700
Message-ID: <1475112246.28155.122.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAA3=++__5iwkyyCvSCWJS_b=pBXg=CTYikGgLSh40dkDaY82vg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Smith <jay@kentik.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35984 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752058AbcI2BYI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 21:24:08 -0400
Received: by mail-pf0-f177.google.com with SMTP id q2so22878371pfj.3
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 18:24:08 -0700 (PDT)
In-Reply-To: <CAA3=++__5iwkyyCvSCWJS_b=pBXg=CTYikGgLSh40dkDaY82vg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-09-28 at 17:18 -0700, Jay Smith wrote:
> I've spent the last week or so trying to track down a recurring
> problem I'm seeing with UDP datagram handling.  I'm new to the
> internals of the Linux network stack, but it appears to me that
> there's a substantial error in recent kernels' handling of UDP
> checksum errors.
> 
> The behavior I'm seeing:  I have a UDP server that receives lots of
> datagrams from many devices on a single port. A small number of those
> devices occasionally send packets with bad UDP checksums.  After I
> receive one of these bad packets, the next recvmsg() made on the
> socket returns data from the bad-checksum packet, but the
> source-address and length of the next (good) packet that arrived at
> the port.
> 
> I believe this issue was introduced between linux 3.18 and 3.19, by a
> set of changes to net/core/datagram.c that made
> skb_copy_and_csum_datagram_msg() and related functions use the
> iov_iter structure to copy data to user buffers.  In the case where
> those functions copy a datagram and then conclude that the checksum is
> invalid, they don't remove the already-copied data from the user's
> iovec; when udp_recvmsg() calls skb_copy_and_csum_datagram_msg() for a
> second time, looking at the next datagram on the queue, that second
> datagram's data is appended to the first datagram's.  So when
> recvmsg() returns to the user, the return value and msg_name reflect
> the second datagram, but the first bytes in the user's iovec come from
> the first (bad) datagram.
> 
> (I've attached a test program that demonstrates the problem.  Note
> that it sees correct behavior unless the bad-checksum packet has > 68
> bytes of UDP data; otherwise, the packet doesn't make it past the
> CHECKSUM_BREAK test, and never enters
> skp_copy_and_csum_datagram_msg().)
> 
> The fix for UDP seems pretty simple; the iov_iter's iov_offset member
> just needs to be set back to zero on a checksum failure.  But it looks
> like skb_copy_and_csum_datagram_msg() is also called from tcp_input.c,
> where I assume that multiple sk_buffs can be copied-and-csum'd into
> the same iov -- if that's right, it seems like iov_iter needs some
> additional state to support rolling-back the most recent copy without
> losing previous ones.
> 
> Any thoughts?

Nice catch !

What about clearing iov_offset from UDP (v4 & v6) only ?

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7d96dc2d3d08fa909f247dfbcbd0fc1eeb59862b..928da2fbb3caa6de4d0e1d889c237590f71607ea 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1342,6 +1342,7 @@ csum_copy_err:
 	/* starting over for a new packet, but check if we need to yield */
 	cond_resched();
 	msg->msg_flags &= ~MSG_TRUNC;
+	msg->msg_iter.iov_offset = 0;
 	goto try_again;
 }
 

(similar for ipv6)
