From: Kevin Dwyer <kevin@pheared.net>
Subject: Strange UDP binding behavior (SO_BINDTODEVICE)
Date: Sun, 5 Oct 2003 13:01:54 -0400
Sender: linux-ha-admin@lists.linux-ha.org
Message-ID: <20031005130154.5bd9d182.kevin@pheared.net>
Reply-To: linux-ha@lists.linux-ha.org
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="pgp-sha1";
 boundary="Signature=_Sun__5_Oct_2003_13_01_54_-0400_MiYcidPLlDoJFbX="
Cc: linux-ha@lists.linux-ha.org
Return-path: <linux-ha-admin@lists.linux-ha.org>
To: netdev@oss.sgi.com
Errors-To: linux-ha-admin@lists.linux-ha.org
List-Unsubscribe: <http://lists.linux-ha.org/mailman/listinfo/linux-ha>,
	<mailto:linux-ha-request@lists.linux-ha.org?subject=unsubscribe>
List-Post: <mailto:linux-ha@lists.linux-ha.org>
List-Help: <mailto:linux-ha-request@lists.linux-ha.org?subject=help>
List-Subscribe: <http://lists.linux-ha.org/mailman/listinfo/linux-ha>,
	<mailto:linux-ha-request@lists.linux-ha.org?subject=subscribe>
List-Archive: <http://lists.linux-ha.org/pipermail/linux-ha/>
List-Id: netdev.vger.kernel.org

--Signature=_Sun__5_Oct_2003_13_01_54_-0400_MiYcidPLlDoJFbX=
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

Hello,

We have come across something that may be a bug, unless this behavior
was intentional.

The problem can be simulated by creating a socket, setting
SO_BINDTODEVICE, and binding to a port.  Then, in a separate process we
attempt to bind to the same port but without the SO_BINDTODEVICE option.
The expected behavior is to get EINVAL because the port is already
bound by a prior call.  However, it succeeds, and the second process
steals the first process' packets.

The likely code in question resides in net/ipv4/udp.c:

        for (sk2 = udp_hash[snum & (UDP_HTABLE_SIZE - 1)];
             sk2 != NULL;
             sk2 = sk2->next) {
                if (sk2->num == snum &&
                    sk2 != sk &&
                    sk2->bound_dev_if == sk->bound_dev_if &&
                    (!sk2->rcv_saddr ||
                     !sk->rcv_saddr ||
                     sk2->rcv_saddr == sk->rcv_saddr) &&
                    (!sk2->reuse || !sk->reuse))
                        goto fail;
        }

The condition (sk2->bound_dev_if == sk->bound_dev_if) will fail because
sk2->bound_dev_if will be the ifindex of the interface we bound to, and
sk->bound_dev_if will be 0, since we didn't bind to a specific
interface.

Lars Ellenberg suggests something like:
|       (!sk2->bound_dev_if ||
|        !sk->bound_dev_if ||
|        sk2->bound_dev_if == sk->bound_dev_if) &&

Which on its face appears to clear the bug.  I don't see any obvious
downsides to it either, but this is why I'm here.

So, is this intentional or a bug?

Thanks.

-- 
- kpd
"If at first you don't succeed, redefine success." - Anonymous

--Signature=_Sun__5_Oct_2003_13_01_54_-0400_MiYcidPLlDoJFbX=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/gE6CN4rbBhHCVDkRAhq0AKC8qufYmGQ20xqb9wTJteA8P6QFbQCfXVav
QPuNUevzS/kGILqDOPuF8sY=
=GFnq
-----END PGP SIGNATURE-----

--Signature=_Sun__5_Oct_2003_13_01_54_-0400_MiYcidPLlDoJFbX=--
_______________________________________________
Linux-HA mailing list
Linux-HA@lists.linux-ha.org
http://lists.linux-ha.org/mailman/listinfo/linux-ha
