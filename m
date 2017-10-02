From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] net: core: decouple ifalias get/set from
 rtnl lock
Date: Mon, 02 Oct 2017 07:53:49 -0700
Message-ID: <1506956029.8061.8.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171002102745.3047-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:37831 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751856AbdJBOxw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 10:53:52 -0400
Received: by mail-pg0-f65.google.com with SMTP id o1so5057608pga.4
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 07:53:52 -0700 (PDT)
In-Reply-To: <20171002102745.3047-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-10-02 at 12:27 +0200, Florian Westphal wrote:
> Device alias can be set by either rtnetlink (rtnl is held) or sysfs.
> 
> rtnetlink hold the rtnl mutex, sysfs acquires it for this purpose.
> Add an extra mutex for it plus a seqcount to get a consistent snapshot
> of the alias buffer.


> +int dev_get_alias(const struct net_device *dev, char *alias, size_t len)
> +{
> +	unsigned int seq;
> +	int ret;
> +
> +	for (;;) {
> +		const char *name;
> +
> +		ret = 0;
> +		rcu_read_lock();
> +		name = rcu_dereference(dev->ifalias);
> +		seq = raw_seqcount_begin(&ifalias_rename_seq);
> +		if (name)
> +			ret = snprintf(alias, len, "%s", name);
> +		rcu_read_unlock();
> +
> +		if (!read_seqcount_retry(&ifalias_rename_seq, seq))
> +			break;
> +
> +		cond_resched();
> +	}
> +
> +	return ret;
> +}

I believe this too complex and not needed.

Just use RCU : A writer is supposed to work on a private copy, and
_then_ publish the new pointer, so that a reader can not see mangled
string.

We either copy the 'old' name or the 'new' one.

A seqcount is not needed, and wont prevent you from reading the value
right before a change anyway.
