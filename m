From: David Lamparter <david.lamparter-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
Subject: [quagga-users 1301] Re: ospf6 on 2.6.x linux kernel -
	IN6_IS_ADDR_LINKLOCAL - fe80::/128
Date: Fri, 16 Jan 2004 16:59:44 +0100
Sender: quagga-users-bounces-UOy77sIEA+cAd7ICUelF/Q@public.gmane.org
Message-ID: <40080A70.5020500@t-online.de>
References: <20031225132805.GA26914@cytrynka.infoland.int.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010709020303090907080306"
Return-path: <quagga-users-bounces-UOy77sIEA+cAd7ICUelF/Q@public.gmane.org>
To: Lukasz Biegaj <pio-5f0Gu3/Ff3Io5WaTebH86Dgy8vVj6WhI@public.gmane.org>,
   glibc bugs <bug-glibc-mXXj517/zsQ@public.gmane.org>,
   quagga-users <quagga-users-UOy77sIEA+cAd7ICUelF/Q@public.gmane.org>,
   quagga-dev <quagga-dev-UOy77sIEA+cAd7ICUelF/Q@public.gmane.org>, netdev <netdev-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org>
In-Reply-To: <20031225132805.GA26914-5f0Gu3/Ff3Io5WaTebH86Dgy8vVj6WhI@public.gmane.org>
List-Unsubscribe: <http://lists.quagga.net/mailman/listinfo/quagga-users>,
	<mailto:quagga-users-request-UOy77sIEA+cAd7ICUelF/W9u/PF5AtMm38Ik5SeuEX72+df2TVCvIA@public.gmane.org>
List-Archive: <http://lists.quagga.net/pipermail/quagga-users>
List-Post: <mailto:quagga-users-UOy77sIEA+cAd7ICUelF/Q@public.gmane.org>
List-Help: <mailto:quagga-users-request-UOy77sIEA+cAd7ICUelF/W9u/PF5AtMm4xOcYYyLxz0@public.gmane.org>
List-Subscribe: <http://lists.quagga.net/mailman/listinfo/quagga-users>,
	<mailto:quagga-users-request-UOy77sIEA+cAd7ICUelF/W9u/PF5AtMmEuNEP1Y2mCuZIoH1IeqzKA@public.gmane.org>
Errors-To: quagga-users-bounces-UOy77sIEA+cAd7ICUelF/Q@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010709020303090907080306
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi,

Lukasz Biegaj wrote:
| Is there a way to make OSPF6 work on 2.6.x linux kernels?
|
| Currently I see this in logs:
| 2003/12/24 11:23:13 OSPF6: LSA: originate [AS-External ID=0.0.0.9
Adv=80.55.247.118] seq: 0x80000001 age: 0
| 1072261393.983434
| 2003/12/24 11:23:13 OSPF6: ASBR: start redistributing 2000::/3 as
LS-ID 10: 1072261393.983804
| 2003/12/24 11:23:13 OSPF6: ASBR: schedule redistribution 2000::/3 as
LS-ID 10 after 0 sec
| 2003/12/24 11:23:13 OSPF6: LSA: originate [AS-External ID=0.0.0.10
Adv=80.55.247.118] seq: 0x80000001 age: 0
| 1072261393.983985
| 2003/12/24 11:23:14 OSPF6: Network: Join AllDRouters on ifindex 4
| 2003/12/24 11:23:14 OSPF6: Network: sendmsg (ifindex: 4) failed:
Invalid argument(22)
[...]
| Linux 2.6.0, Debian SID, quagga from apt.
|

we ran into the same problem and found this:

* Linux 2.6 seems to list all multicast / anycast adresses together with
unicast addresses:

