From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net 2/3] net: sctp: fix panic on duplicate ASCONF chunks
Date: Thu, 16 Oct 2014 01:13:18 +0200
Message-ID: <543EFF8E.7050608@redhat.com>
References: <1412888133-833-1-git-send-email-dborkman@redhat.com> <1412888133-833-3-git-send-email-dborkman@redhat.com> <20141010153954.GE19499@hmsreliant.think-freely.org> <54385777.7090907@redhat.com> <20141012014233.GA16360@localhost.localdomain> <543B0DD7.7000900@redhat.com> <20141015025833.GA6493@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750887AbaJOXNf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2014 19:13:35 -0400
In-Reply-To: <20141015025833.GA6493@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/2014 04:58 AM, Neil Horman wrote:
> On Mon, Oct 13, 2014 at 01:25:11AM +0200, Daniel Borkmann wrote:
>> On 10/12/2014 03:42 AM, Neil Horman wrote:
>>> On Sat, Oct 11, 2014 at 12:02:31AM +0200, Daniel Borkmann wrote:
>>>> On 10/10/2014 05:39 PM, Neil Horman wrote:
>>>> ...
>>>>> Is it worth adding a WARN_ON, to indicate that two ASCONF chunks have been
>>>>> received with duplicate serials?
>>>>
>>>> Don't think so, as this would be triggerable from outside.
>>>>
>>> WARN_ON_ONCE then, per serial number?
>>
>> Sorry, but no. If someone seriously runs that in production and it
>> triggers a WARN() from outside, admins will start sending us bug
>> reports that apparently something with the kernel code is wrong.
>>
>> WARN() should only be used if we have some *internal* unexpected bug,
>> but can still fail gracefully. This would neither be an actual code bug
>> nor would it be an internally triggered one, plus we add unnecessary
>> complexity to the code. Similarly, for those reasons we don't WARN()
>> and throw a stack trace when we receive, say, an skb of invalid length
>> elsewhere.
>>
>> I'd also like to avoid any additional pr_debug().
>>
>> I don't think people enable them in production, and if they really do,
>> it's too late anyway as we already have received this chunk. If anything,
>> I'd rather like to see debugging code further removed as we have already
>> different facilities in the kernel for runtime debugging that are much
>> more powerful.
 >
> What do you suggest then?  It seems like this is a protocol error that an
> administrator will want to be made aware of.  I'm open to other options, but
> just saying "no" isn't sufficient for me.

So what do you want an admin to do with this information?

Currently, we don't throw WARN() stack traces or whatever on other 'malformed'
inputs, we either discard them silently in SCTP or send an ABORT, for example.

Do you suggest the kernel should now start throwing a WARN() on every possible
skb that we discard in order to inform the admin?

Given that we can handle this gracefully by basically ignoring the 2nd identical
ASCONF chunk in a packet and send out a single reply, that's just handled fine.
