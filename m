From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC] ipv4 neigh: match add/del dev lookup behaviour
 to SIOCSARP/SIOCDARP
Date: Tue, 24 Feb 2015 06:35:15 -0800
Message-ID: <54EC8C23.5060204@cumulusnetworks.com>
References: <1424756572-29379-1-git-send-email-roopa@cumulusnetworks.com> <9B0331B6EBBD0E4684FBFAEDA55776F9189654A5@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "hadi@mojatatu.com" <hadi@mojatatu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>
To: "Rosen, Rami" <rami.rosen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:42912 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752321AbbBXOfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 09:35:18 -0500
Received: by pdbfp1 with SMTP id fp1so33710556pdb.9
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 06:35:17 -0800 (PST)
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F9189654A5@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/24/15, 6:01 AM, Rosen, Rami wrote:
> Hi,
>
> @@ -1692,24 +1703,31 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh)
>   		goto out;
>   
>   	ndm = nlmsg_data(nlh);
> +	tbl = neigh_find_table(ndm->ndm_family);
> +	if (tbl == NULL)
> +		return -EAFNOSUPPORT;
> +
> +	if (nla_len(tb[NDA_DST]) < tbl->key_len)
> +		goto out;
> +
> +	dst = nla_data(tb[NDA_DST]);
>   	if (ndm->ndm_ifindex) {
>   		dev = __dev_get_by_index(net, ndm->ndm_ifindex);
>   		if (dev == NULL) {
>   			err = -ENODEV;
>   			goto out;
>   		}
>
> If ip_route_output() fails, then the neigh_add() method will return -EINVAL (as it was initialized thus);
I was intentionally trying not to return any special error code if 
ip_route_output() fails. So the patch tries to make the ip_route_output 
failure same as the case where the user did not specify a device.

> or, in cases when the NTF_PROXY flag is set, it can return 0 or ENOBUFS, according to the result of the pneigh_lookup(), which is called immediately subsequently in this path. But in fact __ip_route_output_key(), which is invoked by ip_route_output(), can return different error codes, like -EINVAL,-ENODEV, -ENETUNREACH and more, via ERR_PTR.
>
>   So maybe better is (in order to reflect the cause of the error):
> +		if (!IS_ERR(rt)) {
> +			dev = rt->dst.dev;
> +			ip_rt_put(rt);
> +		} else
>                                                 return PTR_ERR(rt);

I intentionally don't return here ..because from the original code, the 
NTF_PROXY case seemed to be ok with the device being NULL.  The device 
NULL check was after the NTF_PROXY code.

>
> We can exit the method at this point with "return PTR_ERR(rt)" because we are assured at this point that dev is NULL.
>
> Error handling in neigh_delete() method maybe also be better changed accordingly.

I intend to do some testing for the NTF_PROXY case, however, AFAICT, 
this patch should not have introduced any functional changes in that path.

Thanks!.
