From: Ludo Stellingwerff <ludo@protactive.nl>
Subject: [RFC] Using Fwmark as SPD filter.
Date: Sat, 19 Mar 2005 11:06:50 +0100
Message-ID: <423BF9BA.8090408@protactive.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040506020609010907000306"
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040506020609010907000306
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi All,

I have a kind of feature request, which I like to try and implement.
But I'm not a kernel hacker and terribly short on time, therefor I
like to discuss this feature with you guys first to see if you like the
idea.

I have a problem with the scalability of the SPD database. Because
it's a linear list, sorted by priority, it's possible to make quite
complex ipsecpolicies, but the list will grow enormously. Especially
when using seperate ports in the policy, matching various addresses,
trying to encrypt the default route:), various protocols, etc. Due to
caching this scalability might not be a problem for the kernel, but for
me as maintainer it's quite dainting.

But the netfilter stack allready has a very flexible, advanced traffic
matching structure. It would be nice if we could use the netfilter-mark
as a match in the SPD.
A similar approach exists in NetBSD where it's possible to use a
packetfilter "tag" as a ipsecmatch.

I have been looking into the neccesary changes to the kernel to use
fwmark as SPD match, attached is a unfinished, unclean, old patch
against the debian 2.6.9 source tree. As far as I know the pfkey
interface is still very buggy. Patrick McHardy already pointed out one
omission: "One thing that is missing is setting fl->fwmark for policy
checks of incoming packets in xfrm{46}_decode_session()"

I don't have a patch for the userland side yet. Hopefully I will have
time to continue work on these patches the coming month.

My question concerns the basics: Do you agree that using the fwmark as
a SPD key is a usable way to describe ipsec policies? Would you
consider applying such a patch to the kernel (or through POMng)?

In general, is this work a waste of time or am I hitting something here?

Thanks in advance,
Ludo.

- --

Ludo Stellingwerff

V&S B.V. The Netherlands
ProTactive firewall solution.
Tel: +31 172 416116
Fax: +31 172 416124

site: www.protactive.nl

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iD8DBQFCO/m6OF3sCpZ+AJgRAr8gAJ9Nhg62dtusJ/rLLqFBw+vEIOmFJgCeLxm4
F36sywqctCAJLz/58N0o64Q=
=yZQF
-----END PGP SIGNATURE-----

--------------040506020609010907000306
Content-Type: text/x-patch;
 name="NF_Mark_SPD_match.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="NF_Mark_SPD_match.patch"

diff -wur kernel-source-2.6.9/include/linux/pfkeyv2.h kernel-source-2.6.9b/include/linux/pfkeyv2.h
--- kernel-source-2.6.9/include/linux/pfkeyv2.h 2004-10-18 23:54:55.000000000 +0200
+++ kernel-source-2.6.9b/include/linux/pfkeyv2.h        2005-02-16 08:18:37.000000000 +0100
@@ -216,6 +216,14 @@
 } __attribute__((packed));
 /* sizeof(struct sadb_x_nat_t_port) == 8 */

+/* Pass a Fwmark match */
+struct sadb_x_mark {
+        uint16_t        sadb_x_mark_len;
+        uint16_t        sadb_x_mark_exttype;
+        uint32_t        sadb_x_mark_match;
+} __attribute__((packed));
+/* sizeof(struct sadb_x_mark) == 8 */
+
 /* Message types */
 #define SADB_RESERVED          0
 #define SADB_GETSPI            1
@@ -324,7 +332,9 @@
 #define SADB_X_EXT_NAT_T_SPORT         21
 #define SADB_X_EXT_NAT_T_DPORT         22
 #define SADB_X_EXT_NAT_T_OA            23
-#define SADB_EXT_MAX                   23
+/* The following entry is for matching SPD to fwmark */
+#define SADB_X_EXT_MARK                        24
+#define SADB_EXT_MAX                   24

 /* Identity Extension values */
 #define SADB_IDENTTYPE_RESERVED        0
diff -wur kernel-source-2.6.9/include/linux/xfrm.h kernel-source-2.6.9b/include/linux/xfrm.h
--- kernel-source-2.6.9/include/linux/xfrm.h    2004-10-18 23:53:43.000000000 +0200
+++ kernel-source-2.6.9b/include/linux/xfrm.h   2005-01-20 21:08:27.000000000 +0100
@@ -43,6 +43,7 @@
        __u8    proto;
        int     ifindex;
        uid_t   user;
