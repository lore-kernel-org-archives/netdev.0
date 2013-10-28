From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 28 Oct 2013 15:23:25 +1100
Message-ID: <20131028152325.420fa47f1a2620168acbf002@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__28_Oct_2013_15_23_25_+1100_t5NoZKEre7yDn8xF"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Somnath Kotur <somnath.kotur@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__28_Oct_2013_15_23_25_+1100_t5NoZKEre7yDn8xF
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/emulex/benet/be.h between commit e9e2a904ef0a
("be2net: Warn users of possible broken functionality on BE2 cards with
very old FW versions with latest driver") from the net tree and commit
6384a4d0dcf9 ("be2net: add support for ndo_busy_poll") from the net-next
tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/emulex/benet/be.h
index c99dac6a9ddf,b2765ebb0268..000000000000
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@@ -696,23 -733,114 +733,123 @@@ static inline int qnq_async_evt_rcvd(st
  	return adapter->flags & BE_FLAGS_QNQ_ASYNC_EVT_RCVD;
  }
 =20
 +static inline int fw_major_num(const char *fw_ver)
 +{
 +	int fw_major =3D 0;
 +
 +	sscanf(fw_ver, "%d.", &fw_major);
 +
 +	return fw_major;
 +}
 +
- extern void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
- 		u16 num_popped);
- extern void be_link_status_update(struct be_adapter *adapter, u8 link_sta=
tus);
- extern void be_parse_stats(struct be_adapter *adapter);
- extern int be_load_fw(struct be_adapter *adapter, u8 *func);
- extern bool be_is_wol_supported(struct be_adapter *adapter);
- extern bool be_pause_supported(struct be_adapter *adapter);
- extern u32 be_get_fw_log_level(struct be_adapter *adapter);
+ #ifdef CONFIG_NET_RX_BUSY_POLL
+ static inline bool be_lock_napi(struct be_eq_obj *eqo)
+ {
+ 	bool status =3D true;
+=20
+ 	spin_lock(&eqo->lock); /* BH is already disabled */
+ 	if (eqo->state & BE_EQ_LOCKED) {
+ 		WARN_ON(eqo->state & BE_EQ_NAPI);
+ 		eqo->state |=3D BE_EQ_NAPI_YIELD;
+ 		status =3D false;
+ 	} else {
+ 		eqo->state =3D BE_EQ_NAPI;
+ 	}
+ 	spin_unlock(&eqo->lock);
+ 	return status;
+ }
+=20
+ static inline void be_unlock_napi(struct be_eq_obj *eqo)
+ {
+ 	spin_lock(&eqo->lock); /* BH is already disabled */
+=20
+ 	WARN_ON(eqo->state & (BE_EQ_POLL | BE_EQ_NAPI_YIELD));
+ 	eqo->state =3D BE_EQ_IDLE;
+=20
+ 	spin_unlock(&eqo->lock);
+ }
+=20
+ static inline bool be_lock_busy_poll(struct be_eq_obj *eqo)
+ {
+ 	bool status =3D true;
+=20
+ 	spin_lock_bh(&eqo->lock);
+ 	if (eqo->state & BE_EQ_LOCKED) {
+ 		eqo->state |=3D BE_EQ_POLL_YIELD;
+ 		status =3D false;
+ 	} else {
+ 		eqo->state |=3D BE_EQ_POLL;
+ 	}
+ 	spin_unlock_bh(&eqo->lock);
+ 	return status;
+ }
+=20
+ static inline void be_unlock_busy_poll(struct be_eq_obj *eqo)
+ {
+ 	spin_lock_bh(&eqo->lock);
+=20
+ 	WARN_ON(eqo->state & (BE_EQ_NAPI));
+ 	eqo->state =3D BE_EQ_IDLE;
+=20
+ 	spin_unlock_bh(&eqo->lock);
+ }
+=20
+ static inline void be_enable_busy_poll(struct be_eq_obj *eqo)
+ {
+ 	spin_lock_init(&eqo->lock);
+ 	eqo->state =3D BE_EQ_IDLE;
+ }
+=20
+ static inline void be_disable_busy_poll(struct be_eq_obj *eqo)
+ {
+ 	local_bh_disable();
+=20
+ 	/* It's enough to just acquire napi lock on the eqo to stop
+ 	 * be_busy_poll() from processing any queueus.
+ 	 */
+ 	while (!be_lock_napi(eqo))
+ 		mdelay(1);
+=20
+ 	local_bh_enable();
+ }
+=20
+ #else /* CONFIG_NET_RX_BUSY_POLL */
+=20
+ static inline bool be_lock_napi(struct be_eq_obj *eqo)
+ {
+ 	return true;
+ }
+=20
+ static inline void be_unlock_napi(struct be_eq_obj *eqo)
+ {
+ }
+=20
+ static inline bool be_lock_busy_poll(struct be_eq_obj *eqo)
+ {
+ 	return false;
+ }
+=20
+ static inline void be_unlock_busy_poll(struct be_eq_obj *eqo)
+ {
+ }
+=20
+ static inline void be_enable_busy_poll(struct be_eq_obj *eqo)
+ {
+ }
+=20
+ static inline void be_disable_busy_poll(struct be_eq_obj *eqo)
+ {
+ }
+ #endif /* CONFIG_NET_RX_BUSY_POLL */
+=20
+ void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
+ 		  u16 num_popped);
+ void be_link_status_update(struct be_adapter *adapter, u8 link_status);
+ void be_parse_stats(struct be_adapter *adapter);
+ int be_load_fw(struct be_adapter *adapter, u8 *func);
+ bool be_is_wol_supported(struct be_adapter *adapter);
+ bool be_pause_supported(struct be_adapter *adapter);
+ u32 be_get_fw_log_level(struct be_adapter *adapter);
  int be_update_queues(struct be_adapter *adapter);
  int be_poll(struct napi_struct *napi, int budget);
 =20

