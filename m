From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Increased multicast packet drops in 3.4
Date: Wed, 5 Sep 2012 19:11:08 -0500
Message-ID: <20120906001108.GA6035@BohrerMBP.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:50994 "EHLO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755205Ab2IFALP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 20:11:15 -0400
Received: by mail-ob0-f174.google.com with SMTP id uo13so1459664obb.19
        for <netdev@vger.kernel.org>; Wed, 05 Sep 2012 17:11:14 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been testing the 3.4 kernel compared to the 3.1 kernel and
noticed my application is experiencing a noticeable increase in packet
drops compared to 3.1.  In this case I have 8 processes all listening
on the same multicast group and occasionally 1 or more of the
processes will report drops based on gaps in the sequence numbers on
the packets.  One thing I find interesting is that some of the time 2
or 3 of the 8 processes will report that they missed the exact same
50+ packets.  Since the other processes receive the packets I know
that they are making it to the machine and past the driver.

So far I have not been able to _see_ any OS counters increase when the
drops occur but perhaps there is a location that I have not yet
looked.  I've been looking for drops in /proc/net/udp /proc/net/snmp
and /proc/net/dev.

I've tried using dropwatch/drop_monitor but it is awfully noisy even
after back porting many of the patches Eric Dumazet has contributed to
silence the false positives.  Similarly I setup trace-cmd/ftrace to
record skb:kfree_skb calls with a stacktrace and had my application
stop the trace when a drop was reported.  From these traces I see a
number of the following:

    md_connector-12791 [014]  7952.982818: kfree_skb:            skbaddr=0xffff880583bd7500 protocol=2048 location=0xffffffff813c930b
    md_connector-12791 [014]  7952.982821: kernel_stack:         <stack trace>
=> skb_release_data (ffffffff813c930b)
=> __kfree_skb (ffffffff813c934e)
=> skb_free_datagram_locked (ffffffff813ccca8)
=> udp_recvmsg (ffffffff8143335c)
=> inet_recvmsg (ffffffff8143cbfb)
=> sock_recvmsg_nosec (ffffffff813be80f)
=> __sys_recvmsg (ffffffff813bfe70)
=> __sys_recvmmsg (ffffffff813c2392)
=> sys_recvmmsg (ffffffff813c25b0)
=> system_call_fastpath (ffffffff8148cfd2)

Looking at the code it does look like these could be the drops, since
I do not see any counters incremented in this code path.  However I'm
not very familiar with this code so it could also be a false positive.
It does look like the above stack only gets called if
skb_has_frag_list(skb) does this imply the packet was over one MTU
(1500)?

I'd appreciate any input on possible causes/solutions for these drops.
Or ways that I can further debug this issue to find the root cause of
the increase in drops on 3.4.

Thanks,
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
