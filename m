From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 11/12 -Rev2] IPoIB xmit API addition
Date: Mon, 23 Jul 2007 08:23:25 +0530
Message-ID: <OFDE4B1C58.3892597B-ON65257321.000EF65E-65257321.000FE0C9@in.ibm.com>
References: <20070722094136.GD7800@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	kaber@trash.net, jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, netdev@vger.kernel.org,
	sri@us.ibm.com, davem@davemloft.net, rdreier@cisco.com
To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070722094136.GD7800@mellanox.co.il>
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

Hi Micheal,

"Michael S. Tsirkin" <mst@dev.mellanox.co.il> wrote on 07/22/2007 03:11:36
PM:

> > +   /*
> > +    * Handle skbs completion from tx_tail to wr_id. It is possible to
> > +    * handle WC's from earlier post_sends (possible multiple) in this
> > +    * iteration as we move from tx_tail to wr_id, since if the last
> > +    * WR (which is the one which had a completion request) failed to
be
> > +    * sent for any of those earlier request(s), no completion
> > +    * notification is generated for successful WR's of those earlier
> > +    * request(s).
> > +    */
>
> AFAIK a signalled WR will always generate a completion.
> What am I missing?

Yes, signalled WR will generate a completion. I am trying to catch the case
where, say, I send 64 skbs and set signalling for only the last skb and the
others are set to NO signalling. Now if the driver found the last WR was
bad
for some reason, it will synchronously fail the send for that WR (which
happens to be the only one that is signalled). So after the 1 to 63 skbs
are
finished, there will be no completion called. That was my understanding of
how
this works, and coded it that way so that the next post will clean up the
previous one's completion.

> >
> > +         /*
> > +          * Better error handling can be done here, like free
> > +          * all untried skbs if err == -ENOMEM. However at this
> > +          * time, we re-try all the skbs, all of which will
> > +          * likely fail anyway (unless device finished sending
> > +          * some out in the meantime). This is not a regression
> > +          * since the earlier code is not doing this either.
> > +          */
>
> Are you retrying posting skbs? Why is this a good idea?
> AFAIK, earlier code did not retry posting WRs at all.

Not exactly. If I send 64 skbs to the device and the provider returned a
bad WR at skb # 50, then I will have to try skb# 51-64 again since the
provider has not attemped to send those out as it bails out at the first
failure. The provider ofcourse has already sent out skb# 1-49 before
returning failure at skb# 50. So it is not strictly retry, just xmit of
next skbs which is what the current code also does. I tested this part out
by simulating errors in mthca_post_send and verified that the next
iteration clears up the remaining skbs.

> The comment seems to imply that post send fails as a result of SQ
overflow -

Correct.

> do you see SQ overflow errors in your testing?

No.

> AFAIK, IPoIB should never overflow the SQ.

Correct. It should never happen unless IPoIB has a bug :) I guess the
comment
should be removed ?

Thanks,

- KK
