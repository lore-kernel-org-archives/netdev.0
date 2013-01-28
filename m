From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Patch net-next] pktgen: support net namespace
Date: Sun, 27 Jan 2013 22:52:48 -0800
Message-ID: <87d2wpyf27.fsf@xmission.com>
References: <1359354775-28344-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:34734 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571Ab3A1Gw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 01:52:59 -0500
In-Reply-To: <1359354775-28344-1-git-send-email-amwang@redhat.com> (Cong
	Wang's message of "Mon, 28 Jan 2013 14:32:55 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> writes:

> From: Cong Wang <amwang@redhat.com>
>
> This patch add net namespace to pktgen, so that
> we can use pktgen in different namespaces.

Skimming through this looks like a reasonable patch.

I am not a fan of the number of threads, but that has nothing to do with
correctness, and would certainly require a large change in logic to keep
the number of threads down, which might not be a good idea.


One small nit below.

Eric


> @@ -3592,49 +3607,78 @@ static int pktgen_remove_device(struct pktgen_thread *t,
>  	return 0;
>  }
>  
> -static int __init pg_init(void)
> +static int __net_init pg_net_init(struct net *net)
>  {
> -	int cpu;
> -	struct proc_dir_entry *pe;
> -	int ret = 0;
> -
> -	pr_info("%s", version);
> +	struct pktgen_net *pn = net_generic(net, pg_net_id);
> +	int cpu, ret = 0;
>  
> -	pg_proc_dir = proc_mkdir(PG_PROC_DIR, init_net.proc_net);
> -	if (!pg_proc_dir)
> -		return -ENODEV;
> +	pn->net = net;
> +	if (!pn->proc_dir) {
        ^^^^^^^^^^^^^^^^^^^^

This test is pointless.  pn->proc_dir is allocated with kzalloc so it
will be initially NULL and pg_net_init will be called exactly once
per network namespace so pn->proc_dir will always be NULL here. 

> +		struct proc_dir_entry *pe;
> +		pn->proc_dir = proc_mkdir(PG_PROC_DIR, pn->net->proc_net);
> +		if (!pn->proc_dir) {
> +			pr_warn("cannot create /proc/net/%s\n", PG_PROC_DIR);
> +			return -ENODEV;
> +		}
> +		pe = proc_create(PGCTRL, 0600, pn->proc_dir, &pktgen_fops);
> +		if (pe == NULL) {
> +			pr_err("cannot create %s procfs entry\n", PGCTRL);
> +			ret = -EINVAL;
> +			goto remove;
> +		}
>  
> -	pe = proc_create(PGCTRL, 0600, pg_proc_dir, &pktgen_fops);
> -	if (pe == NULL) {
> -		pr_err("ERROR: cannot create %s procfs entry\n", PGCTRL);
> -		ret = -EINVAL;
> -		goto remove_dir;
>  	}
>  
> -	register_netdevice_notifier(&pktgen_notifier_block);
> -
>  	for_each_online_cpu(cpu) {
>  		int err;
>  
> -		err = pktgen_create_thread(cpu);
> +		err = pktgen_create_thread(cpu, pn);
>  		if (err)
> -			pr_warning("WARNING: Cannot create thread for cpu %d (%d)\n",
> +			pr_warn("Cannot create thread for cpu %d (%d)\n",
>  				   cpu, err);
>  	}
>  
>  	if (list_empty(&pktgen_threads)) {
> -		pr_err("ERROR: Initialization failed for all threads\n");
> +		pr_err("Initialization failed for all threads\n");
>  		ret = -ENODEV;
> -		goto unregister;
> +		goto remove_entry;
>  	}
>  
>  	return 0;
>  
> - unregister:
> -	unregister_netdevice_notifier(&pktgen_notifier_block);
> -	remove_proc_entry(PGCTRL, pg_proc_dir);
> - remove_dir:
> -	proc_net_remove(&init_net, PG_PROC_DIR);
> +remove_entry:
> +	remove_proc_entry(PGCTRL, pn->proc_dir);
> +remove:
> +	proc_net_remove(pn->net, PG_PROC_DIR);
> +	return ret;
> +}
