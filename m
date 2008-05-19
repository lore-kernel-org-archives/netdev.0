From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Bugme-new] [Bug 10737] New: pktgen procfs problem
Date: Mon, 19 May 2008 14:34:38 -0700
Message-ID: <m11w3y7zbl.fsf@frodo.ebiederm.org>
References: <bug-10737-10286@http.bugzilla.kernel.org/>
	<20080517141036.d8f3c768.akpm@linux-foundation.org>
	<482F88DE.8090508@trash.net>
	<20080517215641.acb94677.akpm@linux-foundation.org>
	<48301BE0.9040907@trash.net> <48302E09.8080701@trash.net>
	<48304BB5.7090805@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, devzero@web.de,
	Robert Olsson <robert.olsson@its.uu.se>,
	"Denis V. Lunev" <den@openvz.org>,
	Pavel Emelyanov <xemul@openvz.org>,
	Ben Greear <greearb@candelatech.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:41901 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756720AbYESVkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 17:40:31 -0400
In-Reply-To: <48304BB5.7090805@trash.net> (Patrick McHardy's message of "Sun,
	18 May 2008 17:31:01 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> writes:

> Patrick McHardy wrote:
>>>>> I've been looking into the same problem, without much success so
>>>>> far. The problem appears to affect any /proc/net file, but not
>>>>> files outside of /proc/net, so I'm guessing its net-ns related.
>>>>> A testcase found by Ben Greear is opening the file multiple times:
>>>>>
>>>>> # /tmp/open /proc/net/kpktgen_0
>>>>>
>>>>> => refcnt goes to 1
>>>>>
>>>>> ^C
>>>>>
>>>>> => refcnt goes to 0
>>>>>
>>>>> Without ^C and opening the file a second time:
>>>>>
>>>>> # /tmp/open /proc/net/kpktgen_0
>>>>>
>>>>> => refcnt goes to 2 (sometimes also 11)
>>>>>
>>>>> ^C
>>>>>
>>>>> => refcnt stays at previous value.
>>>>>
>>>>> The refcnt even leaks if the file can't be successfully opened,
>>>>> for example because of lacking permissions.

How are you reading the refcount on kpktgen_0? Just a printk in the
kernel code?

>> Some more information: the problem seems to occur only if
>> the file is opened by two different processes.
>>
>> I'm starting a bisection now.
>
>
> git-bisect identified e9720acd ([NET]: Make /proc/net a symlink
> on /proc/self/net (v3)) as the guilty commit. I couldn't find
> the problem in that commit, so someone with a better understanding
> of how this is supposed to work should look into it.

To recap:
- The problem is that we get complaints from remove_proc_entry
  on unload of the pktgen module.

- The problem appears to only happen when multiple processes open the file.

- The problem only appears after we moved /proc/net into /proc/<pid>/net


The obvious candidate is that we have multiple dcache entries for the
same proc inode.

It looks like time to reproduce this and see if we can figure out why
kpktgend_1 is still exists in the directory we are removing.



Eric

