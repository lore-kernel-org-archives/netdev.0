From: gerrit@erg.abdn.ac.uk
Subject: Re: [RFC][PATCH 1/3] net/ipv4: UDP-Lite extensions
Date: Wed, 23 Aug 2006 16:03:07 +0100
Message-ID: <200608231603.08240@strip-the-willow>
References: <200608231150.42039@strip-the-willow> <Pine.LNX.4.64.0608231019010.3198@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: davem@davemloft.net, alan@lxorguk.ukuu.org.uk,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, kaber@coreworks.de,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964927AbWHWPEP@vger.kernel.org>
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0608231019010.3198@d.namei>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi James,

Quoting James Morris:
|  On Wed, 23 Aug 2006, gerrit@erg.abdn.ac.uk wrote:
|  
|  > +void __init udplite4_register(void)
|  > +{
|  > +	if (proto_register(&udplite_prot, 1))
|  > +		goto out_register_err;
|  > +
|  > +	if (inet_add_protocol(&udplite_protocol, IPPROTO_UDPLITE) < 0)
|  > +		goto out_unregister_proto;
|  > +
|  > +	inet_register_protosw(&udplite4_protosw);
|  > +
|  > +	return;
|  > +
|  > +out_unregister_proto:
|  > +	proto_unregister(&udplite_prot);
|  > +out_register_err:
|  > +	printk(KERN_ERR "udplite4_register: Cannot add UDP-Lite protocol\n");
|  > +}
|  
|  Other protocols & network components call panic() if they fail during boot 
|  initialization.  Not sure if this is a great thing, but it raises the 
|  issue of whether udp-lite should remain consistent here.

The behaviour is consistent (modulo loglevel) with inet_init()
of net/ipv4/af_inet.c:

	// ...

	rc = proto_register(&udp_prot, 1);
	if (rc)
		goto out_unregister_tcp_proto;

	// ... 
      	if (inet_add_protocol(&udp_protocol, IPPROTO_UDP) < 0)
		printk(KERN_CRIT "inet_init: Cannot add UDP protocol\n");
	if (inet_add_protocol(&tcp_protocol, IPPROTO_TCP) < 0)
		printk(KERN_CRIT "inet_init: Cannot add TCP protocol\n");

	// ...
	for (q = inetsw_array; q < &inetsw_array[INETSW_ARRAY_LEN]; ++q)
		inet_register_protosw(q);

 	// ...

        /* UDP Lite is called here, but the code of udplite4_register()
         * could as well be put in place within inet_init()              */

	udplite4_register();


But your question raises another: 
  * if TCP cannot init, there is no layer-4 protocol
  * if UDP cannot register, TCP is unregistered also
  * if RAW cannot register, only UDP is unregistered, but not TCP

>From that I could not deduct a rule what would happen if UDP-Lite failed
to register. If control had reached that above point, it means that all
other protocols have already successfully registered -- if then UDP-Lite
could not register and called a panic(), it would abort the remainder of the
stack. 

So how should the code be integrated:
 (a) following the same scheme as in af_inet.c (like f.e. raw_prot ) or
 (b) keep separate initialisation (as it is used e.g. in net/dccp/ipv4, dccp_v4_init())
 (c) ... ?


Gerrit
