From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 06/10] bridge: introduce fdb offloading via
 switchdev
Date: Mon, 10 Nov 2014 14:47:15 +0100
Message-ID: <20141110134715.GD4256@nanopsycho.orion>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
 <1415530280-9190-7-git-send-email-jiri@resnulli.us>
 <54603564.3070606@mojatatu.com>
 <20141110081552.GD1850@nanopsycho.orion>
 <5460B3E5.7020502@mojatatu.com>
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
Received: from mail-wg0-f44.google.com ([74.125.82.44]:34568 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751721AbaKJNrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 08:47:18 -0500
Received: by mail-wg0-f44.google.com with SMTP id x12so8918018wgg.31
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 05:47:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5460B3E5.7020502@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 10, 2014 at 01:47:33PM CET, jhs@mojatatu.com wrote:
>On 11/10/14 03:15, Jiri Pirko wrote:
>>Mon, Nov 10, 2014 at 04:47:48AM CET, jhs@mojatatu.com wrote:
>>>On 11/09/14 05:51, Jiri Pirko wrote:
>>>>From: Scott Feldman <sfeldma@gmail.com>
>>>>
>
>>Jamal, I believe we discussed this already.
>
>I cant remember how that ended.
>
>>The thing is that current
>>fdb_add/del does not need vlanid and master/self flags, because it
>>already has that (struct nlattr *tb[]). Here is the whole list of
>>parameters to these functions:
>>         NDA_DST,
>>         NDA_LLADDR,
>>         NDA_CACHEINFO,
>>         NDA_PROBES,
>>         NDA_VLAN,
>>         NDA_PORT,
>>         NDA_VNI,
>>         NDA_IFINDEX,
>>         NDA_MASTER,
>>
>>There are few problems in re-using this. It is netlink based so for calling
>>it from bridge code, we would have to construct netlink message. But
>>that could be probably changed.
>
>Trying to understand.
>
>A netlink message for a bridge to add an fdb is targeted at the
>*bridge port*.
>That message has semantic which says "please add this entry
>to the software bridge and/or offloaded hardware".
>If something is targetted at the bridge port, ->ndo_fdb_add()
>is invoked with an internally chewed structure.
>Why would you have to construct a new netlink message to the driver?

Because now, If you would like to pass one of NDA_DST, NDA_LLADDR,
NDA_CACHEINFO, NDA_PROBES, NDA_VLAN, NDA_PORT, NDA_VNI, NDA_IFINDEX,
NDA_MASTER values via ndo_fdb_add/del to the driver, you have to
construct "struct nlattr *tb[]". Preprocessing this tb into struct might
be suitable for some use-case, for some it may not.


>
>
>>As you can see from the list of parameters, this is no longer about fdb (addr,
>>vlanid) but this has been extended to something else.
>
>I am still missing understanding that part.
>Or maybe are you saying that you dont want to pass netlink
>constructs to the driver?

What I try to say is that the naming ndo_fdb_add/del is not accurate
because it is now used for far more than fdb (addr, vlan). See vxlan
code for example.


>
>>See vxlan code for
>>what this is used for. I believe that fdb_add/del should be renamed to
>>something else, perhaps l2neigh_add/del or something like that.
>>The other problem is that fdb_add/del is currently used by various
>>drivers for different purpose (adding macs to unicast list).
>>
>
>Ok, now a small spark ignited in my brain. You did talk about renaming
>things to neighXXX in one of the exchanges. I think this is a separate
>issue from the question of why you cant refactor ndo_fdb_add/del

It can be probably refactored in a way so it fits our fdb offloading
needs. I'm not really sure we would want it. ndo_fdb_* use-case
is dirrerent from what we introduce with ndo_sw_port_fdb_*. The only
similarity is the "fdb" name which in case of ndo_fdb_* is no longer
correct I believe.


>
>The abuse of using this interface for unicast addresses is probably
>driven by the fact some of the hardware probably offloads vlanid 0 or
>something speacial like 4095 to point to the underlying hardware that
>"this belongs to host cpu".
>I am not a fan of it (and have posted in exchanges with Vlad in the
>past).
>
>cheers,
>jamal
