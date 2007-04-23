From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Bugme-new] [Bug 8342] New: sctp_getsockopt_local_addrs_old()
 calls copy_to_user() while a spinlock is held
Date: Mon, 23 Apr 2007 13:43:35 -0400
Message-ID: <462CF047.3050809@hp.com>
References: <200704162134.l3GLYMuF004745@fire-2.osdl.org> <20070420143500.cdac0fab.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010704040003030105010107"
Cc: netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, matthias.kaehlcke@gmail.com,
	lksctp-developers@lists.sourceforge.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:45773 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754087AbXDWRnl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2007 13:43:41 -0400
In-Reply-To: <20070420143500.cdac0fab.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010704040003030105010107
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Andrew Morton wrote:
> On Mon, 16 Apr 2007 14:34:22 -0700
> bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=8342
>>
>>            Summary: sctp_getsockopt_local_addrs_old() calls copy_to_user()
>>                     while a spinlock is held
>>     Kernel Version: 2.6.20
>>             Status: NEW
>>           Severity: normal
>>              Owner: acme@ghostprotocols.net
>>          Submitter: matthias.kaehlcke@gmail.com
>>
>>
>> Problem Description:
>>
>> sctp_getsockopt_local_addrs_old() in net/sctp/socket.c calls copy_to_user()
>> while the spinlock addr_lock is held. this should not be done as copy_to_user()
>> might sleep. the call to sctp_copy_laddrs_to_user() while holding the lock is
>> also problematic as it calls copy_to_user()
>>
> 
> yup.

Thanks for reporting.

The area of this particular lock is quite ugly and will need to be cleaned up.
In the mean time, here is a patch that fixes this for now.

-vlad

--------------010704040003030105010107
Content-Type: text/plain;
 name="p"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="p"

[PATCH] [SCTP] Fix sctp_getsockopt_local_addrs_old() to use local storage

