From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: Re: possible integer underflow in __sctp_auth_cid()
Date: Mon, 2 Jul 2012 13:06:37 +0800
Message-ID: <CAPgLHd_irof=D+R=HfqQR1Yo4MxvRP7S4WWHCyV65-QpYJziBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: vyasevich@gmail.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:45847 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157Ab2GBFGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 01:06:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/30/2012 08:17 PM, Dan Carpenter wrote:
> In 555d3d5d "SCTP: Fix chunk acceptance when no authenticated chunks
> were listed.", we added a check for if (param->param_hdr.length == 0).
> Shouldn't that check be a check for if
> (param->param_hdr.length < sizeos(sizeof(sctp_paramhdr_t)))?  Otherwise,
> when we do the substraction on the next line we would unintentionally
> end up with a high positive number.
>
> I had a similar question about sctp_auth_ep_add_chunkid():
>
> net/sctp/auth.c
>    770          /* Check if we can add this chunk to the array */
>    771          param_len = ntohs(p->param_hdr.length);
>    772          nchunks = param_len - sizeof(sctp_paramhdr_t);
>    773          if (nchunks == SCTP_NUM_CHUNK_TYPES)
>    774                  return -EINVAL;
>    775
>    776          p->chunks[nchunks] = chunk_id;
>
> If param_len is less than sizeof(sctp_paramhdr_t) we could write past
> the end of the array.  There are a couple other places with this same
> subtraction as well.


This will not happen because that p which means ep->auth_chunk_list
is maintained by the endpoint itself, and the default value is
sizeof(sctp_paramhdr_t) or sizeof(sctp_paramhdr_t) + 2.

Instead, I found that if user enable AUTH after the endpoint is
created, set the AUTH chunk may cause panic, because the
ep->auth_chunk_list is NULL.

I think we should introduce a help function to check whether the
AUTH is enabled instead only check sctp_auth_enable, may like:

bool sctp_auth_ep_enabled(struct sctp_endpoint *ep)
{
	if (!sctp_auth_enable)
		return false;

	if (!ep->auth_chunk_list || !ep->auth_hmacs_list)
		return false;

	return true;
}


Regards
Yongjun Wei

>
> regards,
> dan carpenter
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
