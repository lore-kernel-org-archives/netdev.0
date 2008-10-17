From: Patrick Ohly <patrick.ohly@intel.com>
Subject: hardware time stamps + existing time stamp usage
Date: Fri, 17 Oct 2008 16:23:43 +0200
Message-ID: <1224253423.17450.211.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11694 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754466AbYJQOZ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Oct 2008 10:25:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello folks!

It's been a while, I hope you are still interested in the topic. It was
previously discussed under the subject "[RFC][PATCH 1/1] net: support
for hardware timestamping". I would like to revive the discussion (and
eventually the implementation), therefore I'm starting a new thread. I
also have two questions about oddities (?) in the current code.

Octavian posted a patch which modified the sk_buff::tstamp field so that
it can store both system time and hardware time stamps (which may be
unrelated to system time!). A single bit distinguishes the two. Ingo
suggested to drop that distinction. Before going into details of what
might have to be changed, let me take stock of what is currently done
with sk_buff::tstamp.

There seem to be at least three usages: 
      * the netfilter code uses it to trigger timing related filter
        rules (net/netfilter/xt_time.c)
      * keep track of the time stamp of the last packet received via a
        socket (SOCK_TIMESTAMP, net/sock/core.c), used for
        SIOCGSTAMP[NS] 
      * deliver receive time together with packet to user space
        (SOCK_RCVTSTAMP[NS], net/sock/sock.c)

Currently time stamping is enabled via sock_enable_timestamp(), which
itself uses the lower level net_enable_timestamp(). At that level, a
counter keeps track of how many users need time stamping.

Based on how sk_buff::tstamp is used, one can conclude that it needs to
be reasonably close to system time (for the netfilter code) but not
absolutely the same. Ingo also said that it should be monotonically
increasing. However, I doubt that this is currently guaranteed: the
value is created with ktime_get_real(), which in contrast to ktime_get()
is not monotonic (if I read the comments right).

While looking at the code I ran into a few oddities which I don't quite
understand. Could be me, of course ;-}

First, in net/ipv[46]/netfilter/ip*_queue.c, the call to
net_enable_timestamp() is in an else branch of __ipq_rcv_skb(). The
net_disable_timestamp() is unconditionally in __ipq_reset(). Shouldn't
the code take care that enable/disable calls always match exactly?
Perhaps I'm missing something, but at least at first glance that doesn't
seem to be the case. Also, is it possible that net_enable_timestamp() in
__ipq_rcv_skb() is called repeatedly? 

Second, sock_recv_timestamp() in include/net/sock.h only copies
sk_buff::tstamp into sock::sk_tstamp if SOCK_RCVTSTAMP[NS] is not set.
If this is set (note that SOCK_RCVTSTAMPNS also sets SOCK_RCVTSTAMP),
then __sock_recv_timestamp() copies the value into cmsgs instead. Is
that really the intended semantic? My expectation is that all of the
usages above are possible at the same time.

Let's move on to the changes necessary for hardware time stamping.

With regards to hardware time stamps we identified the following
additional usages of sk_buff::tstamp (assuming that we recycle it
instead of adding a new field): 
      * Transport the original hardware timestamps to user space:
        Octavian is doing that with custom patches at the moment that he
        would like to replace with an upstream solution. These hardware
        time stamps are *not* synchronized with system time, only
        between cards. Transforming them to system time decreases their
        accuracy and therefore is not desirable. 
      * Use hardware timestamps as replacement for the currently rather
        inaccurate, software-only time stamps, both for incoming and for
        outgoing packets: this improves the accuracy of system time
        synchronization with PTP [1]. For this use case, the time stamp
        delivered to the user space PTPd should be consistently
        generated either by hardware or in software. Alternating between
        the two methods introduces jumps, which decreases the accuracy
        of the clock synchronization.

The first use case is problematic if the hardware time diverges from
system time *and* net time stamping is enabled (implying that one of the
existing usages of tstamp is active). Would it be acceptable to let the
user of the Linux kernel avoid this conflict or does the kernel itself
need to detect the conflict?

The second additional use case has no such conflict. Ensuring that the
user space daemon just gets the kind of time stamps he wants is harder.
In the previous discussion we ended with the proposal to add socket
flags which determine what kind of time stamps are to be generated (TX
or RX, hardware or software). After looking at this again I believe that
deciding that at the socket level is too late: suppose the daemon has
initialized the hardware time stamping successfully and then requests to
get only hardware time stamps. A packet is received but couldn't be time
stamped (can happen due to hardware limitations). The IP filter needs a
time stamp and therefore generates one in software, which is stored in
sk_buff::tstamp. Now the socket code cannot tell whether this is a time
stamp that it can report to the daemon.

The only solution that I see is to use one bit as flag to distinguish
between hardware and software time stamps, as Octavian originally
suggested. In contrast to his proposal, the rest of the bits are to be
interpreted as system time, i.e., there would be no delayed conversion
of hardware time stamps to system time stamps. In my opinion, such a
conversion would be tricky, for example because it would have to be done
by the hardware driver which generated the time stamp, but there is no
link back to it from sk_buff.

If that flag bit is not acceptable for Linux upstream, then PTPd would
still work, albeit with lower accuracy.

That's all for now - the mail is long enough as it is...
Comments?

[1] http://www.linuxclustersinstitute.org/conferences/archive/2008/PDF/Ohly_92221.pdf

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

