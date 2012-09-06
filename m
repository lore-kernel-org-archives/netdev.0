From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: Increased multicast packet drops in 3.4
Date: Thu, 6 Sep 2012 08:03:16 -0500
Message-ID: <20120906130316.GA2310@BohrerMBP.gateway.2wire.net>
References: <20120906001108.GA6035@BohrerMBP.rgmadvisors.com>
 <1346912560.13121.175.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:58071 "EHLO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752838Ab2IFNDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 09:03:22 -0400
Received: by mail-ob0-f174.google.com with SMTP id uo13so2378292obb.19
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 06:03:22 -0700 (PDT)
In-Reply-To: <1346912560.13121.175.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 06, 2012 at 08:22:40AM +0200, Eric Dumazet wrote:
> On Wed, 2012-09-05 at 19:11 -0500, Shawn Bohrer wrote:
> > I've been testing the 3.4 kernel compared to the 3.1 kernel and
> > noticed my application is experiencing a noticeable increase in packet
> > drops compared to 3.1.  In this case I have 8 processes all listening
> > on the same multicast group and occasionally 1 or more of the
> > processes will report drops based on gaps in the sequence numbers on
> > the packets.  One thing I find interesting is that some of the time 2
> > or 3 of the 8 processes will report that they missed the exact same
> > 50+ packets.  Since the other processes receive the packets I know
> > that they are making it to the machine and past the driver.
> > 
> > So far I have not been able to _see_ any OS counters increase when the
> > drops occur but perhaps there is a location that I have not yet
> > looked.  I've been looking for drops in /proc/net/udp /proc/net/snmp
> > and /proc/net/dev.
> > 
> > I've tried using dropwatch/drop_monitor but it is awfully noisy even
> > after back porting many of the patches Eric Dumazet has contributed to
> > silence the false positives.  Similarly I setup trace-cmd/ftrace to
> > record skb:kfree_skb calls with a stacktrace and had my application
> > stop the trace when a drop was reported.  From these traces I see a
> > number of the following:
> > 
> >     md_connector-12791 [014]  7952.982818: kfree_skb:            skbaddr=0xffff880583bd7500 protocol=2048 location=0xffffffff813c930b
> >     md_connector-12791 [014]  7952.982821: kernel_stack:         <stack trace>
> > => skb_release_data (ffffffff813c930b)
> > => __kfree_skb (ffffffff813c934e)
> > => skb_free_datagram_locked (ffffffff813ccca8)
> > => udp_recvmsg (ffffffff8143335c)
> > => inet_recvmsg (ffffffff8143cbfb)
> > => sock_recvmsg_nosec (ffffffff813be80f)
> > => __sys_recvmsg (ffffffff813bfe70)
> > => __sys_recvmmsg (ffffffff813c2392)
> > => sys_recvmmsg (ffffffff813c25b0)
> > => system_call_fastpath (ffffffff8148cfd2)
> > 
> > Looking at the code it does look like these could be the drops, since
> > I do not see any counters incremented in this code path.  However I'm
> > not very familiar with this code so it could also be a false positive.
> > It does look like the above stack only gets called if
> > skb_has_frag_list(skb) does this imply the packet was over one MTU
> > (1500)?
> > 
> > I'd appreciate any input on possible causes/solutions for these drops.
> > Or ways that I can further debug this issue to find the root cause of
> > the increase in drops on 3.4.
> > 
> > Thanks,
> > Shawn
> > 
> 
> What NIC driver are you using ?
 
$ sudo ethtool -i eth4
driver: mlx4_en
version: 2.0 (Dec 2011)
firmware-version: 2.10.700
bus-info: 0000:05:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: no
supports-register-dump: no

This is the in tree driver from 3.4.9

[ sbohrer@berbox12:/home/sbohrer ]
$ /sbin/lspci | grep -i mell
05:00.0 Network controller: Mellanox Technologies MT27500 Family [ConnectX-3]

> Could you trace if skb_copy_and_csum_datagram_iovec() or
> skb_copy_datagram_iovec() returns an error (it could be EFAULT by
> example) ?
> 
> If so, you could add some debugging to these functions to track what
> exact error it is
> 
> It seems following patch is needed anyway :
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 6f6d1ac..2c965c9 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1226,6 +1226,8 @@ try_again:
>  
>  	if (unlikely(err)) {
>  		trace_kfree_skb(skb, udp_recvmsg);
> +		if (!peeked)
> +			UDP_INC_STATS_USER(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
>  		goto out_free;
>  	}

Sorry, I should have mentioned that it doesn't appear I'm hitting that
tracepoint.  That tracepoint would have a location=udp_recvmsg and I
believe the stack trace would also start at udp_recvmsg.  I didn't see
any of these in the traces I captured.

I think the one I'm hitting is the following with some of my own extra
annotation:

=> kfree_skb()
=> skb_drop_list()
=> skb_drop_fraglist()
> > => skb_release_data (ffffffff813c930b)
=> skb_release_all()
> > => __kfree_skb (ffffffff813c934e)
> > => skb_free_datagram_locked (ffffffff813ccca8)
> > => udp_recvmsg (ffffffff8143335c)
> > => inet_recvmsg (ffffffff8143cbfb)
> > => sock_recvmsg_nosec (ffffffff813be80f)
> > => __sys_recvmsg (ffffffff813bfe70)
> > => __sys_recvmmsg (ffffffff813c2392)
> > => sys_recvmmsg (ffffffff813c25b0)
> > => system_call_fastpath (ffffffff8148cfd2)

kfree_skb() has the trace_kfree_skb() call on net/core/skbuff.c:3283

I can of course still try your patch and double check that I'm not
hitting that one.

Thanks,
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
