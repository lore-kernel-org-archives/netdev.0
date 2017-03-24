From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf v3 1/1] netfilter: snmp: Fix one possible panic when
 snmp_trap_helper fail to register
Date: Fri, 24 Mar 2017 20:01:58 +0100
Message-ID: <20170324190158.GA3202@salvia>
References: <1490055749-52357-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jolsa@redhat.com,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58380 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932567AbdCXTCL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 15:02:11 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 287881EC2D1
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 20:02:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 0442CFB474
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 20:02:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 434C4FB476
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 20:02:02 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1490055749-52357-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 21, 2017 at 08:22:29AM +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> In the commit 93557f53e1fb ("netfilter: nf_conntrack: nf_conntrack snmp
> helper"), the snmp_helper is replaced by nf_nat_snmp_hook. So the
> snmp_helper is never registered. But it still tries to unregister the
> snmp_helper, it could cause the panic.
> 
> Now remove the useless snmp_helper and the unregister call in the
> error handler.
> 
> Fixes: 93557f53e1fb ("netfilter: nf_conntrack: nf_conntrack snmp helper")
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  v3: Remove the angle brackets in description, per Sergei
>  v2: Add the SHA1 ID in the description, per Sergei
>  v1: Initial version
> 
>  net/ipv4/netfilter/nf_nat_snmp_basic.c | 14 +-------------
>  1 file changed, 1 insertion(+), 13 deletions(-)
> 
> diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
> index c9b52c3..5787364 100644
> --- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
> +++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
> @@ -1260,16 +1260,6 @@ static int help(struct sk_buff *skb, unsigned int protoff,
>  	.timeout	= 180,
>  };
>  
> -static struct nf_conntrack_helper snmp_helper __read_mostly = {
> -	.me			= THIS_MODULE,
> -	.help			= help,
> -	.expect_policy		= &snmp_exp_policy,
> -	.name			= "snmp",
> -	.tuple.src.l3num	= AF_INET,
> -	.tuple.src.u.udp.port	= cpu_to_be16(SNMP_PORT),
> -	.tuple.dst.protonum	= IPPROTO_UDP,
> -};
> -
>  static struct nf_conntrack_helper snmp_trap_helper __read_mostly = {
>  	.me			= THIS_MODULE,
>  	.help			= help,
> @@ -1294,10 +1284,8 @@ static int __init nf_nat_snmp_basic_init(void)
>  	RCU_INIT_POINTER(nf_nat_snmp_hook, help);
>  
>  	ret = nf_conntrack_helper_register(&snmp_trap_helper);
> -	if (ret < 0) {
> -		nf_conntrack_helper_unregister(&snmp_helper);
> +	if (ret < 0)
>  		return ret;
> -	}
>  	return ret;

You can provide a more simplified version after this is removed, I
think:

@@ -1283,10 +1283,7 @@ static int __init nf_nat_snmp_basic_init(void)
        BUG_ON(nf_nat_snmp_hook != NULL);
        RCU_INIT_POINTER(nf_nat_snmp_hook, help);
 
-       ret = nf_conntrack_helper_register(&snmp_trap_helper);
-       if (ret < 0)
-               return ret;
-       return ret;
+       return nf_conntrack_helper_register(&snmp_trap_helper);
 }
