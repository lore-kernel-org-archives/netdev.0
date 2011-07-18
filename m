From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with Linus' tree
Date: Mon, 18 Jul 2011 14:41:38 +1000
Message-ID: <20110718144138.d57ab0a2a806e06fabbcfc9b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ilia Kolomisnky <iliak@ti.com>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	Luiz Augusto von Dentz <luiz.von.dentz@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/bluetooth/l2cap_core.c between commit 9191e6ad897a ("Bluetooth: Fix
regression in L2CAP connection procedure") from Linus' tree and commit
e2fd318e3a92 ("Bluetooth: Fixes l2cap "command reject" reply according to
spec") from the net tree.

I fixed it up (see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/bluetooth/l2cap_core.c
index 7705e26,f7f8e2c..0000000
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@@ -620,11 -763,10 +763,11 @@@ static void l2cap_conn_start(struct l2c
  					struct sock *parent = bt_sk(sk)->parent;
  					rsp.result = cpu_to_le16(L2CAP_CR_PEND);
  					rsp.status = cpu_to_le16(L2CAP_CS_AUTHOR_PEND);
 -					parent->sk_data_ready(parent, 0);
 +					if (parent)
 +						parent->sk_data_ready(parent, 0);
  
  				} else {
- 					sk->sk_state = BT_CONFIG;
+ 					l2cap_state_change(chan, BT_CONFIG);
  					rsp.result = cpu_to_le16(L2CAP_CR_SUCCESS);
  					rsp.status = cpu_to_le16(L2CAP_CS_NO_INFO);
  				}
@@@ -2324,10 -2523,14 +2524,13 @@@ static inline int l2cap_config_req(stru
  
  	sk = chan->sk;
  
- 	if (sk->sk_state != BT_CONFIG && sk->sk_state != BT_CONNECT2) {
- 		struct l2cap_cmd_rej rej;
 -	if ((bt_sk(sk)->defer_setup && chan->state != BT_CONNECT2) ||
 -		 (!bt_sk(sk)->defer_setup && chan->state != BT_CONFIG)) {
++	if (chan->state != BT_CONFIG && chan->state != BT_CONNECT2) {
+ 		struct l2cap_cmd_rej_cid rej;
+ 
+ 		rej.reason = cpu_to_le16(L2CAP_REJ_INVALID_CID);
+ 		rej.scid = cpu_to_le16(chan->scid);
+ 		rej.dcid = cpu_to_le16(chan->dcid);
  
- 		rej.reason = cpu_to_le16(0x0002);
  		l2cap_send_cmd(conn, cmd->ident, L2CAP_COMMAND_REJ,
  				sizeof(rej), &rej);
  		goto unlock;
@@@ -4010,10 -4150,9 +4150,10 @@@ static int l2cap_security_cfm(struct hc
  					struct sock *parent = bt_sk(sk)->parent;
  					res = L2CAP_CR_PEND;
  					stat = L2CAP_CS_AUTHOR_PEND;
 -					parent->sk_data_ready(parent, 0);
 +					if (parent)
 +						parent->sk_data_ready(parent, 0);
  				} else {
- 					sk->sk_state = BT_CONFIG;
+ 					l2cap_state_change(chan, BT_CONFIG);
  					res = L2CAP_CR_SUCCESS;
  					stat = L2CAP_CS_NO_INFO;
  				}
