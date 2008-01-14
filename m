From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH] s2io LRO bugs
Date: Mon, 14 Jan 2008 16:33:03 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7702D4F61F@nekter>
References: <20071224061435.GT8181@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Al Viro" <viro@ftp.linux.org.uk>, <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:10753 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755571AbYANVeW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 16:34:22 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071224061435.GT8181@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al,
Thanks for finding this. We have a few patches lined up and will submit
this patch.

Ram

> -----Original Message-----
> From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Al Viro
> Sent: Sunday, December 23, 2007 10:15 PM
> To: jgarzik@pobox.com
> Cc: netdev@vger.kernel.org; Ravinandan.Arakali@neterion.com
> Subject: [PATCH] s2io LRO bugs
> 
> a) initiate_new_session() sets ->tcp_ack to ntohl(...); everything
>    else stores and expects to find there the net-endian value.
> b) check for monotonic timestamps in verify_l3_l4_lro_capable()
>    compares the value sitting in TCP option (right there in the
skb->data,
>    net-endian 32bit) with the value picked from earlier packet.
>    Doing that without ntohl() is an interesting idea and it might even
>    work occasionally; unfortunately, it's quite broken.
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
>  drivers/net/s2io.c |   20 ++++++++++----------
>  drivers/net/s2io.h |    2 +-
>  2 files changed, 11 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> index 9d80f1c..aef0875 100644
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -7898,7 +7898,7 @@ static void initiate_new_session(struct lro
*lro, u8
> *l2h,
>  	lro->iph = ip;
>  	lro->tcph = tcp;
>  	lro->tcp_next_seq = tcp_pyld_len + ntohl(tcp->seq);
> -	lro->tcp_ack = ntohl(tcp->ack_seq);
> +	lro->tcp_ack = tcp->ack_seq;
>  	lro->sg_num = 1;
>  	lro->total_len = ntohs(ip->tot_len);
>  	lro->frags_len = 0;
> @@ -7907,10 +7907,10 @@ static void initiate_new_session(struct lro
*lro,
> u8 *l2h,
>  	 * already been done.
>   	 */
>  	if (tcp->doff == 8) {
> -		u32 *ptr;
> -		ptr = (u32 *)(tcp+1);
> +		__be32 *ptr;
> +		ptr = (__be32 *)(tcp+1);
>  		lro->saw_ts = 1;
> -		lro->cur_tsval = *(ptr+1);
> +		lro->cur_tsval = ntohl(*(ptr+1));
>  		lro->cur_tsecr = *(ptr+2);
>  	}
>  	lro->in_use = 1;
> @@ -7936,7 +7936,7 @@ static void update_L3L4_header(struct s2io_nic
*sp,
> struct lro *lro)
> 
>  	/* Update tsecr field if this session has timestamps enabled */
>  	if (lro->saw_ts) {
> -		u32 *ptr = (u32 *)(tcp + 1);
> +		__be32 *ptr = (__be32 *)(tcp + 1);
>  		*(ptr+2) = lro->cur_tsecr;
>  	}
> 
> @@ -7961,10 +7961,10 @@ static void aggregate_new_rx(struct lro *lro,
> struct iphdr *ip,
>  	lro->window = tcp->window;
> 
>  	if (lro->saw_ts) {
> -		u32 *ptr;
> +		__be32 *ptr;
>  		/* Update tsecr and tsval from this packet */
> -		ptr = (u32 *) (tcp + 1);
> -		lro->cur_tsval = *(ptr + 1);
> +		ptr = (__be32 *) (tcp + 1);
> +		lro->cur_tsval = ntohl(*(ptr + 1));
>  		lro->cur_tsecr = *(ptr + 2);
>  	}
>  }
> @@ -8015,11 +8015,11 @@ static int verify_l3_l4_lro_capable(struct lro
> *l_lro, struct iphdr *ip,
> 
>  		/* Ensure timestamp value increases monotonically */
>  		if (l_lro)
> -			if (l_lro->cur_tsval > *((u32 *)(ptr+2)))
> +			if (l_lro->cur_tsval > ntohl(*((__be32
*)(ptr+2))))
>  				return -1;
> 
>  		/* timestamp echo reply should be non-zero */
> -		if (*((u32 *)(ptr+6)) == 0)
> +		if (*((__be32 *)(ptr+6)) == 0)
>  			return -1;
>  	}
> 
> diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
> index cc1797a..899d60c 100644
> --- a/drivers/net/s2io.h
> +++ b/drivers/net/s2io.h
> @@ -797,7 +797,7 @@ struct lro {
>  	int		in_use;
>  	__be16		window;
>  	u32		cur_tsval;
> -	u32		cur_tsecr;
> +	__be32		cur_tsecr;
>  	u8		saw_ts;
>  };
> 
> --
> 1.5.3.GIT
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
