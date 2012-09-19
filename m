From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: TCPDUMP invalid cksum persists after disabling TCP cksum
 offload
Date: Wed, 19 Sep 2012 07:54:10 +0200
Message-ID: <1348034050.26523.325.camel@edumazet-glaptop>
References: <20120918193208.GA19030@darkstar>
	 <1347998905.2685.29.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120918211423.GA19115@darkstar>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jamie Gloudon <jamie.gloudon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36478 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754157Ab2ISFyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 01:54:13 -0400
Received: by wibhr14 with SMTP id hr14so692057wib.1
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 22:54:12 -0700 (PDT)
In-Reply-To: <20120918211423.GA19115@darkstar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-09-18 at 17:14 -0400, Jamie Gloudon wrote:
> Hello,
>    I am seeing that tx checksum offload appears to be still running after disabling the feature with ethtool. I'm using kernel 3.6.0-rc6 and the latest ethtool from the git repo. 
>  
> The default settings on my e1000e NIC:
> # ethtool -k eth1 | grep ': on'
>  rx-checksumming: on
>  tx-checksumming: on
>         tx-checksum-ip-generic: on
>  scatter-gather: on
>          tx-scatter-gather: on
>  tcp-segmentation-offload: on
>          tx-tcp-segmentation: on
>          tx-tcp6-segmentation: on
>  generic-segmentation-offload: on
>  generic-receive-offload: on
>  rx-vlan-offload: on
>  tx-vlan-offload: on
>  receive-hashing: on
>  highdma: on [fixed]
>  rx-vlan-filter: on [fixed]
>  tx-nocache-copy: on
>  
> The results after disabling tcp cksum offload feature:
> # ethtool -K eth1 tx off
> Actual changes:
>  tx-checksumming: off
>          tx-checksum-ip-generic: off
>  scatter-gather: off
>          tx-scatter-gather: off [requested on]
>  tcp-segmentation-offload: off
>          tx-tcp-segmentation: off [requested on]
>          tx-tcp6-segmentation: off [requested on]
>  generic-segmentation-offload: off [requested on]
>  
> However, in tcpdump, I'm still observing incorrect tcp checksum:
> 14:44:38.838711 IP (tos 0x10, ttl 64, id 45798, offset 0, flags [DF], proto TCP
> (6), length 60)
>      1.1.1.2.59748 > 1.1.1.1.23: Flags [S], cksum 0x0433 (incorrect -> 0x4137), seq 318222122, win 14600, options [mss 1460,sackOK,TS val 5447116 ecr 0,nop,wscale 7], length 0
>  
> Is this behaviour valid? I'm quite baffled.

Thats because dev_hard_start_xmit() calls dev_queue_xmit_nit() before
doing the features tests : 

tcpdump gets a copy of the packet before all mangling done
(skb_checksum_help() in your case)

                if (!list_empty(&ptype_all))
                        dev_queue_xmit_nit(skb, dev);

                features = netif_skb_features(skb);

                if (vlan_tx_tag_present(skb) &&
                    !(features & NETIF_F_HW_VLAN_TX)) {
                        skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
                        if (unlikely(!skb))
                                goto out;

                        skb->vlan_tci = 0;
                }

                if (netif_needs_gso(skb, features)) {
                        if (unlikely(dev_gso_segment(skb, features)))
                                goto out_kfree_skb;
                        if (skb->next)
                                goto gso;
                } else {
                        if (skb_needs_linearize(skb, features) &&
                            __skb_linearize(skb))
                                goto out_kfree_skb;

                        /* If packet is not checksummed and device does not
                         * support checksumming for this protocol, complete
                         * checksumming here.
                         */
                        if (skb->ip_summed == CHECKSUM_PARTIAL) {
                                skb_set_transport_header(skb,
                                        skb_checksum_start_offset(skb));
                                if (!(features & NETIF_F_ALL_CSUM) &&
                                     skb_checksum_help(skb))
                                        goto out_kfree_skb;
                        }
                }

                skb_len = skb->len;
                rc = ops->ndo_start_xmit(skb, dev);


I guess we could move dev_queue_xmit_nit(skb, dev) calls right before the
ndo_start_xmit() calls...
