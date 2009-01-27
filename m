From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 05/21] RDS: Info and stats
Date: Tue, 27 Jan 2009 16:28:00 +0300
Message-ID: <20090127132759.GG2646@ioremap.net>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com> <1233022678-9259-6-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:34337 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753061AbZA0N2B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 08:28:01 -0500
Content-Disposition: inline
In-Reply-To: <1233022678-9259-6-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 26, 2009 at 06:17:42PM -0800, Andy Grover (andy.grover@oracle.com) wrote:
> +void rds_info_register_func(int optname, rds_info_func func)
> +{
> +	int offset = optname - RDS_INFO_FIRST;
> +
> +	BUG_ON(optname < RDS_INFO_FIRST || optname > RDS_INFO_LAST);
> +
> +	spin_lock(&rds_info_lock);
> +	BUG_ON(rds_info_funcs[offset] != NULL);
> +	rds_info_funcs[offset] = func;
> +	spin_unlock(&rds_info_lock);
> +}
> +EXPORT_SYMBOL_GPL(rds_info_register_func);
> +
> +void rds_info_deregister_func(int optname, rds_info_func func)
> +{
> +	int offset = optname - RDS_INFO_FIRST;
> +
> +	BUG_ON(optname < RDS_INFO_FIRST || optname > RDS_INFO_LAST);
> +

Those bug_ons look quite scary, is there a way to actually have a wrong
optname? Plus, those _INFO definitions are declared twice in the code,
which makes it harder to update.

> +/*
> + * Typically we hold an atomic kmap across multiple rds_info_copy() calls
> + * because the kmap is so expensive.  This must be called before using blocking
> + * operations while holding the mapping and as the iterator is torn down.
> + */
> +void rds_info_iter_unmap(struct rds_info_iterator *iter)
> +{
> +	if (iter->addr != NULL) {
> +		kunmap_atomic(iter->addr, KM_USER0);
> +		iter->addr = NULL;
> +	}
> +}
> +

This one is used to temporarily map some address, but functions called
between map and unmap functions (like rds_info_getsockopt()) may sleep,
which is wrong.

-- 
	Evgeniy Polyakov
