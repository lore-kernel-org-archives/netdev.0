From: John Lumby <johnlumby@hotmail.com>
Subject: Re: r8169 :  always copying the rx buffer to new skb
Date: Thu, 28 Apr 2011 21:55:38 -0400
Message-ID: <4DBA1A9A.3000703@hotmail.com>
References: <4DAC7001.9060800@hotmail.com> <1303147676.2857.20.camel@bwh-desktop> <4DACAC7E.4070400@hotmail.com> <20110420191316.GA18805@electric-eye.fr.zoreil.com> <4DAFA9F9.5080909@hotmail.com> <4DB77D03.9070507@hotmail.com> <20110427203544.GB19708@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	nic_swsd@realtek.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from toip5.srvr.bell.ca ([209.226.175.88]:64179 "EHLO
	toip5.srvr.bell.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026Ab1D2Bzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 21:55:55 -0400
In-Reply-To: <20110427203544.GB19708@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/27/11 16:35, Francois Romieu wrote:
>
> The patch mixes different changes. Please avoid it.

Sorry about that,  I'll rewrite with only the changes absolutely needed 
for avoiding memcpy (and maybe the setting of num_rx_bufs ring param?)

> Your MUA damaged the patch. Documentation/SubmittingPatches
> could help if you have not read it yet.

I see some truncation happened,  will fix that in next submission

> The patch makes some gratuitous changes which needlessly
> increase the differences (dirty_xy rename for instance).

will revert those

> A set_ringparam() method which does nothing until open()
> is used does not exactly ring like "least surprize behavior"
> to me.

Please see questions below

> The behavior under memory pressure is still unknown.

I have run some initial tests with memory pressure  -  the pressure 
provided by running n concurrent memory hogs,  each of which loops 
endlessly on allocating 1024 blocks of 1MB bytes each,  writing 
something into all bytes in each block,   then freeing each block,   
then repeating.  result:

*
copybreak        numhogs     workload throughput  swapping alloc 
failures?     dropped packets
                                    
Mb/sec                                   or other NIC err reports?

  16383              0              1043            none           
no                 no
     64              0              1086              |            
no                 no

  16383              1               935           moderate        
no                 no
     64              1               902              |            
no                 no

  16383              2               854           heavy           
no                 no
     64              2               851              |           yes, 
many           no

  16383              3               817           very heavy      
no                 no
     64              3            did not attempt     |
*
   Conclusions  :
     . setting copybreak to 16383 seems to be a valid way of avoiding 
alloc failures when under heavy memory pressure,  although the alloc 
failures don't seem to cause much trouble in these runs.
     .  But I am surprised to see how well the copybreak=16383 case runs 
with no memory pressure,   much better than I saw for the unpatched 
2.6.39rc2 earlier on,  and I need to run some more tests to check 
that.     I will also run same tests on the vanilla 2.6.39.

> I am mildly convinced by the implementation.
>

Thanks for all comments.

I do have a couple more questions:

    .    for my next patch submission  -   what should I base it on?     
Is there a git project which has the "latest" version of r8169.c?    I 
think it's not  torvalds/linux-2.6.git as fixes to r8169.c in that 
project go only to 2011-03-21.   Sorry if this is dumb question.
    .     regarding setting the ring param  -  I understand your comment 
but is it safe to close and open the NIC when called by ethtool 
ioctl?        Would some locking be needed?
    .     and again on the ring params  -   what is the minimum and 
maximum valid value for num rx bufs and separately for num  tx bufs   
that the r8169 supports?


Cheers,   John Lumby
