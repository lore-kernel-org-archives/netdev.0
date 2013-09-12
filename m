From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCHSET] sysfs: disentangle kobject namespace handling from
 sysfs
Date: Wed, 11 Sep 2013 20:19:12 -0700
Message-ID: <20130912031912.GA9773@kroah.com>
References: <1378952949-7900-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, kay@vrfy.org, ebiederm@xmission.com,
	netdev@vger.kernel.org, lizefan@huawei.com
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1378952949-7900-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 11, 2013 at 10:29:02PM -0400, Tejun Heo wrote:
> Hello,
> 
> I'll send out multiple patchsets to separate out sysfs from driver
> core and kobject.  The eventual goal is making sysfs modular enough so
> that cgroup can replace its nightmarish cgroupfs implementation which
> repeated and worsened all the past mistakes of sysfs.  This patchset
> is first of the effort and separates out kobject namespace handling
> from sysfs.
> 
> I never really understood why namespace support was added the way it
> was added.

I just took the patches and didn't ask questions :)

> Namespace information is communicated to sysfs via
> callbacks and back-queries to upper layer, which is a very unusual and
> weird thing to do when all the involved operations are synchronous.
> For example, a tagged attribute creation looks like the following.
> 
>  driver code                    driver callback
>         v                                 ^
>  netdev_class_create_file()               |
>         v                       class_attr->namespace()
>  class_create_file()            class_attr_namespace()
>         v                                 |
>  sysfs_create_file()	                  |
>         v                                 |
>  sysfs_attr_ns() -------------> sysfs_ops->namespace()
> 
> This is an absurd thing to do.  It significantly obfuscates what's
> going on and adds unnecessary uncertainties - for example, can
> namespace() return value disagree with the recorded s_ns value without
> being renamed?  If so, how should that be handled?  If not, what
> guarantees that?  Even the basic placements of callbacks don't make
> much, if any, sense.  Why is per-directory namespace() callback in
> kobj_type while per-attr namespace() callback is in sysfs_ops?  What
> does this even mean?
> 
> Maybe there's some grand design scheme governing all this but it isn't
> obvious at all and the whole thing looks like a hodgepodge of
> short-sighted hacks.
> 
> There is absolutely *nothing* which requires this convolution.  NS tag
> can simply be passed down the stack just like any other type of
> information and adding an extra argument or variant of interface to
> pass down the extra information is way more straight-forward and
> apparently even takes less amount of code, so let's please stop the
> insanity.
> 
> This patchset contains the following seven patches.
> 
>  0001-sysfs-drop-semicolon-from-to_sysfs_dirent-definition.patch
>  0002-sysfs-make-attr-namespace-interface-less-convoluted.patch
>  0003-sysfs-remove-ktype-namespace-invocations-in-director.patch
>  0004-sysfs-remove-ktype-namespace-invocations-in-symlink-.patch
>  0005-sysfs-drop-kobj_ns_type-handling.patch
>  0006-sysfs-clean-up-sysfs_get_dirent.patch
>  0007-sysfs-name-comes-before-ns.patch
> 
> 0001 is a minor prep patch.
> 
> 0002 removes the attr namespace callback.
> 
> 0003-0004 push the dir namespace callback invocations from sysfs to
> kobjct layer.  Eventually, this callback should go too.
> 
> 0005 simplifies sysfs ns support such that sysfs doesn't have any
> specific knowledge of kobj namespaces.  It now purely deals with
> pointer tags.  Combined with the previous changes, this makes sysfs ns
> support mostly modular.
> 
> 0006-0007 are cleanup patches to make param orders conventional and
> consistent - optional param after mandatory one; otherwise, things get
> extremely confusing with different variants of interfaces which take
> or don't take optional params.  No idea how/why this was done the
> wrong way.
> 
> This patchset is based on top of the current master
> c2d95729e3094ecdd8c54e856bbe971adbbd7f48 ("Merge branch 'akpm'
> (patches from Andrew Morton)") and available in the following git
> branch.
> 
>  git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git review-sysfs-separate-out-ns

Nice job with these.  Do you want me to add them to my tree for 3.13, or
do you want to take them through yours as you will be building on top of
them?

If yours, feel free to add:
	Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

To all of these.

And thanks for cleaning this up, it looks much better now.

greg k-h
