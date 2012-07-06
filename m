From: Dilip Daya <dilip.daya-VXdhtT5mjnY@public.gmane.org>
Subject: Re: Network namespace and bonding WARNING at fs/proc/generic.c
	remove_proc_entry
Date: Fri, 06 Jul 2012 14:01:47 -0400
Message-ID: <1341597707.2829.23.camel@pro6455b.example.com>
References: <1340900320.3441.88.camel@pro6455b.example.com>
	<20120705220749.GA11255@mail.hallyn.com> <87ehopu3e5.fsf@xmission.com>
	<20120706170538.GA31679@mail.hallyn.com>
Reply-To: dilip.daya-VXdhtT5mjnY@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120706170538.GA31679-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Serge,

On Fri, 2012-07-06 at 17:05 +0000, Serge E. Hallyn wrote:
> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> > "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> > 
> > > Quoting Dilip Daya (dilip.daya-VXdhtT5mjnY@public.gmane.org):
> > >> Hi,
> > >> 
> > >> I'd discussed the following with Serge Hallyn.
> > >> 
> > >> => Environment based on 3.2.18 / x86_64 kernel.
> > >> => WARNING: at fs/proc/generic.c:808 remove_proc_entry+0xdb/0x21f()
> > >> => WARNING: at fs/proc/generic.c:849 remove_proc_entry+0x208/0x21f()
> > >
> > > Hi,
> > >
> > > thanks much for sending this.  I'm still getting this error on
> > > 3.5.0-2-generic (today's ubuntu quantal kernel)
> > >
> > >> network namespace and bonding
> > >> -----------------------------
> > >> 
> > >> * Migrate two phy nics from host to netns (netns0).
> > >>   - ip link set ethX netns netns0
> > >> 
> > >> * In host environment:
> > >>   - load bonding module, /sbin/modprobe -v bonding mode=1 miimon=100
> > >>   - /sys/class/net/bond0 exists.
> > >>   - /proc/net/bonding/bond0 exists.
> > >>   - /sys/class/net/bonding_masters has bond0.
> > >> 
> > >> * Migrate bond0 to netns (netns0):
> > >>   - ip link set bond0 netns netns0.
> > >> 
> > >> * Within netns (netns0):
> > >>   - /sys/class/net/bonding_masters is empty.
> > >>   - /sys/class/net/bond0 exist.
> > >>   - configure bond0 and ifenslave with two phy nics.
> > >>   - /proc/net/bonding/bond0 does not exist within netns0, but does
> > >>     exist in the host environment.
> > >>   - /sys/class/net/bonding_masters is empty.
> > >
> > > mine is not empty, fwiw.  However
> > >
> > >>   - ping to remote end of bond0 works.
> > >> 
> > >> * Within netns (netns0), flushing ethX and bondY:
> > >>   - down bond0 and its phy nic interfaces:
> > >>   - ip link set ... down
> > >>   - ip addr flush dev [bond0 | eth#]
> > >>   - deleting bond0, /sbin/ip link del dev bond0
> > >
> > > Yup I still get a remove_proc_entry WARNING at fs/proc/generic.c:808,
> > > which is the warning when (!de)
> > 
> > It looks like Dilip is running an old kernel.  There should have been
> > some version of /sys/class/net/bonding_masters in every network
> > namespace since sometime in 2009.
> > 
> > >From the warning it looks like the proc files are being added/removed
> > to the wrong network namespace.  So in one namespace we get an error
> > when we delete the moved device and in the other network namespace
> > we get an error when we remove the /proc/directory.
> > 
> > An old kernel without proper network namespace support is the only
> > reason I can imagine someone would be moving an existing bond device
> > between network namespaces.
> > 
> > If there are other reasons for wanting to move a bonding device between
> > network namespaces it is possible to catch the NETDEV_UNREGISTER and
> > NETDEV_REGISTER events to remove/add the per device proc files at the
> > appropriate time.
> > 
> > However since moving bonding devices appears to be an unneded operation
> > let's just do things simply and forbid moving bonding devices between
> > network namespaces.  Serge, Dilip can you two test the patch below
> > and see if it fixes the warnings.
> > 
> > Eric
> > 
> > 
> > diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> > index 2ee8cf9..818ed64 100644
> > --- a/drivers/net/bonding/bond_main.c
> > +++ b/drivers/net/bonding/bond_main.c
> > @@ -4345,6 +4345,9 @@ static void bond_setup(struct net_device *bond_dev)
> >         bond_dev->priv_flags |= IFF_BONDING;
> >         bond_dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
> >  
> > +       /* Don't allow bond devices to change network namespaces. */
> > +       bond_dev->features |= NETIF_F_LOCAL;
> 
> I believe this needs to be NETIF_F_NETNS_LOCAL.  Test build still going with
> that change.


Correct, I made that change and rebuilt bonding driver:

# modinfo bonding | head
filename:       /lib/modules/3.2.18-clim-3-amd64/kernel/drivers/net/bonding/bonding.ko
alias:          rtnl-link-bond
author:         Thomas Davis, tadavis-/3juihCSby0@public.gmane.org and many others
description:    Ethernet Channel Bonding Driver, v3.7.1-netns
version:        3.7.1-netns
...


My results with the above bonding driver:

(1) Migrating bond0 from host to netns:

  # ip link set bond0 netns netns0
  RTNETLINK answers: Invalid argument

  => cannot migrate bond0 from host to netns.
  => No warnings.


(2) Loading bonding module in host environment and unloading bonding
    module from within netns:

  # modprobe -v -r bonding
  #
rmmod /lib/modules/3.2.18-clim-3-amd64/kernel/drivers/net/bonding/bonding.ko

	# lsmod | grep bond
	<<< bonding module does not exist >>>

	# ll /sys/class/net/
total 0
lrwxrwxrwx 1 root root 0 Jul  6 11:00 lo
-> ../../devices/virtual/net/lo/
lrwxrwxrwx 1 root root 0 Jul  6 11:00 eth7
-> ../../devices/pci0000:00/0000:00:05.0/0000:14:00.1/net/eth7/
lrwxrwxrwx 1 root root 0 Jul  6 11:00 eth6
-> ../../devices/pci0000:00/0000:00:05.0/0000:14:00.0/net/eth6/

	=> No warnings.


-DilipD.
