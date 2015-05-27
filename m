From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: skip fdb add if the port shouldn't learn
Date: Wed, 27 May 2015 09:05:32 +0200
Message-ID: <CABQ03vEQhdXgWk5r103Yd0CPxEWuU3i0m8ztQjtgR0NFDbEXRQ@mail.gmail.com>
References: <1432204977-4293-1-git-send-email-nikolay@cumulusnetworks.com>
	<20150526102809.5c3e8abc@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Wilson Kok <wkok@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>,
	bridge@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:35514 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbbE0HFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 03:05:33 -0400
Received: by iesa3 with SMTP id a3so6884472ies.2
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 00:05:33 -0700 (PDT)
In-Reply-To: <20150526102809.5c3e8abc@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 26, 2015 at 7:28 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Thu, 21 May 2015 03:42:57 -0700
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
>
>> From: Wilson Kok <wkok@cumulusnetworks.com>
>>
>> Check in fdb_add_entry() if the source port should learn, similar
>> check is used in br_fdb_update.
>> Note that new fdb entries which are added manually or
>> as local ones are still permitted.
>> This patch has been tested by running traffic via a bridge port and
>> switching the port's state, also by manually adding/removing entries
>> from the bridge's fdb.
>>
>> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
> What is the problem this is trying to solve?
>
> I think user should be allowed to manually add any entry
> even if learning.

Hi Stephen,
I have been thinking about the use case and have discussed it
internally with colleagues and the patch
author, the main problem is when there's an external software that
adds dynamic entries (learning) and
it could experience a race condition, here's a possible situation:
* external software learns a mac from hw, sends an add to kernel
 * right before that, port goes blocking (or down) and kernel flushes
   mac, sends notification about the state change and mac flush
 * right after that, kernel gets the previous add from external software, it's
   allowed to add, and then sends an add notification
 * mean while, external software processes the link block/down and mac flush,
   followed by the mac add from kernel.  At this point, external software can't
   really know whether it's a user adding the mac intentionally or it's
   a race.

This issue can't really be avoided in user-space.
As I've noted local and static entries are still allowed, and iproute2
bridge utility always
marks the entries as static (NUD_NOARP), this only affects external
dynamic entries which
are usually sent by something that does the learning externally.
I'll keep digging to see if there's another way to go about this since
I'd like to give the user
full freedom. Personally I don't have strong feeling for this patch
and if it's not preferred then
I'll post a revert.

Thanks,
 Nik
