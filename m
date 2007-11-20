From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: 2.6.24-rc3: find complains about /proc/net
Date: Tue, 20 Nov 2007 14:52:04 -0700
Message-ID: <m11wakshyz.fsf@ebiederm.dsl.xmission.com>
References: <20071119191000.GA1560@elf.ucw.cz>
	<200711192304.25087.rjw@sisk.pl> <4743026B.2020907@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:57398 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752861AbXKTVxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 16:53:23 -0500
In-Reply-To: <4743026B.2020907@openvz.org> (Pavel Emelyanov's message of "Tue,
	20 Nov 2007 18:51:07 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov <xemul@openvz.org> writes:

> Rafael J. Wysocki wrote:
>> On Monday, 19 of November 2007, Pavel Machek wrote:
>>> Hi!
>>>
>>> I think that this worked before:
>>>
>>> root@amd:/proc# find . -name "timer_info"
>>> find: WARNING: Hard link count is wrong for ./net: this may be a bug
>>> in your filesystem driver.  Automatically turning on find's -noleaf
>>> option.  Earlier results may have failed to include directories that
>>> should have been searched.
>>> root@amd:/proc#
>> 
>> I'm seeing that too.
>
> I have a better things with 2.6.24-rc3 ;)
>
> # cd /proc/net
> # ls ..
> ls: reading directory ..: Not a directory

Ok.  That part is truly a bug.
Looks like you have tracked down the cause.
Grumble you are getting the wrong .. :(

> and this
>
> # cd /proc
> # find
> ...
> ./net
> find: . changed during execution of find
> # find net
> find: net changed during execution of find
> # find net/
> <this works ok however>
>
> Moreover. Program that opens /proc/net and dumps the /proc/self/fd
> files produces the following:
>
> # cd /
> # a.out /proc/net
> ...
> lr-x------  1 root root 64 Nov 20 18:02 3 -> /proc/net/net (deleted)
> ...
> # cd /proc/net
> # a.out .
> ...
> lr-x------  1 root root 64 Nov 20 18:03 3 -> /proc/net/net (deleted)
> ...

> # a.out ..
> ...
> lr-x------  1 root root 64 Nov 20 18:03 3 -> /proc/net
> ...

Yes all of those are nasty.  So much for my clever way of implementing
these things.  Grr. Simple hacks that almost work!

> This all is somehow related to the shadow proc files.
> E.g. the first problem (with -ENOTDIR) is due to the shadow /proc/net
> dentry doesn't implement the .readdir method:
>
> static const struct file_operations proc_net_dir_operations = {
>         .read                   = generic_read_dir,
> };
>
> And I haven't managed to find out why the rest problems
> occur...
>
> Eric, do you have fixes for it?

Not exactly.  It is tricky.  I have known there are issues but so far
the difficulty of a better solution has been higher then my annoyance
level with this problem.

A special solution for !CONFIG_NET_NS may be practical for 2.6.24.

The only way I know of to really solve this problem cleanly and
completely is to make /proc/net an explicit symlink to /proc/self/net
and make /proc/<pid>/net a magic mountpoint (ala nfs automounts) that
mounts a per network namespace filesystem.  Al Viro wasn't to happy
when I suggested it (mostly because he was convinced such a solution
was likely to be full of races).

The half assed clean solution is to ensure nothing under /proc/net
gets cached and ensure the dentry tree is built properly, for the
current reader of /proc.

A third option is to fix .. in /proc/net.  Although I'm a bit
dubious if that will do more then fix a few symptoms with the
current solution.

Eric
