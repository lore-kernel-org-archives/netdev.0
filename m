From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH v5 net-next 5/8] geneve: Add support to collect tunnel metadata.
Date: Thu, 27 Aug 2015 14:29:26 -0700
Message-ID: <CALnjE+pDWPEbuZ1--bk433x39BXvkf6ZcMcfhbg45DZBMV+HBQ@mail.gmail.com>
References: <1440658015-13028-1-git-send-email-pshelar@nicira.com>
	<1440658015-13028-6-git-send-email-pshelar@nicira.com>
	<20150827091854.GD18481@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:34128 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478AbbH0V31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 17:29:27 -0400
Received: by igui7 with SMTP id i7so4642436igu.1
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 14:29:26 -0700 (PDT)
In-Reply-To: <20150827091854.GD18481@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 27, 2015 at 2:18 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 08/26/15 at 11:46pm, Pravin B Shelar wrote:
>> +     if (ip_tunnel_collect_metadata() || geneve->collect_md) {
>> +             __be16 flags;
>> +             void *opts;
>> +
>> +             flags = TUNNEL_KEY | TUNNEL_GENEVE_OPT |
>> +                     (gnvh->oam ? TUNNEL_OAM : 0) |
>> +                     (gnvh->critical ? TUNNEL_CRIT_OPT : 0);
>> +
>> +             tun_dst = udp_tun_rx_dst(skb, AF_INET, flags,
>> +                                      vni_to_tunnel_id(gnvh->vni),
>> +                                      gnvh->opt_len * 4);
>> +             if (!tun_dst)
>> +                     goto drop;
>> +
>> +             /* Update tunnel dst according to Geneve options. */
>> +             opts = ip_tunnel_info_opts(&tun_dst->u.tun_info,
>> +                                        gnvh->opt_len * 4);
>> +             memcpy(opts, gnvh->options, gnvh->opt_len * 4);
>> +     } else {
>> +             /* Drop packets w/ critical options,
>> +              * since we don't support any...
>> +              */
>> +             if (gnvh->critical)
>> +                     goto drop;
>> +     }
>>
>>       skb_reset_mac_header(skb);
>>       skb_scrub_packet(skb, !net_eq(geneve->net, dev_net(geneve->dev)));
>>       skb->protocol = eth_type_trans(skb, geneve->dev);
>>       skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
>>
>> +     if (tun_dst)
>> +             skb_dst_set(skb, &tun_dst->dst);
>
> It is slightly non obvious that introducing an error condition above
> this and before udp_tun_rx_dst() would introduce a memory leak. Other
> than this looks great now.
>
I can not move this into if condition block since skb-scrub-packet
drops skb dst entry.

> Acked-by: Thomas Graf <tgraf@suug.ch>
