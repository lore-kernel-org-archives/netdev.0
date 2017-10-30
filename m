From: Mark Brown <broonie@kernel.org>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Mon, 30 Oct 2017 17:02:24 +0000
Message-ID: <20171030170224.badokg3dsgjb4hvg@sirena.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="esaqopspeo4g64zq"
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--esaqopspeo4g64zq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/netronome/nfp/flower/action.c

between commit:

  d309ae5c6a0064 ("nfp: refuse offloading filters that redirects to upper d=
evices")

=66rom Linus' tree and commit:

  62d3f60b4d065c ("nfp: use struct fields for 8 bit-wide access")

=66rom the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

diff --cc drivers/net/ethernet/netronome/nfp/flower/action.c
index 8ea9320014ee,0a5fc9f8545f..000000000000
--- a/drivers/net/ethernet/netronome/nfp/flower/action.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/action.c
@@@ -105,19 -104,326 +104,329 @@@ nfp_fl_output(struct nfp_fl_output *out
  	if (!out_dev)
  		return -EOPNOTSUPP;
 =20
- 	/* Only offload egress ports are on the same device as the ingress
- 	 * port.
+ 	tmp_flags =3D last ? NFP_FL_OUT_FLAGS_LAST : 0;
+=20
+ 	if (tun_type) {
+ 		/* Verify the egress netdev matches the tunnel type. */
+ 		if (!nfp_fl_netdev_is_tunnel_type(out_dev, tun_type))
+ 			return -EOPNOTSUPP;
+=20
+ 		if (*tun_out_cnt)
+ 			return -EOPNOTSUPP;
+ 		(*tun_out_cnt)++;
+=20
+ 		output->flags =3D cpu_to_be16(tmp_flags |
+ 					    NFP_FL_OUT_FLAGS_USE_TUN);
+ 		output->port =3D cpu_to_be32(NFP_FL_PORT_TYPE_TUN | tun_type);
+ 	} else {
+ 		/* Set action output parameters. */
+ 		output->flags =3D cpu_to_be16(tmp_flags);
+=20
+ 		/* Only offload if egress ports are on the same device as the
+ 		 * ingress port.
+ 		 */
+ 		if (!switchdev_port_same_parent_id(in_dev, out_dev))
+ 			return -EOPNOTSUPP;
+=20
+ 		output->port =3D cpu_to_be32(nfp_repr_get_port_id(out_dev));
+ 		if (!output->port)
+ 			return -EOPNOTSUPP;
+ 	}
+ 	nfp_flow->meta.shortcut =3D output->port;
+=20
+ 	return 0;
+ }
+=20
+ static bool nfp_fl_supported_tun_port(const struct tc_action *action)
+ {
+ 	struct ip_tunnel_info *tun =3D tcf_tunnel_info(action);
+=20
+ 	return tun->key.tp_dst =3D=3D htons(NFP_FL_VXLAN_PORT);
+ }
+=20
+ static struct nfp_fl_pre_tunnel *nfp_fl_pre_tunnel(char *act_data, int ac=
t_len)
+ {
+ 	size_t act_size =3D sizeof(struct nfp_fl_pre_tunnel);
+ 	struct nfp_fl_pre_tunnel *pre_tun_act;
+=20
+ 	/* Pre_tunnel action must be first on action list.
+ 	 * If other actions already exist they need pushed forward.
  	 */
- 	if (!switchdev_port_same_parent_id(in_dev, out_dev))
+ 	if (act_len)
+ 		memmove(act_data + act_size, act_data, act_len);
+=20
+ 	pre_tun_act =3D (struct nfp_fl_pre_tunnel *)act_data;
+=20
+ 	memset(pre_tun_act, 0, act_size);
+=20
+ 	pre_tun_act->head.jump_id =3D NFP_FL_ACTION_OPCODE_PRE_TUNNEL;
+ 	pre_tun_act->head.len_lw =3D act_size >> NFP_FL_LW_SIZ;
+=20
+ 	return pre_tun_act;
+ }
+=20
+ static int
+ nfp_fl_set_vxlan(struct nfp_fl_set_vxlan *set_vxlan,
+ 		 const struct tc_action *action,
+ 		 struct nfp_fl_pre_tunnel *pre_tun)
+ {
+ 	struct ip_tunnel_info *vxlan =3D tcf_tunnel_info(action);
+ 	size_t act_size =3D sizeof(struct nfp_fl_set_vxlan);
+ 	u32 tmp_set_vxlan_type_index =3D 0;
+ 	/* Currently support one pre-tunnel so index is always 0. */
+ 	int pretun_idx =3D 0;
+=20
+ 	if (vxlan->options_len) {
+ 		/* Do not support options e.g. vxlan gpe. */
  		return -EOPNOTSUPP;
+ 	}
+=20
 +	if (!nfp_netdev_is_nfp_repr(out_dev))
 +		return -EOPNOTSUPP;
 +
- 	output->port =3D cpu_to_be32(nfp_repr_get_port_id(out_dev));
- 	if (!output->port)
+ 	set_vxlan->head.jump_id =3D NFP_FL_ACTION_OPCODE_SET_IPV4_TUNNEL;
+ 	set_vxlan->head.len_lw =3D act_size >> NFP_FL_LW_SIZ;
+=20
+ 	/* Set tunnel type and pre-tunnel index. */
+ 	tmp_set_vxlan_type_index |=3D
+ 		FIELD_PREP(NFP_FL_IPV4_TUNNEL_TYPE, NFP_FL_TUNNEL_VXLAN) |
+ 		FIELD_PREP(NFP_FL_IPV4_PRE_TUN_INDEX, pretun_idx);
+=20
+ 	set_vxlan->tun_type_index =3D cpu_to_be32(tmp_set_vxlan_type_index);
+=20
+ 	set_vxlan->tun_id =3D vxlan->key.tun_id;
+ 	set_vxlan->tun_flags =3D vxlan->key.tun_flags;
+ 	set_vxlan->ipv4_ttl =3D vxlan->key.ttl;
+ 	set_vxlan->ipv4_tos =3D vxlan->key.tos;
+=20
+ 	/* Complete pre_tunnel action. */
+ 	pre_tun->ipv4_dst =3D vxlan->key.u.ipv4.dst;
+=20
+ 	return 0;
+ }
+=20
+ static void nfp_fl_set_helper32(u32 value, u32 mask, u8 *p_exact, u8 *p_m=
ask)
+ {
+ 	u32 oldvalue =3D get_unaligned((u32 *)p_exact);
+ 	u32 oldmask =3D get_unaligned((u32 *)p_mask);
+=20
+ 	value &=3D mask;
+ 	value |=3D oldvalue & ~mask;
+=20
+ 	put_unaligned(oldmask | mask, (u32 *)p_mask);
+ 	put_unaligned(value, (u32 *)p_exact);
+ }
+=20
+ static int
+ nfp_fl_set_eth(const struct tc_action *action, int idx, u32 off,
+ 	       struct nfp_fl_set_eth *set_eth)
+ {
+ 	u32 exact, mask;
+=20
+ 	if (off + 4 > ETH_ALEN * 2)
+ 		return -EOPNOTSUPP;
+=20
+ 	mask =3D ~tcf_pedit_mask(action, idx);
+ 	exact =3D tcf_pedit_val(action, idx);
+=20
+ 	if (exact & ~mask)
  		return -EOPNOTSUPP;
 =20
- 	nfp_flow->meta.shortcut =3D output->port;
+ 	nfp_fl_set_helper32(exact, mask, &set_eth->eth_addr_val[off],
+ 			    &set_eth->eth_addr_mask[off]);
+=20
+ 	set_eth->reserved =3D cpu_to_be16(0);
+ 	set_eth->head.jump_id =3D NFP_FL_ACTION_OPCODE_SET_ETHERNET;
+ 	set_eth->head.len_lw =3D sizeof(*set_eth) >> NFP_FL_LW_SIZ;
+=20
+ 	return 0;
+ }
+=20
+ static int
+ nfp_fl_set_ip4(const struct tc_action *action, int idx, u32 off,
+ 	       struct nfp_fl_set_ip4_addrs *set_ip_addr)
+ {
+ 	__be32 exact, mask;
+=20
+ 	/* We are expecting tcf_pedit to return a big endian value */
+ 	mask =3D (__force __be32)~tcf_pedit_mask(action, idx);
+ 	exact =3D (__force __be32)tcf_pedit_val(action, idx);
+=20
+ 	if (exact & ~mask)
+ 		return -EOPNOTSUPP;
+=20
+ 	switch (off) {
+ 	case offsetof(struct iphdr, daddr):
+ 		set_ip_addr->ipv4_dst_mask =3D mask;
+ 		set_ip_addr->ipv4_dst =3D exact;
+ 		break;
+ 	case offsetof(struct iphdr, saddr):
+ 		set_ip_addr->ipv4_src_mask =3D mask;
+ 		set_ip_addr->ipv4_src =3D exact;
+ 		break;
+ 	default:
+ 		return -EOPNOTSUPP;
+ 	}
+=20
+ 	set_ip_addr->reserved =3D cpu_to_be16(0);
+ 	set_ip_addr->head.jump_id =3D NFP_FL_ACTION_OPCODE_SET_IPV4_ADDRS;
+ 	set_ip_addr->head.len_lw =3D sizeof(*set_ip_addr) >> NFP_FL_LW_SIZ;
+=20
+ 	return 0;
+ }
+=20
+ static void
+ nfp_fl_set_ip6_helper(int opcode_tag, int idx, __be32 exact, __be32 mask,
+ 		      struct nfp_fl_set_ipv6_addr *ip6)
+ {
+ 	ip6->ipv6[idx % 4].mask =3D mask;
+ 	ip6->ipv6[idx % 4].exact =3D exact;
+=20
+ 	ip6->reserved =3D cpu_to_be16(0);
+ 	ip6->head.jump_id =3D opcode_tag;
+ 	ip6->head.len_lw =3D sizeof(*ip6) >> NFP_FL_LW_SIZ;
+ }
+=20
+ static int
+ nfp_fl_set_ip6(const struct tc_action *action, int idx, u32 off,
+ 	       struct nfp_fl_set_ipv6_addr *ip_dst,
+ 	       struct nfp_fl_set_ipv6_addr *ip_src)
+ {
+ 	__be32 exact, mask;
+=20
+ 	/* We are expecting tcf_pedit to return a big endian value */
+ 	mask =3D (__force __be32)~tcf_pedit_mask(action, idx);
+ 	exact =3D (__force __be32)tcf_pedit_val(action, idx);
+=20
+ 	if (exact & ~mask)
+ 		return -EOPNOTSUPP;
+=20
+ 	if (off < offsetof(struct ipv6hdr, saddr))
+ 		return -EOPNOTSUPP;
+ 	else if (off < offsetof(struct ipv6hdr, daddr))
+ 		nfp_fl_set_ip6_helper(NFP_FL_ACTION_OPCODE_SET_IPV6_SRC, idx,
+ 				      exact, mask, ip_src);
+ 	else if (off < offsetof(struct ipv6hdr, daddr) +
+ 		       sizeof(struct in6_addr))
+ 		nfp_fl_set_ip6_helper(NFP_FL_ACTION_OPCODE_SET_IPV6_DST, idx,
+ 				      exact, mask, ip_dst);
+ 	else
+ 		return -EOPNOTSUPP;
+=20
+ 	return 0;
+ }
+=20
+ static int
+ nfp_fl_set_tport(const struct tc_action *action, int idx, u32 off,
+ 		 struct nfp_fl_set_tport *set_tport, int opcode)
+ {
+ 	u32 exact, mask;
+=20
+ 	if (off)
+ 		return -EOPNOTSUPP;
+=20
+ 	mask =3D ~tcf_pedit_mask(action, idx);
+ 	exact =3D tcf_pedit_val(action, idx);
+=20
+ 	if (exact & ~mask)
+ 		return -EOPNOTSUPP;
+=20
+ 	nfp_fl_set_helper32(exact, mask, set_tport->tp_port_val,
+ 			    set_tport->tp_port_mask);
+=20
+ 	set_tport->reserved =3D cpu_to_be16(0);
+ 	set_tport->head.jump_id =3D opcode;
+ 	set_tport->head.len_lw =3D sizeof(*set_tport) >> NFP_FL_LW_SIZ;
+=20
+ 	return 0;
+ }
+=20
+ static int
+ nfp_fl_pedit(const struct tc_action *action, char *nfp_action, int *a_len)
+ {
+ 	struct nfp_fl_set_ipv6_addr set_ip6_dst, set_ip6_src;
+ 	struct nfp_fl_set_ip4_addrs set_ip_addr;
+ 	struct nfp_fl_set_tport set_tport;
+ 	struct nfp_fl_set_eth set_eth;
+ 	enum pedit_header_type htype;
+ 	int idx, nkeys, err;
+ 	size_t act_size;
+ 	u32 offset, cmd;
+=20
+ 	memset(&set_ip6_dst, 0, sizeof(set_ip6_dst));
+ 	memset(&set_ip6_src, 0, sizeof(set_ip6_src));
+ 	memset(&set_ip_addr, 0, sizeof(set_ip_addr));
+ 	memset(&set_tport, 0, sizeof(set_tport));
+ 	memset(&set_eth, 0, sizeof(set_eth));
+ 	nkeys =3D tcf_pedit_nkeys(action);
+=20
+ 	for (idx =3D 0; idx < nkeys; idx++) {
+ 		cmd =3D tcf_pedit_cmd(action, idx);
+ 		htype =3D tcf_pedit_htype(action, idx);
+ 		offset =3D tcf_pedit_offset(action, idx);
+=20
+ 		if (cmd !=3D TCA_PEDIT_KEY_EX_CMD_SET)
+ 			return -EOPNOTSUPP;
+=20
+ 		switch (htype) {
+ 		case TCA_PEDIT_KEY_EX_HDR_TYPE_ETH:
+ 			err =3D nfp_fl_set_eth(action, idx, offset, &set_eth);
+ 			break;
+ 		case TCA_PEDIT_KEY_EX_HDR_TYPE_IP4:
+ 			err =3D nfp_fl_set_ip4(action, idx, offset, &set_ip_addr);
+ 			break;
+ 		case TCA_PEDIT_KEY_EX_HDR_TYPE_IP6:
+ 			err =3D nfp_fl_set_ip6(action, idx, offset, &set_ip6_dst,
+ 					     &set_ip6_src);
+ 			break;
+ 		case TCA_PEDIT_KEY_EX_HDR_TYPE_TCP:
+ 			err =3D nfp_fl_set_tport(action, idx, offset, &set_tport,
+ 					       NFP_FL_ACTION_OPCODE_SET_TCP);
+ 			break;
+ 		case TCA_PEDIT_KEY_EX_HDR_TYPE_UDP:
+ 			err =3D nfp_fl_set_tport(action, idx, offset, &set_tport,
+ 					       NFP_FL_ACTION_OPCODE_SET_UDP);
+ 			break;
+ 		default:
+ 			return -EOPNOTSUPP;
+ 		}
+ 		if (err)
+ 			return err;
+ 	}
+=20
+ 	if (set_eth.head.len_lw) {
+ 		act_size =3D sizeof(set_eth);
+ 		memcpy(nfp_action, &set_eth, act_size);
+ 		*a_len +=3D act_size;
+ 	} else if (set_ip_addr.head.len_lw) {
+ 		act_size =3D sizeof(set_ip_addr);
+ 		memcpy(nfp_action, &set_ip_addr, act_size);
+ 		*a_len +=3D act_size;
+ 	} else if (set_ip6_dst.head.len_lw && set_ip6_src.head.len_lw) {
+ 		/* TC compiles set src and dst IPv6 address as a single action,
+ 		 * the hardware requires this to be 2 separate actions.
+ 		 */
+ 		act_size =3D sizeof(set_ip6_src);
+ 		memcpy(nfp_action, &set_ip6_src, act_size);
+ 		*a_len +=3D act_size;
+=20
+ 		act_size =3D sizeof(set_ip6_dst);
+ 		memcpy(&nfp_action[sizeof(set_ip6_src)], &set_ip6_dst,
+ 		       act_size);
+ 		*a_len +=3D act_size;
+ 	} else if (set_ip6_dst.head.len_lw) {
+ 		act_size =3D sizeof(set_ip6_dst);
+ 		memcpy(nfp_action, &set_ip6_dst, act_size);
+ 		*a_len +=3D act_size;
+ 	} else if (set_ip6_src.head.len_lw) {
+ 		act_size =3D sizeof(set_ip6_src);
+ 		memcpy(nfp_action, &set_ip6_src, act_size);
+ 		*a_len +=3D act_size;
+ 	} else if (set_tport.head.len_lw) {
+ 		act_size =3D sizeof(set_tport);
+ 		memcpy(nfp_action, &set_tport, act_size);
+ 		*a_len +=3D act_size;
+ 	}
 =20
  	return 0;
  }

--esaqopspeo4g64zq
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAln3Wx8ACgkQJNaLcl1U
h9Dq4Af5AbfUbVAbvQUICsByjp0T2j352cTXLA4xUjjMCNwVmyqJI57ng2gdwp5K
27dAJqYaqTffVwEQOByVmcOfMylgbw+6rO06Agw3WXHZ7PUQ1I82zl7IDo/o0n6V
O4dnK1UXMea83Dx47MMSROrl+OpxllN11HJExIn7Cf4lDZpxtQkEoX34TLWfS24b
vS6Mc695uyFsXRTGzoKmjX1S9DSfEp7VvmqVUa1D+nbVnhPCAWtoDTESYLcHBTQX
f9gzBtU3F4LwLZsDZCjsnbMyCiLZsgcgg5xDVmAP7h+P5ae/dHBL8fA018Ohs7LU
mVXnnyGM4HwhvCFn+1Bg8MuTPwFeuQ==
=jGXD
-----END PGP SIGNATURE-----

--esaqopspeo4g64zq--
