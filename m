From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [1/4] DST: Distributed storage documentation.
Date: Mon, 10 Dec 2007 15:31:48 +0100
Message-ID: <1197297108.6399.91.camel@lov.site>
References: <11972872493977@2ka.mipt.ru> <11972872501664@2ka.mipt.ru>
	 <3ae72650712100451h6a84d6cfs9b3a2954c13c4612@mail.gmail.com>
	 <20071210125839.GA16789@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, Greg KH <greg@kroah.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20071210125839.GA16789@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-12-10 at 15:58 +0300, Evgeniy Polyakov wrote:
> On Mon, Dec 10, 2007 at 01:51:43PM +0100, Kay Sievers (kay.sievers@vrfy.org) wrote:
> > On Dec 10, 2007 12:47 PM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> > > diff --git a/Documentation/dst/sysfs.txt b/Documentation/dst/sysfs.txt
> > > new file mode 100644
> > > index 0000000..79d79dc
> > > --- /dev/null
> > > +++ b/Documentation/dst/sysfs.txt
> > > @@ -0,0 +1,30 @@
> > > +This file describes sysfs files created for each storage.
> > > +
> > > +1. Per-storage files.
> > > +Each storage has its own dir /sysfs/devices/$storage_name,
> > 
> > It's always /sys/devices/.
> 
> I meant that for each new device, it will be placed into
> /sys/devices/its_name, but it can also be accessed via
> /sys/bus/dst/devices/

Still, it looks like a path. :)

Please don't reference any device directly with a /sys/devices/ path.
You have to use the subsystem links to the devices
in /sys/bus/dst/devices/. Devices are free to move around
in /sys/devices, even during runtime. Yours don't do, but anyway, please
remove all mentioning of direct access to /sys/devices/.

Btw, where is the top-level /sys/devices/storage/ coming from? I don't
see that in the code. We don't accept any new "virtual parents" here.
Your devices will automatically appear in /sys/devices/virtual/dst/, and
not below your own parent. But that path does not matter anyway, because
you should only access them from the /sys/bus/dst/devices/ directory.

And in general please don't claim generic names like "storage" in any
namespace for a very specific subsystem like this.

> > > +which contains following files:
> > > +
> > > +alg - contains name of the algorithm used to created given storage
> > > +name - name of the storage
> > > +nodes - map of the storage (list of nodes and their sizes and starts)
> > > +remove_all_nodes - writable file which allows to remove all nodes from given
> > > +       storage
> > > +n-$start-$cookie - per node directory, where
> > > +       $start - start of the given node in sectors,
> > > +       $cookie - unique node's id used by DST
> > > +
> > > +2. Per-node files.
> > > +Node's files are located in /sysfs/devices/$storage_name/n-$start-$cookie
> > > +directory, described above.
> > 
> > To which class or bus do the devices you create belong? Care to show a
> > "tree" or "ls -la" of the device?
> 
> It is 'dst' bus.
> 
> uganda:~/codes# ls -la /sys/devices/staorge/
> total 0
> drwxr-xr-x 4 root root    0 2007-12-10 11:46 .
> drwxr-xr-x 9 root root    0 2007-12-10 11:46 ..
> -r--r--r-- 1 root root 4096 2007-12-10 11:46 alg
> lrwxrwxrwx 1 root root    0 2007-12-10 11:46 bus -> ../../bus/dst
> drwxr-xr-x 3 root root    0 2007-12-10 11:46 n-0-ffff81003e24117
> -r--r--r-- 1 root root 4096 2007-12-10 11:46 name
> -r--r--r-- 1 root root 4096 2007-12-10 11:46 nodes
> drwxr-xr-x 2 root root    0 2007-12-10 11:46 power
> -rw-r--r-- 1 root root 4096 2007-12-10 11:46 remove_all_nodes
> lrwxrwxrwx 1 root root    0 2007-12-10 11:46 subsystem -> ../../bus/dst
> -rw-r--r-- 1 root root 4096 2007-12-10 11:46 uevent

Ok, how does:
  ls -l /sys/devices/storage/n-0-ffff81003e24117
look?

> uganda:~/codes# ls -l /sys/bus/dst/
> total 0
> drwxr-xr-x 2 root root    0 2007-12-10 09:52 devices
> drwxr-xr-x 2 root root    0 2007-12-10 09:52 drivers
> -rw-r--r-- 1 root root 4096 2007-12-10 11:46 drivers_autoprobe
> --w------- 1 root root 4096 2007-12-10 11:46 drivers_probe

How does:
  ls -l /sys/bus/dst/devices
look?


Further questions:
Why do you do your own refcounting instead of using kref?
Why don't you use groups for the attributes?
Why don't you use default attributes for the device, where you get all
error handling done by the core.

Kay

