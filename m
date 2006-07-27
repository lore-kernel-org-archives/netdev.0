From: Andy Gay <andy@andynet.net>
Subject: Re: ipsec tunnel policy vs routing table
Date: Thu, 27 Jul 2006 10:27:16 -0400
Message-ID: <1154010436.16424.7.camel@tahini.andynet.net>
References: <BAY103-F281E5B6AC611062170572AB2580@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms046pub.verizon.net ([206.46.252.46]:39093 "EHLO
	vms046pub.verizon.net") by vger.kernel.org with ESMTP
	id S932230AbWG0O1i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 10:27:38 -0400
Received: from andyhp.tranquilitynj.net ([70.18.168.191])
 by vms046.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
 with ESMTPA id <0J32009NQG5JXFWB@vms046.mailsrvcs.net> for
 netdev@vger.kernel.org; Thu, 27 Jul 2006 09:27:20 -0500 (CDT)
In-reply-to: <BAY103-F281E5B6AC611062170572AB2580@phx.gbl>
To: Marco Berizzi <pupilla@hotmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-07-27 at 16:06 +0200, Marco Berizzi wrote:
> Herbert Xu wrote:
> 
> >Marco Berizzi <pupilla@hotmail.com> wrote:
> > >
> > > 172.16.0.0/23 dev eth2  proto kernel  scope link  src 172.16.1.1
> > > 10.180.0.0/16 via 172.16.1.253 dev eth2
> > > 10.0.0.0/8 via pub_ip dev eth0
> > > 127.0.0.0/8 dev lo  scope link
> > >
> > > I have noticed that packets for 10.180.0.0/16 network
> > > are eaten by the ipsec tunnel because the policy allow
> > > them. Is there a way to deliver packets for 10.180.0.0
> > > network to the 172.16.1.253 router (because the route
> > > to 10.180.0.0 is more specific than 10.0.0.0/8)?
> >
> >You need an IPsec pass action.  With Openswan you can do it with
> >something like
> >
> >conn pass
> >	left=%defaultroute
> >	# This should be the leftsubnet of your 10.0.0.0/8 connection.
> >	leftsubnet=0.0.0.0/0
> >	# This field doesn't really matter.
> >	right=172.16.1.253
> >	rightsubnet=10.180.0.0/16
> >         type=passthrough
> >         authby=never
> >         auto=route
> 
> Thanks for the tip Herbert.
> Ok I have inserted this section in openswan init
> file (ipsec.conf)
> 
> conn pass
> 	left=172.16.1.1
> 	leftsubnet=172.16.0.0/23
> 	right=172.16.1.253
> 	rightsubnet=10.180.0./16
> 	type=passthrough
> 	authby=never
> 	auto=route
> 
> After running 'ipsec auto --add pass && ipsec auto
> --route pass' openswan has eaten my static route
> inserted by hand:
> route add -net 10.180.0.0/16 gw 172.16.1.253
> Here is 'ip r s' output after 'ipsec auto --route
> pass':
> 172.16.0.0/23 dev eth2  proto kernel  scope link  src 172.16.1.1
> 10.180.0.0/16 dev eth2  scope link
> 
> All if fine now. It isn't even needed anymore to
> insert the static route now, as it is placed by
> openswan. My question is how linux understand that
> it should send packets for 10.180.0.0/24 to the
> 172.16.1.253 router.

It's a function of the IPsec SADB. The passthrough conn added a more
specific policy that will match before the tunnel policy.
You can run 'ip xfrm p' and 'ip xfrm s' to view the policies & state
info.

BTW - you should really ask these things on the Openswan list, or at
least copy them.

> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

