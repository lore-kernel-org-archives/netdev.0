From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 0/2] Fix /proc/net in presence of net namespaces
Date: Mon, 03 Mar 2008 12:07:08 +0300
Message-ID: <47CBBFBC.3010607@openvz.org>
References: <47C6D743.1050802@openvz.org>	<m1y794514k.fsf@ebiederm.dsl.xmission.com>	<20080228211720.GA1232@vino.hallyn.com>	<m1k5ko4sfi.fsf@ebiederm.dsl.xmission.com>	<47C7BB1B.9060906@openvz.org> <m1zlth3m5f.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: serge@hallyn.com, Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47348 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753073AbYCCJIU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 04:08:20 -0500
In-Reply-To: <m1zlth3m5f.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Pavel Emelyanov <xemul@openvz.org> writes:
> 
>>> I was thinking we might be able to hide the existence of
>>> /proc/.netns/NNN/  however we can read the current working directory.
>>> So even if we only allow explicit access through /proc/net and all
>>> others paths don't work we have something that is visible.
>> I have a patch that overrides the ->readdir method for /proc/.netns,
>> so that you can no longer read the directory contents, but you still
>> can guess one by guessing and opening files in it. Overriding the 
>> ->lookup to screw one up looks like "shadowing" technics.
> 
> Or looking at the symlinks under /proc/<pid>/fd/1
> Or opening something under /proc/net/ and calling get pwd.
> 
>> OTOH - consider you have the ids of existing net namespaces, but cannot 
>> read the contents on any but yours. So what? This information is useless
>> for you. So I dropped this part of a patch.
> 
> However it is fundamental that monitoring programs want to inspect
> the namespaces of other processes.
> 
> In theory the resource group stuff was suppose to provide us with
> all of the names we would need.  However the semantics seem a bit
> to flexible to use for something like this.
> 
>>> - Have readdir and lookup filter the directory entries by the pid
>>>   namespace of the proc mount.
>> So, how are you going to filter the lookup? The problem I see - you have
>> a process that opened the /proc/.netns/X directory (he onws that namespace)
>> and the other one trying to do the same. The VFS layer finds the hashed
>> dentry corresponding to this /proc/.netns/X. The only way you can prevent
>> VFS from giving one to the second task is to override .d_revalidate method 
>> and drop that dentry....
>>
>> But we've already tried to walk this way with no luck.
> 
> I meant a per mount filtering.  Exactly like we do for the pids now.

We (me) do not perform any "filtering" in /proc. I just make /proc play 
the VFS rules - one super-block one tree of dentries.

>>> It looks like we have to tweak things just a bit so that free_pid
>>> would not be called until the pid namespace goes away.  Something
>>> similar to how we do the hash chains.
>> This is not about pid namespace, this is about net namespace and
>> tuning pids management to facilitate networking needs is not the right
>> thing to do.
> 
> Not exactly.  It is about process attribute visibility.  Which
> is what proc is about.  In plan9 where the concept comes from
> namespaces are referred to as process groups, and that is a valid
> view.  At least from a monitoring perspective.
> 
>>> If we make namespaces show up anywhere besides under
>>> "/proc/<pid>/task/<tid>/" we have to do something like this, and pids
>>> are largely designed for this kind of use.
>> Proc consists of two parts - the <pid>-s one with generated-on-the-fly
>> entries and the static one that is represented by proc_dir_entry tree.
>> Do you propose to mix those two?
> 
> Yes.  Because the static entries are beginning to depend on process
> specific attributes.  We have already started with /proc/mounts.

/proc/<pid>/mounts is not represented with any proc_dir_entry, but
what you're proposing with /proc/<pid>/net seems like doing this
representation.

>>> just need a non-global id for our directory entries so we don't paint
>>> ourselves into a corner.
>> What namespace do you mean by "non-global"?
> 
> The best is an id I can take with me when I migrate from machine A
> to machine B.  An id in some namespace or a form that doesn't need
> an id at all is the core requirement.

If we're OK in having a /proc/netns/<xxx> for each namespace, then
this <xxx> is an id, regardless whatever it is - a pre-generated 
number, a pointer, etc.

That said, your only wish is to make this <xxx> be preservable across 
migration, right?

> Eric
> 

