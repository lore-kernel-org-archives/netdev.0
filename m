From: Patrick McHardy <kaber@trash.net>
Subject: Re: Oops in nf_nat_core.c:find_appropriate_src(), kernel 2.6.25.4
Date: Tue, 10 Jun 2008 16:00:29 +0200
Message-ID: <484E88FD.3000908@trash.net>
References: <484A9E75.8000601@redhat.com> <484AA276.9090407@trash.net> <484AA5D5.10404@trash.net> <Pine.LNX.4.64.0806071742180.13503@bizon.gios.gov.pl> <484E4343.5090606@trash.net> <Pine.LNX.4.64.0806101545460.12641@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chuck Ebbert <cebbert@redhat.com>, Netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Krzysztof Oledzki <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41175 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753887AbYFJOAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 10:00:31 -0400
In-Reply-To: <Pine.LNX.4.64.0806101545460.12641@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Oledzki wrote:
> On Tue, 10 Jun 2008, Patrick McHardy wrote:
> 
>> We found the reason for that crash and I've queued these two
>> patches. Please let me know whether they also fix the problem
>> from the redhat bugzilla.
> 
> There is a one thing that still bugs me. This patch removes setting the 
> nat->ct pointer to NULL:
> 
> --- a/net/ipv4/netfilter/nf_nat_core.c
> +++ b/net/ipv4/netfilter/nf_nat_core.c
> @@ -556,7 +556,6 @@ static void nf_nat_cleanup_conntrack(struct nf_conn 
> *ct)
> 
>         spin_lock_bh(&nf_nat_lock);
>         hlist_del_rcu(&nat->bysource);
> -       nat->ct = NULL;
>         spin_unlock_bh(&nf_nat_lock);
>  }
> 
> After this patch the whole function looks like this:
> 
> /* Noone using conntrack by the time this called. */
> static void nf_nat_cleanup_conntrack(struct nf_conn *ct)
> {
>         struct nf_conn_nat *nat = nf_ct_ext_find(ct, NF_CT_EXT_NAT);
> 
>         if (nat == NULL || nat->ct == NULL)
>                 return;
> 
>         NF_CT_ASSERT(nat->ct->status & IPS_NAT_DONE_MASK);
> 
>         spin_lock_bh(&nf_nat_lock);
>         hlist_del_rcu(&nat->bysource);
>         spin_unlock_bh(&nf_nat_lock);
> }
> 
> As you can see we still check if nat->ct is NULL here. So, or the check 
> is now unnecessary, or it is still possible that nat->ct may become 
> NULL. If the second statement is true than we may need to check ct 
> before calling same_src in the find_appropriate_src function.

No, the nf_nat_cleanup_nat function can be called for a NAT extension
that isn't in the hash yet (and thus has nat->ct == NULL) when the
nf_conntrack_alter_reply() call in nf_nat_setup_info() allocates a
helper extension and need to realloc the NAT extension space.

