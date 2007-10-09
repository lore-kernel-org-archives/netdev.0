From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] RE: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 9 Oct 2007 16:28:27 +0530
Message-ID: <OF8571378C.BCC92C60-ON6525736F.003A8E75-6525736F.003C488C@in.ibm.com>
References: <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	mcarlson@broadcom.com, rdreier@cisco.com, hadi@cyberus.ca,
	kaber@trash.net, randy.dunlap@oracle.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>, sri@us.ibm.com
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com>
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

Hi Peter,

"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com> wrote on
10/09/2007 04:03:42 AM:

> > true, that needs some resolution. Heres a hand-waving thought:
> > Assuming all packets of a specific map end up in the same
> > qdiscn queue, it seems feasible to ask the qdisc scheduler to
> > give us enough packages (ive seen people use that terms to
> > refer to packets) for each hardware ring's available space.
> > With the patches i posted, i do that via
> > dev->xmit_win that assumes only one view of the driver; essentially a
> > single ring.
> > If that is doable, then it is up to the driver to say "i have
> > space for 5 in ring[0], 10 in ring[1] 0 in ring[2]" based on
> > what scheduling scheme the driver implements - the dev->blist
> > can stay the same. Its a handwave, so there may be issues
> > there and there could be better ways to handle this.
> >
> > Note: The other issue that needs resolving that i raised
> > earlier was in regards to multiqueue running on multiple cpus
> > servicing different rings concurently.
>
> I can see the qdisc being modified to send batches per queue_mapping.
> This shouldn't be too difficult, and if we had the xmit_win per queue
> (in the subqueue struct like Dave pointed out).

I hope my understanding of multiqueue is correct for this mail to make
sense :-)

Isn't it enough that the multiqueue+batching drivers handle skbs
belonging to different queue's themselves, instead of qdisc having
to figure that out? This will reduce costs for most skbs that are
neither batched nor sent to multiqueue devices.

Eg, driver can keep processing skbs and put to the correct tx_queue
as long as mapping remains the same. If the mapping changes, it posts
earlier skbs (with the correct lock) and then iterates for the other
skbs that have the next different mapping, and so on.

(This is required only if driver is supposed to transmit >1 skb in one
call, otherwise it is not an issue)

Alternatively, supporting drivers could return a different code on
mapping change, like: NETDEV_TX_MAPPING_CHANGED (for batching only)
so that qdisc_run() could retry. Would that work?

Secondly having xmit_win per queue: would it help in multiple skb
case? Currently there is no way to tell qdisc to dequeue skbs from
a particular band - it returns skb from highest priority band.

thanks,

- KK
