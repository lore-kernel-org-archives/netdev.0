From: Chris Leech <cleech-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 0/4] Make iSCSI network namespace aware
Date: Wed, 13 May 2015 15:12:43 -0700
Message-ID: <1431555167-23995-1-git-send-email-cleech@redhat.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: <open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <open-iscsi+bncBCYMVIPVXQMBB7EYZ6VAKGQEEPMR6TA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe>, <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+856124926423+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <http://groups.google.com/group/open-iscsi/subscribe>
List-Id: netdev.vger.kernel.org

I've had a few reports of people trying to run iscsid in a container, which
doesn't work at all when using network namespaces.  This is the start of me
looking at what it would take to make that work, and if it makes sense at all.

The first issue is that the kernel side of the iSCSI netlink control protocol
only operates in the initial network namespace.  But beyond that, if we allow
iSCSI to be managed within a namespace we need to decide what that means.  I
think it makes the most sense to isolate the iSCSI host, along with it's
associated endpoints, connections, and sessions, to a network namespace and
allow multiple instances of the userspace tools to exist in separate namespaces
managing separate hosts.

It works well for iscsi_tcp, which creates a host per session.  There's no
attempt to manage sessions on offloading hosts independently, although future
work could include the ability to move an entire host to a new namespace like
is supported for network devices.

This is only about the structures and functionality involved in maintaining the
iSCSI session, the SCSI host along with it's discovered targets and devices has
no association with network namespaces.

These patches are functional, but not complete.  There's no isolation enforced
in the kernel just yet, so it relies on well behaved userspace.  I plan on
fixing that, but wanted some feedback on the idea and approach so far.

Thanks,
	Chris

Chris Leech (4):
  iscsi: create per-net iscsi nl kernel sockets
  iscsi: sysfs filtering by network namespace
  iscsi: make all netlink multicast namespace aware
  iscsi: set netns for iscsi_tcp hosts

 drivers/scsi/iscsi_tcp.c            |   7 +
 drivers/scsi/scsi_transport_iscsi.c | 264 +++++++++++++++++++++++++++++-------
 include/scsi/scsi_transport_iscsi.h |   2 +
 3 files changed, 222 insertions(+), 51 deletions(-)

-- 
2.1.0

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To unsubscribe from this group and stop receiving emails from it, send an email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
Visit this group at http://groups.google.com/group/open-iscsi.
For more options, visit https://groups.google.com/d/optout.