sctp_getsockopt_local_addrs_old() in net/sctp/socket.c calls copy_to_user()
while the spinlock addr_lock is held. this should not be done as copy_to_user()
might sleep. the call to sctp_copy_laddrs_to_user() while holding the lock is
also problematic as it calls copy_to_user()

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |   96 +++++++++++++++++++++++++++++++++--------------------
 1 files changed, 60 insertions(+), 36 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 6bfae12..56ef543 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3849,7 +3849,7 @@ static int sctp_getsockopt_peer_addrs(struct sock *sk, int len,
 		memcpy(&temp, &from->ipaddr, sizeof(temp));
 		sctp_get_pf_specific(sk->sk_family)->addr_v4map(sp, &temp);
 		addrlen = sctp_get_af_specific(sk->sk_family)->sockaddr_len;
-		if(space_left < addrlen)
+		if (space_left < addrlen)
 			return -ENOMEM;
 		if (copy_to_user(to, &temp, addrlen))
 			return -EFAULT;
@@ -3938,8 +3938,9 @@ done:
 /* Helper function that copies local addresses to user and returns the number
  * of addresses copied.
  */
-static int sctp_copy_laddrs_to_user_old(struct sock *sk, __u16 port, int max_addrs,
-					void __user *to)
+static int sctp_copy_laddrs_old(struct sock *sk, __u16 port,
+					int max_addrs, void *to,
+					size_t *bytes_copied)
 {
 	struct list_head *pos, *next;
 	struct sctp_sockaddr_entry *addr;
@@ -3956,10 +3957,10 @@ static int sctp_copy_laddrs_to_user_old(struct sock *sk, __u16 port, int max_add
 		sctp_get_pf_specific(sk->sk_family)->addr_v4map(sctp_sk(sk),
 								&temp);
 		addrlen = sctp_get_af_specific(temp.sa.sa_family)->sockaddr_len;
-		if (copy_to_user(to, &temp, addrlen))
-			return -EFAULT;
+		memcpy(to, &temp, addrlen);
 
 		to += addrlen;
+		*bytes_copied += addrlen;
 		cnt ++;
 		if (cnt >= max_addrs) break;
 	}
@@ -3967,8 +3968,8 @@ static int sctp_copy_laddrs_to_user_old(struct sock *sk, __u16 port, int max_add
 	return cnt;
 }
 
-static int sctp_copy_laddrs_to_user(struct sock *sk, __u16 port,
-				    void __user **to, size_t space_left)
+static int sctp_copy_laddrs(struct sock *sk, __u16 port, void *to,
+			    size_t space_left, size_t *bytes_copied)
 {
 	struct list_head *pos, *next;
 	struct sctp_sockaddr_entry *addr;
@@ -3985,14 +3986,14 @@ static int sctp_copy_laddrs_to_user(struct sock *sk, __u16 port,
 		sctp_get_pf_specific(sk->sk_family)->addr_v4map(sctp_sk(sk),
 								&temp);
 		addrlen = sctp_get_af_specific(temp.sa.sa_family)->sockaddr_len;
-		if(space_left<addrlen)
+		if (space_left < addrlen)
 			return -ENOMEM;
-		if (copy_to_user(*to, &temp, addrlen))
-			return -EFAULT;
+		memcpy(to, &temp, addrlen);
 
-		*to += addrlen;
+		to += addrlen;
 		cnt ++;
 		space_left -= addrlen;
+		bytes_copied += addrlen;
 	}
 
 	return cnt;
@@ -4016,6 +4017,8 @@ static int sctp_getsockopt_local_addrs_old(struct sock *sk, int len,
 	int addrlen;
 	rwlock_t *addr_lock;
 	int err = 0;
+	void *addrs;
+	size_t bytes_copied = 0;
 
 	if (len != sizeof(struct sctp_getaddrs_old))
 		return -EINVAL;
@@ -4043,6 +4046,15 @@ static int sctp_getsockopt_local_addrs_old(struct sock *sk, int len,
 
 	to = getaddrs.addrs;
 
+	/* Allocate space for a local instance of packed array to hold all
+	 * the data.  We store addresses here first and then put write them
+	 * to the user in one shot.
+	 */
+	addrs = kmalloc(sizeof(union sctp_addr) * getaddrs.addr_num,
+			GFP_KERNEL);
+	if (!addrs)
+		return -ENOMEM;
+
 	sctp_read_lock(addr_lock);
 
 	/* If the endpoint is bound to 0.0.0.0 or ::0, get the valid
@@ -4052,13 +4064,9 @@ static int sctp_getsockopt_local_addrs_old(struct sock *sk, int len,
 		addr = list_entry(bp->address_list.next,
 				  struct sctp_sockaddr_entry, list);
 		if (sctp_is_any(&addr->a)) {
-			cnt = sctp_copy_laddrs_to_user_old(sk, bp->port,
-							   getaddrs.addr_num,
-							   to);
-			if (cnt < 0) {
-				err = cnt;
-				goto unlock;
-			}
+			cnt = sctp_copy_laddrs_old(sk, bp->port,
+						   getaddrs.addr_num,
+						   addrs, &bytes_copied);
 			goto copy_getaddrs;
 		}
 	}
@@ -4068,22 +4076,29 @@ static int sctp_getsockopt_local_addrs_old(struct sock *sk, int len,
 		memcpy(&temp, &addr->a, sizeof(temp));
 		sctp_get_pf_specific(sk->sk_family)->addr_v4map(sp, &temp);
 		addrlen = sctp_get_af_specific(temp.sa.sa_family)->sockaddr_len;
-		if (copy_to_user(to, &temp, addrlen)) {
-			err = -EFAULT;
-			goto unlock;
-		}
+		memcpy(addrs, &temp, addrlen);
 		to += addrlen;
+		bytes_copied += addrlen;
 		cnt ++;
 		if (cnt >= getaddrs.addr_num) break;
 	}
 
 copy_getaddrs:
+	sctp_read_unlock(addr_lock);
+
+	/* copy the entire address list into the user provided space */
+	if (copy_to_user(to, addrs, bytes_copied)) {
+		err = -EFAULT;
+		goto error;
+	}
+
+	/* copy the leading structure back to user */
 	getaddrs.addr_num = cnt;
 	if (copy_to_user(optval, &getaddrs, sizeof(struct sctp_getaddrs_old)))
 		err = -EFAULT;
 
-unlock:
-	sctp_read_unlock(addr_lock);
+error:
+	kfree(addrs);
 	return err;
 }
 
@@ -4103,7 +4118,8 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
 	rwlock_t *addr_lock;
 	int err = 0;
 	size_t space_left;
-	int bytes_copied;
+	int bytes_copied = 0;
+	void *addrs;
 
 	if (len <= sizeof(struct sctp_getaddrs))
 		return -EINVAL;
@@ -4131,6 +4147,9 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
 	to = optval + offsetof(struct sctp_getaddrs,addrs);
 	space_left = len - sizeof(struct sctp_getaddrs) -
 			 offsetof(struct sctp_getaddrs,addrs);
+	addrs = kmalloc(space_left, GFP_KERNEL);
+	if (!addrs)
+		return -ENOMEM;
 
 	sctp_read_lock(addr_lock);
 
@@ -4141,11 +4160,11 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
 		addr = list_entry(bp->address_list.next,
 				  struct sctp_sockaddr_entry, list);
 		if (sctp_is_any(&addr->a)) {
-			cnt = sctp_copy_laddrs_to_user(sk, bp->port,
-						       &to, space_left);
+			cnt = sctp_copy_laddrs(sk, bp->port, addrs,
+						space_left, &bytes_copied);
 			if (cnt < 0) {
 				err = cnt;
-				goto unlock;
+				goto error;
 			}
 			goto copy_getaddrs;
 		}
@@ -4156,26 +4175,31 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
 		memcpy(&temp, &addr->a, sizeof(temp));
 		sctp_get_pf_specific(sk->sk_family)->addr_v4map(sp, &temp);
 		addrlen = sctp_get_af_specific(temp.sa.sa_family)->sockaddr_len;
-		if(space_left < addrlen)
-			return -ENOMEM; /*fixme: right error?*/
-		if (copy_to_user(to, &temp, addrlen)) {
-			err = -EFAULT;
-			goto unlock;
+		if (space_left < addrlen) {
+			err =  -ENOMEM; /*fixme: right error?*/
+			goto error;
 		}
+		memcpy(addrs, &temp, addrlen);
 		to += addrlen;
+		bytes_copied += addrlen;
 		cnt ++;
 		space_left -= addrlen;
 	}
 
 copy_getaddrs:
+	sctp_read_unlock(addr_lock);
+
+	if (copy_to_user(to, addrs, bytes_copied)) {
+		err = -EFAULT;
+		goto error;
+	}
 	if (put_user(cnt, &((struct sctp_getaddrs __user *)optval)->addr_num))
 		return -EFAULT;
-	bytes_copied = ((char __user *)to) - optval;
 	if (put_user(bytes_copied, optlen))
 		return -EFAULT;
 
-unlock:
-	sctp_read_unlock(addr_lock);
+error:
+	kfree(addrs);
 	return err;
 }
 
-- 
1.5.0.3.438.gc49b2


--------------010704040003030105010107--
