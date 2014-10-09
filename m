From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net] ixgbe: check adapter->vfinfo before dereference
Date: Thu, 09 Oct 2014 15:35:52 -0700
Message-ID: <1412894152.2427.3.camel@jtkirshe-mobl>
References: <1412769913-22306-1-git-send-email-thierry.herbelot@6wind.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-3bC9wZBu9HzJegYQZgg0"
Cc: netdev@vger.kernel.org
To: Thierry Herbelot <thierry.herbelot@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:47522 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751195AbaJIWfy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2014 18:35:54 -0400
In-Reply-To: <1412769913-22306-1-git-send-email-thierry.herbelot@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3bC9wZBu9HzJegYQZgg0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-10-08 at 14:05 +0200, Thierry Herbelot wrote:
> this protects against the following panic:
> (before a VF was actually created on p96p1 PF Ethernet port)
> ip link set p96p1 vf 0 spoofchk off
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000052
> IP: [<ffffffffa044a1c1>] ixgbe_ndo_set_vf_spoofchk+0x51/0x150 [ixgbe]
>=20
> Signed-off-by: Thierry Herbelot <thierry.herbelot@6wind.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   73 ++++++++++++++++++=
+++++-
>  1 file changed, 70 insertions(+), 3 deletions(-)

Dropping this patch because the driver generates compile warnings with
this patch applied.

n0324:[0]/usr/src/net-community-queue> make -j 18
SUBDIRS=3Ddrivers/net/ethernet/intel/ixgbe modules
  CC [M]  drivers/net/ethernet/intel/ixgbe/ixgbe_main.o
...
drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c: In function
=C3=A2ixgbe_ping_all_vfs=C3=A2:
drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c:1102: warning: =C3=A2return=
=C3=A2
with a value, in function returning void
drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c: In function
=C3=A2ixgbe_ndo_set_vf_spoofchk=C3=A2:
drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c:1326: warning: =C3=A2return=
=C3=A2
with no value, in function returning non-void
  LD [M]  drivers/net/ethernet/intel/ixgbe/ixgbe.o
  Building modules, stage 2.
  MODPOST 1 modules
  CC      drivers/net/ethernet/intel/ixgbe/ixgbe.mod.o
  LD [M]  drivers/net/ethernet/intel/ixgbe/ixgbe.ko

