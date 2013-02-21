From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH 3/4] sctp: fix association hangs due to errors when reneging
 events from the ordering queue
Date: Thu, 21 Feb 2013 12:23:37 -0500
Message-ID: <51265819.80101@gmail.com>
References: <D64EC45690EF85409BA6C4730E0162244310DF0B@G4W3231.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Roberts, Lee A." <lee.roberts@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <D64EC45690EF85409BA6C4730E0162244310DF0B@G4W3231.americas.hpqcorp.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/21/2013 11:44 AM, Roberts, Lee A. wrote:
> From: Lee A. Roberts <lee.roberts@hp.com>
>
> Resolve SCTP association hangs observed during SCTP stress
> testing.  Observable symptoms include communications hangs
> with data being held in the association reassembly and/or lobby
> (ordering) queues.  Close examination of reassembly queue shows
> missing packets.
>
> In sctp_ulpq_renege_list(), events being reneged from the
> ordering queue may correspond to multiple TSNs.  Identify
> all affected packets; sum freed space and renege from the
> tsnmap.
>
> Patch applies to linux-3.8 kernel.
>
> Signed-off-by: Lee A. Roberts <lee.roberts@hp.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>   net/sctp/ulpqueue.c |   26 ++++++++++++++++++++++----
>   1 file changed, 22 insertions(+), 4 deletions(-)
>
> diff -uprN -X linux-3.8-vanilla/Documentation/dontdiff linux-3.8-SCTP+2/net/sctp/ulpqueue.c linux-3.8-SCTP+3/net/sctp/ulpqueue.c
> --- linux-3.8-SCTP+2/net/sctp/ulpqueue.c	2013-02-21 07:39:40.888281496 -0700
> +++ linux-3.8-SCTP+3/net/sctp/ulpqueue.c	2013-02-21 07:55:32.817713326 -0700
> @@ -962,8 +962,8 @@ static __u16 sctp_ulpq_renege_list(struc
>   		struct sk_buff_head *list, __u16 needed)
>   {
>   	__u16 freed = 0;
> -	__u32 tsn;
> -	struct sk_buff *skb;
> +	__u32 tsn, last_tsn;
> +	struct sk_buff *skb, *flist, *last;
>   	struct sctp_ulpevent *event;
>   	struct sctp_tsnmap *tsnmap;
>
> @@ -977,10 +977,28 @@ static __u16 sctp_ulpq_renege_list(struc
>   		if (TSN_lte(tsn, sctp_tsnmap_get_ctsn(tsnmap)))
>   			break;
>
> -		__skb_unlink(skb, list);
> +		/* Events in ordering queue may have multiple fragments
> +		 * corresponding to additional TSNs.  Sum the total
> +		 * freed space; find the last TSN.
> +		 */
>   		freed += skb_headlen(skb);
> +		flist = skb_shinfo(skb)->frag_list;
> +		for (last = flist; flist; flist = flist->next) {
> +			last = flist;
> +			freed += skb_headlen(last);
> +		}
> +		if (last)
> +			last_tsn = sctp_skb2event(last)->tsn;
> +		else
> +			last_tsn = tsn;
> +
> +		/* Unlink the event, then renege all applicable TSNs. */
> +		__skb_unlink(skb, list);
>   		sctp_ulpevent_free(event);
> -		sctp_tsnmap_renege(tsnmap, tsn);
> +		while (TSN_lte(tsn, last_tsn)) {
> +			sctp_tsnmap_renege(tsnmap, tsn);
> +			tsn++;
> +		}
>   		if (freed >= needed)
>   			return freed;
>   	}
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
