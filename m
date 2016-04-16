From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v3 RFC 2/2] ipv6: add support for stats via
 RTM_GETSTATS
Date: Sat, 16 Apr 2016 09:55:12 +0200
Message-ID: <20160416075512.GB2486@pox.localdomain>
References: <1460777293-39474-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35304 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbcDPHzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 03:55:16 -0400
Received: by mail-wm0-f42.google.com with SMTP id a140so57668348wma.0
        for <netdev@vger.kernel.org>; Sat, 16 Apr 2016 00:55:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1460777293-39474-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/16 at 08:28pm, Roopa Prabhu wrote:
> +static size_t inet6_get_link_af_stats_size(const struct net_device *dev,
> +					   u32 filter_mask)
> +{
> +	if (!(filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_INET6)))
> +		return 0;
> +
> +	if (!__in6_dev_get(dev))
> +		return 0;
> +
> +	return nla_total_size(sizeof(struct nlattr)) /* IFLA_STATS_LINK_INET6 */
> +		+ nla_total_size(IPSTATS_MIB_MAX * 8) /* IFLA_INET6_STATS */
> +		+ nla_total_size(ICMP6_MIB_MAX * sizeof(u64));/* IFLA_INET6_ICMP6STATS */
> +}

I think this is a good example. The above is an expensive way to
figure out whether you have at least one interface with IPv6
statistics. I'd suggest to turn this into:

if (filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_INET6)) {
        size += nla_total_size(sizeof(struct nlattr)) /* IFLA_STATS_LINK_INET6 */
                + nla_total_size(IPSTATS_MIB_MAX * 8) /* IFLA_INET6_STATS */
                + nla_total_size(ICMP6_MIB_MAX * sizeof(u64));/* IFLA_INET6_ICMP6STATS */
}

... and put it into the main calcit function. The user has explicitly opted into
IPv6 statistics so I think it's not a waste to allocate resources for it in the
message. You could also make it depend on "disable_ipv6" to be more accurate but
I think even the above is good enough.
