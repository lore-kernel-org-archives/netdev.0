From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: possible integer underflow in __sctp_auth_cid()
Date: Sat, 30 Jun 2012 15:17:48 +0300
Message-ID: <20120630121748.GD22767@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:29581 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754249Ab2F3MR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 08:17:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In 555d3d5d "SCTP: Fix chunk acceptance when no authenticated chunks
were listed.", we added a check for if (param->param_hdr.length == 0).
Shouldn't that check be a check for if
(param->param_hdr.length < sizeos(sizeof(sctp_paramhdr_t)))?  Otherwise,
when we do the substraction on the next line we would unintentionally
end up with a high positive number.

I had a similar question about sctp_auth_ep_add_chunkid():

net/sctp/auth.c
   770          /* Check if we can add this chunk to the array */
   771          param_len = ntohs(p->param_hdr.length);
   772          nchunks = param_len - sizeof(sctp_paramhdr_t);
   773          if (nchunks == SCTP_NUM_CHUNK_TYPES)
   774                  return -EINVAL;
   775
   776          p->chunks[nchunks] = chunk_id;

If param_len is less than sizeof(sctp_paramhdr_t) we could write past
the end of the array.  There are a couple other places with this same
subtraction as well.

regards,
dan carpenter
