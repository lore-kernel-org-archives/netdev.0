From: Pierre Desvaux <pierre@desvaux.eu>
Subject: Re: unmanaged L2TPv3 ethernet pseudowire Cisco <=> Linux
Date: Mon, 21 Oct 2013 15:08:33 +0000 (UTC)
Message-ID: <loom.20131021T165114-650@post.gmane.org>
References: <Pine.LNX.4.61.1303241153000.20041@envy.nxs.se> <CAEwTi7Rbo3dBqhyDJXYvrkMWfrX9xwUr5VovFoW7BfPAZp4XFw@mail.gmail.com> <Pine.LNX.4.61.1303272104470.20041@envy.nxs.se> <51535D16.4080207@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:38721 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752996Ab3JUPPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Oct 2013 11:15:06 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VYHCB-0005Yo-Ls
	for netdev@vger.kernel.org; Mon, 21 Oct 2013 17:15:04 +0200
Received: from gwinternet.thalesgroup.com ([192.54.144.229])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 17:15:03 +0200
Received: from pierre by gwinternet.thalesgroup.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 17:15:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Chapman <jchapman <at> katalix.com> writes:

> 
> On 27/03/13 20:08, Tomas Agartz wrote:
> > On Tue, 26 Mar 2013, James Chapman wrote:
> > 
> >> The issue is that Linux and Cisco use a different default for the
> >> L2SpecificSublayer header setting and neither implementation provides
> >> a config option to change its setting.  The Linux default is to use
> >> the Default L2SpecificSublayer as defined in the RFC. Unfortunately
> >> the Cisco default is to use no L2SpecificSublayer.
> >>
> >> The kernel already has an API to allow the L2SpecificSublayer setting
> >> to be configured. The missing piece is an iproute2 l2tp config option
> >> to configure it. I'll work on an iproute2 patch now to allow this
> >> setting to be configured.
> > 
> > I patched my iproute2 with your patch and now my tunnel is working.
> > Thank you! :)
> 
> Great. Thanks for reporting back.
> 
> >> For unmanaged tunnels, these parameters must be manually configured
> >> consistently at each side. Both Cisco and Linux default to use no
> >> cookies and both already have config parameters to set cookie
> >> parameters, if needed. However, for L2SpecificSublayer this isn't the
> >> case. We need to add a config option on the Linux side to force the
> >> same setting as Cisco is using.
> > 
> > Does the API in the kernel allow you to set the cookie? In that case it
> > seems like a good idea to add that to iproute2 as well?
> 
> It is already supported. See the cookie and peer_cookie parameters of ip
> l2tp add session.
> 
> ip l2tp help
> or
> man ip-l2tp
> 
> James
> 
> 

Hi,

I have tried an other solution to bypass this issue.
I put a 4 bytes cookie in the paquets sent by the Cisco. It looks like this:
[IPv4][L2TPv3][Cookie][payload]

With value 0, the cookie is seen by the Linux as a L2SpecificSublayer with
Sbit at 0. Wich means ignore the value of the sequence number in
L2SpecificSublayer so Linux accepts it. Linux replies automaticaly with Sbit
0 to Cisco.
Cisco is as well configured to accept a 4 bytes cookie, the
L2SpecificSublayer is now accepted as a cookie.

To configure Cisco:
xconnect 192.168.0.1 200 encapsulation l2tpv3 manual pw-class tlund
   l2tp id 200 200
   l2tp cookie local 4 0
   l2tp cookie remote 4 0

Pierre
