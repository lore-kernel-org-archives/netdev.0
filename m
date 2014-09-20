From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Sat, 20 Sep 2014 10:21:10 -0700
Message-ID: <DCCFAE52-F4BD-4877-A6FC-3C3AE180E871@cumulusnetworks.com>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us> <1411134590-4586-9-git-send-email-jiri@resnulli.us> <541C4AFC.8060500@mojatatu.com> <20140919154946.GH1980@nanopsycho.orion> <541CF75C.9030209@cumulusnetworks.com> <DDC24110-C3F5-470F-B9BE-1D1792415D1E@cumulusnetworks.com> <541D784B.6030302@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>, dborkman <dborkman@redhat.com>,
	ogerlitz <ogerlitz@mellanox.com>, jesse <jesse@nicira.com>,
	pshelar <pshelar@nicira.com>, azhou <azhou@nicira.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>, dev@openvswitch.org,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com,
	Sergey Ryazanov <ryazanov
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:37478 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753961AbaITRVc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 13:21:32 -0400
In-Reply-To: <541D784B.6030302@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sep 20, 2014, at 5:51 AM, Roopa Prabhu <roopa@cumulusnetworks.com> w=
rote:

> On 9/20/14, 1:10 AM, Scott Feldman wrote:
>> On Sep 19, 2014, at 8:41 PM, Roopa Prabhu <roopa@cumulusnetworks.com=
>
>>  wrote:
>>=20
>>=20
>>> On 9/19/14, 8:49 AM, Jiri Pirko wrote:
>>>=20
>>>> Fri, Sep 19, 2014 at 05:25:48PM CEST, jhs@mojatatu.com
>>>>  wrote:
>>>>=20
>>>>> On 09/19/14 09:49, Jiri Pirko wrote:
>>>>>=20
>>>>>> This patch exposes switchdev API using generic Netlink.
>>>>>> Example userspace utility is here:
>>>>>>=20
>>>>>> https://github.com/jpirko/switchdev
>>>>>>=20
>>>>>>=20
>>>>>>=20
>>>>> Is this just a temporary test tool? Otherwise i dont see reason
>>>>> for its existence (or the API that it feeds on).
>>>>>=20
>>>> Please read the conversation I had with Pravin and Jesse in v1 thr=
ead.
>>>> Long story short they like to have the api separated from ovs data=
path
>>>> so ovs daemon can use it to directly communicate with driver. Also=
 John
>>>> Fastabend requested a way to work with driver flows without using =
ovs ->
>>>> that was the original reason I created switchdev genl api.
>>>>=20
>>>> Regarding the "sw" tool, yes it is for testing purposes now. ovs d=
aemon
>>>> will use directly switchdev genl api.
>>>>=20
>>>> I hope I cleared this out.
>>>>=20
>>> We already have all the needed rtnetlink kernel api and userspace t=
ools around it to support all
>>> switching asic features. ie, the rtnetlink api is the switchdev api=
=2E We can do l2, l3, acl's with it.
>>> Its unclear to me why we need another new netlink api. Which will m=
ean none of the existing tools to
>>> create bridges etc will work on a switchdev.
>>> Which seems like going in the direction exactly opposite to what we=
 had discussed earlier.
>>>=20
>> Existing rtnetlink isn=92t available to swdev without some kind of s=
nooping the echoes from the various kernel components (bridge, fib, etc=
).  With swdev_flow, as Jiri has defined it, there is an additional con=
version needed to bridge the gap (bad expression, I know) between rtnet=
link and swdev_flow.  This conversion happens in the kernel components.=
  For example, the bridge module, still driven from userspace by existi=
ng rtnetlink, will formulate the necessary swdev_flow insert/remove cal=
ls to the swdev driver such that HW will offload the fwd path.
>>=20
>> You have:
>>     user -> rtnetlink -> kernel -> netlink echo -> [some process] ->=
 [some driver] -> HW
>>=20
>>=20
>> Jiri has:
>>     user -> rtnetlink -> kernel -> swdev_* -> swdev driver -> HW
>>=20
>>=20
> Keeping the goal to not change or not add a new userspace API in mind=
,
> I have :
>     user -> rtnetlink -> kernel -> ndo_op -> swdev driver  -> HW
>=20

Then you have the same as Jiri, for the traditional L2/L3 case.

> Jiri has:
>     user -> genl (newapi) -> kernel -> swdev_* -> swdev driver -> HW

Jiri=92s genl is for userspace apps that are talking rtnetlink, like OV=
S.  It=92s not a substitute for rtnetlink, it=92s an alternative.  The =
complete picture is:

user -> swdev genl -----
                        \
                         \
                          -------> kernel -> ndo_swdev_* -> swdev drive=
r -> HW
                         /
                        /
user -> rtnetlink ------


-scott
