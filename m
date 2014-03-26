From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 26 Mar 2014 18:35:36 +0100
Message-ID: <20140326173536.GJ2869@minipsycho.orion>
References: <5330BAB7.3040501@mojatatu.com>
 <20140325173927.GE8102@hmsreliant.think-freely.org>
 <20140325180009.GB15723@casper.infradead.org>
 <20140325193533.GF8102@hmsreliant.think-freely.org>
 <CAGVrzcbRggJV+5+EuZnXVoU+qdK9ugPRL+J-mp-UraGuo19jnQ@mail.gmail.com>
 <5332677F.2090404@cumulusnetworks.com>
 <5332B1FE.7080102@mojatatu.com>
 <53330639.8050403@cumulusnetworks.com>
 <20140326165934.GH2869@minipsycho.orion>
 <CAGVrzcbBq2=DG198NnpSWu52+uuundqQ-6QiiuzHF5X_j8fcZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:51818 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752780AbaCZRfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 13:35:39 -0400
Received: by mail-ee0-f48.google.com with SMTP id b57so1924771eek.7
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 10:35:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAGVrzcbBq2=DG198NnpSWu52+uuundqQ-6QiiuzHF5X_j8fcZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 26, 2014 at 06:29:07PM CET, f.fainelli@gmail.com wrote:
>2014-03-26 9:59 GMT-07:00 Jiri Pirko <jiri@resnulli.us>:
>> Wed, Mar 26, 2014 at 05:54:17PM CET, roopa@cumulusnetworks.com wrote:
>>>On 3/26/14, 3:54 AM, Jamal Hadi Salim wrote:
>>>>On 03/26/14 01:37, Roopa Prabhu wrote:
>>>>>On 3/25/14, 1:11 PM, Florian Fainelli wrote:
>>>>>>2014-03-25 12:35 GMT-07:00 Neil Horman <nhorman@tuxdriver.com>:
>>>>
>>>>>Sorry about getting on this thread late and possibly in the middle.
>>>>>Agree on the idea of keeping the ports linked to the master switch dev
>>>>>(or the 'conduit' to the switch chip) via private list instead of the
>>>>>master-slave relationship proposed earlier.
>>>>>By private i mean the netdev->priv linkage to the master switch dev and
>>>>>not really keeping the ports from being exposed to the user.
>>>>>
>>>>>We think its better to keep the switch ports exposed as any other netdev
>>>>>on linux.
>>>>>  This approach will make the switch ports look exactly like a nic port
>>>>>and all tools will continue to work seamlessly. The switch port
>>>>>operations could internally be forwarded to the switch netdev (sw1 in
>>>>>the above case).
>>>>>
>>>>>example:
>>>>>$ip link set dev sw1p0 up
>>>>>$ethtool -S sw1p0
>>>>>
>>>>
>>>>I like the approach. I know the above is a simple version, but i am
>>>>assuming you also mean i can do things like
>>>>ip route add ...
>>>>bridge fdb add ... (and if you like your brctl go ahead)
>>>>bonding ...
>>>>
>>>yes, exactly.  We support this model on our boxes today.
>>>User can bond switch ports on our box in the exact same way as he/she
>>>would bond two nic ports.
>>>Our 'conduit to switch chip' reflects the corresponding lag
>>>configuration in the switch chip.
>>>Same goes for bridging, routing, acls.
>>
>>
>> So you implement bonding netlink api? Or you hook into bonding driver
>> itselt? Can you show us the code?
>
>Before we start talking about bonding, maybe we should make sure that
>we cover some basic hardware switches uses which are to make some
>ports belong to certain VLANs, tagged or untagged?
>
>It seems to me like this would become something like this, assuming P0
>and P1 are two switch ports and 'eth0' is the CPU port, where P0 and
>P1 belong to VLAN1 and CPU belongs to VLAN2:
>
>ip link set dev sw1p0 up
>ip link set dev sw1p1 up
>ip link set dev eth0 up


I might be mistaken, But I think you are missing a switch port
representing a connection to eth0 (eth0 being cpu conterpart of it).
Or is it one of sw1p0 and sw1p1 ?

>
>ip link add link eth0 name eth0.2 type vlan id 2
>
>ip link add link sw1p0 name sw1p0.1 type vlan id 1
>ip link add link sw1p1 name sw1p1.1 type vlan id 1
>
>ip link add sw1.1 type bridge
>ip link set sw1p0.1 master sw1.1
>ip link set sw1p1.1 master sw1.1
>
>Does that fit the model correctly?
>-- 
>Florian
