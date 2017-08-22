From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH] vsock: only load vmci transport on VMware hypervisor by
 default
Date: Tue, 22 Aug 2017 10:54:37 +0100
Message-ID: <20170822095437.GB16799@stefanha-x1.localdomain>
References: <KL1P15301MB0008F70D4E5248AB7A296CE3BF830@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170817135559.GG5539@stefanha-x1.localdomain>
 <04460E3B-B213-4090-96CD-00CEEBE6AC32@vmware.com>
 <KL1P15301MB0008A67BF969A47309CFA992BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170818153716.GB17572@stefanha-x1.localdomain>
 <KL1P15301MB00083B1F5B70CBAB7C42BBD3BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michal Kubecek <mkubecek@suse.cz>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 George Zhang <georgezhang@vmware.com>,
 Stephen Hemminger <sthemmin@microsoft.com>,
 Rolf Neugebauer <rolf.neugebauer@docker.com>,
 Marcelo Cerri <marcelo.cerri@canonical.com>, Asias He <asias@redhat.com>,
 Dan Carpenter <dan.carpenter@oracle.com>, "olaf@aepfle.de" <olaf@aepfle.de>,
 Haiyang Zhang <haiyangz@microsoft.com>, Dave Scott <dave.scott@docker.com>,
 "apw@canonical.com" <apw@canonical.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "joe@perches.com" <joe@perches.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 Vitaly Kuznetsov <vkuznets@redhat.com>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "Jorgen S. Hansen" <jhansen@vmware.com>
To: Dexuan Cui <decui@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <KL1P15301MB00083B1F5B70CBAB7C42BBD3BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
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

On Fri, Aug 18, 2017 at 11:07:37PM +0000, Dexuan Cui wrote:
> > From: Stefan Hajnoczi [mailto:stefanha@redhat.com]
> > > CID is not really used by us, because we only support guest<->host
> > communication,
> > > and don't support guest<->guest communication. The Hyper-V host
> > references
> > > every VM by VmID (which is invisible to the VM), and a VM can only talk to
> > the
> > > host via this feature.
> > 
> > Applications running inside the guest should use VMADDR_CID_HOST (2) to
> > connect to the host, even on Hyper-V.
> I have no objection, and this patch does support this usage of the
> user-space applications.
>
> > By the way, we should collaborate on a test suite and a vsock(7) man
> > page that documents the semantics of AF_VSOCK sockets.  This way our
> > transports will have the same behavior and AF_VSOCK applications will
> > work on all 3 hypervisors.
> I can't agree more. :-)
> BTW, I have been using Rolf's test suite to test my patch:
> https://github.com/rn/virtsock/tree/master/c
> Maybe this can be a good starting point.

Thanks for sharing this, I will try it with virtio-vsock.

I have a netcat-like utility here:
https://github.com/stefanha/linux/blob/vsock-extras/nc-vsock.c

> > Not all features need to be supported.  For example, VMCI supports
> > SOCK_DGRAM while Hyper-V and virtio do not.  But features that are
> > available should behave identically.
> I totally agree, though I'm afraid Hyper-V may have a little more limitations
> compared to VMware/KVM duo to the <VM_ID, ServiceID> <--> <cid, port>
> mapping.
>  
> > > Can we use the 'protocol' parameter in the socket() function:
> > > int socket(int domain, int type, int protocol)
> > >
> > > IMO currently the 'protocol' is not really used.
> > > I think we can modify __vsock_core_init() to allow multiple transport layers
> > to
> > >  be registered, and we can define different 'protocol' numbers for
> > > VMware/KVM/Hyper-V, and ask the application to explicitly specify what
> > should
> > > be used. Considering compatibility, we can use the default transport in a
> > given
> > > VM depending on the underlying hypervisor.
> > 
> > I think AF_VSOCK should hide the transport from users/applications.
> Ideally yes, but let's consider the KVM-on-KVM nested scenario: when
> an application in the Level-1 VM creates an AF_VSOCK socket and call
> connect() for it, how can we know if the app is trying to connect to
> the Level-0 host, or connect to the Level-2 VM? We can't.

We *can* by looking at the destination CID.  Please take a look at
drivers/misc/vmw_vmci/vmci_route.c:vmci_route() to see how VMCI handles
nested virt.

It boils down to something like this:

  static int vsock_stream_connect(struct socket *sock, struct sockaddr *addr,
                                  int addr_len, int flags)
  {
      ...
      if (remote_addr.svm_cid == VMADDR_CID_HOST)
          transport = host_transport;
      else
          transport = guest_transport;

It's easy for connect(2) but Jorgen mentioned it's harder for listen(2)
because the socket would need to listen on both transports.  We define
two new constants VMADDR_CID_LISTEN_FROM_GUEST and
VMADDR_CID_LISTEN_FROM_HOST for bind(2) so that applications can decide
which side to listen on.  Or the listen socket could simply listen to
both sides.

Stefan
