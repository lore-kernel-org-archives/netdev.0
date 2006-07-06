From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] per-task delay accounting taskstats interface: control exit data through cpumasks]
Date: Fri, 7 Jul 2006 00:40:09 +0200
Message-ID: <20060706224009.GA14627@postel.suug.ch>
References: <44ACD7C3.5040008@watson.ibm.com> <20060706025633.cd4b1c1d.akpm@osdl.org> <1152185865.5986.15.camel@localhost.localdomain> <20060706120835.GY14627@postel.suug.ch> <20060706144808.1dd5fadf.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nagar@watson.ibm.com, jlan@sgi.com, pj@sgi.com,
	Valdis.Kletnieks@vt.edu, balbir@in.ibm.com, csturtiv@sgi.com,
	linux-kernel@vger.kernel.org, hadi@cyberus.ca,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:41363 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750976AbWGFWjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2006 18:39:48 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060706144808.1dd5fadf.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Andrew Morton <akpm@osdl.org> 2006-07-06 14:48
> In the interests of keeping this work decoupled from netlink enhancements
> I'd propose the below.  Is it bad to modify the data at nla_data()?

Yes, it points into a skb data buffer which may be shared by sitting
on other queues if the message is to be broadcasted. In this case it
would be harmless but the policy is to leave it unmodified. Otherwise
I agree it's better to move forward and not wait for the API change.

> --- a/kernel/taskstats.c~per-task-delay-accounting-taskstats-interface-control-exit-data-through-cpumasks-fix
> +++ a/kernel/taskstats.c
> @@ -299,6 +299,23 @@ cleanup:
>  	return 0;
>  }
>  
> +static int parse(struct nlattr *na, cpumask_t *mask)
> +{
> +	char *data;
> +	int len;
> +
> +	if (na == NULL)
> +		return 1;
> +	len = nla_len(na);
> +	if (len > TASKSTATS_CPUMASK_MAXLEN)
> +		return -E2BIG;
> +	if (len < 1)
> +		return -EINVAL;
> +	data = nla_data(na);
> +	data[len - 1] = '\0';
> +	return cpulist_parse(data, *mask);
> +}

Usually this is done by using strlcpy:

Example fro genetlink.c
if (info->attrs[CTRL_ATTR_FAMILY_NAME]) {
	char name[GENL_NAMSIZ];

	if (nla_strlcpy(name, info->attrs[CTRL_ATTR_FAMILY_NAME],
			GENL_NAMSIZ) >= GENL_NAMSIZ)
		goto errout;

	res = genl_family_find_byname(name);
}
