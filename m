From: jamal <hadi@cyberus.ca>
Subject: RE: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: 12 Sep 2003 08:44:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063370664.1028.85.camel@jzny.localdomain>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010124F032@orsmsx402.jf.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com, ricardoz@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010124F032@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2003-09-12 at 01:13, Feldman, Scott wrote:
> > Feldman, Scott wrote:
> > > * Change the default number of Tx descriptors from 256 to 1024.
> > >   Data from [ricardoz@us.ibm.com] shows it's easy to overrun
> > >   the Tx desc queue.
> > 
> > 
> > All e1000 patches applied except this one.
> > 
> > You're just wasting memory.
> 
> 256 descriptors does sound like enough, but what about the fragmented
> skb case?  MAX_SKB_FRAGS is (64K/4K + 2) = 18, and each fragment gets
> mapped to one descriptor.  It even gets worse with e1000 because we may
> need to split a fragment into two fragments in the driver to workaround
> hardware errata.  :-(
> 
> It would be interesting to see the frags:skb ratio for 2.6 with TSO
> enabled and disabled with Rick's test.  So our effective number of
> descriptors needs to be adjusted by that ratio.  I agree with David that
> it's wasteful for the device driver to worry about more than
> dev->tx_queue_len, but that's in skb units, not descriptor units.
> 

Ok, i overlooked the frags part.
Donald Becker is the man behind setting the # of descriptors to either
32 or 64 for 10/100. I think i saw some email from him once on how he
reached the conclusion to choose those numbers. Note, this was before
zero copy tx and skb frags. Someone needs to talk to Donald and come up
with values that make more sense for Gige and skb frags. It would be
nice to see how the numbers are derived.  
 
> On the other hand, if we're always running the descriptor ring near
> empty, we've got other problems.  It seems to reason that it doesn't
> matter how big the ring is if we're in that situation.  If the CPU can
> overrun the device, expanding the queues between the CPU and the device
> may help with bursts but gets you nothing for a sustained load.
> 

Well, theres only one way out that device ;-> and it goes out at a max 
rate of Gige. If you have sustained incoming rates from the CPU(s) of
greater than Gige, then you are fucked anyways and you are better to
drop at the scheduler queue.

> I flunked that queuing theory class anyway, so what do I know?  Every
> time I get stuck in a traffic slug on the freeway, I think about that
> class.  Hey, that means my car is like an skb, so maybe longer roads
> would help?  Not!


Note we do return an indication that the packet was dropped. What you do
with that information is relative. TCP makes use of it in the kernel
which makes sense. UDP congestion control is mostly under the influence
of the UDP app in user space. The impedance between user space and
kernel makes that info useless to the UDP app especially in cases when
the system is overloaded (which is where this matters most). This is of
course theory and someone who really wants to find out should
experiment. I would be pleasantly shocked if it turned out the info to
the UDP app was useful. An interesting thing to try , which violates
UDP, is to have UDP requeue a packet back to the socket queue in the
kernel everytime an indication is received that the scheduler queue
dropped the packet. User space by virtue of UDP sock queue not emptying
should find out soon and slow down.
All this is really speculation:
A UDP app that really care about congestion should factor it from an end
to end perspective and use the big socket queues suggested to buffer
things.

To give anology to your car, if you only find out half way later that
there was a red light a few meters back then that info is useless. If
you dont get hit and reverse you may find that infact the light has
turned to green which is again useless ;-> 

cheers,
jamal 
  
