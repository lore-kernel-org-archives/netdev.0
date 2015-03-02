From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Flows! Offload them.
Date: Mon, 02 Mar 2015 14:49:58 -0800
Message-ID: <54F4E916.4050805@gmail.com>
References: <20150226133326.GC23050@casper.infradead.org> <54EF3A78.9020507@intel.com> <20150226201635.GA366@hmsreliant.think-freely.org> <20150226215255.GA15033@penelope.isobedori.kobe.vergenet.net> <20150227012239.GB8847@neilslaptop.think-freely.org> <CA+mtBx_E5D-ryU=etdKf+7bnYwqHKJbqDc22A5=ypWCL5Z_E1g@mail.gmail.com> <20150302134946.GB7971@gospo.home.greyhouse.net> <CAE4R7bCQrHqgyBkEuEpoZnn2npeuBrGUG60Zwpg8RBB20JwqeA@mail.gmail.com> <CAGpadYEC3-5AdkOG66q0vX+HM0c6EU-C0ZT=sKGe7rZRHsYYKg@mail.gmail.com> <CAE4R7bAueaSn7Z+Wcipf7UYQ57GteomTJDM8Ohn_-KFu5zw0sw@mail.gmail.com> <20150302224335.GA14057@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Shrijeet Mukherjee <shrijeet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Simon Horman <simon.horman@netronome.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	"jpettit@nicira.com" <jpettit@nicira.com>,
	Joe Stringer <joestringer@nicira.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	Benjamin LaHaise <bcrl@kvack.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:41400 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753924AbbCBWu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 17:50:27 -0500
Received: by pdno5 with SMTP id o5so43102128pdn.8
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 14:50:27 -0800 (PST)
In-Reply-To: <20150302224335.GA14057@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/15 14:43, Andy Gospodarek wrote:
> On Mon, Mar 02, 2015 at 02:13:35PM -0800, Scott Feldman wrote:
>> On Mon, Mar 2, 2015 at 10:31 AM, Shrijeet Mukherjee <shrijeet@gmail.com> wrote:
>>>>
>>>> Can you elaborate on "allow for async write of data to hardware
>>>> tables"?  Is this the trampoline model where user's request goes to
>>>> the kernel, and then back to user-space, and finally to the hardware
>>>> via an user-space SDK?  I think we should exclude that model from
>>>> discussions about resource management.  With the recent L2/L3 offload
>>>> work, I'm advocating a synchronous call path from user to kernel to
>>>> hardware so we can return a actionable result code, and put the burden
>>>> of resource management in user-space, not in the kernel.
>>>>
>>> Scott you mean synchronous to the switchdev driver right ?
>>
>> Correct.
> 
> So while I agree with you that it would be ideal to be synchronous all
> the way to the hardware (and that is what I continue to tell vendors
> they should do) you would like to see each driver individually manage
> whether or not they chose to make these calls async and handle the
> fallout in their own?

I am not sure I follow you here, the way I would see it is something
like this:

SWITCHDEV	DRIVER
ndo_foo ->
		foo_op ->
			bus_op() ->
			# wait for interrupt
			complete()
ndo_foo 	<- return

at which point, the only things that matters is that the switch driver
ensures calls serialization at its own level (concurrent HW registers
access), eventually working under the assumption that ndo_foo() is also
called with appropriate locking (rtnl) to prevent concurrent operations
from occurring.

If the model is more like the switch driver is responsible for locally
queuing multiple commands, then I agree, we might not want that at all.

-- 
Florian