[equinox-Fynnp5iTXxOlVyrhU4qvOw@public.gmane.org]:~ # ip a l dc2
9: dc2-eEeg5gueQ+g@public.gmane.org: <POINTOPOINT,MULTICAST,NOARP,UP> mtu 1460 qdisc noqueue
~    link/gre 0.0.0.0 peer 217.82.189.49
~    inet 172.22.24.1 peer 172.22.2.2/32 scope global dc2
~    inet6 fe80::ac17:2402/64 scope link
~       valid_lft forever preferred_lft forever
~    inet6 ff02::5/128 scope global
~       valid_lft forever preferred_lft forever
~    inet6 ff02::1/128 scope global
~       valid_lft forever preferred_lft forever
~    inet6 fe80::/128 scope global
~       valid_lft forever preferred_lft forever
(note the 2nd last line)

* ospf6d uses the address list for selecting a linklocal address with
IN6_IS_ADDR_LINKLOCAL
(quagga/ospf6d/ospf_interface.c:192)

~      /* linklocal scope check */
~      if (IN6_IS_ADDR_LINKLOCAL (&c->address->u.prefix6))
~        l = &c->address->u.prefix6;

* IN6_IS_ADDR_LINKLOCAL is defined in /usr/include/netinet/in.h:307 as
follows:

#define IN6_IS_ADDR_LINKLOCAL(a) \
~        ((((__const uint32_t *) (a))[0] & htonl (0xffc00000)) \
~         == htonl (0xfe800000))

* in conjunction with 2.6 reporting all multicast/anycast addresses,
this gets fe80:: (all-routers as far as i remember) into the OSPF6
interface, but the kernel will reject this (of course...):

~  OSPF6: Network: sendmsg (ifindex: 9) failed: Invalid argument(22)


I don't know whose fault it is (how is IN6_IS_ADDR_LINKLOCAL defined to
work? Is it OK for the kernel to include anycast/multicast addresses?)
but this breaks ospf6d. Our fix was to change netinet/in.h because
IN6_IS_ADDR_LINKLOCAL returning !0 only for unicast addresses seemed to
be "the right thing". Patch attached. (categorize that patch as "dirty
works-for-me hack")

David Lamparter


P.S.: glibc people please Cc me, i'm only subscribed to netdev and quagga-*

System environment:
Linux Kernel 2.6.1, x86, non-SMP, preemptible, vanilla
GNU C Library stable release version 2.3.2, by Roland McGrath et al.
quagga 0.96.4 CVS (Fre Jan 16 16:43:35 CET 2004)
gcc version 3.2.3 20030422 (Gentoo Linux 1.4 3.2.3-r3, propolice)

- --
A0C21986 David Lamparter (equinox) <david.lamparter-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
2D7F 5CC6 93AD 38DD 6CD5  47A0 A5F0 4657 A0C2 1986
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFACAplpfBGV6DCGYYRAlQ9AJ44NbGi+WCVsMiCqq7Sklg7cKq1GQCePAjn
QK+iNxE0JP+rdar7H3Ceapw=
=QdyO
-----END PGP SIGNATURE-----

--------------010709020303090907080306
Content-Type: text/plain;
 name="glibc-ipv6-is_linklocal.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="glibc-ipv6-is_linklocal.patch"

--- usr/include/netinet/in.h.prelinklocalfix	2004-01-16 15:58:53.000000000 +0100
+++ usr/include/netinet/in.h	2004-01-16 16:54:31.501509680 +0100
@@ -306,7 +306,9 @@
 
 #define IN6_IS_ADDR_LINKLOCAL(a) \
 	((((__const uint32_t *) (a))[0] & htonl (0xffc00000))		      \
-	 == htonl (0xfe800000))
+	 == htonl (0xfe800000)						      \
+	&& ((((__const uint32_t *) (a))[2]) != 0			      \
+	|| (((__const uint32_t *) (a))[3]) != 0))
 
 #define IN6_IS_ADDR_SITELOCAL(a) \
 	((((__const uint32_t *) (a))[0] & htonl (0xffc00000))		      \

--------------010709020303090907080306
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Quagga-users mailing list
Quagga-users-UOy77sIEA+cAd7ICUelF/Q@public.gmane.org
http://lists.quagga.net/mailman/listinfo/quagga-users

--------------010709020303090907080306--
