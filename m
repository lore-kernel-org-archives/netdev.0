From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH 5/6] xen-netback: coalesce slots before copying
Date: Tue, 26 Mar 2013 11:13:38 +0000
Message-ID: <515182E2.50103@citrix.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com> <1364209702-12437-6-git-send-email-wei.liu2@citrix.com> <5150699C.6080209@citrix.com> <CAOsiSVUNO0FQkfJWjv9bcoMgKNnHu4XYciz61hG3YNFzZNxK3w@mail.gmail.com> <51507C9B.3080109@citrix.com> <CAOsiSVV8gtKqFxyAr3XN9YF78WjtFqzvx5mnA1dKTrS_4qzXBw@mail.gmail.com> <51509789.8090608@citrix.com> <20130325190911.GC7004@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <liuw@liuw.name>, Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:58922 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753570Ab3CZLNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 07:13:41 -0400
In-Reply-To: <20130325190911.GC7004@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/13 19:09, Wei Liu wrote:
> On Mon, Mar 25, 2013 at 06:29:29PM +0000, David Vrabel wrote:
>>>>
>>>
>>> Are you suggesting move the default macro value to header file? It is
>>> just an estimation, I have no knowledge of the accurate maximum value,
>>> so I think make it part of the protocol a bad idea.
>>
>> How is the author of a new frontend supposed to know how many slots they
>> can use per packet if it is not precisely defined?
>>
> 
> A new frontend shuold use the scheme you mentioned below to get the
> maximum value. For old frontends that cannot be fixed, administrator can
> configure max_skb_slots to accommodate their need.

I'm happy to the threshold for fatal errors to be configurable via a
module parameter.

>>> Do you have a handle on the maximum value?
>>
>> Backends should provide the value to the frontend via a xenstore key
>> (e.g., max-slots-per-frame).  This value should be at least 18 (the
>> historical value of MAX_SKB_FRAGS).
>>
>> The frontend may use up to this specified value or 17 if the
>> max-slots-per-frame key is missing.
>>
>> Supporting at least 18 in the backend is required for existing
>> frontends.  Limiting frontends to 17 allows them to work with all
>> backends (including recent Linux version that only supported 17).
>>
>> It's not clear why 19 or 20 were suggested as possible values.  I
>> checked back to 2.6.18 and MAX_SKB_FRAGS there is (65536/PAGE_SIZE + 2)
> 
> Because the check is >= MAX_SKB_FRAGS originally and James Harper told
> me that "Windows stops counting on 20".
> 
>> == 18.
>>
>> Separately, it may be sensible for the backend to drop packets with more
>> frags than max-slots-per-frame up to some threshold where anything more
>> is considered malicious (i.e., 1 - 18 slots is a valid packet, 19-20 are
>> dropped and 21 or more is a fatal error).
>>
> 
> Why drop the packet when we are able to process it? Frontend cannot know
> it has crossed the line anyway.

Because it's a change to the protocol and we do not want to do this for
a regression fix.

As a separate fix we can consider increasing the number of slots
per-packet once there is a mechanism to report this to the front end.

David
