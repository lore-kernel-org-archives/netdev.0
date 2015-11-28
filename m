From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5] mpls: support for dead routes
Date: Fri, 27 Nov 2015 22:15:42 -0800
Message-ID: <5659468E.5080905@cumulusnetworks.com>
References: <1448407342-61181-1-git-send-email-roopa@cumulusnetworks.com> <20151125.111827.2264696682456564840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36420 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118AbbK1GPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2015 01:15:45 -0500
Received: by pacdm15 with SMTP id dm15so131598583pac.3
        for <netdev@vger.kernel.org>; Fri, 27 Nov 2015 22:15:44 -0800 (PST)
In-Reply-To: <20151125.111827.2264696682456564840.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/15, 8:18 AM, David Miller wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Tue, 24 Nov 2015 15:22:22 -0800
>
>> v4 -v5
>> 	- if kmemdup fails, modify the original route in place. This is a
>> 	corner case and only side effect is that in the remote case
>> 	of kmemdup failure, the changes will not be atomically visible
>> 	to datapath.
> I really don't like this.
>
> Either you need to make the changes appear atomic to the data path,
> and you therefore must fail the operation if kmemdup() fails, or it
> doesn't matter and you should just always change the route in-place.
>
> As far as I can tell it can't possibly matter.  The alive counter is
> never modified by the data path, it is only tested to make a multipath
> decision.  Likewise it's rather harmless to send a frame or two via a
> device currently going down.
>
> But if you're convinced it matters, then is matters, and you can't
> fake things when kmemdup() fails.  And in that case I would recommend
> that you use a two pass algorithm, one pass allocates all of the
> new routes, and the second fills them in, inserts them, and frees
> the old ones.
>
> That is the only way you can unwind and fail cleanly.
>
> And oh yeah, that's right, you can't really fail this and make the
> ifdown not proceed.
>
> So you're stuck, right?
>
> That's why this has to be designed in a way where memory allocations
> are not necessary.  These notifiers aren't really designed to facilitate
> situations that require resource acquisitions that can fail.
>
Get your point. I am not convinced that the atomic update matters much for the transient case.
 I was trying to accommodate comments i got during the review and it seemed ok to cover both
cases by optionally doing the atomic update when we can. But, I get your position on this.
