From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH] igmp: make /proc/net/{igmp,mcfilter} per netns
Date: Mon, 08 Sep 2008 11:35:02 +0200
Message-ID: <48C4F1C6.6080605@fr.ibm.com>
References: <20080908012855.GC575@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:41161 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975AbYIHJfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 05:35:38 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id m889ZH8J285808
	for <netdev@vger.kernel.org>; Mon, 8 Sep 2008 09:35:17 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m889ZEAN2052340
	for <netdev@vger.kernel.org>; Mon, 8 Sep 2008 11:35:14 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m889Z8SU019565
	for <netdev@vger.kernel.org>; Mon, 8 Sep 2008 11:35:10 +0200
In-Reply-To: <20080908012855.GC575@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

I have exactly the same patch to be submitted :)

Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>

By the way, you are posting patches related to netns. As some of us are 
working in this area too, do you mind to sync with us for the network 
items you want to handle to avoid duplicate work ?

We are currently working on mroute[6].

Thanks.
   -- Daniel

> ---
> 
>  net/ipv4/igmp.c |   49 ++++++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 40 insertions(+), 9 deletions(-)
> 
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
> @@ -2272,6 +2272,7 @@ int ip_check_mc(struct in_device *in_dev, __be32 mc_addr, __be32 src_addr, u16 p
>  
>  #if defined(CONFIG_PROC_FS)
>  struct igmp_mc_iter_state {
> +	struct seq_net_private p;
>  	struct net_device *dev;
>  	struct in_device *in_dev;
>  };
> @@ -2280,11 +2281,12 @@ struct igmp_mc_iter_state {
>  
>  static inline struct ip_mc_list *igmp_mc_get_first(struct seq_file *seq)
>  {
> +	struct net *net = seq_file_net(seq);
>  	struct ip_mc_list *im = NULL;
>  	struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);
>  
>  	state->in_dev = NULL;
> -	for_each_netdev(&init_net, state->dev) {
> +	for_each_netdev(net, state->dev) {
>  		struct in_device *in_dev;
>  		in_dev = in_dev_get(state->dev);
>  		if (!in_dev)
> @@ -2405,7 +2407,7 @@ static const struct seq_operations igmp_mc_seq_ops = {
>  
>  static int igmp_mc_seq_open(struct inode *inode, struct file *file)
>  {
> -	return seq_open_private(file, &igmp_mc_seq_ops,
> +	return seq_open_net(inode, file, &igmp_mc_seq_ops,
>  			sizeof(struct igmp_mc_iter_state));
>  }
>  
> @@ -2414,10 +2416,11 @@ static const struct file_operations igmp_mc_seq_fops = {
>  	.open		=	igmp_mc_seq_open,
>  	.read		=	seq_read,
>  	.llseek		=	seq_lseek,
> -	.release	=	seq_release_private,
> +	.release	=	seq_release_net,
>  };
>  
>  struct igmp_mcf_iter_state {
> +	struct seq_net_private p;
>  	struct net_device *dev;
>  	struct in_device *idev;
>  	struct ip_mc_list *im;
> @@ -2427,13 +2430,14 @@ struct igmp_mcf_iter_state {
>  
>  static inline struct ip_sf_list *igmp_mcf_get_first(struct seq_file *seq)
>  {
> +	struct net *net = seq_file_net(seq);
>  	struct ip_sf_list *psf = NULL;
>  	struct ip_mc_list *im = NULL;
>  	struct igmp_mcf_iter_state *state = igmp_mcf_seq_private(seq);
>  
>  	state->idev = NULL;
>  	state->im = NULL;
> -	for_each_netdev(&init_net, state->dev) {
> +	for_each_netdev(net, state->dev) {
>  		struct in_device *idev;
>  		idev = in_dev_get(state->dev);
>  		if (unlikely(idev == NULL))
> @@ -2564,7 +2568,7 @@ static const struct seq_operations igmp_mcf_seq_ops = {
>  
>  static int igmp_mcf_seq_open(struct inode *inode, struct file *file)
>  {
> -	return seq_open_private(file, &igmp_mcf_seq_ops,
> +	return seq_open_net(inode, file, &igmp_mcf_seq_ops,
>  			sizeof(struct igmp_mcf_iter_state));
>  }
>  
> @@ -2573,14 +2577,41 @@ static const struct file_operations igmp_mcf_seq_fops = {
>  	.open		=	igmp_mcf_seq_open,
>  	.read		=	seq_read,
>  	.llseek		=	seq_lseek,
> -	.release	=	seq_release_private,
> +	.release	=	seq_release_net,
>  };
>  
> -int __init igmp_mc_proc_init(void)
> +static int igmp_net_init(struct net *net)
>  {
> -	proc_net_fops_create(&init_net, "igmp", S_IRUGO, &igmp_mc_seq_fops);
> -	proc_net_fops_create(&init_net, "mcfilter", S_IRUGO, &igmp_mcf_seq_fops);
> +	struct proc_dir_entry *pde;
> +
> +	pde = proc_net_fops_create(net, "igmp", S_IRUGO, &igmp_mc_seq_fops);
> +	if (!pde)
> +		goto out_igmp;
> +	pde = proc_net_fops_create(net, "mcfilter", S_IRUGO, &igmp_mcf_seq_fops);
> +	if (!pde)
> +		goto out_mcfilter;
>  	return 0;
> +
> +out_mcfilter:
> +	proc_net_remove(net, "igmp");
> +out_igmp:
> +	return -ENOMEM;
> +}
> +
> +static void igmp_net_exit(struct net *net)
> +{
> +	proc_net_remove(net, "mcfilter");
> +	proc_net_remove(net, "igmp");
> +}
> +
> +static struct pernet_operations igmp_net_ops = {
> +	.init = igmp_net_init,
> +	.exit = igmp_net_exit,
> +};
> +
> +int __init igmp_mc_proc_init(void)
> +{
> +	return register_pernet_subsys(&igmp_net_ops);
>  }
>  #endif

