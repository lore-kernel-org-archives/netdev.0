From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: fix rx checksum validation for IPv6
Date: Fri, 14 Sep 2012 20:39:06 +0300
Message-ID: <1347644346.4491.1.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1347577184-8417-1-git-send-email-mschmidt@redhat.com>
 <1347578079.8555.141.camel@edumazet-glaptop>
 <1347600028.23482.1.camel@lb-tlvb-eilong.il.broadcom.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "Eric Dumazet" <edumazet@google.com>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>,
	"Merav Sicron" <meravs@broadcom.com>,
	"Robert Evans" <evansr@google.com>,
	"Tom Herbert" <therbert@google.com>,
	"Willem de Bruijn" <willemb@google.com>,
	"David Miller" <davem@davemloft.net>,
	"Havard Skinnemoen" <hskinnemoen@google.com>
To: "Michal Schmidt" <mschmidt@redhat.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2896 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759580Ab2INRkO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 13:40:14 -0400
In-Reply-To: <1347600028.23482.1.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-14 at 08:20 +0300, Eilon Greenstein wrote:
> On Fri, 2012-09-14 at 01:14 +0200, Eric Dumazet wrote:
> > On Fri, 2012-09-14 at 00:59 +0200, Michal Schmidt wrote:
> > > Commit d6cb3e41 "bnx2x: fix checksum validation" caused a perform=
ance
> > > regression for IPv6. Rx checksum offload does not work. IPv6 pack=
ets
> > > are passed to the stack with CHECKSUM_NONE.
> > >=20
> > > The hardware obviously cannot perform IP checksum validation for =
IPv6,
> > > because there is no checksum in the IPv6 header. This should not =
prevent
> > > us from setting CHECKSUM_UNNECESSARY.
> > >=20
> > > Tested on BCM57711.
> > >=20
> > > Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> > > ---
> > >  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 12 +++++++----=
-
> > >  1 file changed, 7 insertions(+), 5 deletions(-)
> > >=20
> > > diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/dr=
ivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> > > index af20c6e..e8e97a7 100644
> > > --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> > > +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> > > @@ -662,14 +662,16 @@ void bnx2x_csum_validate(struct sk_buff *sk=
b, union eth_rx_cqe *cqe,
> > >  				 struct bnx2x_fastpath *fp,
> > >  				 struct bnx2x_eth_q_stats *qstats)
> > >  {
> > > -	/* Do nothing if no IP/L4 csum validation was done */
> > > -
> > > +	/* Do nothing if no L4 csum validation was done.
> > > +	 * We do not check whether IP csum was validated. For IPv4 we a=
ssume
> > > +	 * that if the card got as far as validating the L4 csum, it al=
so
> > > +	 * validated the IP csum. IPv6 has no IP csum.
> > > +	 */
> > >  	if (cqe->fast_path_cqe.status_flags &
> > > -	    (ETH_FAST_PATH_RX_CQE_IP_XSUM_NO_VALIDATION_FLG |
> > > -	     ETH_FAST_PATH_RX_CQE_L4_XSUM_NO_VALIDATION_FLG))
> > > +	    ETH_FAST_PATH_RX_CQE_L4_XSUM_NO_VALIDATION_FLG)
> > >  		return;
> > > =20
> > > -	/* If both IP/L4 validation were done, check if an error was fo=
und. */
> > > +	/* If L4 validation was done, check if an error was found. */
> > > =20
> > >  	if (cqe->fast_path_cqe.type_error_flags &
> > >  	    (ETH_FAST_PATH_RX_CQE_IP_BAD_XSUM_FLG |
> >=20
> > Thanks for fixing this bug !
> >=20
> > Acked-by: Eric Dumazet <edumazet@google.com>
>=20
> Indeed - thanks Michal!
>=20
> Acked-by: Eilon Greenstein <eilong@broadcom.com>
>=20

Just in case someone will look up this thread in the future, I=E2=80=99=
m adding
some details: the comment is almost right, the HW does not verify the
IPv6 header in case it contains extension headers  this is why this
patch is required (though some users with IPv6 that does not use any
extension headers will not see the issue).

In other words: Eric  this is how we both missed it=E2=80=A6
