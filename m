From: "Hubert Sokolowski" <h.sokolowski@wit.edu.pl>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Thu, 11 Dec 2014 16:39:40 -0000
Message-ID: <6e03100b17d3e17625f1c323d94a853e.squirrel@poczta.wsisiz.edu.pl>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>
    <54894850.5000603@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, "Jamal Hadi Salim" <hadi@mojatatu.com>
To: "Roopa Prabhu" <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dervish.wsisiz.edu.pl ([213.135.44.54]:50258 "EHLO
	dervish.wsisiz.edu.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934349AbaLKQjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 11:39:44 -0500
In-Reply-To: <54894850.5000603@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I think commit
> "5e6d243587990a588143b9da3974833649595587 "bridge: netlink dump
> interface at par with brctl" tried to make sure even the dflt entries
> (ie dev->uc and dev->mc) were also printed in the below case. ie the
> 'self' entries in the below output.
>
> # ./bridge fdb show brport eth1
> 02:00:00:12:01:02 vlan 0 master br0 permanent
> 00:17:42:8a:b4:05 vlan 0 master br0 permanent
> 00:17:42:8a:b4:07 self permanent
> 33:33:00:00:00:01 self permanent
>
> Am guessing reverting the patch is going to make the 'self' entries in
> the above output to go away.
> Can you please confirm ?.

I don't want you to revert the patch, as the main goal of the patch
was to enable filtering in the kernel. I am only proposing
to revert part of it that allows driver to implement own dump.
This does not break the filtering in the kernel.
Whether the 'self' entries will go away it depends if the driver
overrides ndo_fdb_dump callback with its own. For cases where the driver
does not implement the callback, the dflt callback is still called
showing 'self' entries:
[root@silpixa00378825 ~]# bridge fdb show
33:33:00:00:00:01 dev em1 self permanent
01:00:5e:00:00:01 dev em1 self permanent
33:33:00:00:00:01 dev p4p1 self permanent
01:00:5e:00:00:01 dev p4p1 self permanent
33:33:ff:81:56:db dev p4p1 self permanent
01:00:5e:00:00:fb dev p4p1 self permanent
33:33:00:00:00:01 dev dummy0 self permanent

>
> Also, if i hear your concern correctly, for bridge ports that implement
> ndo_fdb_dump, with commit 5e6d243587990a588143b9da3974833649595587, we
> will get two entries for each 'self' entry above.
> Can you also paste sample output for that ?.

My patch affects *only* drivers that implements own dump callback.
Implementing own dump callback means the driver want to have a control
over what is being dumped. For example you may want to dump a hardware
MAC table only (my case) where 'self' entries created by kernel make no sense.
Also there are drivers that calls dflt callback from inside own dump function.
Please see following dump callback implemented for QLogic:
static int qlcnic_fdb_dump(struct sk_buff *skb, struct netlink_callback *ncb,
                        struct net_device *netdev,
                        struct net_device *filter_dev, int idx)
{
        struct qlcnic_adapter *adapter = netdev_priv(netdev);

        if (!adapter->fdb_mac_learn)
                return ndo_dflt_fdb_dump(skb, ncb, netdev, filter_dev, idx);
[...]

Another example of dflt being called twice is macvlan.c where ndo_fdb_dump
is actually initialized with the dflt callback:
macvlan.c:1022:        .ndo_fdb_dump           = ndo_dflt_fdb_dump,

Thanks,
Hubert
