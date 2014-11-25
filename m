From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 0/4] switch device: offload policy attributes
Date: Mon, 24 Nov 2014 22:39:19 -0800
Message-ID: <54742417.3030100@gmail.com>
References: <1416610170-21224-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bCDp2Cf=azOJvnm3_YRdsD5vwCafbcVFuseUaPuYKDA1g@mail.gmail.com> <547346EB.7060302@cumulusnetworks.com> <CAE4R7bAY2zMy4SiuwhdXyH2Swqv1KfkrBJ_ZwU_RYdCW3k+Mvg@mail.gmail.com> <5473B874.1010005@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Benjamin LaHaise <bcrl@kvack.org>, Thomas Graf <tgraf@suug.ch>,
	stephen@networkplumber.org, John Linville <linville@tuxdriver.com>,
	nhorman@tuxdriver.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	vyasevic@redhat.com, Florian Fainelli <f.fainelli@gmail.com>,
	buytenh@wantstofly.org, Aviad Raveh <aviadr@mellanox.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:56844 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbaKYGjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 01:39:48 -0500
Received: by mail-oi0-f53.google.com with SMTP id x69so7756362oia.40
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 22:39:48 -0800 (PST)
In-Reply-To: <5473B874.1010005@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/24/2014 03:00 PM, Roopa Prabhu wrote:
> On 11/24/14, 12:48 PM, Scott Feldman wrote:
>> On Mon, Nov 24, 2014 at 4:55 AM, Roopa Prabhu
>> <roopa@cumulusnetworks.com> wrote:
>>> On 11/24/14, 2:18 AM, Scott Feldman wrote:
>>>> Hi Roopa,
>>>>
>>>> I have a patch pending against Jiri's v2 that's uses existing
>>>> ndo_bridge_setlink/getlink to push policy settings down to port driver
>>>> for controlling HW offload.  I had to make a few tweaks, but for the
>>>> most part setlink/getlink already has the master/self semantics so
>>>> users can set policy flags on bridge's SW version of the port (master)
>>>> or on the offloaded version of the port (self).
>>>>     I added the new
>>>> hwmode option "swdev" to the existing "vepa"|"veb" choices.  When you
>>>> specify hwmode, SELF is set and the port driver's setlink get's
>>>> called.  Did you look at setlink/getlink?  It looks like the kernel
>>>> and iproute2 where going down this route of using setlink/getlink for
>>>> SELF policy, so I'm wondering if we need more?
>>> If i understand you correctly, this will mean the port driver
>>> implements the
>>> setlink/getlink with the  bridge port flags and attributes. And, it also
>>> means
>>> the port driver will parse the netlink msg instead of the bridge driver
>>> parsing all attributes and then calling offloads.
>> Yes, exactly, the port driver parses/fills bridge_setlink/getlink
>> netlink msg to set/get port settings.  It's basically a passthru for
>> rtnl_bridge_setlink/getlink handling RTM_GETLNK/RTM_SETLINK on
>> PF_BRIDGE.
> This will duplicate msg parsing code and validation code in the kernel
> bridge driver and in all the port drivers.
> If this is the path we plan to go down on,...it will also mean we will
> do the same thing
> for bonds, vxlans and maybe others in the future.
>

Where it makes sense we can do the msg parsing in a common
location once right? The fdb hooks and setlink/getlink handlers should 
probably be cleaned up for this as well. Or we can build a set of
utility functions _dflt_ handlers that drivers can call to do the
parsing. At least these are not exposed to the user API so we can
iterate over this as needed and as more attributes are needed.

> In the mode where kernel and hw state need to remain in sync,
> I am also concerned about how we handle failure cases.
>
> I think we will have cases where the kernel will set the attribute and
> hw will fail. In which case can we rollback ?

In the fdb cases we set a flag to indicate how far we got in the
command and then punt it back to user space where it can be rolled
back. We don't have any sort of reserve and commit or rollback on error
behaviour. It seems like a "nice" feature but perhaps the first
iteration can just return how far it got and let user space handle
the rollback.

At least this is how I planned to handle flow tables and flow updates
as Simon pointed out.

[...]

-- 
John Fastabend         Intel Corporation
