From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 03/16] net: Basic network namespace infrastructure.
Date: Mon, 10 Sep 2007 11:16:44 +0530
Message-ID: <OF55551EA4.A3E6920C-ON65257352.001D6A3E-65257352.001FBEA7@in.ibm.com>
References: <m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Linux Containers <containers@lists.osdl.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP02.au.ibm.com ([202.81.18.163]:36308 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755346AbXIJFqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 01:46:10 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8A5k8t6018782
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 15:46:08 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8A5nfix032812
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 15:49:41 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8A5k6CJ011141
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 15:46:07 +1000
In-Reply-To: <m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote on 09/09/2007 02:45:34 AM:

Hi Eric,

> +static int register_pernet_operations(struct list_head *list,
> +                  struct pernet_operations *ops)
> +{
> <snip>
> +out:
> +   return error;
> +
> +out_undo:
> +   /* If I have an error cleanup all namespaces I initialized */
> +   list_del(&ops->list);
> +   for_each_net(undo_net) {
> +      if (undo_net == net)
> +         goto undone;
> +      if (ops->exit)
> +         ops->exit(undo_net);
> +   }
> +undone:
> +   goto out;
> +}

You could remove "undone" label (and associated) goto with a "break".

> +static void unregister_pernet_operations(struct pernet_operations *ops)
> +{
> +   struct net *net;
> +
> +   list_del(&ops->list);
> +   for_each_net(net)
> +      if (ops->exit)
> +         ops->exit(net);
> +}
> +
> +/**
> + *      register_pernet_subsys - register a network namespace subsystem
> + *   @ops:  pernet operations structure for the subsystem
> + *
> + *   Register a subsystem which has init and exit functions
> + *   that are called when network namespaces are created and
> + *   destroyed respectively.
> + *
> + *   When registered all network namespace init functions are
> + *   called for every existing network namespace.  Allowing kernel
> + *   modules to have a race free view of the set of network namespaces.
> + *
> + *   When a new network namespace is created all of the init
> + *   methods are called in the order in which they were registered.
> + *
> + *   When a network namespace is destroyed all of the exit methods
> + *   are called in the reverse of the order with which they were
> + *   registered.
> + */
<snip>
> +/**
> + *      unregister_pernet_subsys - unregister a network namespace
subsystem
> + *   @ops: pernet operations structure to manipulate
> + *
> + *   Remove the pernet operations structure from the list to be
> + *   used when network namespaces are created or destoryed.  In
> + *   addition run the exit method for all existing network
> + *   namespaces.
> + */
> +void unregister_pernet_subsys(struct pernet_operations *module)
> +{
> +   mutex_lock(&net_mutex);
> +   unregister_pernet_operations(module);
> +   mutex_unlock(&net_mutex);
> +}

Don't you require something like for_each_net_backwards to 'exit' in
reverse order? Same comment for unregister_subnet_subsys(). Should this
be done for failure in register_pernet_operations too?

thanks,

- KK

