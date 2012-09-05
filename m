From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the vfs tree
Date: Wed, 5 Sep 2012 12:02:04 +1000
Message-ID: <20120905120204.a8990185fb80f6b1b65bc6ea@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__5_Sep_2012_12_02_04_+1000_jyxg41JzRfqx0O_j"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Masatake YAMATO <yamato@redhat.com>,
	Al Viro <viro@zeniv.linux.org.uk>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__5_Sep_2012_12_02_04_+1000_jyxg41JzRfqx0O_j
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/socket.c between commits f8a78429cc70 ("take descriptor handling from
sock_alloc_file() to callers") and 32b529f92ea7 ("unexport sock_map_fd(),
switch to sock_alloc_file()") from the vfs tree and commit 600e177920df
("net: Providing protocol type via system.sockprotoname xattr
of /proc/PID/fd entries") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary.  I also had
to add this merge fix patch:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 5 Sep 2012 11:52:06 +1000
Subject: [PATCH] net: cope with sock_alloc_file() API change

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 include/linux/net.h |    3 ++-
 net/9p/trans_fd.c   |    2 +-
 net/sctp/socket.c   |    2 +-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index c8a9708..a3831f3 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -247,7 +247,8 @@ extern int   	     sock_sendmsg(struct socket *sock, st=
ruct msghdr *msg,
 				  size_t len);
 extern int	     sock_recvmsg(struct socket *sock, struct msghdr *msg,
 				  size_t size, int flags);
-extern struct file  *sock_alloc_file(struct socket *sock, int flags);
+extern struct file  *sock_alloc_file(struct socket *sock, int flags,
+				     const char *dname);
 extern struct socket *sockfd_lookup(int fd, int *err);
 extern struct socket *sock_from_file(struct file *file, int *err);
 #define		     sockfd_put(sock) fput(sock->file)
diff --git a/net/9p/trans_fd.c b/net/9p/trans_fd.c
index 8c4e0b5..1c8b557 100644
--- a/net/9p/trans_fd.c
+++ b/net/9p/trans_fd.c
@@ -801,7 +801,7 @@ static int p9_socket_open(struct p9_client *client, str=
uct socket *csocket)
 		return -ENOMEM;
=20
 	csocket->sk->sk_allocation =3D GFP_NOIO;
-	file =3D sock_alloc_file(csocket, 0);
+	file =3D sock_alloc_file(csocket, 0, NULL);
 	if (IS_ERR(file)) {
 		pr_err("%s (%d): failed to map fd\n",
 		       __func__, task_pid_nr(current));
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 5ba739e..59d16ea 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4313,7 +4313,7 @@ static int sctp_getsockopt_peeloff(struct sock *sk, i=
nt len, char __user *optval
 		goto out;
 	}
=20
-	newfile =3D sock_alloc_file(newsock, 0);
+	newfile =3D sock_alloc_file(newsock, 0, NULL);
 	if (unlikely(IS_ERR(newfile))) {
 		put_unused_fd(retval);
 		sock_release(newsock);
--=20
1.7.10.280.gaa39

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/socket.c
index 79170dc,977c0f4..0000000
--- a/net/socket.c
+++ b/net/socket.c
@@@ -346,15 -347,30 +347,23 @@@ static struct file_system_type sock_fs_
   *	but we take care of internal coherence yet.
   */
 =20
- struct file *sock_alloc_file(struct socket *sock, int flags)
 -static int sock_alloc_file(struct socket *sock, struct file **f, int flag=
s,
 -			   const char *dname)
++struct file *sock_alloc_file(struct socket *sock, int flags,
++			     const char *dname)
  {
  	struct qstr name =3D { .name =3D "" };
  	struct path path;
  	struct file *file;
 -	int fd;
 -
 -	fd =3D get_unused_fd_flags(flags);
 -	if (unlikely(fd < 0))
 -		return fd;
 =20
+ 	if (dname) {
+ 		name.name =3D dname;
+ 		name.len =3D strlen(name.name);
+ 	} else if (sock->sk) {
+ 		name.name =3D sock->sk->sk_prot_creator->name;
+ 		name.len =3D strlen(name.name);
+ 	}
  	path.dentry =3D d_alloc_pseudo(sock_mnt->mnt_sb, &name);
 -	if (unlikely(!path.dentry)) {
 -		put_unused_fd(fd);
 -		return -ENOMEM;
 -	}
 +	if (unlikely(!path.dentry))
 +		return ERR_PTR(-ENOMEM);
  	path.mnt =3D mntget(sock_mnt);
 =20
  	d_instantiate(path.dentry, SOCK_INODE(sock));
@@@ -373,26 -390,22 +382,26 @@@
  	file->f_flags =3D O_RDWR | (flags & O_NONBLOCK);
  	file->f_pos =3D 0;
  	file->private_data =3D sock;
 -
 -	*f =3D file;
 -	return fd;
 +	return file;
  }
 +EXPORT_SYMBOL(sock_alloc_file);
 =20
 -int sock_map_fd(struct socket *sock, int flags)
 +static int sock_map_fd(struct socket *sock, int flags)
  {
  	struct file *newfile;
 -	int fd =3D sock_alloc_file(sock, &newfile, flags, NULL);
 +	int fd =3D get_unused_fd_flags(flags);
 +	if (unlikely(fd < 0))
 +		return fd;
 =20
- 	newfile =3D sock_alloc_file(sock, flags);
 -	if (likely(fd >=3D 0))
++	newfile =3D sock_alloc_file(sock, flags, NULL);
 +	if (likely(!IS_ERR(newfile))) {
  		fd_install(fd, newfile);
 +		return fd;
 +	}
 =20
 -	return fd;
 +	put_unused_fd(fd);
 +	return PTR_ERR(newfile);
  }
 -EXPORT_SYMBOL(sock_map_fd);
 =20
  struct socket *sock_from_file(struct file *file, int *err)
  {
@@@ -1395,27 -1471,12 +1467,27 @@@ SYSCALL_DEFINE4(socketpair, int, family
  		err =3D fd1;
  		goto out_release_both;
  	}
 -
 -	fd2 =3D sock_alloc_file(sock2, &newfile2, flags, NULL);
 +	fd2 =3D get_unused_fd_flags(flags);
  	if (unlikely(fd2 < 0)) {
  		err =3D fd2;
 +		put_unused_fd(fd1);
 +		goto out_release_both;
 +	}
 +
- 	newfile1 =3D sock_alloc_file(sock1, flags);
++	newfile1 =3D sock_alloc_file(sock1, flags, NULL);
 +	if (unlikely(IS_ERR(newfile1))) {
 +		err =3D PTR_ERR(newfile1);
 +		put_unused_fd(fd1);
 +		put_unused_fd(fd2);
 +		goto out_release_both;
 +	}
 +
- 	newfile2 =3D sock_alloc_file(sock2, flags);
++	newfile2 =3D sock_alloc_file(sock2, flags, NULL);
 +	if (IS_ERR(newfile2)) {
 +		err =3D PTR_ERR(newfile2);
  		fput(newfile1);
  		put_unused_fd(fd1);
 +		put_unused_fd(fd2);
  		sock_release(sock2);
  		goto out;
  	}
@@@ -1553,13 -1615,6 +1625,14 @@@ SYSCALL_DEFINE4(accept4, int, fd, struc
  		sock_release(newsock);
  		goto out_put;
  	}
- 	newfile =3D sock_alloc_file(newsock, flags);
++	newfile =3D sock_alloc_file(newsock, flags,
++				  sock->sk->sk_prot_creator->name);
 +	if (unlikely(IS_ERR(newfile))) {
 +		err =3D PTR_ERR(newfile);
 +		put_unused_fd(newfd);
 +		sock_release(newsock);
 +		goto out_put;
 +	}
 =20
  	err =3D security_socket_accept(sock, newsock);
  	if (err)

--Signature=_Wed__5_Sep_2012_12_02_04_+1000_jyxg41JzRfqx0O_j
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQRrKcAAoJEECxmPOUX5FEQzUQAI0MlbKoAB/Mp0EXy7gcjsMt
vpa3Gh4jatbecDDAWeOFYp6wRvu+5GDmr8t89+q7A6b68fZffvmCFH+KKSjtNJNh
mnWo10SuJVZyG74d99SX5eFOSSNl0eg3PlxxB8CvoMJ4p8/5C7aVyIGRuNJuRUon
h7glVODwsI5OcahvXEIYHpW7gI2EdOUaHG0Qg8/6zFTrLUnOVtbcZuwv0SNrKVyB
omOEqfpfDHsTXz8tXdsoIiG59WIIwW3layyf3kj8Za5vpZrJ4xQkw4c+k39neRLJ
Xa3t5pIYQcO/F+WV7rFCHprXPo4oqF+ycTFxh75+6YJZqi1fhMyG8RYd4GcT0Ows
VYRB7SmtQKlua3hT0ytIIphP/N27Gm4m8hpwZ1v/FWYT4v+IAJyAh1kGL54Fc8qz
3rvlJJUtzIzkBuOuBXYS2Nc+mlSWMaHm9x8RopDloKec/aCWB7gwN0FnFDGTtaRK
EwvsxMLCf154YJMZ75wlbvYp86MvViekA8uhTyNcMY+CR/tEta0K2GAIlnYkoQPe
tELJNFJsqsBihiw8Mp9mK8SsFRFVTyaK7+EDeNNXue+fQt4vR8YDoLwBD+I3rLAd
vBXB6Sa40P8QEnihwnO7KemPEphpqXSFu2SM/kV0ItH8dTWbjhKaN3AqEU5suvTm
EKl9+CaNcTrdz8eIKmPZ
=b+Bx
-----END PGP SIGNATURE-----

--Signature=_Wed__5_Sep_2012_12_02_04_+1000_jyxg41JzRfqx0O_j--
