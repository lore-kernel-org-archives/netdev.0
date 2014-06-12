From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Thu, 12 Jun 2014 12:01:46 +1000
Message-ID: <20140612120146.74f55b1d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/uDDBZh3NHhtG.3fg7OWwddM"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Roland Dreier <roland@kernel.org>, linux-rdma@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/uDDBZh3NHhtG.3fg7OWwddM
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/infiniband/hw/cxgb4/cm.c between commits 11b8e22d4d09
("RDMA/cxgb4: Fix vlan support") and 9eccfe109b27 ("RDMA/cxgb4: Add
support for iWARP Port Mapper user space service") from Linus' tree and
commits 92e7ae71726c ("iw_cxgb4: Choose appropriate hw mtu index and
ISS for iWARP connections") and b408ff282dda ("iw_cxgb4: don't truncate
the recv window size") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/infiniband/hw/cxgb4/cm.c
index 96d7131ab974,965eaafd5851..000000000000
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@@ -533,38 -532,17 +537,49 @@@ static int send_abort(struct c4iw_ep *e
  	return c4iw_l2t_send(&ep->com.dev->rdev, skb, ep->l2t);
  }
 =20
 +/*
 + * c4iw_form_pm_msg - Form a port mapper message with mapping info
 + */
 +static void c4iw_form_pm_msg(struct c4iw_ep *ep,
 +				struct iwpm_sa_data *pm_msg)
 +{
 +	memcpy(&pm_msg->loc_addr, &ep->com.local_addr,
 +		sizeof(ep->com.local_addr));
 +	memcpy(&pm_msg->rem_addr, &ep->com.remote_addr,
 +		sizeof(ep->com.remote_addr));
 +}
 +
 +/*
 + * c4iw_form_reg_msg - Form a port mapper message with dev info
 + */
 +static void c4iw_form_reg_msg(struct c4iw_dev *dev,
 +				struct iwpm_dev_data *pm_msg)
 +{
 +	memcpy(pm_msg->dev_name, dev->ibdev.name, IWPM_DEVNAME_SIZE);
 +	memcpy(pm_msg->if_name, dev->rdev.lldi.ports[0]->name,
 +				IWPM_IFNAME_SIZE);
 +}
 +
 +static void c4iw_record_pm_msg(struct c4iw_ep *ep,
 +			struct iwpm_sa_data *pm_msg)
 +{
 +	memcpy(&ep->com.mapped_local_addr, &pm_msg->mapped_loc_addr,
 +		sizeof(ep->com.mapped_local_addr));
 +	memcpy(&ep->com.mapped_remote_addr, &pm_msg->mapped_rem_addr,
 +		sizeof(ep->com.mapped_remote_addr));
 +}
 +
+ static void best_mtu(const unsigned short *mtus, unsigned short mtu,
+ 		     unsigned int *idx, int use_ts)
+ {
+ 	unsigned short hdr_size =3D sizeof(struct iphdr) +
+ 				  sizeof(struct tcphdr) +
+ 				  (use_ts ? 12 : 0);
+ 	unsigned short data_size =3D mtu - hdr_size;
+=20
+ 	cxgb4_best_aligned_mtu(mtus, hdr_size, data_size, 8, idx);
+ }
+=20
  static int send_connect(struct c4iw_ep *ep)
  {
  	struct cpl_act_open_req *req;
@@@ -583,14 -561,11 +598,15 @@@
  	int sizev6 =3D is_t4(ep->com.dev->rdev.lldi.adapter_type) ?
  				sizeof(struct cpl_act_open_req6) :
  				sizeof(struct cpl_t5_act_open_req6);
 -	struct sockaddr_in *la =3D (struct sockaddr_in *)&ep->com.local_addr;
 -	struct sockaddr_in *ra =3D (struct sockaddr_in *)&ep->com.remote_addr;
 -	struct sockaddr_in6 *la6 =3D (struct sockaddr_in6 *)&ep->com.local_addr;
 -	struct sockaddr_in6 *ra6 =3D (struct sockaddr_in6 *)&ep->com.remote_addr;
 +	struct sockaddr_in *la =3D (struct sockaddr_in *)
 +				 &ep->com.mapped_local_addr;
 +	struct sockaddr_in *ra =3D (struct sockaddr_in *)
 +				 &ep->com.mapped_remote_addr;
 +	struct sockaddr_in6 *la6 =3D (struct sockaddr_in6 *)
 +				   &ep->com.mapped_local_addr;
 +	struct sockaddr_in6 *ra6 =3D (struct sockaddr_in6 *)
 +				   &ep->com.mapped_remote_addr;
+ 	int win;
 =20
  	wrlen =3D (ep->com.remote_addr.ss_family =3D=3D AF_INET) ?
  			roundup(sizev4, 16) :
@@@ -1796,7 -1821,8 +1862,8 @@@ static int import_ep(struct c4iw_ep *ep
  		step =3D cdev->rdev.lldi.nrxq /
  			cdev->rdev.lldi.nchan;
  		ep->rss_qid =3D cdev->rdev.lldi.rxq_ids[
 -			cxgb4_port_idx(n->dev) * step];
 +			cxgb4_port_idx(pdev) * step];
+ 		set_tcp_window(ep, (struct port_info *)netdev_priv(pdev));
 =20
  		if (clear_mpa_v1) {
  			ep->retry_with_mpa_v1 =3D 0;

--Sig_/uDDBZh3NHhtG.3fg7OWwddM
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJTmQoPAAoJEMDTa8Ir7ZwVb9MP/inAPHgZ3+Zb6t/5TPc6qPfK
LjS3tLXTQcJK1wkjahO+tPhb8UuiZNnhgQS7VoGDUlbtgMXUA2xTP9+B/q8hk4Of
ZH5zI3SsfQ08X8iiS+XbqeVQMgciBoREUJRno2O4ZryA5GqDZXbdjBloy0utSHM6
EtvcquP4u+U8CkxuyfanNGVtdaJpVCKgOLDRrbs+El5ZuP6s4nOnn4zDI5+CbZFv
a3Q6zXelsm6LFY1Esad0uqw+6XJ6jvTnhHKUaFeHBdwUPtSv0JtqFmklegImk87i
6jkL8xYbHlB/y5rKXv3EcxWBU4iINj7gPZvI6nUKyfShzr38VqEqLg2ek944W73N
ixG4DlLF2QyPuzwXxArxSH9v3Gg+jMN3qHbw38X6t+kBc2TmbnTpFYvJz15v98R7
Dl3ijfWDDZFVjxMvbRRDMhWxveOayYyqW7TbCQ1FF9HVHR01iJE4HhHZu+RnGYpp
c8DbQtU+K+tq4AIFhNTDs06BC7xjicDw/C052A8ypgFiiOd8YTpaplmjPazSxgNl
/nEboJEsym6fibzMlF+uXPFFtPC9Jt/A0k3fLdAC/mLRElv477IaKt7X2A8iVmEE
fmbA3FEzDuwAYZbu/XOnXf18ne2vzchIYuWBOvV7/+3ZyzV9VEEJ6Bs9LI6ATkNF
6CqMWfdHbtr3HrK7EZFq
=m3Ok
-----END PGP SIGNATURE-----

--Sig_/uDDBZh3NHhtG.3fg7OWwddM--
