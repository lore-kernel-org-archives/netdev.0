From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH 1/4] sctp: fix association hangs due to off-by-one errors
 in sctp_tsnmap_grow()
Date: Wed, 27 Feb 2013 08:52:12 -0500
Message-ID: <512E0F8C.4030408@gmail.com>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com> <1361889376-22171-2-git-send-email-lee.roberts@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Lee A. Roberts" <lee.roberts@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f42.google.com ([209.85.213.42]:62163 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759904Ab3B0NwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 08:52:16 -0500
Received: by mail-yh0-f42.google.com with SMTP id w49so59292yhw.29
        for <netdev@vger.kernel.org>; Wed, 27 Feb 2013 05:52:16 -0800 (PST)
In-Reply-To: <1361889376-22171-2-git-send-email-lee.roberts@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/2013 09:36 AM, Lee A. Roberts wrote:
> From: "Lee A. Roberts" <lee.roberts@hp.com>
>
> Resolve SCTP association hangs observed during SCTP stress
> testing.  Observable symptoms include communications hangs
> with data being held in the association lobby (ordering)
> queue.  Close examination of reassembly/ordering queues shows
> duplicated packets.
>
> In sctp_tsnmap_mark(), correct off-by-one error when calculating
> size value for sctp_tsnmap_grow().
>
> In sctp_tsnmap_grow(), correct off-by-one error when copying
> and resizing the tsnmap.  If max_tsn_seen is in the LSB of the
> word, this bit can be lost, causing the corresponding packet
> to be transmitted again and to be entered as a duplicate into
> the SCTP reassembly/ordering queues.  Change parameter name
> from "gap" (zero-based index) to "size" (one-based) to enhance
> code readability.
>
> Signed-off-by: Lee A. Roberts <lee.roberts@hp.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>   net/sctp/tsnmap.c |   13 +++++++------
>   1 file changed, 7 insertions(+), 6 deletions(-)
>
> diff --git a/net/sctp/tsnmap.c b/net/sctp/tsnmap.c
> index 5f25e0c..396c451 100644
> --- a/net/sctp/tsnmap.c
> +++ b/net/sctp/tsnmap.c
> @@ -51,7 +51,7 @@
>   static void sctp_tsnmap_update(struct sctp_tsnmap *map);
>   static void sctp_tsnmap_find_gap_ack(unsigned long *map, __u16 off,
>   				     __u16 len, __u16 *start, __u16 *end);
> -static int sctp_tsnmap_grow(struct sctp_tsnmap *map, u16 gap);
> +static int sctp_tsnmap_grow(struct sctp_tsnmap *map, u16 size);
>
>   /* Initialize a block of memory as a tsnmap.  */
>   struct sctp_tsnmap *sctp_tsnmap_init(struct sctp_tsnmap *map, __u16 len,
> @@ -124,7 +124,7 @@ int sctp_tsnmap_mark(struct sctp_tsnmap *map, __u32 tsn,
>
>   	gap = tsn - map->base_tsn;
>
> -	if (gap >= map->len && !sctp_tsnmap_grow(map, gap))
> +	if (gap >= map->len && !sctp_tsnmap_grow(map, gap + 1))
>   		return -ENOMEM;
>
>   	if (!sctp_tsnmap_has_gap(map) && gap == 0) {
> @@ -360,23 +360,24 @@ __u16 sctp_tsnmap_num_gabs(struct sctp_tsnmap *map,
>   	return ngaps;
>   }
>
> -static int sctp_tsnmap_grow(struct sctp_tsnmap *map, u16 gap)
> +static int sctp_tsnmap_grow(struct sctp_tsnmap *map, u16 size)
>   {
>   	unsigned long *new;
>   	unsigned long inc;
>   	u16  len;
>
> -	if (gap >= SCTP_TSN_MAP_SIZE)
> +	if (size > SCTP_TSN_MAP_SIZE)
>   		return 0;
>
> -	inc = ALIGN((gap - map->len),BITS_PER_LONG) + SCTP_TSN_MAP_INCREMENT;
> +	inc = ALIGN((size - map->len), BITS_PER_LONG) + SCTP_TSN_MAP_INCREMENT;
>   	len = min_t(u16, map->len + inc, SCTP_TSN_MAP_SIZE);
>
>   	new = kzalloc(len>>3, GFP_ATOMIC);
>   	if (!new)
>   		return 0;
>
> -	bitmap_copy(new, map->tsn_map, map->max_tsn_seen - map->base_tsn);
> +	bitmap_copy(new, map->tsn_map,
> +		map->max_tsn_seen - map->cumulative_tsn_ack_point);
>   	kfree(map->tsn_map);
>   	map->tsn_map = new;
>   	map->len = len;
>
