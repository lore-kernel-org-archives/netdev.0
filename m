From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 9 Oct 2007 16:50:14 +0530
Message-ID: <OF683730EE.A2EA6C97-ON6525736F.003D7800-6525736F.003E4748@in.ibm.com>
References: <20071009.040255.71088090.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, gaagaan@gmail.com, jeff@garzik.org,
	Robert.Olsson@data.slu.se, mcarlson@broadcom.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	hadi@cyberus.ca, netdev@vger.kernel.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com,
	shemminger@linux-foundation.org, kaber@trash.net,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071009.040255.71088090.davem@davemloft.net>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Hi Dave,

David Miller <davem@davemloft.net> wrote on 10/09/2007 04:32:55 PM:

> > Isn't it enough that the multiqueue+batching drivers handle skbs
> > belonging to different queue's themselves, instead of qdisc having
> > to figure that out? This will reduce costs for most skbs that are
> > neither batched nor sent to multiqueue devices.
> >
> > Eg, driver can keep processing skbs and put to the correct tx_queue
> > as long as mapping remains the same. If the mapping changes, it posts
> > earlier skbs (with the correct lock) and then iterates for the other
> > skbs that have the next different mapping, and so on.
>
> The complexity in most of these suggestions is beginning to drive me a
> bit crazy :-)
>
> This should be the simplest thing in the world, when TX queue has
> space, give it packets.  Period.
>
> When I hear suggestions like "have the driver pick the queue in
> ->hard_start_xmit() and return some special status if the queue
> becomes different".....  you know, I really begin to wonder :-)
>
> If we have to go back, get into the queueing layer locks, have these
> special cases, and whatnot, what's the point?

I understand your point, but the qdisc code itself needs almost no
change, as small as:

qdisc_restart()
{
      ...
      case NETDEV_TX_MAPPING_CHANGED:
      /*
       * Driver sent some skbs from one mapping, and found others
       * are for different queue_mapping. Try again.
       */
      ret = 1; /* guaranteed to have atleast 1 skb in batch list */
      break;
      ...
}

Alternatively if the driver does all the dirty work, qdisc needs no
change at all. However, I am not sure if this addresses all the
concerns raised by you, Peter, Jamal, others.

> This code should eventually be able to run lockless all the way to the
> TX queue handling code of the driver.  The queueing code should know
> what TX queue the packet will be bound for, and always precisely
> invoke the driver in a state where the driver can accept the packet.

This sounds like a good idea :)

I need to think more on this, esp as my batching sends multiple skbs of
possibly different mappings to device, and those skbs stay in batch list
if driver couldn't send them out.

thanks,

- KK
