From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH 2/3] sctp: fix association hangs due to reassembly/ordering
 logic
Date: Wed, 20 Feb 2013 11:38:58 -0500
Message-ID: <5124FC22.2090706@gmail.com>
References: <1361374925.3450.2.camel@laptop.lroberts> <D64EC45690EF85409BA6C4730E0162244310CBB5@G4W3231.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Roberts, Lee A." <lee.roberts@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <D64EC45690EF85409BA6C4730E0162244310CBB5@G4W3231.americas.hpqcorp.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/20/2013 10:55 AM, Roberts, Lee A. wrote:
> From: Lee A. Roberts <lee.roberts@hp.com>
>
> Resolve SCTP association hangs observed during SCTP stress
> testing.  Observable symptoms include communications hangs
> with data being held in the association reassembly and/or lobby
> (ordering) queues.  Close examination of reassembly queue shows
> missing packets.
>
> In sctp_ulpq_renege_list(), do not renege packets below the
> cumulative TSN ACK point.  Events being reneged from the
> ordering queue may correspond to multiple TSNs; identify
> and renege all affected packets from the tsnmap.
>
> Patch applies to linux-3.8 kernel.
>
> Signed-off-by: Lee A. Roberts <lee.roberts@hp.com>
> ---
>   net/sctp/ulpqueue.c |   30 +++++++++++++++++++++++++-----
>   1 file changed, 25 insertions(+), 5 deletions(-)
>
> diff -uprN -X linux-3.8-vanilla/Documentation/dontdiff linux-3.8-SCTP
> +1/net/sctp/ulpqueue.c linux-3.8-SCTP+2/net/sctp/ulpqueue.c
> --- linux-3.8-SCTP+1/net/sctp/ulpqueue.c	2013-02-18 16:58:34.00000000=
0
> -0700
> +++ linux-3.8-SCTP+2/net/sctp/ulpqueue.c	2013-02-20 08:17:53.67923336=
5
> -0700
> @@ -962,20 +962,40 @@ static __u16 sctp_ulpq_renege_list(struc
>   		struct sk_buff_head *list, __u16 needed)
>   {
>   	__u16 freed =3D 0;
> -	__u32 tsn;
> -	struct sk_buff *skb;
> +	__u32 tsn, last_tsn;
> +	struct sk_buff *skb, *flist, *last;
>   	struct sctp_ulpevent *event;
>   	struct sctp_tsnmap *tsnmap;
>
>   	tsnmap =3D &ulpq->asoc->peer.tsn_map;
>
> -	while ((skb =3D __skb_dequeue_tail(list)) !=3D NULL) {
> -		freed +=3D skb_headlen(skb);
> +	while ((skb =3D skb_peek_tail(list)) !=3D NULL) {
>   		event =3D sctp_skb2event(skb);
>   		tsn =3D event->tsn;
>
> +		/* Don't renege below the Cumulative TSN ACK Point. */
> +		if (TSN_lte(tsn, sctp_tsnmap_get_ctsn(tsnmap)))
> +			break;
> +
> +		/* Events in ordering queue may have multiple fragments
> +		 * corresponding to additional TSNs.  Find the last one.
> +		 */
> +		flist =3D skb_shinfo(skb)->frag_list;
> +		for (last =3D flist; flist; flist =3D flist->next)
> +			last =3D flist;
> +		if (last)
> +			last_tsn =3D sctp_skb2event(last)->tsn;
> +		else
> +			last_tsn =3D tsn;
> +
> +		/* Unlink the event, then renege all applicable TSNs. */
> +		__skb_unlink(skb, list);
> +		freed +=3D skb_headlen(skb);


This is no longer correct.  You are actually freeing more space if you=20
are reneging a reassembled event from the the ordered queue.

Please separate the 2 patches since they fix 2 distinct bugs.

Thanks
-vlad

>   		sctp_ulpevent_free(event);
> -		sctp_tsnmap_renege(tsnmap, tsn);
> +		while (TSN_lte(tsn, last_tsn)) {
> +			sctp_tsnmap_renege(tsnmap, tsn);
> +			tsn++;
> +		}
>   		if (freed >=3D needed)
>   			return freed;
>   	}
>
> N=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDr=EF=BF=BD=EF=BF=BDy=EF=
=BF=BD=EF=BF=BD=EF=BF=BDb=EF=BF=BDX=EF=BF=BD=EF=BF=BD=C7=A7v=EF=BF=BD^=EF=
=BF=BD)=DE=BA{.n=EF=BF=BD+=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD{=EF=BF=BD=
=EF=BF=BD=EF=BF=BDi=EF=BF=BD{ay=EF=BF=BD=1D=CA=87=DA=99=EF=BF=BD,j=07=EF=
=BF=BD=EF=BF=BDf=EF=BF=BD=EF=BF=BD=EF=BF=BDh=EF=BF=BD=EF=BF=BD=EF=BF=BD=
z=EF=BF=BD=1E=EF=BF=BDw=EF=BF=BD=EF=BF=BD=EF=BF=BD=0C=EF=BF=BD=EF=BF=BD=
=EF=BF=BDj:+v=EF=BF=BD=EF=BF=BD=EF=BF=BDw=EF=BF=BDj=EF=BF=BDm=EF=BF=BD=EF=
=BF=BD=EF=BF=BD=EF=BF=BD=07=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDzZ+=EF=BF=
=BD=EF=BF=BD=DD=A2j"=EF=BF=BD=EF=BF=BD!tml=3D
>
