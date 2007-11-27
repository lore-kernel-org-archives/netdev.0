From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2.6.24-rc3] Fix /proc/net breakage
Date: Tue, 27 Nov 2007 05:36:49 -0700
Message-ID: <m1hcj7lva6.fsf@ebiederm.dsl.xmission.com>
References: <20071119191000.GA1560@elf.ucw.cz>
	<200711192304.25087.rjw@sisk.pl> <4743026B.2020907@openvz.org>
	<m1hcj8mz1p.fsf_-_@ebiederm.dsl.xmission.com>
	<474BFD83.6060500@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:40151 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444AbXK0Mi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 07:38:26 -0500
In-Reply-To: <474BFD83.6060500@openvz.org> (Pavel Emelyanov's message of "Tue,
	27 Nov 2007 14:20:35 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov <xemul@openvz.org> writes:

> [snip]
>
>> 
>> Well I clearly goofed when I added the initial network namespace support
>> for /proc/net.  Currently things work but there are odd details visible
>> to user space, even when we have a single network namespace.
>> 
>> Since we do not cache proc_dir_entry dentries at the moment we can
>> just modify ->lookup to return a different directory inode depending
>> on the network namespace of the process looking at /proc/net, replacing
>> the current technique of using a magic and fragile follow_link method.
>> 
>> To accomplish that this patch:
>> - introduces a shadow_proc method to allow different dentries to
>>   be returned from proc_lookup.
>> - Removes the old /proc/net follow_link magic
>> - Fixes a weakness in our not caching of proc generic dentries.
>> 
>> As shadow_proc uses a task struct to decided which dentry to return we
>> can go back later and fix the proc generic caching without modifying any code
> that
>> uses the shadow_proc method.
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>
> Thanks, Eric. 
>
> Much better ('find /proc' works and so does 'ls ..'), but one 
> issue is still unsolved :(
>
> I mentioned the program, that opens the directory and dumps the
> content of the /proc/self/fd. Here it is (stupid but simple):

The cause is totally different this time, and is not limited
to /proc/net.  But this is the only side effect of the changes now.

I used the one line version of your test program to confirm this:

 $ cd /proc/driver/

 $ ls -l /proc/self/fd/100 100< .

 lr-x------ 1 eric eric 64 Nov 27 05:06 /proc/self/fd/100 -> /proc/driver/

 $  ls -l /proc/self/fd/100 100< .

 lr-x------ 1 eric eric 64 Nov 27 05:07 /proc/self/fd/100 -> /proc/driver (deleted)

What is happening is that the aggressive non-caching logic is dropping
the dentries and thus they show up as deleted.  I.e. When something
triggers another lookup of that dentry revalidate drops the old
dentry.

This actually fixes a race in /proc today where if you open a file,
remove the module for it, reload the module for that file, and then
attempt to access it, lookup will return the old dentry with the
old fops (even if there is not a current version of that file).
kill_proc_inodes current keeps us from using the old version of
the file_operations for directories (because it removes them) but
it does not prevent this DOS attack where keeping a proc file open
always ensures everyone will see the old version.

Given that the behavior seems more correct then what we have currently
I can live with files showing up as deleted from time to time.

Ultimately the fix is to correct the caching logic in
fs/proc/generic.c to only drop dentries when necessary and then
the deleted markers will only show up when the file or directory
really goes away.

I don't expect user space will care about the semi-legitimate
(deleted) marks.  So I don't think this one down side will be a big
deal for 2.6.24.

Eric




