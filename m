From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v4 for-next 05/12] IB/cm: Share listening CM IDs
Date: Tue, 19 May 2015 12:35:45 -0600
Message-ID: <20150519183545.GH18675@obsidianresearch.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
 <1431841868-28063-6-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:48499 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755411AbbESSfs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 14:35:48 -0400
Content-Disposition: inline
In-Reply-To: <1431841868-28063-6-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 17, 2015 at 08:51:01AM +0300, Haggai Eran wrote:
> @@ -212,6 +212,8 @@ struct cm_id_private {
>  	spinlock_t lock;	/* Do not acquire inside cm.lock */
>  	struct completion comp;
>  	atomic_t refcount;
> +	/* Number of clients sharing this ib_cm_id. Only valid for listeners. */
> +	atomic_t sharecount;

No need for this atomic, hold the lock

The use of the atomic looks racy:

> +	if (!atomic_dec_and_test(&cm_id_priv->sharecount)) {
> +		/* The id is still shared. */
> +		return;
> +	}

Might race with this:

> +		if (atomic_inc_return(&cm_id_priv->sharecount) == 1) {
> +			/* This ID is already being destroyed */
> +			atomic_dec(&cm_id_priv->sharecount);
> +			goto new_id;
> +		}
> +

Resulting in use-after-free of cm_id_priv->sharecount

Don't try and be clever with atomics, it is almost always wrong.

The share count should be 'listen_sharecount' because it *only* works
for listen.

The above test in cm_destroy_id should only be in the listen branch of
the if.

> + * Create a new listening ib_cm_id and listen on the given service ID.
> + *
> + * If there's an existing ID listening on that same device and service ID,
> + * return it.
> + *

.. Callers should call cm_destroy_id when done with the listen ..

Jason
