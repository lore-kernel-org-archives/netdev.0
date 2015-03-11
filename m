From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [net-next PATCH] ipv4: FIB Local/MAIN table collapse
Date: Wed, 11 Mar 2015 09:03:07 -0700
Message-ID: <CAA93jw5GR_Mgx8rmrMmOLXsmeW2xsCy=5xYyzOiEFHAtY=mFeA@mail.gmail.com>
References: <20150306213830.1139.16932.stgit@ahduyck-vm-fedora20>
	<55005829.5050406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Sabrina Dubroca <sd@queasysnail.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:46047 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbbCKQDI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 12:03:08 -0400
Received: by obbnt9 with SMTP id nt9so9785724obb.12
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 09:03:07 -0700 (PDT)
In-Reply-To: <55005829.5050406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 7:58 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On 03/06/2015 01:47 PM, Alexander Duyck wrote:
>> This patch is meant to collapse local and main into one by convertin=
g
>> tb_data from an array to a pointer.  Doing this allows us to point t=
he
>> local table into the main while maintaining the same variables in th=
e
>> table.
>>
>> As such the tb_data was converted from an array to a pointer, and a =
new
>> array called data is added in order to still provide an object for t=
b_data
>> to point to.
>>
>> In order to track the origin of the fib aliases a tb_id value was ad=
ded in
>> a hole that existed on 64b systems.  Using this we can also reverse =
the
>> merge in the event that custom FIB rules are enabled.
>>
>> With this patch I am seeing an improvement of 20ns to 30ns for routi=
ng
>> lookups as long as custom rules are not enabled, with custom rules e=
nabled
>> we fall back to split tables and the original behavior.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>> ---
>>
>> Changes since the RFC:
>>   Added tb_id value so I could split main and local for custom rules
>>   Added functionality to split tables if custom rules were enabled
>>   Added table replacement and unmerge functions
>>
>> I have done some testing on this to verify performance gains and tha=
t I can
>> split the tables correctly when I enable custom rules, but this patc=
h is
>> what I would consider to be high risk since I am certain there are t=
hings I
>> have not considered.
>>
>> If this gets pulled into someone's switchdev tree instead of into ne=
t-next I
>> would be perfectly fine with that as I am sure this can use some add=
itional
>> testing.
>
> Has anyone out there had a chance to review this patch?  I had sugges=
ted
> holding off on applying it to net-next for additional testing, but I
> haven't found anything, and the only related issue is the one issue
> Sabrina reported for the RTNL locking which was already in net-next a=
nyway.


My environment consists largely of 32 bit routing platforms (openwrt)
running the current homenet routing protocol (babel), using, in
particular, the babeld source specific routing extensions ( see
http://arxiv.org/pdf/1403.0445v3.pdf  ) which do use multiple routing
tables, and other uncommon things like p2p routes and odd netmasks
like /27 and /30.

But: I simply can't keep up with you and this entire patchset changes
so dramatically how routing works that you make me nervous. I would
like to see quagga (and babeld) improved to use atomic updates in
particular (They do a delete + add for no good reason), and for
protocols like ospf, bgp, etc, to be actively tested on real traffic
loads on live data against this entire patchset.

Your 64 bit x86 benchmarks are very exciting and I do look forward to
one day soon attempting to evaluate and benchmark these changes on
teeny 32 bit platforms both in the general case and in this
environment, and am mostly just hoping that others that are doing
higher end real world routing with big tables (such as BGP) are paying
more attention than I can.

What test procedures are you using at present (and what is everyone els=
e using)?

> If nobody has any objections then maybe we should apply this after
> Sabrina's patch and see what other bugs if any can be found when this
> goes into linux-next?  I figure that since the performance gains from
> this patch are fairly significant the risk is likely worth the reward=
=2E
>
> - Alex
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Dave T=C3=A4ht
Let's make wifi fast, less jittery and reliable again!

https://plus.google.com/u/0/107942175615993706558/posts/TVX3o84jjmb
