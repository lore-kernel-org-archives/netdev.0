From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 06/10] bridge: introduce fdb offloading via
 switchdev
Date: Mon, 10 Nov 2014 09:15:52 +0100
Message-ID: <20141110081552.GD1850@nanopsycho.orion>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
 <1415530280-9190-7-git-send-email-jiri@resnulli.us>
 <54603564.3070606@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:54490 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbaKJIPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 03:15:55 -0500
Received: by mail-wg0-f44.google.com with SMTP id x12so8115257wgg.17
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 00:15:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54603564.3070606@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 10, 2014 at 04:47:48AM CET, jhs@mojatatu.com wrote:
>On 11/09/14 05:51, Jiri Pirko wrote:
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>Add two new ndos: ndo_sw_port_fdb_add/del to offload static bridge
>>fdb entries.  Static bridge FDB entries are installed, for example,
>>using iproute2 bridge cmd:
>>
>>        bridge fdb add ADDR dev DEV master vlan VID
>>
>>This would install ADDR into the bridge's FDB for port DEV on vlan VID.  The
>>switch driver implements two ndo_swdev ops to add/delete FDB entries in the
>>switch device:
>>
>>        int ndo_sw_port_fdb_add(struct net_device *dev,
>>                                const unsigned char *addr,
>>                                u16 vid);
>>
>>        int ndo_sw_port_fdb_del(struct net_device *dev,
>>                                const unsigned char *addr,
>>                                u16 vid);
>>
>>The driver returns 0 on success, negative error code on failure.
>>
>>Note: the switch driver would not implement ndo_fdb_add/del/dump on a port
>>netdev as these are intended for devices maintaining their own FDB.  In our
>>case, we want the Linux bridge to own the FBD.
>>
>>Note: by default, the bridge does not filter on VLAN and only bridges untagged
>>traffic.  To enable VLAN support, turn on VLAN filtering:
>>
>>       echo 1 >/sys/class/net/<bridge>/bridge/vlan_filtering
>>
>
>Sorry - why is the current fdb_add/del insufficient? It needs a vlanid
>and the master/self flags should indicate intent to add to h/w vs s/w.

Jamal, I believe we discussed this already. The thing is that current
fdb_add/del does not need vlanid and master/self flags, because it
already has that (struct nlattr *tb[]). Here is the whole list of
parameters to these functions:
        NDA_DST,
        NDA_LLADDR,
        NDA_CACHEINFO,
        NDA_PROBES,
        NDA_VLAN,
        NDA_PORT,
        NDA_VNI,
        NDA_IFINDEX,
        NDA_MASTER,

There are few problems in re-using this. It is netlink based so for calling
it from bridge code, we would have to construct netlink message. But
that could be probably changed.
As you can see from the list of parameters, this is no longer about fdb (addr,
vlanid) but this has been extended to something else. See vxlan code for
what this is used for. I believe that fdb_add/del should be renamed to
something else, perhaps l2neigh_add/del or something like that.
The other problem is that fdb_add/del is currently used by various
drivers for different purpose (adding macs to unicast list).

Scott, you may probably want to add something to this.

>
>cheers,
>jamal
>
