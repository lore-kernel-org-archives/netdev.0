From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: (udp-en/decap broken in 2.6.8-rc2?) Re: ipsec, nat-t, iproute2?
Date: Sat, 31 Jul 2004 20:32:07 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1Bqr9r-0004av-00@gondolin.me.apana.org.au>
References: <20040731083456.GA24761@outpost.ds9a.nl>
Cc: herbert@gondor.apana.org.au, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ahu@ds9a.nl (bert hubert)
In-Reply-To: <20040731083456.GA24761@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

bert hubert <ahu@ds9a.nl> wrote:
> 
> Would this be:
> #define UDP_ESPINUDP    100, known in the kernel as UDP_ENCAP?

Correct.

> Does the socket need to be kept open after the setsockopt? Do the

Yes.

> encapsulated packets reach userspace?

No.

> The right way to do this is probably to first get a socket, set it to
> UDP_ENCAP, and only then try to negotiate an SA, using the port number
> assigned previously?

Theoretically you can use another port if you're the initiator, but the
draft document requires you to use port 4500.

> I'm trying to figure out how this stuff works with an eye on documenting it.
> So far I haven't been able to get openswan to do nat-t, hence I've been
> trying to do this from the ground up.

There is a NAT-T bug in Opeswan 2.1.* which was recently fixed.
Here is the patch.

In future please ask on users@lists.openswan.org.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
Index: programs/pluto/server.c
===================================================================
RCS file: /public/cvs/openswan-2/programs/pluto/server.c,v
retrieving revision 1.97
diff -u -r1.97 server.c
--- programs/pluto/server.c	2 Jun 2004 12:42:50 -0000	1.97
+++ programs/pluto/server.c	22 Jul 2004 03:34:50 -0000
@@ -523,6 +523,51 @@
     }
 #endif
 
