From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v4 2/2] vxlan: allow specifying multiple
 default destinations
Date: Mon, 24 Jun 2013 06:48:17 +0000 (UTC)
Message-ID: <kq8q3h$9lu$1@ger.gmane.org>
References: <1372004543-24675-1-git-send-email-mike.rapoport@ravellosystems.com>
 <1372004543-24675-3-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:53491 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751473Ab3FXGtF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 02:49:05 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Ur0Zm-0007b3-6N
	for netdev@vger.kernel.org; Mon, 24 Jun 2013 08:49:04 +0200
Received: from 60.160.82.190 ([60.160.82.190])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 08:48:34 +0200
Received: from xiyou.wangcong by 60.160.82.190 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 08:48:34 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Jun 2013 at 16:22 GMT, Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
>  static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
>  {
> +	int err;
> +
>  	if (tb[IFLA_ADDRESS]) {
>  		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN) {
>  			pr_debug("invalid link address (not ethernet)\n");
> @@ -1460,6 +1599,10 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
>  		}
>  	}
>  
> +	err = vxlan_validate_remotes(data[IFLA_VXLAN_REMOTES]);
> +	if (err)
> +		return err;
> +
>  	return 0;
>  }


Seems you can simply return vxlan_validate_remotes(...); here.


> +static int vxlan_fill_remotes_info(struct sk_buff *skb,
> +				   const struct vxlan_dev *vxlan)
> +{
> +	struct vxlan_rdst *rd;
> +	struct nlattr *nest, *rdst_nest;
> +	__be32 ip;
> +	int i = 1;
> +
> +	if (!vxlan->remotes_cnt)
> +		return 0;
> +
> +	nest = nla_nest_start(skb, IFLA_VXLAN_REMOTES);
> +	if (nest == NULL)
> +		goto nla_put_failure;
> +
> +	list_for_each_entry_rcu(rd, &vxlan->remotes, list) {


Need RCU read lock here?


> +		ip = rd->remote_ip;
> +
> +		if (ip == vxlan->default_dst.remote_ip)
> +			continue;
> +
> +		rdst_nest = nla_nest_start(skb, i);
> +		if (rdst_nest == NULL)
> +			goto nla_put_failure;
> +
> +		if (nla_put_be32(skb, IFLA_VXLAN_REMOTE_ADDR, ip))
> +			goto nla_put_failure;
> +
> +		nla_nest_end(skb, rdst_nest);
> +		i++;
> +	}
> +
> +	nla_nest_end(skb, nest);
> +
> +	return 0;
> +
> +nla_put_failure:
> +	return -EMSGSIZE;
> +}
> +


Thanks!