--Signature=_Mon__28_Oct_2013_15_23_25_+1100_t5NoZKEre7yDn8xF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.21 (GNU/Linux)

iQIcBAEBCAAGBQJSbebBAAoJEMDTa8Ir7ZwV7WoP/3kA0YToUtYYFmtwB8Q3WFBi
uKoy2ndDr11M4wQwcviixkgwz5Ag9U2w2LYUCZdHGLkfbcTYT/lzh477hFyBi8+F
ylaCNfU+2lSX7TBNlN058zGwm5vbi3Eo9D3+hfK2pmFDwK6iKWpp++32JrJurcD4
2K3yF0LqYKJzYxoZJ23wLG7/IKmiuKEm6SooQcmAL+Ha4kHg2Hh/d9hC4wf7D0Qc
yT0ipRNXAQTmczKkCykaMXNmz15Ewl+4V4diqZgYbBhcSuSR9LxLEYlQFFShJisb
L6G+uEurgQH4wIV0eUJ1o63BuzZRXf6YPuuxeK2MBNnxe9qq/V9b04FFO5koTngP
kaw6lpAYYV0k1neG3NEurxTiz04H9vXJ7hmIANCItdO9BEEba271aoYHafVKP3L2
f6M/U1hLe4YYoGGQx4nqhG3PTd8pG9cibxOmrgwnklFtvyqBpe13frma8DWM21Tb
DCFhYSseW3u1qhEFzGHnrslMrrUD2ME+J1ZPbdBOwigeRJON/ZnVHWZFqKkzKUxA
OtD063w1NnAu94BsjyH7+PPRKWshhz8iMhI4QbuSpvRxgcrB4sPR+aF4mlKQ6iWr
jWc5YiCDZK68WYG3cfGeG/QsgYXUfaCOm1i7AHXrae2zsCf4d+Y4SExBSRZrm8hf
RvNe/lKwnzooa5cRKsE3
=mFUx
-----END PGP SIGNATURE-----

--Signature=_Mon__28_Oct_2013_15_23_25_+1100_t5NoZKEre7yDn8xF--
