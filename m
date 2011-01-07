From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the security-testing tree with the net
 tree
Date: Fri, 7 Jan 2011 11:44:00 +1100
Message-ID: <20110107114400.e4d1d33b.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Casey Schaufler <casey@schaufler-ca.com>
To: James Morris <jmorris@namei.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi James,

Today's linux-next merge of the security-testing tree got a conflict in
security/smack/smack_lsm.c between commit
3610cda53f247e176bcbb7a7cca64bc53b12acdb ("af_unix: Avoid socket->sk NULL
OOPS in stream connect security hooks") from the net tree and commit
b4e0d5f0791bd6dd12a1c1edea0340969c7c1f90 ("Smack: UDS revision") from the
security-testing tree.

I fixed it up (I think - see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc security/smack/smack_lsm.c
index ccb71a0,05dc4da..0000000
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@@ -2415,17 -2534,21 +2534,21 @@@ static int smack_setprocattr(struct tas
   * Return 0 if a subject with the smack of sock could access
   * an object with the smack of other, otherwise an error code
   */
 -static int smack_unix_stream_connect(struct socket *sock,
 -				     struct socket *other, struct sock *newsk)
 +static int smack_unix_stream_connect(struct sock *sock,
 +				     struct sock *other, struct sock *newsk)
  {
- 	struct inode *sp = SOCK_INODE(sock->sk_socket);
- 	struct inode *op = SOCK_INODE(other->sk_socket);
 -	struct socket_smack *ssp = sock->sk->sk_security;
 -	struct socket_smack *osp = other->sk->sk_security;
++	struct socket_smack *ssp = sock->sk_security;
++	struct socket_smack *osp = other->sk_security;
  	struct smk_audit_info ad;
+ 	int rc = 0;
  
  	smk_ad_init(&ad, __func__, LSM_AUDIT_DATA_NET);
 -	smk_ad_setfield_u_net_sk(&ad, other->sk);
 +	smk_ad_setfield_u_net_sk(&ad, other);
- 	return smk_access(smk_of_inode(sp), smk_of_inode(op),
- 				 MAY_READWRITE, &ad);
+ 
+ 	if (!capable(CAP_MAC_OVERRIDE))
+ 		rc = smk_access(ssp->smk_out, osp->smk_in, MAY_WRITE, &ad);
+ 
+ 	return rc;
  }
  
  /**
