From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH RFC net-next 3/4] bridge: move write-heavy fdb members in
 their own cache line
Date: Tue, 31 Jan 2017 17:39:58 +0100
Message-ID: <bbd290ea-3760-d68b-ba5d-1594ef33ca90@cumulusnetworks.com>
References: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
 <1485876718-18091-4-git-send-email-nikolay@cumulusnetworks.com>
 <20170131083757.17b9a2aa@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:34944 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751064AbdAaQkB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 11:40:01 -0500
Received: by mail-wm0-f46.google.com with SMTP id b65so86757385wmf.0
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 08:40:00 -0800 (PST)
In-Reply-To: <20170131083757.17b9a2aa@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/01/17 17:37, Stephen Hemminger wrote:
> On Tue, 31 Jan 2017 16:31:57 +0100
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> 
>> Fdb's used and updated fields are written to on every packet forward and
>> packet receive respectively. Thus if we are receiving packets from a
>> particular fdb, they'll cause false-sharing with everyone who has looked
>> it up (even if it didn't match, since mac/vid share cache line!). The
>> "used" field is even worse since it is updated on every packet forward
>> to that fdb, thus the standard config where X ports use a single gateway
>> results in 100% fdb false-sharing. Note that this patch does not prevent
>> the last scenario, but it makes it better for other bridge participants
>> which are not using that fdb (and are only doing lookups over it).
>> The point is with this move we make sure that only communicating parties
>> get the false-sharing, in a later patch we'll show how to avoid that too.
>>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> ---
> 
> What about making updated a per-cpu value?
> 

Quote from patch 0000:
"I'm not a fan of adding new options to the bridge, so I'm open to
suggestions for this one. Things I've tried before that:
- dynamically allocate a pool of percpu memory for used/updated fields
  (works but it's more complicated as we need dynamic resizing, too)
- dynamically allocate percpu memory for each fdb separately (I'm not a fan
  of this one, but it's much simpler to implement)

Of these two obviously the first approach worked best, but the complexity
it brings is considerable, while with this patchset we can achieve the same
result with proper configuration. Any feedback on this one would be greatly
appreciated."

I'm not sure how acceptable it is to do per-cpu allocations for each fdb, as
a network storm or flood can cause many of these. That's the reason I went with
this approach.
Would it be okay if we allocate per-cpu for each fdb ?
