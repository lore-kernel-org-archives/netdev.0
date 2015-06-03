From: Joao Martins <Joao.Martins@neclab.eu>
Subject: Re: [RFC PATCH 04/13] xen-netback: implement RX persistent grants
Date: Wed, 3 Jun 2015 17:08:00 +0000
Message-ID: <A5DD989F-E37A-4070-AC82-0539431A08B2@neclab.eu>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-5-git-send-email-joao.martins@neclab.eu>
 <20150519153205.GC26335@zion.uk.xensource.com>
 <65A385A5-4D11-4032-BB1B-82180AF76477@neclab.eu>
 <20150602150704.GQ19403@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.neclab.eu ([195.37.70.40]:37580 "EHLO mailer1.neclab.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964984AbbFCRIR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 13:08:17 -0400
In-Reply-To: <20150602150704.GQ19403@zion.uk.xensource.com>
Content-Language: en-US
Content-ID: <D4668EF0D6F2494A92CD37A92C2B5C1F@office.hd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 02 Jun 2015, at 17:07, Wei Liu <wei.liu2@citrix.com> wrote:

> On Fri, May 22, 2015 at 10:25:10AM +0000, Joao Martins wrote:
>> 
>> On 19 May 2015, at 17:32, Wei Liu <wei.liu2@citrix.com> wrote:
>> 
>>> On Tue, May 12, 2015 at 07:18:28PM +0200, Joao Martins wrote:
>>>> It starts by doing a lookup in the tree for a gref. If no persistent
>>>> grant is found on the tree, it will do grant copy and prepare
>>>> the grant maps. Finally valides the grant map and adds it to the tree.
>>> 
>>> validates?
>>> 
>>>> After mapped these grants can be pulled from the tree in the subsequent
>>>> requests. If it's out of pages in the tree pool, it will fallback to
>>>> grant copy.
>>>> 
>>> 
>>> Again, this looks complicated. Why use combined scheme? I will do
>>> detailed reviews after we're sure we need such scheme.
>> When we don't have the gref in tree we need to map it and then copying
>> afterwards into the newly mapped page (and this only happens once until
>> the grant is in tree). My options here were to either do this explicitly,
>> after we add the persistent grant in which we would need to save to
>> dst/src address and len to copy. The other option is to reuse the grant
>> copy (since it's only once until the grant is in the tree) and use memcpy
>> in followings requests. Additionally I allow the fallback to grant copy in
> 
> Which approach were you using here? I looked at the code but couldn't
> quite get which one you were getting at. I guess the first one?

The one I used was the second one i.e. grant copy when the gref is not in tree,
and memcpy on subsequent requests. The only difference in these options is really
to memcpy (first option) or to grant copy (second option) on the first lookup
of the gref in the tree. The problem with the first option is adding more
state to save where to memcpy which we can only do after mapping the grant. Thus
reusing the grant copy simplifies, but probably makes things not as clear.

Perhaps what I suggested in an earlier comment (regarding TX persistent grants) could
simplify things.


>> case the guest provides providing more grefs > max_grants.
>> 
>> Note that this is also the case for TX as well, with regard to grant
>> copying the header. I was unsure about which one is the most correct way
>> of doing it, but ultimately the latter involved a smaller codepath, and
>> that's why I chose it. What do you think?
>> 
> 
> Shorter is better. Easier to understand.
