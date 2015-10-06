From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net] ppp: don't override sk->sk_state in pppoe_flush_dev()
Date: Tue, 6 Oct 2015 10:50:36 +0200
Message-ID: <20151006085036.GC2882@alphalink.fr>
References: <b7fbf103cd589741e3938550e7cf0f3684d8951c.1443605079.git.g.nault@alphalink.fr>
 <7045c1dad4647944f61c958511d45fcd@visp.net.lb>
 <20151002175426.GE2911@alphalink.fr>
 <356ca8b8094bb2460c0182c00e120378@visp.net.lb>
 <1444018131.14634.6.camel@mattb-dl>
 <20151005122459.GG2911@alphalink.fr>
 <1444091180.1468.17.camel@mattb-dl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "core@irc.lg.ua" <core@irc.lg.ua>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"paulus@samba.org" <paulus@samba.org>,
	"nuclearcat@nuclearcat.com" <nuclearcat@nuclearcat.com>
To: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:39037 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751340AbbJFIuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 04:50:39 -0400
Content-Disposition: inline
In-Reply-To: <1444091180.1468.17.camel@mattb-dl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 06, 2015 at 12:26:20AM +0000, Matt Bennett wrote:
> On Mon, 2015-10-05 at 14:24 +0200, Guillaume Nault wrote:
> > On Mon, Oct 05, 2015 at 04:08:51AM +0000, Matt Bennett wrote:
> > > Hi, I am seeing this panic occur occasionally however I am unsure how to
> > > go about reproducing it. Is it enough to simply keep creating and
> > > tearing down the PPP interface? I can also test and/or investigate this
> > > issue if a suitable reproduction method is available.
> > > 
> > There are at least two issues resulting in similar Oops.
> > 
> > The first one goes with MTU/address/link state updates on the
> > underlying interface: any such update on an interface used by a
> > PPPoE connection will generally result in an Oops when releasing the
> > PPPoE connection. This is fixed by e6740165b8f7 ("ppp: don't override
> > sk->sk_state in pppoe_flush_dev()").
> 
> Without your patch ("ppp: don't override sk->sk_state in
> pppoe_flush_dev()") I can see the following function calls being made
> when changing the mtu on the underlying ethernet interface for the PPPoE
> connection:
> 
> 1. pppoe_flush_dev() - setting PPPOX_ZOMBIE
> 
> 2. pppoe_connect - setting PPPOX_NONE (shown below)
> 
> /* Delete the old binding */
> 	if (stage_session(po->pppoe_pa.sid)) {
> 		pppox_unbind_sock(sk);
> 		pn = pppoe_pernet(sock_net(sk));
> 		delete_item(pn, po->pppoe_pa.sid,
> 			    po->pppoe_pa.remote, po->pppoe_ifindex);
> 		if (po->pppoe_dev) {
> 			dev_put(po->pppoe_dev);
> 			po->pppoe_dev = NULL;
> 		}
> 
> 		memset(sk_pppox(po) + 1, 0,
> 		       sizeof(struct pppox_sock) - sizeof(struct sock));
> 		sk->sk_state = PPPOX_NONE;
> 	}
> 
> 3. pppoe_release - No oops (since sk->sk_state is no longer in
> {PPPOX_CONNECTED,PPPOX_BOUND,PPPOX_ZOMBIE})
> 
> It doesn't look to me like the above functions can execute
> asynchronously but I'd have to look harder. I am using 3.16 by the way.
> 
Just drop the pppoe_connect() call. Right after the pppoe_flush_dev()
call, sk_state is PPPOX_ZOMBIE and pppoe_dev is NULL. This is enouhg to
make pppoe_release() crash.

The typical scenario e6740165b8f7 ("ppp: don't override sk->sk_state in
pppoe_flush_dev()") fixes is:

  Userspace process #1:                       Userspace process #2:
  ---------------------                       ---------------------
    fd = socket(AF_PPPOX, PX_PROTO_OE, 0);
    connect(fd, {AF_PPPOX, PX_PROTO_EO,
            $sid, $mac_addr, $ifname},
            sizeof(struct sockaddr_pppox));

    ... process_packets() ...                   # ip link set $ifname mtu $mtu

    close(fd); --> Kernel Oops
