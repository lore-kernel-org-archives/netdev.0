From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Wed, 11 Apr 2012 12:56:33 +1000
Message-ID: <20120411125633.c4b4aea8948a9ca9c74e9e2b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__11_Apr_2012_12_56_33_+1000_ybpPKmZiTVFAa_.6"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Javier Cardona <javier@cozybit.com>,
	Marco Porsch <marco.porsch@s2005.tu-chemnitz.de>,
	Pavel Zubarev <pavel.zubarev@gmail.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__11_Apr_2012_12_56_33_+1000_ybpPKmZiTVFAa_.6
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless-next tree got a conflict in
net/wireless/nl80211.c between commit 9360ffd18597 ("wireless: Stop using
NLA_PUT*()") from the net-next tree and commit d299a1f21ea7 ("{nl,cfg}
80211: Support for mesh synchronization") from the wireless-next tree.

I fixed it up (see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/wireless/nl80211.c
index 65622e9,b12a052..0000000
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@@ -2540,17 -2486,18 +2543,20 @@@ static int nl80211_send_station(struct=20
 =20
  		nla_nest_end(msg, bss_param);
  	}
 -	if (sinfo->filled & STATION_INFO_STA_FLAGS)
 -		NLA_PUT(msg, NL80211_STA_INFO_STA_FLAGS,
 -			sizeof(struct nl80211_sta_flag_update),
 -			&sinfo->sta_flags);
 -	if (sinfo->filled & STATION_INFO_T_OFFSET)
 -		NLA_PUT_U64(msg, NL80211_STA_INFO_T_OFFSET,
 -			    sinfo->t_offset);
 +	if ((sinfo->filled & STATION_INFO_STA_FLAGS) &&
 +	    nla_put(msg, NL80211_STA_INFO_STA_FLAGS,
 +		    sizeof(struct nl80211_sta_flag_update),
 +		    &sinfo->sta_flags))
 +		goto nla_put_failure;
++	if ((sinfo->filled & STATION_INFO_T_OFFSET) &&
++	    nla_put_u64(msg, NL80211_STA_INFO_T_OFFSET, sinfo->t_offset))
++		goto nla_put_failure;
  	nla_nest_end(msg, sinfoattr);
 =20
 -	if (sinfo->filled & STATION_INFO_ASSOC_REQ_IES)
 -		NLA_PUT(msg, NL80211_ATTR_IE, sinfo->assoc_req_ies_len,
 -			sinfo->assoc_req_ies);
 +	if ((sinfo->filled & STATION_INFO_ASSOC_REQ_IES) &&
 +	    nla_put(msg, NL80211_ATTR_IE, sinfo->assoc_req_ies_len,
 +		    sinfo->assoc_req_ies))
 +		goto nla_put_failure;
 =20
  	return genlmsg_end(msg, hdr);
 =20
@@@ -3328,48 -3274,49 +3334,50 @@@ static int nl80211_get_mesh_config(stru
  	pinfoattr =3D nla_nest_start(msg, NL80211_ATTR_MESH_CONFIG);
  	if (!pinfoattr)
  		goto nla_put_failure;
 -	NLA_PUT_U32(msg, NL80211_ATTR_IFINDEX, dev->ifindex);
 -	NLA_PUT_U16(msg, NL80211_MESHCONF_RETRY_TIMEOUT,
 -			cur_params.dot11MeshRetryTimeout);
 -	NLA_PUT_U16(msg, NL80211_MESHCONF_CONFIRM_TIMEOUT,
 -			cur_params.dot11MeshConfirmTimeout);
 -	NLA_PUT_U16(msg, NL80211_MESHCONF_HOLDING_TIMEOUT,
 -			cur_params.dot11MeshHoldingTimeout);
 -	NLA_PUT_U16(msg, NL80211_MESHCONF_MAX_PEER_LINKS,
 -			cur_params.dot11MeshMaxPeerLinks);
 -	NLA_PUT_U8(msg, NL80211_MESHCONF_MAX_RETRIES,
 -			cur_params.dot11MeshMaxRetries);
 -	NLA_PUT_U8(msg, NL80211_MESHCONF_TTL,
 -			cur_params.dot11MeshTTL);
 -	NLA_PUT_U8(msg, NL80211_MESHCONF_ELEMENT_TTL,
 -			cur_params.element_ttl);
 -	NLA_PUT_U8(msg, NL80211_MESHCONF_AUTO_OPEN_PLINKS,
 -			cur_params.auto_open_plinks);
 -	NLA_PUT_U32(msg, NL80211_MESHCONF_SYNC_OFFSET_MAX_NEIGHBOR,
 -			cur_params.dot11MeshNbrOffsetMaxNeighbor);
 -	NLA_PUT_U8(msg, NL80211_MESHCONF_HWMP_MAX_PREQ_RETRIES,
 -			cur_params.dot11MeshHWMPmaxPREQretries);
 -	NLA_PUT_U32(msg, NL80211_MESHCONF_PATH_REFRESH_TIME,
 -			cur_params.path_refresh_time);
 -	NLA_PUT_U16(msg, NL80211_MESHCONF_MIN_DISCOVERY_TIMEOUT,
 -			cur_params.min_discovery_timeout);
 -	NLA_PUT_U32(msg, NL80211_MESHCONF_HWMP_ACTIVE_PATH_TIMEOUT,
 -			cur_params.dot11MeshHWMPactivePathTimeout);
 -	NLA_PUT_U16(msg, NL80211_MESHCONF_HWMP_PREQ_MIN_INTERVAL,
 -			cur_params.dot11MeshHWMPpreqMinInterval);
 -	NLA_PUT_U16(msg, NL80211_MESHCONF_HWMP_PERR_MIN_INTERVAL,
 -			cur_params.dot11MeshHWMPperrMinInterval);
 -	NLA_PUT_U16(msg, NL80211_MESHCONF_HWMP_NET_DIAM_TRVS_TIME,
 -			cur_params.dot11MeshHWMPnetDiameterTraversalTime);
 -	NLA_PUT_U8(msg, NL80211_MESHCONF_HWMP_ROOTMODE,
 -			cur_params.dot11MeshHWMPRootMode);
 -	NLA_PUT_U16(msg, NL80211_MESHCONF_HWMP_RANN_INTERVAL,
 -			cur_params.dot11MeshHWMPRannInterval);
 -	NLA_PUT_U8(msg, NL80211_MESHCONF_GATE_ANNOUNCEMENTS,
 -			cur_params.dot11MeshGateAnnouncementProtocol);
 -	NLA_PUT_U8(msg, NL80211_MESHCONF_FORWARDING,
 -			cur_params.dot11MeshForwarding);
 -	NLA_PUT_U32(msg, NL80211_MESHCONF_RSSI_THRESHOLD,
 -			cur_params.rssi_threshold);
 +	if (nla_put_u32(msg, NL80211_ATTR_IFINDEX, dev->ifindex) ||
 +	    nla_put_u16(msg, NL80211_MESHCONF_RETRY_TIMEOUT,
 +			cur_params.dot11MeshRetryTimeout) ||
 +	    nla_put_u16(msg, NL80211_MESHCONF_CONFIRM_TIMEOUT,
 +			cur_params.dot11MeshConfirmTimeout) ||
 +	    nla_put_u16(msg, NL80211_MESHCONF_HOLDING_TIMEOUT,
 +			cur_params.dot11MeshHoldingTimeout) ||
 +	    nla_put_u16(msg, NL80211_MESHCONF_MAX_PEER_LINKS,
 +			cur_params.dot11MeshMaxPeerLinks) ||
 +	    nla_put_u8(msg, NL80211_MESHCONF_MAX_RETRIES,
 +		       cur_params.dot11MeshMaxRetries) ||
 +	    nla_put_u8(msg, NL80211_MESHCONF_TTL,
 +		       cur_params.dot11MeshTTL) ||
 +	    nla_put_u8(msg, NL80211_MESHCONF_ELEMENT_TTL,
 +		       cur_params.element_ttl) ||
 +	    nla_put_u8(msg, NL80211_MESHCONF_AUTO_OPEN_PLINKS,
 +		       cur_params.auto_open_plinks) ||
++	    nla_put_u32(msg, NL80211_MESHCONF_SYNC_OFFSET_MAX_NEIGHBOR,
++			cur_params.dot11MeshNbrOffsetMaxNeighbor) ||
 +	    nla_put_u8(msg, NL80211_MESHCONF_HWMP_MAX_PREQ_RETRIES,
 +		       cur_params.dot11MeshHWMPmaxPREQretries) ||
 +	    nla_put_u32(msg, NL80211_MESHCONF_PATH_REFRESH_TIME,
 +			cur_params.path_refresh_time) ||
 +	    nla_put_u16(msg, NL80211_MESHCONF_MIN_DISCOVERY_TIMEOUT,
 +			cur_params.min_discovery_timeout) ||
 +	    nla_put_u32(msg, NL80211_MESHCONF_HWMP_ACTIVE_PATH_TIMEOUT,
 +			cur_params.dot11MeshHWMPactivePathTimeout) ||
 +	    nla_put_u16(msg, NL80211_MESHCONF_HWMP_PREQ_MIN_INTERVAL,
 +			cur_params.dot11MeshHWMPpreqMinInterval) ||
 +	    nla_put_u16(msg, NL80211_MESHCONF_HWMP_PERR_MIN_INTERVAL,
 +			cur_params.dot11MeshHWMPperrMinInterval) ||
 +	    nla_put_u16(msg, NL80211_MESHCONF_HWMP_NET_DIAM_TRVS_TIME,
 +			cur_params.dot11MeshHWMPnetDiameterTraversalTime) ||
 +	    nla_put_u8(msg, NL80211_MESHCONF_HWMP_ROOTMODE,
 +		       cur_params.dot11MeshHWMPRootMode) ||
 +	    nla_put_u16(msg, NL80211_MESHCONF_HWMP_RANN_INTERVAL,
 +			cur_params.dot11MeshHWMPRannInterval) ||
 +	    nla_put_u8(msg, NL80211_MESHCONF_GATE_ANNOUNCEMENTS,
 +		       cur_params.dot11MeshGateAnnouncementProtocol) ||
 +	    nla_put_u8(msg, NL80211_MESHCONF_FORWARDING,
 +		       cur_params.dot11MeshForwarding) ||
 +	    nla_put_u32(msg, NL80211_MESHCONF_RSSI_THRESHOLD,
 +			cur_params.rssi_threshold))
 +		goto nla_put_failure;
  	nla_nest_end(msg, pinfoattr);
  	genlmsg_end(msg, hdr);
  	return genlmsg_reply(msg, info);

--Signature=_Wed__11_Apr_2012_12_56_33_+1000_ybpPKmZiTVFAa_.6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPhPLhAAoJEECxmPOUX5FE4lQP/iRR+7FnfPiQ8rvJsy6HdOa5
r+/7AirJYA8dNcflsLBgHPdACLrCX0SFqr7/m2MPSL+Ya1tysNRzZnPDuiiBKUWX
Y5FELzIdONAnS+CVhGIwP1h0kjdZV+LANW8qagvUu/3U0jzmQYiv+9M9kOgCNIka
X7oXerLYKvSegQ08XM6S+jShrP6Ju1jSL9ye0vELj6o+WsCf2wrWzAp4miYVpsfb
lUFkB88J+1E4IqN0Z9i15ftTgI0SgIjYG6Vl68ydfp3uSMn50tczPp5i0uim3hnN
8evpSA21npdM/DSzIf8Ltzwh4ewNaYTEKJ1JtmTsckQTTvHA09oHkKnUzChzsUXd
wLqSAfhU0oIDE9C2SkISUw/GWDSBDOZOejpgVidxRFIjzh01yvgxX3VT4xU4UN6/
C7+IyXCVqndTRFhhvikUTsCBHlA0hhXRzZcTPy4rfO7zr35A9C7IcwvMLVUS8v9D
kdG0MxKJDYT7Rw5hT4qFggRawt8NvT5rz4OUm1bAJMeqF2grxK/mkel55urGMKDc
hU/b6A97aCmEwZZsnsgCZ+LewfSnLfrmV+Imk6ll2lgpQ4BlTiqUw4FFKM4PWowq
CepD1vZLQAxsEoGKPI5fp+2P64MugtITJdQD2KEJpuiKQbes3EE60WWUDfmuw4n3
6J7u9/kuvuSROwO/BCcj
=MUMF
-----END PGP SIGNATURE-----

--Signature=_Wed__11_Apr_2012_12_56_33_+1000_ybpPKmZiTVFAa_.6--
