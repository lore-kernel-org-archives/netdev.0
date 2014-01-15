From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] sysfs_rename_link() and its usage
Date: Tue, 14 Jan 2014 17:35:23 -0800
Message-ID: <87iotmc9ic.fsf@xmission.com>
References: <20140114171740.GB1867@redhat.com>
	<20140114182135.GA29296@kroah.com> <20140114191208.GA9942@redhat.com>
	<20140114193139.GA3636@kroah.com> <20140114210610.GC9942@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg KH <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140114210610.GC9942@redhat.com> (Veaceslav Falico's message of
	"Tue, 14 Jan 2014 22:06:10 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Veaceslav Falico <vfalico@redhat.com> writes:

> On Tue, Jan 14, 2014 at 11:31:39AM -0800, Greg KH wrote:
>>On Tue, Jan 14, 2014 at 08:12:08PM +0100, Veaceslav Falico wrote:
>>> On Tue, Jan 14, 2014 at 10:21:35AM -0800, Greg KH wrote:
>>> >On Tue, Jan 14, 2014 at 06:17:40PM +0100, Veaceslav Falico wrote:
>>> >>Hi,
>>> >>
>>> >>I'm hitting a strange issue and/or I'm completely lost in sysfs internals.
>>> >>
>>> >>Consider having two net_device *a, *b; which are registered normally.
>>> >>Now, to create a link from /sys/class/net/a->name/linkname to b, one should
>>> >>use:
>>> >>
>>> >>sysfs_create_link(&(a->dev.kobj), &(b->dev.kobj), linkname);
>>> >>
>>> >>To remove it, even simpler:
>>> >>
>>> >>sysfs_remove_link(&(a->dev.kobj), linkname);
>>> >>
>>> >>This works like a charm. However, if I want to use (obviously, with the
>>> >>symlink present):
>>> >>
>>> >>sysfs_rename_link(&(a->dev.kobj), &(b->dev.kobj), oldname, newname);
>>> >
>>> >You forgot the namespace option to this call, what kernel version are
>>> >you using here?
>>>
>>> It's git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next ,
>>> 3.13-rc6 with some networking patches on top of it.
>>>
>>> And wrt namespace - there are two functions, one is sysfs_rename_link(),
>>> which calls the second one - sysfs_rename_link_ns() with NULL namespace.
>>>
>>> >
>>> >>this fails with:
>>> >>
>>> >>"sysfs: ns invalid in 'a->name' for 'oldname'"
>>> >
>>> >Looks like the namespace for this link isn't valid.
>>>
>>> Yep, though dunno why.
>>
>>Are you testing this with network namespaces enabled?  Perhaps that is
>>why, you need to specify the namespace of the link that you are
>>changing.
>>
>>The fact that the bridge link works is odd to me, I would think that it
>>too needs to specify the network namespace involved, but perhaps bridge
>>objects aren't part of any specific network namespace?  I don't know the
>>bridging code at all, sorry.
>
> Yep, might be it, will test soon and come back with the results.
>
> What still bugs me, though, is the logic - why is it possible to remove/add
> without specifying namespace, while it fails to rename it? Maybe the rename
> function should do a better job at detecting the namespace?

The basic sysfs_rename primitive and device_rename support moving
network devices across namespaces.  Since the new name can be in a new
namespace the network namespace the new network namespace needs to be
specified.

The reason the bridge code is different is that apparently Tejun broke
the bridge code when he converted sysfs.  Apparently no one has tested
the appropriate bridge path with network namespaces enabled and screamed
yet.

sysfs_rename_link was originally written to infer figure everything out
based on the target device.  Because symlinks only make sense being in
the same namespace of their devices.  Tejun broke the inference and now
you are having hard time using the code.

Tejun could you please take care of this breakage.

The commit that broke things was:

commit 4b30ee58ee64c64f59fd876e4afa6ed82caef3a4
Author: Tejun Heo <tj@kernel.org>
Date:   Wed Sep 11 22:29:06 2013 -0400

    sysfs: remove ktype->namespace() invocations in symlink code
    
    There's no reason for sysfs to be calling ktype->namespace().  It is
    backwards, obfuscates what's going on and unnecessarily tangles two
    separate layers.
    
    There are two places where symlink code calls ktype->namespace().
    
    * sysfs_do_create_link_sd() calls it to find out the namespace tag of
      the target directory.  Unless symlinking races with cross-namespace
      renaming, this equals @target_sd->s_ns.
    
    * sysfs_rename_link() uses it to find out the new namespace to rename
      to and the new namespace can be different from the existing one.
      The function is renamed to sysfs_rename_link_ns() with an explicit
      @ns argument and the ktype->namespace() invocation is shifted to the
      device layer.
    
    While this patch replaces ktype->namespace() invocation with the
    recorded result in @target_sd, this shouldn't result in any behvior
    difference.
    
    Signed-off-by: Tejun Heo <tj@kernel.org>
    Cc: Eric W. Biederman <ebiederm@xmission.com>
    Cc: Kay Sievers <kay@vrfy.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Eric