+#if defined(linux) && defined(KERNEL26_SUPPORT)
+    if (!no_klips && kernel_ops->type == KERNEL_TYPE_LINUX)
+    {
+	struct sadb_x_policy policy;
+	int level, opt;
+
+	policy.sadb_x_policy_len = sizeof(policy) / IPSEC_PFKEYv2_ALIGN;
+	policy.sadb_x_policy_exttype = SADB_X_EXT_POLICY;
+	policy.sadb_x_policy_type = IPSEC_POLICY_BYPASS;
+	policy.sadb_x_policy_dir = IPSEC_DIR_INBOUND;
+	policy.sadb_x_policy_reserved = 0;
+	policy.sadb_x_policy_id = 0;
+	policy.sadb_x_policy_reserved2 = 0;
+
+	if (addrtypeof(&ifp->addr) == AF_INET6)
+	{
+	    level = IPPROTO_IPV6;
+	    opt = IPV6_IPSEC_POLICY;
+	}
+	else
+	{
+	    level = IPPROTO_IP;
+	    opt = IP_IPSEC_POLICY;
+	}
+
+	if (setsockopt(fd, level, opt
+	  , &policy, sizeof(policy)) < 0)
+	{
+	    log_errno((e, "setsockopt IPSEC_POLICY in process_raw_ifaces()"));
+	    close(fd);
+	    return -1;
+	}
+
+	policy.sadb_x_policy_dir = IPSEC_DIR_OUTBOUND;
+
+	if (setsockopt(fd, level, opt
+	  , &policy, sizeof(policy)) < 0)
+	{
+	    log_errno((e, "setsockopt IPSEC_POLICY in process_raw_ifaces()"));
+	    close(fd);
+	    return -1;
+	}
+    }
+#endif
+
     setportof(htons(port), &ifp->addr);
     if (bind(fd, sockaddrof(&ifp->addr), sockaddrlenof(&ifp->addr)) < 0)
     {
@@ -659,13 +704,10 @@
 		if (q == NULL)
 		{
 		    /* matches nothing -- create a new entry */
-		    int fd = socket(addrtypeof(&ifp->addr), SOCK_DGRAM, IPPROTO_UDP);
+		    int fd = create_socket(ifp, v->name, pluto_port);
 
 		    if (fd < 0)
-		    {
-			log_errno((e, "socket() in process_raw_ifaces()"));
 			break;
-		    }
 
 #ifdef NAT_TRAVERSAL
 		    if (nat_traversal_support_non_ike)
@@ -673,96 +715,6 @@
 			nat_traversal_espinudp_socket(fd, ESPINUDP_WITH_NON_IKE);
 		    }
 #endif
-		    if (fcntl(fd, F_SETFD, FD_CLOEXEC) == -1)
-		    {
-			log_errno((e, "fcntl(,, FD_CLOEXEC) in process_raw_ifaces()"));
-			break;
-		    }
-
-		    if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR
-		    , (const void *)&on, sizeof(on)) < 0)
-		    {
-			log_errno((e, "setsockopt SO_REUSEADDR in process_raw_ifaces()"));
-			break;
-		    }
-
-		    /* To improve error reporting.  See ip(7). */
-#if defined(IP_RECVERR) && defined(MSG_ERRQUEUE)
-		    if (setsockopt(fd, SOL_IP, IP_RECVERR
-		    , (const void *)&on, sizeof(on)) < 0)
-		    {
-			log_errno((e, "setsockopt IP_RECVERR in process_raw_ifaces()"));
-			break;
-		    }
-#endif
-
-		    /* With IPv6, there is no fragmentation after
-		     * it leaves our interface.  PMTU discovery
-		     * is mandatory but doesn't work well with IKE (why?).
-		     * So we must set the IPV6_USE_MIN_MTU option.
-		     * See draft-ietf-ipngwg-rfc2292bis-01.txt 11.1
-		     */
-#ifdef IPV6_USE_MIN_MTU	/* YUCK: not always defined */
-		    if (addrtypeof(&ifp->addr) == AF_INET6
-		    && setsockopt(fd, SOL_SOCKET, IPV6_USE_MIN_MTU
-		      , (const void *)&on, sizeof(on)) < 0)
-		    {
-			log_errno((e, "setsockopt IPV6_USE_MIN_MTU in process_raw_ifaces()"));
-			break;
-		    }
-#endif
-
-#if defined(linux) && defined(KERNEL26_SUPPORT)
-		    if (!no_klips && kernel_ops->type == KERNEL_TYPE_LINUX)
-		    {
-			struct sadb_x_policy policy;
-			int level, opt;
-
-			policy.sadb_x_policy_len = sizeof(policy) / IPSEC_PFKEYv2_ALIGN;
-			policy.sadb_x_policy_exttype = SADB_X_EXT_POLICY;
-			policy.sadb_x_policy_type = IPSEC_POLICY_BYPASS;
-			policy.sadb_x_policy_dir = IPSEC_DIR_INBOUND;
-			policy.sadb_x_policy_reserved = 0;
-			policy.sadb_x_policy_id = 0;
-			policy.sadb_x_policy_reserved2 = 0;
-
-			if (addrtypeof(&ifp->addr) == AF_INET6)
-			{
-			    level = IPPROTO_IPV6;
-			    opt = IPV6_IPSEC_POLICY;
-			}
-			else
-			{
-			    level = IPPROTO_IP;
-			    opt = IP_IPSEC_POLICY;
-			}
-
-			if (setsockopt(fd, level, opt
-			  , &policy, sizeof(policy)) < 0)
-			{
-			    log_errno((e, "setsockopt IPSEC_POLICY in process_raw_ifaces()"));
-			    break;
-			}
-
-			policy.sadb_x_policy_dir = IPSEC_DIR_OUTBOUND;
-
-			if (setsockopt(fd, level, opt
-			  , &policy, sizeof(policy)) < 0)
-			{
-			    log_errno((e, "setsockopt IPSEC_POLICY in process_raw_ifaces()"));
-			    break;
-			}
-		    }
-#endif
-
-		    setportof(htons(pluto_port), &ifp->addr);
-		    if (bind(fd, sockaddrof(&ifp->addr), sockaddrlenof(&ifp->addr)) < 0)
-		    {
-			log_errno((e, "bind() for %s/%s %s:%u in process_raw_ifaces()"
-			    , ifp->name, v->name
-			    , ip_str(&ifp->addr), (unsigned) pluto_port));
-			break;
-		    }
 
 		    q = alloc_thing(struct iface, "struct iface");
 		    q->rname = clone_str(ifp->name, "real device name");
