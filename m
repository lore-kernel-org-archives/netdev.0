From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC 06/11] Add support for QP verbs
Date: Thu, 15 Sep 2016 16:05:56 +0300
Message-ID: <20160915130556.GA26069@leon.nu>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-7-git-send-email-Ram.Amrani@qlogic.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="q5wOvoHkaccQRDme"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
        Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
        rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1473696465-27986-7-git-send-email-Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--q5wOvoHkaccQRDme
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Sep 12, 2016 at 07:07:40PM +0300, Ram Amrani wrote:
> Add support for Queue Pair verbs which adds, deletes,
> modifies and queries Queue Pairs.
>
> Signed-off-by: Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/infiniband/hw/qedr/main.c          |   15 +-
>  drivers/infiniband/hw/qedr/qedr.h          |  126 +++
>  drivers/infiniband/hw/qedr/qedr_cm.h       |   40 +
>  drivers/infiniband/hw/qedr/qedr_hsi_rdma.h |   11 +
>  drivers/infiniband/hw/qedr/qedr_user.h     |   34 +
>  drivers/infiniband/hw/qedr/verbs.c         | 1098 ++++++++++++++++++++++++-
>  drivers/infiniband/hw/qedr/verbs.h         |    7 +
>  drivers/net/ethernet/qlogic/qed/qed_cxt.h  |    1 +
>  drivers/net/ethernet/qlogic/qed/qed_roce.c | 1211 ++++++++++++++++++++++++++++
>  drivers/net/ethernet/qlogic/qed/qed_roce.h |   71 ++
>  include/linux/qed/qed_roce_if.h            |  144 ++++
>  11 files changed, 2756 insertions(+), 2 deletions(-)
>  create mode 100644 drivers/infiniband/hw/qedr/qedr_cm.h
>

<....>

> +
> +static inline int get_gid_info_from_table(struct ib_qp *ibqp,
> +					  struct ib_qp_attr *attr,
> +					  int attr_mask,
> +					  struct qed_rdma_modify_qp_in_params
> +					  *qp_params)
> +{
> +	enum rdma_network_type nw_type;
> +	struct ib_gid_attr gid_attr;
> +	union ib_gid gid;
> +	u32 ipv4_addr;
> +	int rc = 0;
> +	int i;
> +
> +	rc = ib_get_cached_gid(ibqp->device, attr->ah_attr.port_num,
> +			       attr->ah_attr.grh.sgid_index, &gid, &gid_attr);
> +	if (!rc && !memcmp(&gid, &zgid, sizeof(gid)))
> +		rc = -ENOENT;
> +
> +	if (!rc && gid_attr.ndev) {
> +		qp_params->vlan_id = rdma_vlan_dev_vlan_id(gid_attr.ndev);
> +
> +		dev_put(gid_attr.ndev);
> +		nw_type = ib_gid_to_network_type(gid_attr.gid_type, &gid);
> +		switch (nw_type) {
> +		case RDMA_NETWORK_IPV6:
> +			memcpy(&qp_params->sgid.bytes[0], &gid.raw[0],
> +			       sizeof(qp_params->sgid));
> +			memcpy(&qp_params->dgid.bytes[0],
> +			       &attr->ah_attr.grh.dgid,
> +			       sizeof(qp_params->dgid));
> +			qp_params->roce_mode = ROCE_V2_IPV6;
> +			SET_FIELD(qp_params->modify_flags,
> +				  QED_ROCE_MODIFY_QP_VALID_ROCE_MODE, 1);
> +			break;
> +		case RDMA_NETWORK_IB:
> +			memcpy(&qp_params->sgid.bytes[0], &gid.raw[0],
> +			       sizeof(qp_params->sgid));
> +			memcpy(&qp_params->dgid.bytes[0],
> +			       &attr->ah_attr.grh.dgid,
> +			       sizeof(qp_params->dgid));
> +			qp_params->roce_mode = ROCE_V1;
> +			break;
> +		case RDMA_NETWORK_IPV4:
> +			memset(&qp_params->sgid, 0, sizeof(qp_params->sgid));
> +			memset(&qp_params->dgid, 0, sizeof(qp_params->dgid));
> +			ipv4_addr = qedr_get_ipv4_from_gid(gid.raw);
> +			qp_params->sgid.ipv4_addr = ipv4_addr;
> +			ipv4_addr =
> +			    qedr_get_ipv4_from_gid(attr->ah_attr.grh.dgid.raw);
> +			qp_params->dgid.ipv4_addr = ipv4_addr;
> +			SET_FIELD(qp_params->modify_flags,
> +				  QED_ROCE_MODIFY_QP_VALID_ROCE_MODE, 1);
> +			qp_params->roce_mode = ROCE_V2_IPV4;
> +			break;
> +		}
> +	}
> +	if (rc)
> +		return -EINVAL;

I think it is better to check "rc" right after call to
ib_get_cached_gid().


--q5wOvoHkaccQRDme
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX2py0AAoJEORje4g2clinPZIQANC+cY8oXajehPYoxC6sTRgM
MbTB8hpyUvx06VWYzL3qI36/s/ldvqlsSuQPQ0T6YOMPJYdll/blDSpdxJxCyOpl
6EqkRmtOLOmfQV/y0Sx+jN/zhR7Cd9WKN9DVV70m9HzK+zYchYPTwgaHXy7vhL/W
amMak+FCCaDHtaEReMIECpLz7VflCfSrKZe0d9MTOysN+ac82OAmwFDJrzniDu5P
yQ2uL6nDGOtIbw8kgBJIqg/siq0sznIKkMon8gL036YVYDnmYCoDNnp9ZgphEmza
5zvUC1v4vu2lbv+YAFQSDr26OMb+A6mTlod28XfPtTVoNJOI+Zz0jC6LdIf6FGlV
fY+F2cRl8OgJvvtmooMktP21DnH3WzJGL4ueKTTq4gTwLsrDSVtV+QoSMJ25oFOO
OWBDAw5kZ9drape/nlaFwoJIW4wzzaNsW082KcGwGxCTnIJUDqD3K69BqJNJQYhB
gLqVRs1XrAGXP5H9iCkbjUX96Q9gDXxTf8X90vbqCJCejSUwKxxq+kAWHJpXnEd7
4PWKzHeHG2L724I8FkIIR/PGkP29tZNsCk68EU41qNkpCI//7j0h8M8JTeHWVS6F
9pl0ElE7d+OL1CzeEbRuRwu0NhskS1z3QArshTnM4eYcUT/Yqv3U5hl7xf3f6MBT
CKH6QDGfFedzHj11gpva
=lzzF
-----END PGP SIGNATURE-----

--q5wOvoHkaccQRDme--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
