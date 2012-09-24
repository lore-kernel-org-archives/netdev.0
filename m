From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the userns tree with the  tree
Date: Mon, 24 Sep 2012 21:31:10 +1000
Message-ID: <20120924213110.e502f9ead9b0be3de062bbbf@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__24_Sep_2012_21_31_10_+1000_wU+DS7hN_XqlTeKt"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__24_Sep_2012_21_31_10_+1000_wU+DS7hN_XqlTeKt
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Eric,

Today's linux-next merge of the userns tree got a conflict in
kernel/audit.c between commit 15e473046cb6 ("netlink: Rename pid to
portid to avoid confusion") from the net-next tree and commits
8aa14b64981e ("audit: Simply AUDIT_TTY_SET and AUDIT_TTY_GET") and
017143fecb33 ("audit: Remove the unused uid parameter from
audit_receive_filter") from the userns tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc kernel/audit.c
index e0cf64a,511488a..0000000
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@@ -782,8 -769,8 +769,8 @@@ static int audit_receive_msg(struct sk_
  		}
  		/* fallthrough */
  	case AUDIT_LIST:
 -		err =3D audit_receive_filter(msg_type, NETLINK_CB(skb).pid,
 +		err =3D audit_receive_filter(msg_type, NETLINK_CB(skb).portid,
- 					   uid, seq, data, nlmsg_len(nlh),
+ 					   seq, data, nlmsg_len(nlh),
  					   loginuid, sessionid, sid);
  		break;
  	case AUDIT_ADD_RULE:
@@@ -801,8 -788,8 +788,8 @@@
  		}
  		/* fallthrough */
  	case AUDIT_LIST_RULES:
 -		err =3D audit_receive_filter(msg_type, NETLINK_CB(skb).pid,
 +		err =3D audit_receive_filter(msg_type, NETLINK_CB(skb).portid,
- 					   uid, seq, data, nlmsg_len(nlh),
+ 					   seq, data, nlmsg_len(nlh),
  					   loginuid, sessionid, sid);
  		break;
  	case AUDIT_TRIM:
@@@ -878,21 -865,14 +865,14 @@@
  		break;
  	case AUDIT_TTY_GET: {
  		struct audit_tty_status s;
- 		struct task_struct *tsk;
- 		unsigned long flags;
-=20
- 		rcu_read_lock();
- 		tsk =3D find_task_by_vpid(pid);
- 		if (tsk && lock_task_sighand(tsk, &flags)) {
- 			s.enabled =3D tsk->signal->audit_tty !=3D 0;
- 			unlock_task_sighand(tsk, &flags);
- 		} else
- 			err =3D -ESRCH;
- 		rcu_read_unlock();
-=20
- 		if (!err)
- 			audit_send_reply(NETLINK_CB(skb).portid, seq,
- 					 AUDIT_TTY_GET, 0, 0, &s, sizeof(s));
+ 		struct task_struct *tsk =3D current;
+=20
+ 		spin_lock_irq(&tsk->sighand->siglock);
+ 		s.enabled =3D tsk->signal->audit_tty !=3D 0;
+ 		spin_unlock_irq(&tsk->sighand->siglock);
+=20
 -		audit_send_reply(NETLINK_CB(skb).pid, seq,
++		audit_send_reply(NETLINK_CB(skb).portid, seq,
+ 				 AUDIT_TTY_GET, 0, 0, &s, sizeof(s));
  		break;
  	}
  	case AUDIT_TTY_SET: {

--Signature=_Mon__24_Sep_2012_21_31_10_+1000_wU+DS7hN_XqlTeKt
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQYER+AAoJEECxmPOUX5FE5NoP/1cmlyD+MAa8Z5kW92UFheKL
uBHaV4D3N4bY0BOQrSrYyvqbQqxi8o6dfzlV+BvRSMmEoN+bbcoo+3WmBujb/snB
ZZnBATV33UL/Sl03AqwaO9XD01WArL/IGMxawuEeLK+bzm5cxwLfJgIk3da7G+o3
EfoR8KjychMvD/L/+RPxdHqgMD0C/CGSHqhkmKfl99xPDqWv/rXUnB06YnaNiyQd
HeOmgChSZQfJp81PkhxwTRqx8GM3qURm4s3/aM9K5wjOlAf9OOxUu004mj9dVeN8
R4J2kvxsQdlXLrWbYVSnryBbHZ5LBo1F0JbPHe3OK7DWm3E46akn5cduUMlXcjLk
sDQPTjVccenlnSR8yVPeCzMD1YEsCDHwgvRGUppa5rN0dieQyrDnjaqALkkfCZBB
6s9yn1dqqgNXZiWdYyEfoQanEGdEZ9pyttMNl8Toi6SK5tKxsEDe35mDjEHeRm/P
fUL6UwuxCdoJveuY7OuN+YAleU4gZNXs8Tba6oeOSA+PYMOiZTRkFwklAMFqxOVZ
Nbm2fx0fWYhtEYF1uaYOQCzyZNaLm7D6dn1mkFCPN2vwbb1ZtVuBAv4xZB6qJ1dz
y4hoK+l62XZ1qK7pnrZ4+VCclQPlJnrrIFfya09IZ+ASsZZLgM8VlDsXszwLEydz
KSVK+EPK0dx/rq0zQYj2
=eMXQ
-----END PGP SIGNATURE-----

--Signature=_Mon__24_Sep_2012_21_31_10_+1000_wU+DS7hN_XqlTeKt--
