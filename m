From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH iproute2 v3] bridge: Add master device name to bridge
 fdb show
Date: Sun, 08 Jun 2014 07:24:38 -0400
Message-ID: <539447F6.9040906@mojatatu.com>
References: <1402205022-7083-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wkok@cumulusnetworks.com, sfeldma@cumulusnetworks.com,
	shm@cumulusnetworks.com, Vlad Yasevich <vyasevic@redhat.com>
To: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:46213 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753481AbaFHLYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jun 2014 07:24:48 -0400
Received: by mail-ie0-f170.google.com with SMTP id to1so4490518ieb.29
        for <netdev@vger.kernel.org>; Sun, 08 Jun 2014 04:24:47 -0700 (PDT)
In-Reply-To: <1402205022-7083-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


note: The "Self" addresses are derived from uni/multicast addresses of
the port i.e they are _not_ part of the fdb.
IMO, it is unfortunate that  the fdb command is being used for
dealing with device specific multicast/unicast address management
as is "ip link" - but the API is out there already.
Therefore they dont really belong to the fdb table and displaying
the master as the bridge maybe misleading.

For that reason, I like your earlier patch.
Vlad?

cheers,
jamal


On 06/08/14 01:23, roopa@cumulusnetworks.com wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch adds master dev name from NDA_MASTER netlink attribute
>   to bridge fdb show output
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
>
> For comparision with the above, below is the output for NTF_SELF today,
> # bridge fdb show
> 33:33:00:00:00:01 dev eth0 self permanent
> 01:00:5e:00:00:01 dev eth0 self permanent
> 33:33:ff:00:01:cc dev eth0 self permanent
>
> If change in output is a concern, 'master' can be put at the end of the fdb
> output line or made optional with -d[etails] option.
>
> change from v1 to v2:
>      use 'bridge' instead of 'master' in fdb show output
>
> change from v2 to v3:
>      use 'master' instead of 'bridge' in fdb show output
>      (master could also be a vxlan device)
>
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>   bridge/fdb.c              |    5 ++++-
>   include/linux/neighbour.h |    1 +
>   2 files changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/bridge/fdb.c b/bridge/fdb.c
> index 9b720e3..d1c3da6 100644
> --- a/bridge/fdb.c
> +++ b/bridge/fdb.c
> @@ -146,7 +146,10 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>   	}
>   	if (r->ndm_flags & NTF_SELF)
>   		fprintf(fp, "self ");
> -	if (r->ndm_flags & NTF_MASTER)
> +	if (tb[NDA_MASTER])
> +		fprintf(fp, "master %s ",
> +			ll_index_to_name(rta_getattr_u32(tb[NDA_MASTER])));
> +	else if (r->ndm_flags & NTF_MASTER)
>   		fprintf(fp, "master ");
>   	if (r->ndm_flags & NTF_ROUTER)
>   		fprintf(fp, "router ");
> diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
> index d3ef583..4a1d7e9 100644
> --- a/include/linux/neighbour.h
> +++ b/include/linux/neighbour.h
> @@ -24,6 +24,7 @@ enum {
>   	NDA_PORT,
>   	NDA_VNI,
>   	NDA_IFINDEX,
> +	NDA_MASTER,
>   	__NDA_MAX
>   };
>
>
