From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] e100 rx: or s and el bits
Date: Tue, 01 May 2007 11:01:56 -0400
Message-ID: <46375664.8030701@roinet.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@pobox.com>, Jeff Garzik <jeff@garzik.org>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>
To: Milton Miller <miltonm@bga.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:40307
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753996AbXEAPBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 11:01:00 -0400
In-Reply-To: <200705011124.l41BOEG4007662@sullivan.realtime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Milton Miller wrote:
> In commit d52df4a35af569071fda3f4eb08e47cc7023f094, the description
> talks about emulating another driver by setting addtional bits and
> the being unable to test when submitted.  Seeing the & operator to
> set more bits made me suspicious, and indeed the bits are defined
> in positive logic:
> 
> 	cb_s      = 0x4000,
> 	cb_el     = 0x8000,
> 
> So anding those together would be 0.   I'm guessing they should
> be or'd, but don't have hardware here to test, much like the
> committed patch.  In fact, I'll let someone else do the compile
> test too.  I'll update the comment.
> 

I wonder if this worked for me because the hardware also spun on the 
link field being NULL?  Since the RU base is also set to 0, the 
calculated physical address would be 0 as well.  I would imagine if the 
hardware tried to read/write to very low addresses across PCI, there 
would be issues.  I will retest with a small receive pool to try to hit 
the problem.

It seems to apply to a pretty recent git pull from linus's tree.  I 
manually merged this into the 2.6.18.4 kernel we are using.  With the 
original in kernel driver (just EL bit, no S bit), I had two tests that 
would always end in horrible memory corruption on a PXA255 based system. 
  One is a 12 hour bidirectional TCP test using iperf with the ethernet 
port sending packets to a wireless card and vice versa.  The other is a 
similar configuration running a 12 hour UDP test sending 20 
megabits/second in each direction.  Even through the original S-bit 
patch seems broken, we have had days of continuous traffic through it 
without issue where previously we could never go more than 6 hours.

I will let folks know how it goes.  In the UDP test, the ethernet side 
often gets ahead of the available buffers due to CPU and PCI usage by 
the wireless card and its driver.

I will also run these tests with the new patch and with a smaller 
receive pool (default is 256) to make the pool run out more often.


-Ack
