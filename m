From: Paul Moore <pmoore@redhat.com>
Subject: Re: [RFC PATCH v2 3/3] tun: fix LSM/SELinux labeling of tun/tap devices
Date: Thu, 06 Dec 2012 10:46:11 -0500
Message-ID: <7448004.siKCIqQqTi@sifl>
References: <20121205202144.18626.61966.stgit@localhost> <20121205202619.18626.98778.stgit@localhost> <20121206103325.GG10837@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, jasowang@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20121206103325.GG10837@redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, December 06, 2012 12:33:25 PM Michael S. Tsirkin wrote:
> On Wed, Dec 05, 2012 at 03:26:19PM -0500, Paul Moore wrote:
> > This patch corrects some problems with LSM/SELinux that were introduced
> > with the multiqueue patchset.  The problem stems from the fact that the
> > multiqueue work changed the relationship between the tun device and its
> > associated socket; before the socket persisted for the life of the
> > device, however after the multiqueue changes the socket only persisted
> > for the life of the userspace connection (fd open).  For non-persistent
> > devices this is not an issue, but for persistent devices this can cause
> > the tun device to lose its SELinux label.
> > 
> > We correct this problem by adding an opaque LSM security blob to the
> > tun device struct which allows us to have the LSM security state, e.g.
> > SELinux labeling information, persist for the lifetime of the tun
> > device.  In the process we tweak the LSM hooks to work with this new
> > approach to TUN device/socket labeling and introduce a new LSM hook,
> > security_tun_dev_create_queue(), to approve requests to create a new
> > TUN queue via TUNSETQUEUE.
> > 
> > The SELinux code has been adjusted to match the new LSM hooks, the
> > other LSMs do not make use of the LSM TUN controls.  This patch makes
> > use of the recently added "tun_socket:create_queue" permission to
> > restrict access to the TUNSETQUEUE operation.  On older SELinux
> > policies which do not define the "tun_socket:create_queue" permission
> > the access control decision for TUNSETQUEUE will be handled according
> > to the SELinux policy's unknown permission setting.
> > 
> > Signed-off-by: Paul Moore <pmoore@redhat.com>
> 
> OK so just to verify: this can be used to ensure that qemu
> process that has the queue fd can only attach it to
> a specific device, right?

Whenever a new queue is created via TUNSETQUEUE/tun_set_queue() the 
security_tun_dev_create_queue() LSM hook is called.  When SELinux is enabled 
this hook ends up calling selinux_tun_dev_create_queue() which checks that the 
calling process (process_t) is allowed to create a new queue on the specified 
device (tundev_t) .  If you are familiar with SELinux security policy, the 
allow rule would look like this:

  allow process_t tundev_t:tun_socket create_queue;

In practice, if we assume libvirt is creating the TUN device and running with 
a SELinux label of virtd_t and that QEMU instances are running with a SELinux 
label of svirt_t then the allow rule would look like this:

  allow svirt_t virtd_t:tun_socket create_queue;

There is also the matter of the MLS/MCS constraints providing additional 
separation but that is another level of detail which I don't believe is 
important for our discussion.

-- 
paul moore
security and virtualization @ redhat

