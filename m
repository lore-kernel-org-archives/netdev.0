From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sun, 8 May 2011 05:44:28 -0700
Message-ID: <20110508124428.GJ2641@linux.vnet.ibm.com>
References: <891B02256A0667292521A4BF@Ximines.local>
 <1304770926.2821.1157.camel@edumazet-laptop>
 <0F4A638C2A523577CDBC295E@Ximines.local>
 <1304785589.3207.5.camel@edumazet-laptop>
 <178E8895FB84C07251538EF7@Ximines.local>
 <1304793174.3207.22.camel@edumazet-laptop>
 <1304793749.3207.26.camel@edumazet-laptop>
 <1304838742.3207.45.camel@edumazet-laptop>
 <F57561A93EFF5E88729A8D53@nimrod.local>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Alex Bligh <alex@alex.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:45923 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751277Ab1EHMoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2011 08:44:34 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p48CMr3l023087
	for <netdev@vger.kernel.org>; Sun, 8 May 2011 08:22:53 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p48CiUdH942162
	for <netdev@vger.kernel.org>; Sun, 8 May 2011 08:44:30 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p48CiTfs009472
	for <netdev@vger.kernel.org>; Sun, 8 May 2011 08:44:30 -0400
Content-Disposition: inline
In-Reply-To: <F57561A93EFF5E88729A8D53@nimrod.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 08, 2011 at 10:35:02AM +0100, Alex Bligh wrote:
> Eric,
> 
> --On 8 May 2011 09:12:22 +0200 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> >By the way, if I change HZ from 1000 to 100 I now have ten times slower
> >result :
> 
> I repeated that test here. With HZ set to 1000 I got a total time of
> 4.022 seconds to remove 100 interfaces, of which:
> 
> Total 3.03808 Usage 199 Average 0.01527 elsewhere
> Total 0.93992 Usage 200 Average 0.00470 synchronizing
> 
> as opposed to a total of 27.917 seconds with HZ set to 100, of which
> 
> Total 18.98515 Usage 199 Average 0.09540 elsewhere
> Total 8.77581 Usage 200 Average 0.04388 synchronizing
> 
> Not quite a factor of 10 improvement, but nearly.
> 
> I have CONFIG_RCU_FAST_NO_HZ=y
> 
> I suspect this may just mean an rcu reader holds the rcu_read_lock
> for a jiffies related time. Though I'm having difficulty seeing
> what that might be on a system where the net is in essence idle.

OK, let's break it out...

4.022 seconds for 100 interfaces means about 40 milliseconds per interface.

My guess is that you have CONFIG_NO_HZ=y, which means that RCU needs to
figure out that various CPUs are in dyntick-idle state, which is a minimum
of 6 jiffies.  It could be longer if a given CPU happens to be in IRQ
when RCU checks, so call it 9 jiffies.  If you are doing the interfaces
synchronously, you will likely have to wait for a prior grace period (due
to background activity).  So I can easily imagine 18 milliseconds for
HZ=1000.  40 milliseconds sounds a bit high, but perhaps not impossible.

							Thanx, Paul
