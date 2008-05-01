From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 00/10] sysfs tagged directories
Date: Thu, 1 May 2008 10:10:51 -0500
Message-ID: <20080501151051.GB16038@sergelap.austin.ibm.com>
References: <20080429171015.473938697@theryb.frec.bull.fr> <20080429173621.GA16625@suse.de> <20080429180445.GA18110@sergelap.austin.ibm.com> <20080429184151.GA19794@suse.de> <20080429193417.GA19282@sergelap.austin.ibm.com> <20080501031341.GD4911@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Tejun Heo <htejun@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:45145 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751452AbYEAPKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2008 11:10:55 -0400
Content-Disposition: inline
In-Reply-To: <20080501031341.GD4911@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Greg KH (gregkh@suse.de):
> On Tue, Apr 29, 2008 at 02:34:17PM -0500, Serge E. Hallyn wrote:
> > Finally, to give an idea about how the trees end up looking, here is
> > what I just did on my test box;
> > 
> > /usr/sbin/ip link add type veth
> > mount --bind /mnt /mnt
> > mkdir /mnt/sys
> > mount --make-shared /mnt
> > ns_exec -cmn /bin/sh  # unshare netns and mounts ns
> >  # At this point, I still see eth0 and friends under /sys/class/net etc
> > mount -t sysfs none /sys
> >  # At this point, /sys/class/net has only lo0 and sit0, and
> >  # /sys/devices/pci0000:00/0000:00:03.0/net:eth0 is a dead link
> > mount --bind /sys /mnt/sys
> > echo $$
> > 	3050
> > 
> > (back in another shell):
> > /usr/sbin/ip link set veth1 netns 3050
> > 
> > (back in container shell):
> > /usr/sbin/ip link set veth1 name eth0
> >  # Now /sys/devices/pci0000:00/0000:00:03.0/net:eth0 is a live link to
> >  # the /sys/class/net/eth0 which is really the original veth1
> > exit
> > 
> > ls /mnt/sys/class/net
> >  # empty directory
> 
> What does this all look like without CONFIG_SYSFS_DEPRECATED enabled,
> which is what all sane distros do these days.  That's going to change
> the look of the tree for stuff like this a lot I think...
> 
> thanks,
> 
> greg k-h

Now before moving veth1 to the new netns, we have in the container:
/sys/class/net:
lo  sit0

/sys/devices/virtual/net:
lo  sit0

and after moving veth1, we have in the container:

/sys/class/net:
lo  sit0  veth1

/sys/devices/virtual/net:
lo  sit0

In the parent network namespace, veth1 is removed from /sys/class/net
but remains in /sys/devices/virtual/net.

I'm not sure whether this is the renaming bug that Daniel Lezcano's
patch addresses.  If not (as I suspect) then that clearly needs to be
fixed.

Benjamin can you play around with this and test it with Daniel's
patch?

thanks,
-serge