>=20
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net=
/ethernet/intel/ixgbe/ixgbe_sriov.c
> index c14d4d8..c6c9c0a 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> @@ -314,7 +314,7 @@ static int ixgbe_set_vf_multicasts(struct ixgbe_adapt=
er *adapter,
>  	int entries =3D (msgbuf[0] & IXGBE_VT_MSGINFO_MASK)
>  		       >> IXGBE_VT_MSGINFO_SHIFT;
>  	u16 *hash_list =3D (u16 *)&msgbuf[1];
> -	struct vf_data_storage *vfinfo =3D &adapter->vfinfo[vf];
> +	struct vf_data_storage *vfinfo;
>  	struct ixgbe_hw *hw =3D &adapter->hw;
>  	int i;
>  	u32 vector_bit;
> @@ -322,6 +322,11 @@ static int ixgbe_set_vf_multicasts(struct ixgbe_adap=
ter *adapter,
>  	u32 mta_reg;
>  	u32 vmolr =3D IXGBE_READ_REG(hw, IXGBE_VMOLR(vf));
> =20
> +	if (!adapter->vfinfo)
> +		return -1;
> +
> +	vfinfo =3D &adapter->vfinfo[vf];
> +
>  	/* only so many hash values supported */
>  	entries =3D min(entries, IXGBE_MAX_VF_MC_ENTRIES);
> =20
> @@ -363,6 +368,9 @@ void ixgbe_restore_vf_multicasts(struct ixgbe_adapter=
 *adapter)
>  	u32 vector_reg;
>  	u32 mta_reg;
> =20
> +	if (!adapter->vfinfo)
> +		return;
> +
>  	for (i =3D 0; i < adapter->num_vfs; i++) {
>  		u32 vmolr =3D IXGBE_READ_REG(hw, IXGBE_VMOLR(i));
>  		vfinfo =3D &adapter->vfinfo[i];
> @@ -416,6 +424,9 @@ static s32 ixgbe_set_vf_lpe(struct ixgbe_adapter *ada=
pter, u32 *msgbuf, u32 vf)
>  		u32 reg_offset, vf_shift, vfre;
>  		s32 err =3D 0;
> =20
> +		if (!adapter->vfinfo)
> +			return -1;
> +
>  #ifdef CONFIG_FCOE
>  		if (dev->features & NETIF_F_FCOE_MTU)
>  			pf_max_frame =3D max_t(int, pf_max_frame,
> @@ -505,6 +516,9 @@ static inline void ixgbe_vf_reset_event(struct ixgbe_=
adapter *adapter, u32 vf)
>  	struct vf_data_storage *vfinfo =3D &adapter->vfinfo[vf];
>  	u8 num_tcs =3D netdev_get_num_tc(adapter->netdev);
> =20
> +	if (!adapter->vfinfo)
> +		return;
> +
>  	/* add PF assigned VLAN or VLAN 0 */
>  	ixgbe_set_vf_vlan(adapter, true, vfinfo->pf_vlan, vf);
> =20
> @@ -541,6 +555,8 @@ static inline void ixgbe_vf_reset_event(struct ixgbe_=
adapter *adapter, u32 vf)
>  static int ixgbe_set_vf_mac(struct ixgbe_adapter *adapter,
>  			    int vf, unsigned char *mac_addr)
>  {
> +	if (!adapter->vfinfo)
> +		return -1;
>  	ixgbe_del_mac_filter(adapter, adapter->vfinfo[vf].vf_mac_addresses, vf)=
;
>  	memcpy(adapter->vfinfo[vf].vf_mac_addresses, mac_addr, ETH_ALEN);
>  	ixgbe_add_mac_filter(adapter, adapter->vfinfo[vf].vf_mac_addresses, vf)=
;
> @@ -610,6 +626,9 @@ int ixgbe_vf_configuration(struct pci_dev *pdev, unsi=
gned int event_mask)
> =20
>  	bool enable =3D ((event_mask & 0x10000000U) !=3D 0);
> =20
> +	if (!adapter->vfinfo)
> +		return -1;
> +
>  	if (enable)
>  		eth_zero_addr(adapter->vfinfo[vfn].vf_mac_addresses);
> =20
> @@ -620,13 +639,18 @@ static int ixgbe_vf_reset_msg(struct ixgbe_adapter =
*adapter, u32 vf)
>  {
>  	struct ixgbe_ring_feature *vmdq =3D &adapter->ring_feature[RING_F_VMDQ]=
;
>  	struct ixgbe_hw *hw =3D &adapter->hw;
> -	unsigned char *vf_mac =3D adapter->vfinfo[vf].vf_mac_addresses;
> +	unsigned char *vf_mac;
>  	u32 reg, reg_offset, vf_shift;
>  	u32 msgbuf[4] =3D {0, 0, 0, 0};
>  	u8 *addr =3D (u8 *)(&msgbuf[1]);
>  	u32 q_per_pool =3D __ALIGN_MASK(1, ~vmdq->mask);
>  	int i;
> =20
> +	if (!adapter->vfinfo)
> +		return -1;
> +
> +	vf_mac =3D adapter->vfinfo[vf].vf_mac_addresses;
> +
>  	e_info(probe, "VF Reset msg received from vf %d\n", vf);
> =20
>  	/* reset the filters for the device */
> @@ -721,6 +745,9 @@ static int ixgbe_set_vf_mac_addr(struct ixgbe_adapter=
 *adapter,
>  {
>  	u8 *new_mac =3D ((u8 *)(&msgbuf[1]));
> =20
> +	if (!adapter->vfinfo)
> +		return -1;
> +
>  	if (!is_valid_ether_addr(new_mac)) {
>  		e_warn(drv, "VF %d attempted to set invalid mac\n", vf);
>  		return -1;
> @@ -773,6 +800,9 @@ static int ixgbe_set_vf_vlan_msg(struct ixgbe_adapter=
 *adapter,
>  	u32 bits;
>  	u8 tcs =3D netdev_get_num_tc(adapter->netdev);
> =20
> +	if (!adapter->vfinfo)
> +		return -1;
> +
>  	if (adapter->vfinfo[vf].pf_vlan || tcs) {
>  		e_warn(drv,
>  		       "VF %d attempted to override administratively set VLAN configur=
ation\n"
> @@ -839,6 +869,9 @@ static int ixgbe_set_vf_macvlan_msg(struct ixgbe_adap=
ter *adapter,
>  		    IXGBE_VT_MSGINFO_SHIFT;
>  	int err;
> =20
> +	if (!adapter->vfinfo)
> +		return -1;
> +
>  	if (adapter->vfinfo[vf].pf_set_mac && index > 0) {
>  		e_warn(drv,
>  		       "VF %d requested MACVLAN filter but is administratively denied\=
n",
> @@ -875,6 +908,9 @@ static int ixgbe_negotiate_vf_api(struct ixgbe_adapte=
r *adapter,
>  {
>  	int api =3D msgbuf[1];
> =20
> +	if (!adapter->vfinfo)
> +		return -1;
> +
>  	switch (api) {
>  	case ixgbe_mbox_api_10:
>  	case ixgbe_mbox_api_11:
> @@ -897,6 +933,9 @@ static int ixgbe_get_vf_queues(struct ixgbe_adapter *=
adapter,
>  	unsigned int default_tc =3D 0;
>  	u8 num_tcs =3D netdev_get_num_tc(dev);
> =20
> +	if (!adapter->vfinfo)
> +		return -1;
> +
>  	/* verify the PF is supporting the correct APIs */
>  	switch (adapter->vfinfo[vf].vf_api) {
>  	case ixgbe_mbox_api_20:
> @@ -935,6 +974,9 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter=
 *adapter, u32 vf)
>  	struct ixgbe_hw *hw =3D &adapter->hw;
>  	s32 retval;
> =20
> +	if (!adapter->vfinfo)
> +		return -1;
> +
>  	retval =3D ixgbe_read_mbx(hw, msgbuf, mbx_size, vf);
> =20
>  	if (retval) {
> @@ -1008,6 +1050,9 @@ static void ixgbe_rcv_ack_from_vf(struct ixgbe_adap=
ter *adapter, u32 vf)
>  	struct ixgbe_hw *hw =3D &adapter->hw;
>  	u32 msg =3D IXGBE_VT_MSGTYPE_NACK;
> =20
> +	if (!adapter->vfinfo)
> +		return;
> +
>  	/* if device isn't clear to send it shouldn't be reading either */
>  	if (!adapter->vfinfo[vf].clear_to_send)
>  		ixgbe_write_mbx(hw, &msg, 1, vf);
> @@ -1051,6 +1096,9 @@ void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapt=
er)
>  	u32 ping;
>  	int i;
> =20
> +	if (!adapter->vfinfo)
> +		return -1;
> +

This should be simply "return;" since this is a void function.

>  	for (i =3D 0 ; i < adapter->num_vfs; i++) {
>  		ping =3D IXGBE_PF_CONTROL_MSG;
>  		if (adapter->vfinfo[i].clear_to_send)
> @@ -1064,6 +1112,9 @@ int ixgbe_ndo_set_vf_mac(struct net_device *netdev,=
 int vf, u8 *mac)
>  	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
>  	if (!is_valid_ether_addr(mac) || (vf >=3D adapter->num_vfs))
>  		return -EINVAL;
> +	if (!adapter->vfinfo)
> +		return -1;
> +
>  	adapter->vfinfo[vf].pf_set_mac =3D true;
>  	dev_info(&adapter->pdev->dev, "setting MAC %pM on VF %d\n", mac, vf);
>  	dev_info(&adapter->pdev->dev, "Reload the VF driver to make this"
> @@ -1083,6 +1134,9 @@ int ixgbe_ndo_set_vf_vlan(struct net_device *netdev=
, int vf, u16 vlan, u8 qos)
>  	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
>  	struct ixgbe_hw *hw =3D &adapter->hw;
> =20
> +	if (!adapter->vfinfo)
> +		return -1;
> +
>  	if ((vf >=3D adapter->num_vfs) || (vlan > 4095) || (qos > 7))
>  		return -EINVAL;
>  	if (vlan || qos) {
> @@ -1147,8 +1201,12 @@ static void ixgbe_set_vf_rate_limit(struct ixgbe_a=
dapter *adapter, int vf)
>  	struct ixgbe_hw *hw =3D &adapter->hw;
>  	u32 bcnrc_val =3D 0;
>  	u16 queue, queues_per_pool;
> -	u16 tx_rate =3D adapter->vfinfo[vf].tx_rate;
> +	u16 tx_rate;
> =20
> +	if (!adapter->vfinfo)
> +		return;
> +
> +	tx_rate =3D adapter->vfinfo[vf].tx_rate;
>  	if (tx_rate) {
>  		/* start with base link speed value */
>  		bcnrc_val =3D adapter->vf_rate_link_speed;
> @@ -1197,6 +1255,9 @@ void ixgbe_check_vf_rate_limit(struct ixgbe_adapter=
 *adapter)
>  {
>  	int i;
> =20
> +	if (!adapter->vfinfo)
> +		return;
> +
>  	/* VF Tx rate limit was not set */
>  	if (!adapter->vf_rate_link_speed)
>  		return;
> @@ -1259,6 +1320,9 @@ int ixgbe_ndo_set_vf_spoofchk(struct net_device *ne=
tdev, int vf, bool setting)
>  	struct ixgbe_hw *hw =3D &adapter->hw;
>  	u32 regval;
> =20
> +	if (!adapter->vfinfo)
> +		return;
> +

The return needs to return an integer.

>  	adapter->vfinfo[vf].spoofchk_enabled =3D setting;
> =20
>  	regval =3D IXGBE_READ_REG(hw, IXGBE_PFVFSPOOF(vf_target_reg));
> @@ -1283,6 +1347,9 @@ int ixgbe_ndo_get_vf_config(struct net_device *netd=
ev,
>  	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
>  	if (vf >=3D adapter->num_vfs)
>  		return -EINVAL;
> +	if (!adapter->vfinfo)
> +		return -EINVAL;
> +
>  	ivi->vf =3D vf;
>  	memcpy(&ivi->mac, adapter->vfinfo[vf].vf_mac_addresses, ETH_ALEN);
>  	ivi->max_tx_rate =3D adapter->vfinfo[vf].tx_rate;



--=-3bC9wZBu9HzJegYQZgg0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUNw3IAAoJEOVv75VaS+3O1BkP/0WG+RqQx02k2+AEFuf0O3Xg
76XczXi+6oP8bZoPOS17UWonKc0Zn7TvDeOHVBfhRjG80dqMtIKF4+OeeuJtt37Q
/n4oWiizbpq7Pd8eg6GTYAWPPVAd8cPuiW1BGcQAVb1XJRdI1OaSThT8VoFedAby
8PEtta3NTYK29+nJEYkzpzZkm8gCWQ4Y/crY6HGFGBKIXSbjXZhr6b5L4YsOJoVm
YVCq2HMTgg4TzUXfnHgRgeuFhIoNznT+f+xPPjOP6mxIAaKZ0BqZ0SmaWLSwlnYa
kv3jrVMZdV2AW6WZG1hidcvyp8+Fxb8fj/EEgnc917MDLyZgGl65Q5lbFyzkL1sN
HINRQ/AYZ9ZkVP2RXcm5wIHvnbuO+LjaRYM6PQbQpoWHPXC6LX/WNNjt0yWK1Ov3
X2QNB9aRj4LUqa/KnmiPwXxlUjNO2NtXO/G5GnZCH/U2NQC/hMNxExX6DEsYtwk8
WY8+pTsjn+mqXpBuVl9Wi7YrOV9C5h7Vi19rDWS+tgVfR7ET959sxmsFRqMuP2O0
l5FUxqSWKKzNs7ukNvUE/9EltFJTQYbYGLdn1g/iS9w7IBUNSsphfhfQ7aRUh482
p5PiSqu/63hnb+DNwqnjXGNL7KhvHDAs/lFpkVyaziJYwnmI2w6VEUG244AsTuco
CWqa8/5Q/Gh/oM1obVUd
=Iv+P
-----END PGP SIGNATURE-----

--=-3bC9wZBu9HzJegYQZgg0--
