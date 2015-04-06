From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v2 25/26] switchdev: convert swdev_fib_ipv4_add/del
 over to swdev_port_obj_add/del
Date: Mon, 6 Apr 2015 14:56:45 -0700
Message-ID: <CAE4R7bCAx8X49LDXDN+uT66ped=M_C+zWc-b1wX6H3wijyD2Hg@mail.gmail.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
	<1427882882-2533-26-git-send-email-sfeldma@gmail.com>
	<551C094D.7000707@cumulusnetworks.com>
	<20150401160522.GE2025@nanopsycho.orion>
	<551ED558.3020303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, roopa <roopa@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	"Arad, Ronen" <ronen.arad@intel.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:34490 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752745AbbDFV4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 17:56:46 -0400
Received: by qkgx75 with SMTP id x75so33137846qkg.1
        for <netdev@vger.kernel.org>; Mon, 06 Apr 2015 14:56:45 -0700 (PDT)
In-Reply-To: <551ED558.3020303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 3, 2015 at 11:00 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 01/04/15 09:05, Jiri Pirko wrote:
>>> This looks nice. However, my only concern is we have now ended up adding a
>>> whole layer of abstraction to all objects. The api abstraction seemed fine.
>>> But, carrying it to objects and duplicating every object in the swdev layer
>>> seems too much duplication. Maybe its just me.
>>> we will end up adding this for bond attributes...vxlan...fdb and nftables
>>
>> +1
>
> +1.
>
>>
>>> etc.
>>>
>>> The advantage of switchdev in the kernel was to have access the existing
>>> kernel api and objects directly from switchdev layer.
>>> In which case, to me, it would be better to skip this extra layer of objects.
>>> And keep the way you had it originally.
>
> Same here, I am not exactly sure how much good the abstract object is
> giving us here since we are already in the kernel, and we cannot/do not
> necessarily want to eliminate a large number of swdev_ops, as these are
> precisely the API we want to define.
>
> NB: if we were to do that for swdev_ops, the next step would be doing
> the same thing for netdev_ops to reduce their number, would not we?
>
> Maybe for now solving the stacked device problem and
> prepare/commit/rollback is good enough to keep you busy that adding the
> object layer is a completely secondary problem to solve ;)?

To solve the stacked device problem and support
prepare/commit/rollback, for both attrs and objs, but using a
parameter list call structure for each attr/obj type will result in a
lot of duplicated code.  You'll end up replicating the basic
lower-dev-walk recursion algo for each, and also replicating the
prepare/commit/rollback logic.  It's the typed parameter list unique
for each obj or attr that messes things up.  Going to the attr/obj
model let's us write the algos once.

We're also eliminating the swdev ops which pass netlink args.  There
are cases where we want to originate the swdev ops call within the
kernel, outside of a netlink message context.  For example, flushing
FDB entries from the device.  Today, to flush FDB entries from the
device, we'd need to call ndo_fdb_del() and pass in netlink arguments
that are made-up.  We create a fake struct ndmsg *ndm and a fake
struct nlattr *tb[] and pass those in to ndo_fdb_del() and hope no-one
expects anything useful in those fake structures.  Moving to the
attr/obj model, we can make the direct in-kernel call to flush the FDB
entries from the device without having to fake a netlink call inside
the kernel.

FDB entry obj would be the next obj to add.  The stacked support and
transaction support come for free.

-scott
