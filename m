From: Chris Leech <cleech@redhat.com>
Subject: Re: [RFC PATCH 0/4] Make iSCSI network namespace aware
Date: Thu, 21 May 2015 13:26:05 -0700
Message-ID: <20150521202605.GE17115@straylight.hirudinean.org>
References: <1431555167-23995-1-git-send-email-cleech@redhat.com>
 <555CD657.6080004@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
To: open-iscsi@googlegroups.com
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <555CD657.6080004@redhat.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 20, 2015 at 11:45:43AM -0700, Andy Grover wrote:
> On 05/13/2015 03:12 PM, Chris Leech wrote:
> >This is only about the structures and functionality involved in maintaining the
> >iSCSI session, the SCSI host along with it's discovered targets and devices has
> >no association with network namespaces.
> >
> >These patches are functional, but not complete.  There's no isolation enforced
> >in the kernel just yet, so it relies on well behaved userspace.  I plan on
> >fixing that, but wanted some feedback on the idea and approach so far.
> 
> Seems like a good direction, to me.
> 
> What would be the extent of the userspace (open-iscsi) changes needed to go
> along with this?

There's no core changes needed in the open-iscsi tools, it's more a
matter of how iscsid is packaged and executed.

The control socket between iscsid and iscsiadm binds to an abstract unix
domain path, so that works fine as long as you run iscsiadm from within
the same net ns as the iscsid instance you want to talk to.

The pid file checks clash if /var/run is common between instances.
Putting iscsid in a container could provide separate config files and
configuration databases, but there may be something that could improve
handling there.

I've been testing using 'ip netns exec' to run iscsid in a new network
namespace (it actually crates a new mount namespace as well, to remount
/sys with the new namespace filtered view).

My test setup so far has been the following:

  A VM with two virtio network interfaces on different virtual networks.
  I have an iSCSI target configured with two portals, one on each
  virtual network.

  I create two new network namespaces with 'ip netns add' and then move
  the nics into them with 'ip link <dev> netns <ns>' and bring them
  online.

  Using 'ip netns exec' I start up an iscsid instance in each namespace,
  using the --foreground option to avoid the PID file clash.

  Form within each namespace I can run iscsiadm to manage sessions
  through one of the iscsid instances.  With this setup they share the
  persistent configuration database, so I specifically select which
  records to start/stop.

- Chris

