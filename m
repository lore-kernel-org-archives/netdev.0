From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 3/3] RDS: make sure not to loop forever inside
 rds_send_xmit
Date: Tue, 07 Apr 2015 17:26:07 -0400 (EDT)
Message-ID: <20150407.172607.869971800253661690.davem@davemloft.net>
References: <cover.1428437150.git.sowmini.varadhan@oracle.com>
	<cover.1428437150.git.sowmini.varadhan@oracle.com>
	<a757317ae49acd938022254b5b0d899262d56008.1428437150.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chien.yen@oracle.com, rds-devel@oss.oracle.com, agrover@redhat.com,
	clm@fb.com, zab@zabbo.net, ajaykumar.hotchandani@oracle.com,
	sergei.shtylyov@cogentembedded.com
To: sowmini.varadhan@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a757317ae49acd938022254b5b0d899262d56008.1428437150.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue,  7 Apr 2015 16:38:04 -0400

> @@ -157,6 +160,17 @@ int rds_send_xmit(struct rds_connection *conn)
>  	}
>  
>  	/*
> +	 * we record the send generation after doing the xmit acquire.
> +	 * if someone else manages to jump in and do some work, we'll use
> +	 * this to avoid a goto restart farther down.
> +	 *
> +	 * we don't need a lock because the counter is only incremented
> +	 * while we have the in_xmit bit held.
> +	 */
> +	conn->c_send_gen++;
> +	send_gen = conn->c_send_gen;

This increment does need to either be changed to be an atomic_t
or covered by a lock.

Otherwise two concurrent callers can both try to increment it at
the same time, and it only effectively increments once.  That's
corrupted state and will break all of the new logic added here.

Still very unhappy with this patch series submission, as I still find
new problems every time I look at these changes.  Are you evaluating
them and double checking all of the claims in the commit log message
and comments, and logic in these, or are you just passing them off
upstream after testing and leaving the checking to people like me?
