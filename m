From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v2 06/10] bridge: introduce fdb offloading via switchdev
Date: Sun, 9 Nov 2014 23:30:11 -1000
Message-ID: <CAE4R7bDD1=KLGs44UWz--4Ua=-KpEzDSv08ALhYeAdW_L1AXpw@mail.gmail.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
	<1415530280-9190-7-git-send-email-jiri@resnulli.us>
	<54603564.3070606@mojatatu.com>
	<20141110081552.GD1850@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, nhorman@tuxdriver.com,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	vyasevic@redhat.com, Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:59933 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741AbaKJJgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 04:36:00 -0500
Received: by mail-wi0-f172.google.com with SMTP id bs8so9806392wib.5
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 01:35:59 -0800 (PST)
In-Reply-To: <20141110081552.GD1850@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 9, 2014 at 10:15 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Mon, Nov 10, 2014 at 04:47:48AM CET, jhs@mojatatu.com wrote:
>>On 11/09/14 05:51, Jiri Pirko wrote:
>>>From: Scott Feldman <sfeldma@gmail.com>
>>>
>>>Add two new ndos: ndo_sw_port_fdb_add/del to offload static bridge
>>>fdb entries.  Static bridge FDB entries are installed, for example,
>>>using iproute2 bridge cmd:
>>>
>>>        bridge fdb add ADDR dev DEV master vlan VID
>>>
>>>This would install ADDR into the bridge's FDB for port DEV on vlan VID.  The
>>>switch driver implements two ndo_swdev ops to add/delete FDB entries in the
>>>switch device:
>>>
>>>        int ndo_sw_port_fdb_add(struct net_device *dev,
>>>                                const unsigned char *addr,
>>>                                u16 vid);
>>>
>>>        int ndo_sw_port_fdb_del(struct net_device *dev,
>>>                                const unsigned char *addr,
>>>                                u16 vid);
>>>
>>>The driver returns 0 on success, negative error code on failure.
>>>
>>>Note: the switch driver would not implement ndo_fdb_add/del/dump on a port
>>>netdev as these are intended for devices maintaining their own FDB.  In our
>>>case, we want the Linux bridge to own the FBD.
>>>
>>>Note: by default, the bridge does not filter on VLAN and only bridges untagged
>>>traffic.  To enable VLAN support, turn on VLAN filtering:
>>>
>>>       echo 1 >/sys/class/net/<bridge>/bridge/vlan_filtering
>>>
>>
>>Sorry - why is the current fdb_add/del insufficient? It needs a vlanid
>>and the master/self flags should indicate intent to add to h/w vs s/w.
>
> Jamal, I believe we discussed this already. The thing is that current
> fdb_add/del does not need vlanid and master/self flags, because it
> already has that (struct nlattr *tb[]). Here is the whole list of
> parameters to these functions:
>         NDA_DST,
>         NDA_LLADDR,
>         NDA_CACHEINFO,
>         NDA_PROBES,
>         NDA_VLAN,
>         NDA_PORT,
>         NDA_VNI,
>         NDA_IFINDEX,
>         NDA_MASTER,
>
> There are few problems in re-using this. It is netlink based so for calling
> it from bridge code, we would have to construct netlink message. But
> that could be probably changed.
> As you can see from the list of parameters, this is no longer about fdb (addr,
> vlanid) but this has been extended to something else. See vxlan code for
> what this is used for. I believe that fdb_add/del should be renamed to
> something else, perhaps l2neigh_add/del or something like that.
> The other problem is that fdb_add/del is currently used by various
> drivers for different purpose (adding macs to unicast list).
>
> Scott, you may probably want to add something to this.

You hit the main point: having to synthesize netlink msg in the bridge
driver and pass it down to port driver using .ndo_fdb_add/del is
awkward.  And then, if the port driver implements .ndo_fdb_add/del
(and dump), then user could by-pass bridge and install fdbs directly
on port, as if the port maintains its own fdb.  We want the bridge fdb
to be the single fdb, and static fdbs installed by user on bridge to
be pushed down to sw port driver to be installed in hw.


>>
>>cheers,
>>jamal
>>
