From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH iproute2] bridge: Add master device name to bridge fdb
 show
Date: Wed, 28 May 2014 16:00:17 -0400
Message-ID: <53864051.4070102@gmail.com>
References: <1401255611-30862-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, wkok@cumulusnetworks.com,
	sfeldma@cumulusnetworks.com, shm@cumulusnetworks.com
To: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:37819 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbaE1UAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 16:00:20 -0400
Received: by mail-qg0-f53.google.com with SMTP id f51so19303989qge.12
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 13:00:20 -0700 (PDT)
In-Reply-To: <1401255611-30862-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/2014 01:40 AM, roopa@cumulusnetworks.com wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> (This patch depends on net-next patch titled
> "Add bridge ifindex to bridge fdb notify msgs")
> 
> This patch adds master dev name from NDA_MASTER netlink attribute
>  to bridge fdb show output
> 
> current iproute2 tries to print 'master' in the output if NTF_MASTER
> is present. But, kernel today does not set NTF_MASTER during dump
> requests. Which means I have not seen iproute2 bridge cmd print 'master' atall.
> This patch overrides the NTF_MASTER flag if NDA_MASTER attribute is present.
> 
> Example output:
> 
> before this patch:
> # bridge fdb show
> 44:38:39:00:27:ba dev bond2.2003 permanent
> 44:38:39:00:27:bb dev bond4.2003 permanent
> 44:38:39:00:27:bc dev bond2.2004 permanent
> 
> After this patch:
> # bridge fdb show
> 44:38:39:00:27:ba dev bond2.2003 master br-2003 permanent
> 44:38:39:00:27:bb dev bond4.2003 master br-2003 permanent
> 44:38:39:00:27:bc dev bond2.2004 master br-2004 permanent

'master' is already a reserved word in the bridge command and
has a slightly different connotation. May be replace it with
'bridge' or something similar.

> 
> For comparision with the above, below is the output for NTF_SELF today,
> # bridge fdb show
> 33:33:00:00:00:01 dev eth0 self permanent
> 01:00:5e:00:00:01 dev eth0 self permanent
> 33:33:ff:00:01:cc dev eth0 self permanent
> 
> If change in output is a concern, 'master' can be put at the end of the fdb
> output line or made optional with -d[etails] option.

As Stephen always mentions, iproute commands have to be invertable.
In other words, what you get out of the show command you should
be able to feed back into a set command.

As such, it would probably be a good thing to support
bridge fdb set 44:38:39:00:27:ba dev bond2.2003 bridge br-2003 permanent

and I think this ends up being something very close to what
Jamal already proposed.

May be work together and come up with a single syntax.

-vlad


> 
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  bridge/fdb.c              |    5 ++++-
>  include/linux/neighbour.h |    1 +
>  2 files changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/bridge/fdb.c b/bridge/fdb.c
> index 9b720e3..d1c3da6 100644
> --- a/bridge/fdb.c
> +++ b/bridge/fdb.c
> @@ -146,7 +146,10 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>  	}
>  	if (r->ndm_flags & NTF_SELF)
>  		fprintf(fp, "self ");
> -	if (r->ndm_flags & NTF_MASTER)
> +	if (tb[NDA_MASTER])
> +		fprintf(fp, "master %s ",
> +			ll_index_to_name(rta_getattr_u32(tb[NDA_MASTER])));
> +	else if (r->ndm_flags & NTF_MASTER)
>  		fprintf(fp, "master ");
>  	if (r->ndm_flags & NTF_ROUTER)
>  		fprintf(fp, "router ");
> diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
> index d3ef583..4a1d7e9 100644
> --- a/include/linux/neighbour.h
> +++ b/include/linux/neighbour.h
> @@ -24,6 +24,7 @@ enum {
>  	NDA_PORT,
>  	NDA_VNI,
>  	NDA_IFINDEX,
> +	NDA_MASTER,
>  	__NDA_MAX
>  };
>  
> 
