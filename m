From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 08/14] pci: Add SRIOV helper function to determine if
 VFs are assigned to guest
Date: Sat, 20 Apr 2013 20:31:28 -0700
Message-ID: <1366515088.2209.15.camel@jtkirshe-mobl>
References: <1366451353-24714-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1366451353-24714-9-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-OmQNSJlrm3Jm29a/Kjmo"
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: davem@davemloft.net, Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1366451353-24714-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-OmQNSJlrm3Jm29a/Kjmo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-04-20 at 02:49 -0700, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
>=20
> This function is meant to add a helper function that will determine if a =
PF
> has any VFs that are currently assigned to a guest.  We currently have be=
en
> implementing this function per driver, and going forward I would like to =
avoid
> that by making this function generic and using this helper.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Adding linux-pci mailing list and Bjorn to the CC.

Bjorn- David Miller needs a signoff by PCI maintainer.=20

> ---
>  drivers/pci/iov.c   | 41 +++++++++++++++++++++++++++++++++++++++++
>  include/linux/pci.h |  5 +++++
>  2 files changed, 46 insertions(+)
>=20
> diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
> index ee599f2..fd99720 100644
> --- a/drivers/pci/iov.c
> +++ b/drivers/pci/iov.c
> @@ -729,6 +729,47 @@ int pci_num_vf(struct pci_dev *dev)
>  EXPORT_SYMBOL_GPL(pci_num_vf);
> =20
>  /**
> + * pci_vfs_assigned - returns number of VFs are assigned to a guest
> + * @dev: the PCI device
> + *
> + * Returns number of VFs belonging to this device that are assigned to a=
 guest.
> + * If device is not a physical function returns -ENODEV.
> + */
> +int pci_vfs_assigned(struct pci_dev *dev)
> +{
> +	struct pci_dev *vfdev;
> +	unsigned int vfs_assigned =3D 0;
> +	unsigned short dev_id;
> +
> +	/* only search if we are a PF */
> +	if (!dev->is_physfn)
> +		return -ENODEV;
> +
> +	/*
> +	 * determine the device ID for the VFs, the vendor ID will be the
> +	 * same as the PF so there is no need to check for that one
> +	 */
> +	pci_read_config_word(dev, dev->sriov->pos + PCI_SRIOV_VF_DID, &dev_id);
> +
> +	/* loop through all the VFs to see if we own any that are assigned */
> +	vfdev =3D pci_get_device(dev->vendor, dev_id, NULL);
> +	while (vfdev) {
> +		/*
> +		 * It is considered assigned if it is a virtual function with
> +		 * our dev as the physical function and the assigned bit is set
> +		 */
> +		if (vfdev->is_virtfn && (vfdev->physfn =3D=3D dev) &&
> +		    (vfdev->dev_flags & PCI_DEV_FLAGS_ASSIGNED))
> +			vfs_assigned++;
> +
> +		vfdev =3D pci_get_device(dev->vendor, dev_id, vfdev);
> +	}
> +
> +	return vfs_assigned;
> +}
> +EXPORT_SYMBOL_GPL(pci_vfs_assigned);
> +
> +/**
>   * pci_sriov_set_totalvfs -- reduce the TotalVFs available
>   * @dev: the PCI PF device
>   * @numvfs: number that should be used for TotalVFs supported
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index 2461033a..03b4d3c 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -1643,6 +1643,7 @@ extern int pci_enable_sriov(struct pci_dev *dev, in=
t nr_virtfn);
>  extern void pci_disable_sriov(struct pci_dev *dev);
>  extern irqreturn_t pci_sriov_migration(struct pci_dev *dev);
>  extern int pci_num_vf(struct pci_dev *dev);
> +extern int pci_vfs_assigned(struct pci_dev *dev);
>  extern int pci_sriov_set_totalvfs(struct pci_dev *dev, u16 numvfs);
>  extern int pci_sriov_get_totalvfs(struct pci_dev *dev);
>  #else
> @@ -1661,6 +1662,10 @@ static inline int pci_num_vf(struct pci_dev *dev)
>  {
>  	return 0;
>  }
> +static inline int pci_vfs_assigned(struct pci_dev *dev)
> +{
> +	return 0;
> +}
>  static inline int pci_sriov_set_totalvfs(struct pci_dev *dev, u16 numvfs=
)
>  {
>  	return 0;



--=-OmQNSJlrm3Jm29a/Kjmo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRc12RAAoJEOVv75VaS+3OYnUP/AigVZEVP2H4UTntmGVWtaKq
SQU58LgwSmRGmZE/I4bl4tnjW8wKRjb0lMVhQmix9rFLZLgDa43SY+j+ub7XjS07
4XxuzJsu2KOrFKw/NHj/Ee/96sQskpNl8zD1oC23YvRRrY5owcB5S9bIUlsPcAfV
QxiEdcNj27T7zQk79XYPLkyDvB0FJyn5Y0jVUspMOSwAQGZizC0pV15wsGUF2klN
54RceycuaMbeQ+R73ZHMNAmYPFXXtOjmmgZNqrWdLvL4452iClRAzvUUrbfHJ07V
9lKz0fMEAS+Wv+3t28bs9i8OP5jVjp920FpvMDOwtLmJTvsehVCNdExq1RD08mhP
cqytKi8GtFby5DpmOjIoZLpKy09tlDHZ6fh2ceIljNhh1ow+zL7F9sqsafLKIIVn
21c5MB2IYx08zfPnFMKAg6K/oWMLliwmI7lOnxmL1gKdrmL424wR9FhQaDbxJYeq
fujnO36h4I3GeOfjk/OCKTFCBRUMkk1s493x7VnHS5TzFlbZap3LqIwzBWdnuL1e
VSPc5i5eR5yO+HqBM6TZ3vayJjddIDcLMuh1sDW0FbVDkj3Wpk9Rq/JZ3sTrtCYD
QyJBFfZf260RZTVSfAVKto/WCkiiUo0viH0Sky+yrqheRFJ7TvBR60QoALQ8HrKP
h/+6L1DQYriWs6qXtiIT
=Lqvj
-----END PGP SIGNATURE-----

--=-OmQNSJlrm3Jm29a/Kjmo--
