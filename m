From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH 0/7] introduce Hyper-V VM Sockets(hvsock)
Date: Fri, 17 Jul 2015 05:36:47 +0000
Message-ID: <f1a828efd9954230a182877bfeb01e21@SIXPR30MB031.064d.mgd.msft.net>
References: <1436193575-26674-1-git-send-email-decui@microsoft.com>
 <20150716155859.GA29366@stefanha-thinkpad.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20150716155859.GA29366@stefanha-thinkpad.redhat.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Stefan Hajnoczi
> Sent: Thursday, July 16, 2015 23:59
> On Mon, Jul 06, 2015 at 07:39:35AM -0700, Dexuan Cui wrote:
> > Hyper-V VM Sockets (hvsock) is a byte-stream based communication
> mechanism
> > between Windowsd 10 (or later) host and a guest. It's kind of TCP over
> > VMBus, but the transportation layer (VMBus) is much simpler than IP.
> > With Hyper-V VM Sockets, applications between the host and a guest can
> > talk with each other directly by the traditional BSD-style socket APIs.
> >
> > The patchset implements the necessary support in the guest side by adding
> > the necessary new APIs in the vmbus driver, and introducing a new driver
> > hv_sock.ko, which implements_a new socket address family AF_HYPERV.
> >
> >
> > I know the kernel has already had a VM Sockets driver (AF_VSOCK) based
> > on VMware's VMCI (net/vmw_vsock/, drivers/misc/vmw_vmci), and KVM is
> > proposing AF_VSOCK of virtio version:
> > http://thread.gmane.org/gmane.linux.network/365205.
> >
> > However, though Hyper-V VM Sockets may seem conceptually similar to
> > AF_VOSCK, there are differences in the transportation layer, and IMO these
> > make the direct code reusing impractical:
> >
> > 1. In AF_VSOCK, the endpoint type is: <u32 ContextID, u32 Port>, but in
> > AF_HYPERV, the endpoint type is: <GUID VM_ID, GUID ServiceID>. Here GUID
> > is 128-bit.
> >
> > 2. AF_VSOCK supports SOCK_DGRAM, while AF_HYPERV doesn't.
> >
> > 3. AF_VSOCK supports some special sock opts, like
> SO_VM_SOCKETS_BUFFER_SIZE,
> > SO_VM_SOCKETS_BUFFER_MIN/MAX_SIZE and
> SO_VM_SOCKETS_CONNECT_TIMEOUT.
> > These are meaningless to AF_HYPERV.
> >
> > 4. Some AF_VSOCK's VMCI transportation ops are meanless to
> AF_HYPERV/VMBus,
> > like    .notify_recv_init
> >         .notify_recv_pre_block
> >         .notify_recv_pre_dequeue
> >         .notify_recv_post_dequeue
> >         .notify_send_init
> >         .notify_send_pre_block
> >         .notify_send_pre_enqueue
> >         .notify_send_post_enqueue
> > etc.
> >
> > So I think we'd better introduce a new address family: AF_HYPERV.
> 
> Points 2-4 are not critical.  I think there are solutions to them.
> 
> Point 1 is the main issue: hvsock has <GUID, GUID> addresses instead of
> vsock's <u32, u32> addresses.  Perhaps a mapping could be used but that
> is pretty ugly.
Hi Stefan,
Exactly!

In the current AF_VSOCK code and the related transport layer (the wrapper
ops of VMware's VMCI), the <u32, u32> endpoint is widely used by
"struct sockaddr_vm" (this struct is exported to the user space).

So, anyway, the user space application has to explicitly handle the different
endpoint sizes.

And in the driver side, IMO there is no way to reuse the code of
AF_VSOCK with clean changes.

> One idea is something like a userspace <GUID, GUID> <->
> <u32, u32> lookup function that applications can use if they want to
> accept GUIDs.
Thanks for the suggestion!
While this is technically possible, IMO it would mess up the driver side's
AF_VSOCK code: in many places, we'll have to add ugly code like:

IF the endpoint size is <u32, u32> THEN
	use the existing logic;
ELSE
	use the new logic;

> I don't have a workable alternative to propose, so I agree that a new
> address family is justified.
Thanks for your exact understanding! :-)

-- Dexuan
