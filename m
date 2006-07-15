From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 3/7] NetLabel: CIPSOv4 engine
Date: Sat, 15 Jul 2006 09:15:40 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607150913510.24495@d.namei>
References: <20060714185739.780700000@flek.zko.hp.com>
 <20060714185915.270209000@flek.zko.hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, davem@davemloft.net,
	sds@epoch.ncsc.mil, jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:36524 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1161290AbWGONPp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jul 2006 09:15:45 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <20060714185915.270209000@flek.zko.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Jul 2006, paul.moore@hp.com wrote:

> +int cipso_v4_doi_add(struct cipso_v4_doi *doi_def)
> +{
> +	if (doi_def == NULL || doi_def->doi == CIPSO_V4_DOI_UNKNOWN)
> +		return -EINVAL;
> +
> +	doi_def->valid = 1;
> +	INIT_RCU_HEAD(&doi_def->rcu);
> +	INIT_LIST_HEAD(&doi_def->dom_list);
> +
> +	rcu_read_lock();
> +	if (cipso_v4_doi_search(doi_def->doi) != NULL) {
> +		rcu_read_unlock();
> +		return -EEXIST;
> +	}
> +	spin_lock(&cipso_v4_doi_list_lock);
> +	list_add_tail_rcu(&doi_def->list, &cipso_v4_doi_list);
> +	spin_unlock(&cipso_v4_doi_list_lock);
> +	rcu_read_unlock();
> +
> +	return 0;
> +}

This is racy in that you can end up with duplicate entries in the list 
between rcu_read_lock() and spin_lock().

You need to perform the search a second time under the spin_lock() as a 
slow path to verify that an entry wasn't added, before adding a new one.


- James
James Morris
<jmorris@namei.org>
