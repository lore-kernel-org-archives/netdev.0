From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [RFC] sysfs_rename_link() and its usage
Date: Tue, 14 Jan 2014 20:12:08 +0100
Message-ID: <20140114191208.GA9942@redhat.com>
References: <20140114171740.GB1867@redhat.com>
 <20140114182135.GA29296@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140114182135.GA29296@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 14, 2014 at 10:21:35AM -0800, Greg KH wrote:
>On Tue, Jan 14, 2014 at 06:17:40PM +0100, Veaceslav Falico wrote:
>> Hi,
>>
>> I'm hitting a strange issue and/or I'm completely lost in sysfs internals.
>>
>> Consider having two net_device *a, *b; which are registered normally.
>> Now, to create a link from /sys/class/net/a->name/linkname to b, one should
>> use:
>>
>> sysfs_create_link(&(a->dev.kobj), &(b->dev.kobj), linkname);
>>
>> To remove it, even simpler:
>>
>> sysfs_remove_link(&(a->dev.kobj), linkname);
>>
>> This works like a charm. However, if I want to use (obviously, with the
>> symlink present):
>>
>> sysfs_rename_link(&(a->dev.kobj), &(b->dev.kobj), oldname, newname);
>
>You forgot the namespace option to this call, what kernel version are
>you using here?

It's git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next ,
3.13-rc6 with some networking patches on top of it.

And wrt namespace - there are two functions, one is sysfs_rename_link(),
which calls the second one - sysfs_rename_link_ns() with NULL namespace.

>
>> this fails with:
>>
>> "sysfs: ns invalid in 'a->name' for 'oldname'"
>
>Looks like the namespace for this link isn't valid.

Yep, though dunno why.

>
>> in
>>
>>  608 struct sysfs_dirent *sysfs_find_dirent(struct sysfs_dirent *parent_sd,
>> ...
>>  615         if (!!sysfs_ns_type(parent_sd) != !!ns) {
>>  616                 WARN(1, KERN_WARNING "sysfs: ns %s in '%s' for '%s'\n",
>>  617                         sysfs_ns_type(parent_sd) ? "required" : "invalid",
>>  618                         parent_sd->s_name, name);
>>  619                 return NULL;
>>  620         }
>>
>> Code path:
>> warn_slowpath_fmt+0x46/0x50
>> sysfs_get_dirent_ns+0x30/0x80
>> sysfs_find_dirent+0x84/0x110
>> sysfs_get_dirent_ns+0x3e/0x80
>> sysfs_rename_link_ns+0x54/0xd0
>>
>> I have no idea what this code means. Is there any reason for it to
>> fail (i.e. am I doing something wrong?) or I've hit a bug?
>
>What exactly are you trying to do here?  Care to provide a pointer to
>your code somewhere?

I've tried to handle the network device renames, ended up doing it with
sysfs_remove/add_link() calls. Patches:

http://patchwork.ozlabs.org/patch/310798/
http://patchwork.ozlabs.org/patch/310796/

If an upper device (say, vlan, bonding, bridge etc.) enslaves another
device, symlinks are created (given bridge0 and eth0):

/sys/class/net/eth0/upper_bridge0 -> ../bridge0
/sys/class/net/bridge0/lower_eth0 -> ../eth0

However, in case someone renames eth0/bridge0, these symlinks should also
be renamed, and sysfs_rename_link() should fit great here. But it fails.

>
>> I've tested the only user of it (bridge) - and it works fine, however it's
>> not using its own net_device's kobject but rather its own dir.
>
>The driver core also uses this function, and it works there, so I'd
>blame your code :)

Yeah, I'd also like to blame it, I'm afraid of touching anything
sysfs-related :).

>
>thanks,
>
>greg k-h
