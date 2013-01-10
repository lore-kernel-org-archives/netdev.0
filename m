From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tainted warnings with tcp splicing in 3.7.1
Date: Thu, 10 Jan 2013 10:42:08 -0800
Message-ID: <1357843328.27446.2417.camel@edumazet-glaptop>
References: <F476A81A60AA6B458C3DA58B993EA70A1B8F394A@MUCR10053060111.muc.traviangames.lan>
	 <1357750898.27446.33.camel@edumazet-glaptop>
	 <1357751372.27446.40.camel@edumazet-glaptop>
	 <1357801149.27446.1142.camel@edumazet-glaptop>
	 <20130110072136.GK9943@1wt.eu>
	 <1357831787.27446.2168.camel@edumazet-glaptop>
	 <1357834825.27446.2205.camel@edumazet-glaptop>  <50EF06DD.7070207@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>,
	Christian Becker <c.becker@traviangames.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:57891 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755606Ab3AJSmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 13:42:21 -0500
Received: by mail-da0-f51.google.com with SMTP id i30so368687dad.38
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 10:42:20 -0800 (PST)
In-Reply-To: <50EF06DD.7070207@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-10 at 10:22 -0800, Rick Jones wrote:
> On 01/10/2013 08:20 AM, Eric Dumazet wrote:
> > I also want to thanks Rick, as the latest netperf has splice() support.
> >
> > Thanks Rick !
> 
> You are quite welcome - and thank you for helping me get it to actually 
> work :)
> 
> Those wishing to try it themselves should grab the top-of-trunk netperf 
> bits from http://www.netperf.org/svn/netperf2/trunk .  The use of 
> splice() is gated by a test-specific -V option:
> 
> raj@tardy:~/netperf2_trunk/src$ ./netperf -t omni -- -d recv -V
> OMNI Receive TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
> localhost.localdomain () port 0 AF_INET : copy avoidance : demo
> Remote      Local       Remote Elapsed Throughput Throughput
> Send Socket Recv Socket Send   Time               Units
> Size        Size        Size   (sec)
> Final       Final
> 1661688     4194304     16384  10.00   26103.14   10^6bits/s
> 
> You should see that "copy avoidance" appearing in the test banner.  It 
> will also "take" for things like a migrated TCP_mumble test.  For those 
> cases where you don't see a throughput change, enabling CPU utilization 
> measurement and looking at that and service demand should show a difference.

Thanks Rick !

Can we use zero copy for the sender as well (sendfile() or vmsplice()) ?

Here are some results :

Reference time (no splice())

# ./netperf -H 127.0.0.1 -t omni -- -d recv     
OMNI Receive TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 127.0.0.1 ()
port 0 AF_INET
catcher: timer popped with times_up != 0
Remote      Local       Remote Elapsed Throughput Throughput  
Send Socket Recv Socket Send   Time               Units       
Size        Size        Size   (sec)                          
Final       Final                                             
2097152     2097152     16384  10.00   33237.74   10^6bits/s  


zero copy at receiver (splice(socket ->pipe), splice(pipe -> /dev/null))

# ./netperf -H 127.0.0.1 -t omni -- -d recv -V
OMNI Receive TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 127.0.0.1 ()
port 0 AF_INET : copy avoidance
catcher: timer popped with times_up != 0
Remote      Local       Remote Elapsed Throughput Throughput  
Send Socket Recv Socket Send   Time               Units       
Size        Size        Size   (sec)                          
Final       Final                                             
1325580     2097152     16384  10.00   51980.60   10^6bits/s  