+       __u32   fwmark;
 };

 #define XFRM_INF (~(__u64)0)
diff -wur kernel-source-2.6.9/include/net/xfrm.h kernel-source-2.6.9b/include/net/xfrm.h
--- kernel-source-2.6.9/include/net/xfrm.h      2004-11-17 11:47:11.000000000 +0100
+++ kernel-source-2.6.9b/include/net/xfrm.h     2005-01-20 21:15:19.000000000 +0100
@@ -469,7 +469,8 @@
                !((xfrm_flowi_dport(fl) ^ sel->dport) & sel->dport_mask) &&
                !((xfrm_flowi_sport(fl) ^ sel->sport) & sel->sport_mask) &&
                (fl->proto == sel->proto || !sel->proto) &&
-               (fl->oif == sel->ifindex || !sel->ifindex);
+               (fl->oif == sel->ifindex || !sel->ifindex) &&
+               (fl->fl4_fwmark == sel->fwmark || !sel->fwmark);
 }

 static inline int
diff -wur kernel-source-2.6.9/net/key/af_key.c kernel-source-2.6.9b/net/key/af_key.c
--- kernel-source-2.6.9/net/key/af_key.c        2004-10-18 23:55:36.000000000 +0200
+++ kernel-source-2.6.9b/net/key/af_key.c       2005-01-20 21:25:24.000000000 +0100
@@ -336,6 +336,7 @@
        [SADB_X_EXT_NAT_T_SPORT]        = (u8) sizeof(struct sadb_x_nat_t_port),
        [SADB_X_EXT_NAT_T_DPORT]        = (u8) sizeof(struct sadb_x_nat_t_port),
        [SADB_X_EXT_NAT_T_OA]           = (u8) sizeof(struct sadb_address),
+       [SADB_X_EXT_MARK]               = (u8) sizeof(struct sadb_x_mark),
 };

 /* Verify sadb_address_{len,prefixlen} against sa_family.  */
@@ -892,6 +893,7 @@
                n_port->sadb_x_nat_t_port_reserved = 0;
        }

+
        return skb;
 }

@@ -1647,7 +1649,8 @@
                (sockaddr_size * 2) +
                sizeof(struct sadb_x_policy) +
                (xp->xfrm_nr * (sizeof(struct sadb_x_ipsecrequest) +
-                               (socklen * 2)));
+                               (socklen * 2))) +
+               sizeof(struct sadb_x_mark);
 }

 static struct sk_buff * pfkey_xfrm_policy2msg_prep(struct xfrm_policy *xp)
@@ -1671,6 +1674,7 @@
        struct sadb_lifetime *lifetime;
        struct sadb_x_policy *pol;
        struct sockaddr_in   *sin;
+       struct sadb_x_mark   *match;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
        struct sockaddr_in6  *sin6;
 #endif
@@ -1855,6 +1859,11 @@
                        }
                }
        }
+       match = (struct sadb_x_mark*) skb_put(skb, sizeof (struct sadb_x_mark));
+       match->sadb_x_mark_len = sizeof(*match)/sizeof(uint64_t);
+       match->sadb_x_mark_exttype = SADB_X_EXT_MARK;
+       match->sadb_x_mark_match = xp->selector.fwmark;
+
        hdr->sadb_msg_len = size / sizeof(uint64_t);
        hdr->sadb_msg_reserved = atomic_read(&xp->refcnt);
 }
@@ -1868,6 +1877,7 @@
        struct xfrm_policy *xp;
        struct sk_buff *out_skb;
        struct sadb_msg *out_hdr;
+       struct sadb_x_mark *mark;

        if (!present_and_same_family(ext_hdrs[SADB_EXT_ADDRESS_SRC-1],
                                     ext_hdrs[SADB_EXT_ADDRESS_DST-1]) ||
@@ -1930,6 +1940,9 @@
                xp->lft.soft_add_expires_seconds = lifetime->sadb_lifetime_addtime;
                xp->lft.soft_use_expires_seconds = lifetime->sadb_lifetime_usetime;
        }
+       if ((mark = ext_hdrs[SADB_X_EXT_MARK-1]) != NULL) {
+               xp->selector.fwmark = mark->sadb_x_mark_match;
+       }
        xp->xfrm_nr = 0;
        if (pol->sadb_x_policy_type == IPSEC_POLICY_IPSEC &&
            (err = parse_ipsecrequests(xp, pol)) < 0)


--------------040506020609010907000306--
