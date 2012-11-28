From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: move inet_dport/inet_num in sock_common
Date: Tue, 27 Nov 2012 19:13:31 -0800
Message-ID: <1354072411.14302.46.camel@edumazet-glaptop>
References: <1354028815.14302.35.camel@edumazet-glaptop>
	 <1354043156.2701.17.camel@bwh-desktop.uk.solarflarecom.com>
	 <1354051401.14302.40.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ling Ma <ling.ma.program@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:59280 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272Ab2K1DNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 22:13:46 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so4540987dak.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 19:13:45 -0800 (PST)
In-Reply-To: <1354051401.14302.40.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-27 at 13:23 -0800, Eric Dumazet wrote:
> On Tue, 2012-11-27 at 19:05 +0000, Ben Hutchings wrote:
> > On Tue, 2012-11-27 at 07:06 -0800, Eric Dumazet wrote:
> 
> > >  struct sock_common {
> > > -	/* skc_daddr and skc_rcv_saddr must be grouped :
> > > -	 * cf INET_MATCH() and INET_TW_MATCH()
> > > +	/* skc_daddr and skc_rcv_saddr must be grouped on a 8 bytes aligned
> > > +	 * address on 64bit arches : cf INET_MATCH() and INET_TW_MATCH()
> > 
> > __aligned(8)?
> 
> Nope, only on 64 bit this requirement exists (since a long time)
> 
> I am not sure we want complexity on this.
> 
> And we dont want holes to be automatically added here neither.

Hmm, maybe the following could be the right way, as we did
for skc_hash/skc_u16hashes


 struct sock_common {
-       /* skc_daddr and skc_rcv_saddr must be grouped :
-        * cf INET_MATCH() and INET_TW_MATCH()
+       /* skc_daddr and skc_rcv_saddr must be grouped on a 8 bytes aligned
+        * address on 64bit arches : cf INET_MATCH() and INET_TW_MATCH()
         */
-       __be32                  skc_daddr;
-       __be32                  skc_rcv_saddr;
-
+       union {
+               unsigned long   skc_laddr;
+               struct {
+                       __be32  skc_daddr;
+                       __be32  skc_rcv_saddr;
+               };
+       };
        union  {
                unsigned int    skc_hash;
                __u16           skc_u16hashes[2];
        };
+       /* skc_dport && skc_num must be grouped as well */
+       union {
+               unsigned int    skc_ports;
+               struct {
+                       __be16  skc_dport;
+                       __u16   skc_num;
+               };
+       };
+
        unsigned short          skc_family;
        volatile unsigned char  skc_state;
        unsigned char           skc_reuse;
