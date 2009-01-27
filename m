From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 06/21] RDS: Connection handling
Date: Tue, 27 Jan 2009 16:34:19 +0300
Message-ID: <20090127133418.GH2646@ioremap.net>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com> <1233022678-9259-7-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.ru ([195.178.208.66]:40865 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753723AbZA0NeU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 08:34:20 -0500
Content-Disposition: inline
In-Reply-To: <1233022678-9259-7-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 26, 2009 at 06:17:43PM -0800, Andy Grover (andy.grover@oracle.com) wrote:
> +static inline int rds_conn_is_sending(struct rds_connection *conn)
> +{
> +	int ret = 0;
> +
> +	if (!mutex_trylock(&conn->c_send_lock))
> +		ret = 1;
> +	else
> +		mutex_unlock(&conn->c_send_lock);
> +
> +	return ret;
> +}
> +

This one is eventually invoked under the spin_lock with turned off irqs,
which may freeze the machine:
rds_for_each_conn_info() -> spin_lock_irqsave(global lock) ->
rds_conn_info_visitor() -> rds_conn_info_set() -> rds_conn_is_sending()
-> boom.

I did not not check further though.

-- 
	Evgeniy Polyakov
