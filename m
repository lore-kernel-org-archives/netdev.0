From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH] vsock: only load vmci transport on VMware hypervisor by
 default
Date: Thu, 17 Aug 2017 14:55:59 +0100
Message-ID: <20170817135559.GG5539@stefanha-x1.localdomain>
References: <KL1P15301MB0008F70D4E5248AB7A296CE3BF830@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="I3tAPq1Rm2pUxvsp"
Cc: "'Jorgen S. Hansen'" <jhansen@vmware.com>,
        "'davem@davemloft.net'" <davem@davemloft.net>,
        "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
        "'gregkh@linuxfoundation.org'" <gregkh@linuxfoundation.org>,
        "'devel@linuxdriverproject.org'" <devel@linuxdriverproject.org>,
        KY Srinivasan <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        'George Zhang' <georgezhang@vmware.com>,
        'Michal Kubecek' <mkubecek@suse.cz>,
        'Asias He' <asias@redhat.com>,
        'Vitaly Kuznetsov' <vkuznets@redhat.com>,
        'Cathy Avery' <cavery@redhat.com>,
        "'jasowang@redhat.com'" <jasowang@redhat.com>,
        'Rolf Neugebauer' <rolf.neugebauer@docker.com>,
        'Dave Scott' <dave.scott@docker.com>,
        'Marcelo Cerri' <marcelo.cerri@canonical.com>,
        "'apw@
To: Dexuan Cui <decui@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <KL1P15301MB0008F70D4E5248AB7A296CE3BF830@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--I3tAPq1Rm2pUxvsp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 17, 2017 at 08:00:29AM +0000, Dexuan Cui wrote:
>=20
> Without the patch, vmw_vsock_vmci_transport.ko can automatically load
> when an application creates an AF_VSOCK socket.
>=20
> This is the expected good behavior on VMware hypervisor, but as we
> are going to add hv_sock.ko (i.e. Hyper-V transport for AF_VSOCK), we
> should make sure vmw_vsock_vmci_transport.ko can't load on Hyper-V,
> otherwise there is a -EBUSY conflict when both vmw_vsock_vmci_transport.ko
> and hv_sock.ko try to call vsock_core_init() on Hyper-V.
>=20
> On the other hand, hv_sock.ko can only load on Hyper-V, because it
> depends on hv_vmbus.ko, which detects Hyper-V in hv_acpi_init().
>=20
> KVM's vsock_virtio_transport doesn't have the issue because it doesn't
> define MODULE_ALIAS_NETPROTO(PF_VSOCK).

Thanks for sending this patch, vmci's MODULE_ALIAS_NETPROTO(PF_VSOCK) is
a problem for vhost_vsock.ko (the virtio host driver) too.  A host
userspace program can create a AF_VSOCK socket before vhost_vsock is
loaded.  The vmci transport will be unconditionally loaded and that's
not the right behavior.

Putting aside nested virtualization, I want to load the transport (vmci,
Hyper-V, vsock) for which there is paravirtualized hardware present
inside the guest.

It's a little tricker on the host side (doesn't matter for Hyper-V and
probably also doesn't for VMware) because the host-side driver is a
software device with no hardware backing it.  In KVM we assume the
vhost_vsock.ko kernel module will be loaded sufficiently early.

Things get trickier with nested virtualization because the VM might want
to talk to its host but also to its nested VMs.  The simple way of
fixing this would be to allow two transports loaded simultaneously and
route traffic destined to CID 2 to the host transport and all other
traffic to the guest transport.

Perhaps we should discuss these cases a bit more to figure out how to
avoid conflicts over MODULE_ALIAS_NETPROTO(PF_VSOCK).

