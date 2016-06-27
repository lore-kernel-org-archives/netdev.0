From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v5 0/4] return offloaded stats as default and
 expose original sw stats
Date: Mon, 27 Jun 2016 15:11:58 +0200
Message-ID: <20160627131158.GE2058@nanopsycho.orion>
References: <20160623113508.GE2060@nanopsycho.orion>
 <CACcJQnTfr5n75q48aJQ3bwzfCd9oThTCHcR_qWG7R9aV13pOQw@mail.gmail.com>
 <20160623154038.GH2060@nanopsycho.orion>
 <CAJieiUjsMHdTbhGqyo+8ys7S5QZ9KYvTY+LDC-bbo6dRk3FBRw@mail.gmail.com>
 <20160626093334.GA1984@nanopsycho.orion>
 <577019B0.9080708@cumulusnetworks.com>
 <20160626181546.GA1938@nanopsycho.orion>
 <CAJieiUgjfO-J_uUVV6VVS8ar1Fg8wMJwcmaemu==Su3DospLTA@mail.gmail.com>
 <20160627065102.GC2058@nanopsycho.orion>
 <CAJieiUh_2B3y78Fa7Oqwy6oc3WaJrNJk+h95tjT3=ojwXfGccQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Nogah Frankel <nogahf@mellanox.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Yotam Gigi <yotamg@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>, sd@queasysnail.net,
	eranbe@mellanox.com, Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <edumazet@google.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	David Ahern <dsa@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:38741 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbcF0NM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 09:12:29 -0400
