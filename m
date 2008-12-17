From: Kris Katterjohn <katterjohn@gmail.com>
Subject: [PATCH] IPv4 raw_hdrincl_nomangle sysctl
Date: Wed, 17 Dec 2008 14:44:58 -0600
Message-ID: <494964CA.5050109@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030503080506020409010706"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost04.isp.att.net ([204.127.217.104]:48884 "EHLO
	fmailhost04.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbYLQUpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 15:45:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030503080506020409010706
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hey everyone,

Sometimes it's just plain useful to be able to build full bogus IP packets and
be able to send them, such as to see how different pieces of software react to
them.  This is an interest of mine.

I've attached a patch to add a net.ipv4.raw_hdrincl_nomangle sysctl (defaults
to 0) to control whether or not Linux changes the header passed using
IP_HDRINCL (checksum, IPID, etc).  This way it's not required to build a
special kernel simply to have control over what you send.  This was needed,
for example, in this discussion[1] on Nmap's packet handling.

I'm obviously not a regular kernel developer, so any hints on making this
patch better would be much appreciated.  It works great for me, though, and
it's quite simple.

Thanks,
Kris Katterjohn

[1] http://seclists.org/nmap-dev/2008/q4/index.html#543


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iQIcBAEBAgAGBQJJSWTFAAoJEP9K37xXYl36F/kP/jfoLpeA7T4c2mSKcdIRMDDf
FLhuxCeqK3TnKPopRL5PBe0r1JJOGrYjQkdtOoajbWIa6nFNZ1l4GA3S7qrs+kXU
VnTV6qA2VIiDH/SgfWj6lOcHLhCAePnQYukl1fcYnhSgiwNDXSjav+LudlyN2oRa
/yJMgceVsvS3vP31Y9U2Go6RlxcCAxqwLnkepbzCpStzM93cIXiTwSOwhTqP0k9c
seZ5vhYGdVL/uoCkztGoEkdxpt1FBnS8UQsF8ljbo0GvTsz3ojWRpYq0Z15/ZT+c
y/bdR1HwCCHNss6Wxda4RDrRbDRgGzz+MfqWtEDCA/nKD74aMYAQtz/3iG5hMn2z
m46qNQ1OyYQqebU8zHMHTNBilkRNTIUvvzu9LdgY2axxzb/2GoJYrMXPAiqrc9Jf
CeVBk7yrIAaA5HqaXUzmwzZTWqWSUwkrUtjnJ9jiCY7iQY+kLyh6IdvwrIZF6oZ2
yBlrSyuGgtnQnCyUS3zvHA2VJhvinGIL8RWFxZhS+DD7ODKzZfsllm/7bkORvjGl
0YmciQGWTnr4pJaYCK87n16lqvw98t5UTMtPmtQxHbyWkAOTPSQYvbIH+5wS9qvJ
Llppo6TFJSS9E4YX+IkAcS3452zSb8ySxM2u1UHt40GvPbodFmx7btKxtClsGX1u
5SZnaWxHcgdSk20sxd2N
=sbTx
-----END PGP SIGNATURE-----

--------------030503080506020409010706
Content-Type: text/x-diff;
 name="rawsysctl.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rawsysctl.patch"

--- linux/net/ipv4/sysctl_net_ipv4.c	2008-12-13 17:56:16.000000000 -0600
+++ linux/net/ipv4/sysctl_net_ipv4.c	2008-12-17 13:57:26.000000000 -0600
@@ -28,6 +28,7 @@ static int ip_local_port_range_max[] = {
 
 extern seqlock_t sysctl_port_range_lock;
 extern int sysctl_local_port_range[2];
+extern int sysctl_raw_hdrincl_nomangle;
 
 /* Update system visible IP port range */
 static void set_local_port_range(int range[2])
@@ -745,6 +746,14 @@ static struct ctl_table ipv4_table[] = {
 		.strategy	= &sysctl_intvec,
 		.extra1		= &zero
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "raw_hdrincl_nomangle",
+		.data		= &sysctl_raw_hdrincl_nomangle,
+		.maxlen		= sizeof(sysctl_raw_hdrincl_nomangle),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
 	{ .ctl_name = 0 }
 };
 
--- linux/net/ipv4/raw.c	2008-12-13 17:56:16.000000000 -0600
+++ linux/net/ipv4/raw.c	2008-12-16 20:42:20.000000000 -0600
@@ -82,6 +82,9 @@ static struct raw_hashinfo raw_v4_hashin
 	.lock = __RW_LOCK_UNLOCKED(raw_v4_hashinfo.lock),
 };
 
+int sysctl_raw_hdrincl_nomangle __read_mostly;
+EXPORT_SYMBOL(sysctl_raw_hdrincl_nomangle);
+
 void raw_hash_sk(struct sock *sk)
 {
 	struct raw_hashinfo *h = sk->sk_prot->h.raw_hash;
@@ -358,7 +361,8 @@ static int raw_send_hdrinc(struct sock *
 
 	/* We don't modify invalid header */
 	iphlen = iph->ihl * 4;
-	if (iphlen >= sizeof(*iph) && iphlen <= length) {
+	if (iphlen >= sizeof(*iph) && iphlen <= length &&
+	    sysctl_raw_hdrincl_nomangle == 0) {
 		if (!iph->saddr)
 			iph->saddr = rt->rt_src;
 		iph->check   = 0;

--------------030503080506020409010706--
