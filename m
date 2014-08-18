From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH] drivers: net: ethernet: intel: e1000: e1000_ethtool.c
 coding style fixes
Date: Mon, 18 Aug 2014 08:29:48 -0700
Message-ID: <53F21BEC.2070204@intel.com>
References: <1408180328-4827-1-git-send-email-cristos@vipserv.org> <1408214489.2683.87.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>,
	Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:14147 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751464AbaHRP3t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2014 11:29:49 -0400
In-Reply-To: <1408214489.2683.87.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/16/2014 11:41 AM, Joe Perches wrote:
> On Sat, 2014-08-16 at 11:12 +0200, Krzysztof Majzerowicz-Jaszcz wrote:
>> @@ -1835,11 +1830,11 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
>>  	for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
>>  		switch (e1000_gstrings_stats[i].type) {
>>  		case NETDEV_STATS:
>> -			p = (char *) netdev +
>> +			p = (char *)netdev +
>>  					e1000_gstrings_stats[i].stat_offset;
>>  			break;
>>  		case E1000_STATS:
>> -			p = (char *) adapter +
>> +			p = (char *)adapter +
>>  					e1000_gstrings_stats[i].stat_offset;
>>  			brseak;
>>  		}
> 
> Maybe use a temporary for &e1000_gstring_stats[i]
> 
> Something like: (w/ void * for char *, WARN_ONCE, trigraph->if/else)
> 
> static void e1000_get_ethtool_stats(struct net_device *netdev,
> 				    struct ethtool_stats *stats, u64 *data)
> {
> 	struct e1000_adapter *adapter = netdev_priv(netdev);
> 	int i;
> 	void *p = NULL;
> 	const struct e1000_stats *stat = e1000_gstring_stats;
> 
> 	e1000_update_stats(adapter);
> 
> 	for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
> 		switch (stat->type) {
> 		case NETDEV_STATS:
> 			p = (void *)netdev + stat->stat_offset;
> 			break;
> 		case E1000_STATS:
> 			p = (void *)adapter + stat->stat_offset;
> 			break;
> 		default:
> 			WARN_ONCE(1, "Invalid E1000 stat type: %u index %d\n",
> 				  stat->type, i);
> 			break;
> 		}
> 
> 		if (stat->sizeof_stat == sizeof(u64))
> 			data[i] = *(u64 *)p;
> 		else
> 			data[i] = *(u32 *)p;
> 
> 		stat++;
> 	}
> }
> 

Doing any kind of pointer math on a void pointer is generally unsafe as
it is an incomplete type.  The only reason why it works in GCC is
because GCC has a nonstandard extension that makes it report as having a
size of 1.

This is why the math is being done on a char * as it is a complete type
with a size of 1.

Thanks,

Alex
