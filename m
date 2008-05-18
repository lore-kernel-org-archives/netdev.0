From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 10737] New: pktgen procfs problem
Date: Sun, 18 May 2008 03:39:42 +0200
Message-ID: <482F88DE.8090508@trash.net>
References: <bug-10737-10286@http.bugzilla.kernel.org/> <20080517141036.d8f3c768.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	devzero@web.de, Robert Olsson <robert.olsson@its.uu.se>,
	"Denis V. Lunev" <den@openvz.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55783 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753555AbYERBk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 21:40:57 -0400
In-Reply-To: <20080517141036.d8f3c768.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Sat, 17 May 2008 13:59:25 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
>
>   
>> http://bugzilla.kernel.org/show_bug.cgi?id=10737
>>
>>            Summary: pktgen procfs problem
>>            Product: Networking
>>            Version: 2.5
>>      KernelVersion: 2.6.26-rc2
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Other
>>         AssignedTo: acme@ghostprotocols.net
>>         ReportedBy: devzero@web.de
>>
>>
>> Latest working kernel version: n/a
>> Earliest failing kernel version: 2.6.26-rc2
>> Distribution: suse 10.1
>> Hardware Environment: p4 + gigabyte i915g MoBo
>> Software Environment:
>> Problem Description:
>> pktgen module ocaasional seems to leak procfs entry
>>
>> May 18 00:00:34 test kernel: [ 2663.373955] pktgen v2.69: Packet Generator for
>> packet performance testing.
>> May 18 00:00:34 test kernel: [ 2663.384819] remove_proc_entry: removing
>> non-empty directory 'net/pktgen', leaking at least 'kpktgend_1'
>>     
>
> ^^
>
> Possibly we were always leaking this procfs entry, and newly-added
> procfs diagnostics are now detecting it.
>   

I've been looking into the same problem, without much success so
far. The problem appears to affect any /proc/net file, but not
files outside of /proc/net, so I'm guessing its net-ns related.
A testcase found by Ben Greear is opening the file multiple times:

# /tmp/open /proc/net/kpktgen_0

=> refcnt goes to 1

^C

=> refcnt goes to 0

Without ^C and opening the file a second time:

# /tmp/open /proc/net/kpktgen_0

=> refcnt goes to 2 (sometimes also 11)

^C

=> refcnt stays at previous value.

The refcnt even leaks if the file can't be successfully opened,
for example because of lacking permissions.

