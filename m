From: "Love, Robert W" <robert.w.love@intel.com>
Subject: RE: [RFC PATCH] qos: Limit a filter's priority to a 16 bit value
Date: Fri, 1 May 2009 19:10:36 -0700
Message-ID: <273D38FBE7C6FE46A1689FCD014A0B8B495C01C0@azsmsx505.amr.corp.intel.com>
References: <20090501184242.12714.2663.stgit@fritz>
	 <20090501.155155.58484825.davem@davemloft.net>
	 <273D38FBE7C6FE46A1689FCD014A0B8B495C016A@azsmsx505.amr.corp.intel.com>
 <1241229126.7162.5.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "hadi@cyberus.ca" <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:48109 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752606AbZEBCKh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 22:10:37 -0400
In-Reply-To: <1241229126.7162.5.camel@dogo.mojatatu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Fri, 2009-05-01 at 16:30 -0700, Love, Robert W wrote:
> 
>> I should be more clear by saying that this should only
>> fail with filter priorities assigned by the kernel.
>> I think if the user passes down the priority when
>> creating the filter it should always be 16bits and it's fine.
>> 
>> However, when the kernel is assigning priorities, the
>> first assigned priority for a filter is 0xC0000000,
>> the second is "the lowest priority - 1" so 0xBFFFFFFF.
>> 
>> It will assign this value in tcf_auto_prio() which will
>> directly assign the 32bit value to to tp->prio with-
>> 
>> tp->prio = nprio ? : tcf_auto_prio(*back);
> 
> I think the above should read:
> tp->prio = nprio ? : TC_H_MAJ(tcf_auto_prio(*back));
> 
I think you might be right, although, I don't see why
we use a u32 when we're always storing a u16. There might
be a good reason, but it seems error-prone.

With your change the kernel would be selecting the
following priorities.

0xC0000000
0xC0000000 - 1 = 0xBFFFFFFF -> TC_H_MAJ makes 0xBFFF
0xBFFF0000 - 1 = 0xBFFEFFFF -> TC_H_MAJ makes 0xBFFE
...

so the low bits are irrelevant.

> More importantly however, you should _never_ specify
> a filter you intend to delete individually without specifying
> its priority.

Absolutely, the kernel would never find it. :)

> Common practise in scripts is to just delete the root
> qdisc or class to delete all filters.
> 
Just for a little background. The netdev based FCoE solution
w/ DCB uses the multiq qdisc to filter FCoE packets into
specific queues. I don't want our script to yank out the
multiq qdisc just because FCoE traffic has stopped. The FCoE
script doesn't know if the user has other filters applied for
that interface/qdisc. The script should just remove its
filters and not disrupt anything else on the chain.

I have a patch to our user space script that filters FIP
(FCoE Initialization Protocol) to the same FCoE queue that
DCB has negotiated with the switch. As soon as I added the
second filter I realized that I couldn't delete or modify it.
