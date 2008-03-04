From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/2] Fix /proc/net in presence of net namespaces
Date: Tue, 04 Mar 2008 15:49:11 -0700
Message-ID: <m1ejaq2jh4.fsf@ebiederm.dsl.xmission.com>
References: <47C6D743.1050802@openvz.org>
	<m1y794514k.fsf@ebiederm.dsl.xmission.com>
	<20080228211720.GA1232@vino.hallyn.com>
	<m1k5ko4sfi.fsf@ebiederm.dsl.xmission.com>
	<47C7BB1B.9060906@openvz.org>
	<m1zlth3m5f.fsf@ebiederm.dsl.xmission.com>
	<47CBBFBC.3010607@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: serge@hallyn.com, Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:34753 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754573AbYCDWvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 17:51:22 -0500
In-Reply-To: <47CBBFBC.3010607@openvz.org> (Pavel Emelyanov's message of "Mon,
	03 Mar 2008 12:07:08 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov <xemul@openvz.org> writes:

>>>> - Have readdir and lookup filter the directory entries by the pid
>>>>   namespace of the proc mount.
>>> So, how are you going to filter the lookup? The problem I see - you have
>>> a process that opened the /proc/.netns/X directory (he onws that namespace)
>>> and the other one trying to do the same. The VFS layer finds the hashed
>>> dentry corresponding to this /proc/.netns/X. The only way you can prevent
>>> VFS from giving one to the second task is to override .d_revalidate method 
>>> and drop that dentry....
>>>
>>> But we've already tried to walk this way with no luck.
>> 
>> I meant a per mount filtering.  Exactly like we do for the pids now.
>
> We (me) do not perform any "filtering" in /proc. I just make /proc play 
> the VFS rules - one super-block one tree of dentries.

Exactly.  For different super blocks we return a different set of
processes and a different set of numbers of those processes.  If you
do use ids that do not live in a namespace I agree you do not need to
do different things for different mounts, but that seems ugly and
problematic.

>>>> If we make namespaces show up anywhere besides under
>>>> "/proc/<pid>/task/<tid>/" we have to do something like this, and pids
>>>> are largely designed for this kind of use.
>>> Proc consists of two parts - the <pid>-s one with generated-on-the-fly
>>> entries and the static one that is represented by proc_dir_entry tree.
>>> Do you propose to mix those two?
>> 
>> Yes.  Because the static entries are beginning to depend on process
>> specific attributes.  We have already started with /proc/mounts.
>
> /proc/<pid>/mounts is not represented with any proc_dir_entry, but
> what you're proposing with /proc/<pid>/net seems like doing this
> representation.

Yes.  I am talking about placing things represented with a
prod_dir_entry and having them show up under a hierarchy not
represented with proc_dir_entries under /proc/<pid>.

As that is clean, worked well for /proc/mounts, does not
require ids at all, and is essentially the optimal form
for monitoring processes.

/proc/mounts used to have a proc_dir_entry.  When it was reimplemented
to be per fs namespace that was removed.

>>>> just need a non-global id for our directory entries so we don't paint
>>>> ourselves into a corner.
>>> What namespace do you mean by "non-global"?
>> 
>> The best is an id I can take with me when I migrate from machine A
>> to machine B.  An id in some namespace or a form that doesn't need
>> an id at all is the core requirement.
>
> If we're OK in having a /proc/netns/<xxx> for each namespace, then
> this <xxx> is an id, regardless whatever it is - a pre-generated 
> number, a pointer, etc.
>
> That said, your only wish is to make this <xxx> be preservable across 
> migration, right?

No, that is not my only wish.

- I wish for a clean maintainable interface.
- I wish for an interface that we can use for monitoring programs like
  top and ps.
- I wish for an interface that is migration safe.

It is my opinion that using an id is simply an optimization to reduce
the number of cached proc dentries.

I gave a full run down of what I wish and the reasons for it earlier
in this thread. I have not seen you respond to that message.

Currently I am NOT ok having a /proc/netns/<xxx>. It appears to be
a contentious premature optimization.

VFS clean, maintainable, and usable for monitoring is
/proc/<pid>/task/<tid>/net.

We can always figure out how to optimize that form later.

Eric