>=20
> The patch also adds a module parameter "skip_hypervisor_check" for
> vmw_vsock_vmci_transport.ko.
>=20
> Signed-off-by: Dexuan Cui <decui@microsoft.com>
> Cc: Alok Kataria <akataria@vmware.com>
> Cc: Andy King <acking@vmware.com>
> Cc: Adit Ranadive <aditr@vmware.com>
> Cc: George Zhang <georgezhang@vmware.com>
> Cc: Jorgen Hansen <jhansen@vmware.com>
> Cc: K. Y. Srinivasan <kys@microsoft.com>
> Cc: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: Stephen Hemminger <sthemmin@microsoft.com>
> ---
>  net/vmw_vsock/Kconfig          |  2 +-
>  net/vmw_vsock/vmci_transport.c | 11 +++++++++++
>  2 files changed, 12 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/vmw_vsock/Kconfig b/net/vmw_vsock/Kconfig
> index a24369d..3f52929 100644
> --- a/net/vmw_vsock/Kconfig
> +++ b/net/vmw_vsock/Kconfig
> @@ -17,7 +17,7 @@ config VSOCKETS
> =20
>  config VMWARE_VMCI_VSOCKETS
>  	tristate "VMware VMCI transport for Virtual Sockets"
> -	depends on VSOCKETS && VMWARE_VMCI
> +	depends on VSOCKETS && VMWARE_VMCI && HYPERVISOR_GUEST
>  	help
>  	  This module implements a VMCI transport for Virtual Sockets.
> =20
> diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transpor=
t.c
> index 10ae782..c068873 100644
> --- a/net/vmw_vsock/vmci_transport.c
> +++ b/net/vmw_vsock/vmci_transport.c
> @@ -16,6 +16,7 @@
>  #include <linux/types.h>
>  #include <linux/bitops.h>
>  #include <linux/cred.h>
> +#include <linux/hypervisor.h>
>  #include <linux/init.h>
>  #include <linux/io.h>
>  #include <linux/kernel.h>
> @@ -73,6 +74,10 @@ struct vmci_transport_recv_pkt_info {
>  	struct vmci_transport_packet pkt;
>  };
> =20
> +static bool skip_hypervisor_check;
> +module_param(skip_hypervisor_check, bool, 0444);
> +MODULE_PARM_DESC(hot_add, "If set, attempt to load on non-VMware platfor=
ms");
> +
>  static LIST_HEAD(vmci_transport_cleanup_list);
>  static DEFINE_SPINLOCK(vmci_transport_cleanup_lock);
>  static DECLARE_WORK(vmci_transport_cleanup_work, vmci_transport_cleanup);
> @@ -2085,6 +2090,12 @@ static int __init vmci_transport_init(void)
>  {
>  	int err;
> =20
> +	/* Check if we are running on VMware's hypervisor and bail out
> +	 * if we are not.
> +	 */
> +	if (!skip_hypervisor_check && x86_hyper !=3D &x86_hyper_vmware)
> +		return -ENODEV;
> +
>  	/* Create the datagram handle that we will use to send and receive all
>  	 * VSocket control messages for this context.
>  	 */
> --=20
> 2.7.4
>=20

--I3tAPq1Rm2pUxvsp
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZlaBvAAoJEJykq7OBq3PIL5MH/0nes0IGVnhRkyenU95K9lSj
bwC5sVuAErNihjkCRY+Q22iGPRH+sUYP884vQSIzU5ey1/dUPqtTnn+YEkUpJ1MC
HpPEPLFpAQHW+aunjiJw5wceiFmMvc2V+JqVVEdQBF1S1IYArWCNeKOsluO980yI
Iuzj7+d587EgJUtm9r13wQRKNyNAaNJjmxnlJKiITT2d6F55f81CxaOSMEs8o1IF
5OS2OMiqoEadgbrT5WkEugzBS8q6V74FBHH1DmS2QWVcCtVZfc85VeQE3sIIjp6C
ZY59rthZRlOcb329FY9CW7brRuHFmJ6K+52FQCdlwT4psclC+bMcEGuC2Sq7yT8=
=Ry6z
-----END PGP SIGNATURE-----

--I3tAPq1Rm2pUxvsp--