Received: by mail-wm0-f52.google.com with SMTP id r201so114649385wme.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 06:12:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJieiUh_2B3y78Fa7Oqwy6oc3WaJrNJk+h95tjT3=ojwXfGccQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jun 27, 2016 at 03:02:31PM CEST, roopa@cumulusnetworks.com wrote:
>[resending ...my previous reply sent some non-text content]
>
>On Sun, Jun 26, 2016 at 11:51 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>
>> Mon, Jun 27, 2016 at 04:53:53AM CEST, roopa@cumulusnetworks.com wrote:
>> >On Sun, Jun 26, 2016 at 11:15 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> >> Sun, Jun 26, 2016 at 08:06:40PM CEST, roopa@cumulusnetworks.com wrote:
>> >>>On 6/26/16, 2:33 AM, Jiri Pirko wrote:
>> >>>> Sat, Jun 25, 2016 at 05:50:59PM CEST, roopa@cumulusnetworks.com wrote:
>> >>>>> On Thu, Jun 23, 2016 at 8:40 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> >>>>>> Thu, Jun 23, 2016 at 05:11:26PM CEST, anuradhak@cumulusnetworks.com wrote:
>> >>>>>>>>>>> we can't separate CPU and HW stats there. In some cases (or ASICs) HW
>> >>>>>>>>>>> counters do
>> >>>>>>>>>>> not include CPU generated packets....you will have to add CPU
>> >>>>>>>>>>> generated pkt counters to the
>> >>>>>>>>>>> hw counters for such virtual device stats.
>> >>>>>>>>>> Can you please provide and example how that could happen?
>> >>>>>>>>> example is the bridge vlan stats I mention below. These are usually counted
>> >>>>>>>>> by attaching hw virtual counter resources. And CPU generated packets
>> >>>>>>>>> in some cases maybe setup to bypass the ASIC pipeline because the CPU
>> >>>>>>>>> has already made the required decisions. So, they may not be counted by
>> >>>>>>>>> by such hw virtual counters.
>> >>>>>>>> Bypass ASIC? How do the packets get on the wire?
>> >>>>>>>>
>> >>>>>>> Bypass the "forwarding pipeline" in the ASIC that is. Obviously the
>> >>>>>>> ASIC ships the CPU generated packet out of the switch/front-panel
>> >>>>>>> port. Continuing Roopa's example of vlan netdev stats.... To get the
>> >>>>>>> HW stats counters are typically tied to the ingress and egress vlan hw
>> >>>>>>> entries. All the incoming packets are subject to the ingress vlan
>> >>>>>>> lookup irrespective of whether they get punted to the CPU or whether
>> >>>>>>> they are forwarded to another front panel port. In that case the
>> >>>>>>> ingress HW stats does represent all packets. However for CPU
>> >>>>>>> originated packets egress vlan lookups are bypassed in the ASIC (this
>> >>>>>>> is common forwarding option in most ASICs) and the packet shipped as
>> >>>>>>> is out of front-panel port specified by the CPU. Which means these
>> >>>>>>> packets will NOT be counted against the egress VLAN HW counter; hence
>> >>>>>>> the need for summation.
>> >>>>>> Driver will know about this, and will provide the stats accordignly to
>> >>>>>> the core. Who else than driver should resolve this.
>> >>>>>>
>> >>>>> The point was/is that there should be only two categories:
>> >>>>> 1) the base default stats: can contain 'only sw', 'only hw' or 'a
>> >>>>> summation of hw and sw' in some cases.
>> >>>>> The user does not care about the breakdown.
>> >>>>>
>> >>>>> 2) everything else falls into the second category: driver provided
>> >>>>> breakdown of stats for easier debugging.
>> >>>>> This today is ethtool stats and we can have an equivalent nested
>> >>>>> attribute for this in the new stats api.
>> >>>>> Lets call it IFLA_STATS_LINK_DRIVER or you pick a name. Lets make it
>> >>>>> nested and extensible (like ethtool is) and
>> >>>>> driver can expose any kind of stats there.
>> >>>>> ie lets move the stats you are proposing to this category of stats.....
>> >>>>> instead of introducing a third category 'SW stats'.
>> >>>> What you are proposing is essentially what our patchset does. We expose
>> >>>> 2 sets of stats. hw and pure sw. hw includes all, driver will take
>> >>>> care of it cause he knows what is going on in hw.
>> >>>the splitting into hw and sw is causing some confusion with respect
>> >>
>> >> I still don't get why you are talking about split :( I see no split.
>> >>
>> >>
>> >>>to existing stats and will be confusing for future stats. And i am not sure how many
>> >>>users would prefer the split this way.
>> >>>So, instead of doing the split, i think we should at this time introduce
>> >>>driver specific stats (like ethtool) as a nested netlink attribute.
>> >>
>> >> The default netlink stats should be hw (or accumulated as you call it).
>> >> The reason is to avoid confusion for existing apps. Another attribute is
>> >> possible for more break-out stats - that is what this patchset is doing.
>> >>
>> >> Ethtool stats are wrong and useless for apps as they are driver-specific.
>> >
>> >apps only care about overall stats. thats the aggregate stats
>> >provided by the default netlink netdev api to the user...which already exists.
>> >
>> >they don't care about your new breakdown either.
>>
>> Agreed. That is what our patchset is doing.
>>
>>
>> >
>> >breakdown of stats are used for debugging and thats what ethtool stats provide.
>> >
>> >
>> >
>> >>
>> >>
>> >>>>
>> >>>> Btw mirroring random string stats into Netlink is not a good idea IMO.
>> >>>Any reason you say that ?. I am thinking it would be much easier with netlink.
>> >>>keeping it simple, it is a nested attribute with stat-name and value pair.
>> >>>
>> >>>struct stat {
>> >>>    char stats_name[STATS_NAME_LEN];    /* STATS_NAME_LEN = 32 */
>> >>>    __u64 stat;
>> >>>};
>> >>
>> >> No please. This should be well defined generic group of stats.
>> >> Driver-specific names/stats stats are wrong.
>> >>
>> >
>> >they are meant for debugging. are you saying the new stats api should
>> >not contain 'ethtool like' stats ?
>> >
>> >ethtool stats are very valuable today. They are extensible.
>> >They cannot be made generic and they are specific to a hardware or use case.
>> >
>> >We use it for our switch port stats too. Base aggregate stats summed
>> >up and provided as default netdev stats. via ethtool we provide lot
>> >more hardware specific breakdown.
>>
>> Leave it in ethtool then. I really think it is not idea to put random
>> named-stats in netlink.
>
>
>
>The point of the stats api is to bring all stats together.
>ethtool stats are very valuable. so there is no point leaving them out.
>they will be in here sooner or later.
>
>when there is already a discussion of moving ethtool to netlink,..i am not sure
>I understand the hesitation on moving ethtool stats to netlink.

It's not well defined. That's the issue. It's "debugfs"...


>
>>
>>
>> This patchset uses well defined values for slowpatch(/sw/cpu) stats.
>> That is I believe the only way to do this.
>>
>
>It seems to be your preferred way. I don't think it is the only way to
>do it. It can very well be part of the nested
>breakdown stats i am talking about.

We are using existing well-defined structure. Very easy and clean.
