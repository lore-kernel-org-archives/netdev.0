From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to submit
	to upper layer
Date: Fri, 13 Mar 2009 10:06:56 -0700
Message-ID: <65634d660903131006n44f068dw18b2fe9dce25399e@mail.gmail.com>
References: <1236761624.2567.442.camel@ymzhang>
	 <877i2wfh1l.fsf@basil.nowhere.org> <1236845792.2567.484.camel@ymzhang>
	 <1236866906.3221.11.camel@achroite>
	 <1236926602.2567.528.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, herbert@gondor.apana.org.au,
	jesse.brandeburg@intel.com, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:32299 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761047AbZCMRHI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 13:07:08 -0400
In-Reply-To: <1236926602.2567.528.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 11:43 PM, Zhang, Yanmin
<yanmin_zhang@linux.intel.com> wrote:
>
> On Thu, 2009-03-12 at 14:08 +0000, Ben Hutchings wrote:
> > On Thu, 2009-03-12 at 16:16 +0800, Zhang, Yanmin wrote:
> > > On Wed, 2009-03-11 at 12:13 +0100, Andi Kleen wrote:
> > [...]
> > > > =A0and just use the hash function on the
> > > > NIC.
> > > Sorry. I can't understand what the hash function of NIC is. Perha=
ps NIC hardware has something
> > > like hash function to decide the RX queue number based on SRC/DST=
?
> >
> > Yes, that's exactly what they do. =A0This feature is sometimes call=
ed
> > Receive-Side Scaling (RSS) which is Microsoft's name for it. =A0Mic=
rosoft
> > requires Windows drivers performing RSS to provide the hash value t=
o the
> > networking stack, so Linux drivers for the same hardware should be =
able
> > to do so too.
> Oh, I didn't know the background. I need study more about network.
> Thanks for explain it.
>

You'll definitely want to look at the hardware provided hash.  We've
been using a 10G NIC which provides a Toeplitz hash (the one defined
by Microsoft) and a software RSS-like capability to move packets from
an interrupting CPU to another for processing.  The hash could be used
to index to a set of CPUs, but we also use the hash as a connection
identifier to key into a lookup table to steer packets to the CPU
where the application is running based on the running CPU of the last
recvmsg.  Using the device provided hash in this manner is a HUGE win,
as opposed to taking cache misses to get 4-tuple from packet itself to
compute a hash.  I posted some patches a while back on our work if
you're interested.

We also using multiple RX queues of the 10G device in concert with
pretty good results.  We have noticed that the interrupt overheads
substantially mitigate the benefits.  In fact, I would say the
software packet steering has provided the greater benefit (and it's
very useful on our many 1G NICS that don't have multiq!).

Tom
