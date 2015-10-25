From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: Linux 4.2.4
Date: Sun, 25 Oct 2015 20:46:47 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1510252032420.14141@blackhole.kfki.hu>
References: <20151023003306.GA25388@kroah.com> <562C83FD.6010402@wiesinger.com> <20151025082547.GA22300@kroah.com> <20151025090308.GA17656@1wt.eu> <562CA13C.90500@wiesinger.com> <20151025094634.GA6832@1wt.eu> <562CB396.2080509@wiesinger.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Willy Tarreau <w@1wt.eu>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	Greg KH <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org, stable@vger.kernel.org, lwn@lwn.net,
	Jiri Slaby <jslaby@suse.cz>
To: Gerhard Wiesinger <lists@wiesinger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp0.kfki.hu ([148.6.0.25]:54571 "EHLO smtp0.kfki.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751608AbbJYTpW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Oct 2015 15:45:22 -0400
In-Reply-To: <562CB396.2080509@wiesinger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sun, 25 Oct 2015, Gerhard Wiesinger wrote:

> On 25.10.2015 10:46, Willy Tarreau wrote:
> > ipset *triggered* the problem. The whole stack dump would tell more. 
> 
> OK, find the stack traces in the bug report:
> https://bugzilla.redhat.com/show_bug.cgi?id=1272645
> 
> Kernel 4.1.10 triggered also a kernel dump when playing with ipset commands
> and IPv6, details in the bug report  ....

It seems to me it is an architecture-specific alignment issue. I don't 
have a Cortex-A7 ARM hardware and qemu doesn't seem to support it either, 
so I'm unable to reproduce it (ipset passes all my tests on my hardware, 
including more complex ones than what breaks here). My first wild guess is 
that the dynamic array of the element structure is not aligned properly. 
Could you give a try to the next patch?

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index afe905c..1cf357d 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -1211,6 +1211,9 @@ static const struct ip_set_type_variant mtype_variant = {
 	.same_set = mtype_same_set,
 };
 
+#define IP_SET_BASE_ALIGN(dtype)	\
+	ALIGN(sizeof(struct dtype), __alignof__(struct dtype))
+
 #ifdef IP_SET_EMIT_CREATE
 static int
 IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
@@ -1319,12 +1322,12 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 #endif
 		set->variant = &IPSET_TOKEN(HTYPE, 4_variant);
 		set->dsize = ip_set_elem_len(set, tb,
-				sizeof(struct IPSET_TOKEN(HTYPE, 4_elem)));
+				IP_SET_BASE_ALIGN(IPSET_TOKEN(HTYPE, 4_elem)));
 #ifndef IP_SET_PROTO_UNDEF
 	} else {
 		set->variant = &IPSET_TOKEN(HTYPE, 6_variant);
 		set->dsize = ip_set_elem_len(set, tb,
-				sizeof(struct IPSET_TOKEN(HTYPE, 6_elem)));
+				IP_SET_BASE_ALIGN(IPSET_TOKEN(HTYPE, 6_elem)));
 	}
 #endif
 	if (tb[IPSET_ATTR_TIMEOUT]) {

If that does not solve it, then could you help to narrow down the issue? 
Does the bug still appear if your remove the counter extension of the set?

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
