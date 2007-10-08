From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 1/4] [NET_SCHED] explict hold dev tx lock
Date: Sun, 07 Oct 2007 21:51:24 -0700 (PDT)
Message-ID: <20071007.215124.85709188.davem@davemloft.net>
References: <1190674298.4264.24.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32903A51462@orsmsx414.amr.corp.intel.com>
	<1190677099.4264.37.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, kumarkr@linux.ibm.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	randy.dunlap@oracle.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, shemminger@linux-foundation.org,
	kaber@trash.net
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1190677099.4264.37.camel@localhost>
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
Date: Mon, 24 Sep 2007 19:38:19 -0400

> How is the policy to define the qdisc queues locked/mapped to tx rings? 

For these high performance 10Gbit cards it's a load balancing
function, really, as all of the transmit queues go out to the same
physical port so you could:

1) Load balance on CPU number.
2) Load balance on "flow"
3) Load balance on destination MAC

etc. etc. etc.

It's something that really sits logically between the qdisc and the
card, not something that is a qdisc thing.

In some ways it's similar to bonding, but using anything similar to
bonding's infrastructure (stacking devices) is way overkill for this.

And then we have the virtualization network devices where the queue
selection has to be made precisely, in order for the packet to
reach the proper destination, rather than a performance improvement.
It is also a situation where the TX queue selection is something
to be made between qdisc activity and hitting the device.

I think we will initially have to live with taking the centralized
qdisc lock for the device, get in and out of that as fast as possible,
then only take the TX queue lock of the queue selected.

After we get things that far we can try to find some clever lockless
algorithm for handling the qdisc to get rid of that hot spot.

These queue selection schemes want a common piece of generic code.  A
set of load balancing algorithms, a "select TX queue by MAC with a
default fallback on no match" for virtualization, and interfaces for
both drivers and userspace to change the queue selection scheme.
