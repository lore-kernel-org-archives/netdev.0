From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 0/10 REV5] Implement skb batching and
 support in IPoIB/E1000
Date: Mon, 17 Sep 2007 09:37:15 -0700 (PDT)
Message-ID: <20070917.093715.106267826.davem@davemloft.net>
References: <1189998103.4230.76.camel@localhost>
	<20070916.201318.71091570.davem@davemloft.net>
	<1190033500.4230.102.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, jagana@us.ibm.com, peter.p.waskiewicz.jr@intel.com,
	kumarkr@linux.ibm.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com, mcarlson@broadcom.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com,
	shemminger@linux-foundation.org, kaber@trash.net
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1190033500.4230.102.camel@localhost>
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

From: jamal <hadi@cyberus.ca>
Date: Mon, 17 Sep 2007 08:51:40 -0400

> On Sun, 2007-16-09 at 20:13 -0700, David Miller wrote:
> 
> > This only makes sense for devices which can 1) scatter-gather
> > and 2) checksum on transmit.  
> 
> If you have knowledge there are enough descriptors in the driver to
> cover all skbs you are passing, do you need to have #1? 
> Note i dont touch fragments, i am assuming the driver is smart enough to
> handle them otherwise it wont advertise it can handle scatter-gather

Yes, because you can have multiple descriptors per SKB
because we have the head part in skb->data and the rest
in the page vector.

Thus the device must be able to handle multiple descriptors
representing one packet.

> > Otherwise we make too many copies and/or passes over the data.
> 
> I didnt understand this last bit - you are still going to go over the
> list regardless of whether you call ->hard_start_xmit() once or
> multiple times over the same list, no? In the later case i am assuming
> a trimmed down ->hard_start_xmit()

If the device can't checksum, we have to pass over the data to
compute the checksum and stick it into the headers.

If the device can't scatter-gather, we have to allocate and
copy into a linear buffer.

Otherwise it's just bumping page reference counts and adjusting
offsets, no data touching at all.
