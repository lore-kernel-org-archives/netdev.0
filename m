From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv3 net-next 2/5] {IPv4,xfrm} Add ESN support for AH
 ingress part
Date: Tue, 14 Jan 2014 11:34:27 +0100
Message-ID: <20140114103426.GJ31491@secunet.com>
References: <1389663552-29638-1-git-send-email-fan.du@windriver.com>
 <1389663552-29638-3-git-send-email-fan.du@windriver.com>
 <20140114095425.GH31491@secunet.com>
 <52D50AFC.6030302@windriver.com>
 <20140114100900.GI31491@secunet.com>
 <52D50EB6.3010301@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36571 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751329AbaANKe3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 05:34:29 -0500
Content-Disposition: inline
In-Reply-To: <52D50EB6.3010301@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 06:17:26PM +0800, Fan Du wrote:
>=20
>=20
> On 2014=E5=B9=B401=E6=9C=8814=E6=97=A5 18:09, Steffen Klassert wrote:
> >On Tue, Jan 14, 2014 at 06:01:32PM +0800, Fan Du wrote:
> >>
> >>
> >>On 2014=E5=B9=B401=E6=9C=8814=E6=97=A5 17:54, Steffen Klassert wrot=
e:
> >>>On Tue, Jan 14, 2014 at 09:39:09AM +0800, Fan Du wrote:
> >>>>@@ -381,7 +393,14 @@ static int ah_input(struct xfrm_state *x, st=
ruct sk_buff *skb)
> >>>>  	sg_init_table(sg, nfrags);
> >>>>  	skb_to_sgvec(skb, sg, 0, skb->len);
> >>>>
> >>>>-	ahash_request_set_crypt(req, sg, icv, skb->len);
> >>>>+	if (x->props.flags&   XFRM_STATE_ESN) {
> >>>>+		sg_unmark_end(&sg[nfrags - 1]);
> >>>>+		/* Attach seqhi sg right after packet payload */
> >>>>+		*seqhi =3D htonl(XFRM_SKB_CB(skb)->seq.output.hi);
> >>>
> >>>This is ah_input(), so you should use the high bits of the input
> >>>sequence number here. The ipv6 patch has the same problem.
> >>
> >>ok, I will fix this.
> >>
> >>>
> >>>>+		sg_init_table(seqhisg, sglists);
> >>>
> >>>Why do you add a separate SG table for this?
> >>
> >>It just initialize a single seqhisg, which is actually followed beh=
ind packet payload sg table.
> >>initialized seqhisg actually mark itself as the end of sg list.
> >>
> >
> >Why don't you just add this entry to the existing SG table?
> >
>=20
> Do you mean scatterwalk_crypto_chain ?

No, I mean something like:

sg_init_table(sg, nfrags + sglists)

if (x->props.flags & XFRM_STATE_ESN) {
	*seqhi =3D XFRM_SKB_CB(skb)->seq.input.hi;
	sg_set_buf(sg + nfrags, seqhi, seqhi_len);
}
