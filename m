From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Thu, 11 Sep 2003 22:13:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010124F032@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>, <ricardoz@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Feldman, Scott wrote:
> > * Change the default number of Tx descriptors from 256 to 1024.
> >   Data from [ricardoz@us.ibm.com] shows it's easy to overrun
> >   the Tx desc queue.
> 
> 
> All e1000 patches applied except this one.
> 
> You're just wasting memory.

256 descriptors does sound like enough, but what about the fragmented
skb case?  MAX_SKB_FRAGS is (64K/4K + 2) = 18, and each fragment gets
mapped to one descriptor.  It even gets worse with e1000 because we may
need to split a fragment into two fragments in the driver to workaround
hardware errata.  :-(

It would be interesting to see the frags:skb ratio for 2.6 with TSO
enabled and disabled with Rick's test.  So our effective number of
descriptors needs to be adjusted by that ratio.  I agree with David that
it's wasteful for the device driver to worry about more than
dev->tx_queue_len, but that's in skb units, not descriptor units.

On the other hand, if we're always running the descriptor ring near
empty, we've got other problems.  It seems to reason that it doesn't
matter how big the ring is if we're in that situation.  If the CPU can
overrun the device, expanding the queues between the CPU and the device
may help with bursts but gets you nothing for a sustained load.

I flunked that queuing theory class anyway, so what do I know?  Every
time I get stuck in a traffic slug on the freeway, I think about that
class.  Hey, that means my car is like an skb, so maybe longer roads
would help?  Not!

-scott
