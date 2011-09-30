From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: conntrack events over netlink flood
Date: Fri, 30 Sep 2011 16:46:12 +0300
Message-ID: <21804201a542b723ddc2bbfb8bcb570d@visp.net.lb>
References: <069917f11e06f3cf2e1ce9715f435b61@visp.net.lb>
 <20110930125956.GD13047@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:40668 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575Ab1I3NrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 09:47:18 -0400
In-Reply-To: <20110930125956.GD13047@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Fri, 30 Sep 2011 14:59:56 +0200, Florian Westphal wrote:
> Denys Fedoryshchenko <denys@visp.net.lb> wrote:
>
> [ cc: netfilter-devel ]
>
>>  After enabling events and running conntrack -E i notice flood in 
>> output
>>  of server that have PPPoE and PPTP connections. Here is the output:
>>
>>  OfficeNAT ~ # conntrack  -E
>>   [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1
>>  srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3
>>  dstkey=0x0 [ASSURED]
>>   [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1
>>  srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3
>>  dstkey=0x0 [ASSURED]
>
> [..]
>
>>  Is it considered as a bug? I think it should not send on each 
>> packet
>>  conntrack event.
>
> Bug. Update events should only be generated when something in the
> conntrack has changed (e.g. the connmark).
>
> Could you please try this patch (untested)?
>
> Subject: [PATCH] netfilter: conntrack_gre: only create ct assured 
> event once
>
> diff --git a/net/netfilter/nf_conntrack_proto_gre.c
> b/net/netfilter/nf_conntrack_proto_gre.c
> --- a/net/netfilter/nf_conntrack_proto_gre.c
> +++ b/net/netfilter/nf_conntrack_proto_gre.c
> @@ -241,8 +241,8 @@ static int gre_packet(struct nf_conn *ct,
>  		nf_ct_refresh_acct(ct, ctinfo, skb,
>  				   ct->proto.gre.stream_timeout);
>  		/* Also, more likely to be important, and not a probe. */
> -		set_bit(IPS_ASSURED_BIT, &ct->status);
> -		nf_conntrack_event_cache(IPCT_ASSURED, ct);
> +		if (!test_and_set_bit(IPS_ASSURED_BIT, &ct->status))
> +			nf_conntrack_event_cache(IPCT_ASSURED, ct);
>  	} else
>  		nf_ct_refresh_acct(ct, ctinfo, skb,
>  				   ct->proto.gre.timeout);
 Fine now, patch fixed this bug.

 Tested-by: Denys Fedoryshchenko <denys@visp.net.lb>

 ---
 System administrator
 Denys Fedoryshchenko
 Virtual ISP S.A.L.
