From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net] ipv6: do not overwrite inetpeer metrics prematurely
Date: Tue, 11 Mar 2014 10:53:09 +0100
Message-ID: <20140311095309.GA3287@unicorn.suse.cz>
References: <20140310.010313.703650662340510015.davem@davemloft.net>
 <20140310081533.GA27052@unicorn.suse.cz>
 <20140310120016.GH5493@order.stressinduktion.org>
 <20140310.223841.953940361609160158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:50288 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753263AbaCKJxL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2014 05:53:11 -0400
Content-Disposition: inline
In-Reply-To: <20140310.223841.953940361609160158.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 10, 2014 at 10:38:41PM -0400, David Miller wrote:
> 
> Does this version address everyone's concerns?  Michal can you test it
> for me?

There is still a problem:

12sp0:~ # ip route add fec0::1 dev eth0 rto_min 1000
12sp0:~ # ip -6 route show
fe80::/64 dev eth0  proto kernel  metric 256 
fec0::1 dev eth0  metric 1024  rto_min lock 1s
12sp0:~ # ip route change fec0::1 dev eth0 hoplimit 10
12sp0:~ # ip -6 route show
fe80::/64 dev eth0  proto kernel  metric 256 
fec0::1 dev eth0  metric 1024  hoplimit 10 rto_min lock 1s

IMHO this comes from the was_writable test in fib_commit_metrics():

> +static int fib_commit_metrics(struct dst_entry *dst, struct nlattr *mx, int mx_len)
> +{
> +	struct nlattr *nla;
> +	bool was_writable;
> +	int remaining;
> +	u32 *mp;
> +
> +	was_writable = !dst_metrics_read_only(dst);
> +	mp = dst_metrics_write_ptr(dst);
> +
> +	if (was_writable)
> +		memset(mp, 0, RTAX_MAX * sizeof(u32));
> +
> +	nla_for_each_attr(nla, mx, mx_len, remaining) {
> +		int type = nla_type(nla);
> +
> +		if (type) {
> +			if (type > RTAX_MAX)
> +				return -EINVAL;
> +
> +			mp[type - 1] = nla_get_u32(nla);
> +		}
> +	}
> +	return 0;
> +}

For DST_HOST, was_writable is always false as at this point,
dst->_metrics still points to the shared default. I believe what we want
to know is whether the _original_ dst_entry (the one we are replacing,
if any) has writable metrics. Because if it has, we are reusing them, if
not, we get new ones. For non-DST_HOST routes, we can always skip the
memset() as we never share (writeable) metrics between old and new in
the non-DST_HOST case.

I also believe the function should return immediately if mx is null so
that we don't call dst_metrics_write_ptr() if no metrics are to be set
for the new route.

I'll test these changes and send an updated patch if I find no problem
with it.

                                                         Michal Kubecek
