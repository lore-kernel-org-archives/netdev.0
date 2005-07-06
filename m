From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: Re: [PATCH 2.6.13-rc1 8/17] bonding: SYSFS INTERFACE (large)
Date: Wed, 6 Jul 2005 12:09:06 -0700 (PDT)
Message-ID: <20050706190906.74128.qmail@web81301.mail.yahoo.com>
References: <Pine.CYG.4.58.0507061126090.1208@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, Radheka Godse <radheka.godse@intel.com>,
        fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitch Williams <mitch.a.williams@intel.com>
In-Reply-To: <Pine.CYG.4.58.0507061126090.1208@mawilli1-desk2.amr.corp.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mitch Williams <mitch.a.williams@intel.com> wrote:
> On Sat, 2 Jul 2005, Dmitry Torokhov wrote:
> 
> >
> > Couple of comments:
> [snip]
> 
> > > +
> > > +static struct class *netdev_class;
> > > +/*--------------------------- Data Structures
> -----------------------------*/
> > > +
> > > +/* Bonding sysfs lock.  Why can't we just use the subsytem lock?
> > > + * Because kobject_register tries to acquire the subsystem lock.  If
> > > + * we already hold the lock (which we would if the user was creating
> > > + * a new bond through the sysfs interface), we deadlock.
> > > + */
> > > +
> > > +struct rw_semaphore bonding_rwsem;
> >
> > klists were just added to the kernel proper. Does this sentiment still
> > holds true?
> 
> 
> Thanks for reviewing this patch, Dmitry.  We appreciate your efforts, and
> we'll make the changes you pointed out.
> 
> In this case, we hold the lock on access to all bonding-owned sysfs files,
> because it's possible for changes to one file to alter the contents and/or
> presence of another file.  Consider:
> 
> 1) process 'foo' opens /sys/class/net/bond1/mode
> 2) process 'bar' opens /sys/class/net/bonding_masters
> 3) process 'bar' writes to bonding_masters and removes bond1
> 4) process 'foo' tries to write
> 5) Boom.  Or rather, oops.
> 
> Thus, we have this lock.  I don't think that klists will help here.
> 

Semaphore will not help in scenario you described:

1) process 'bar' opens /sys/class/net/bonding_masters
2) process 'foo' opens /sys/class/net/bond1/mode
3) process 'bar' starts to write to bonding_masters and
   acquires semaphore
3) process 'foo' tries to write and waits for semaphore
   to become available
3) process 'bar' finishes writing and removes bond1
4) process 'foo' acquires the semaphore and continues with
   write
5) Boom.  Or rather, oops.

-- 
Dmitry 
