From: Jose Alberto Reguero <jareguero@telefonica.net>
Subject: Re: Problem with sockets an 2.6.21-rc5 kernel
Date: Tue, 27 Mar 2007 20:30:37 +0200
Message-ID: <200703272030.37843.jareguero@telefonica.net>
References: <200703262303.21448.jareguero@telefonica.net> <20070327144658.GA25125@2ka.mipt.ru> <200703271741.09949.jareguero@telefonica.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_NLWCGg8aPgC5yuR"
Cc: netdev@vger.kernel.org, Jay Cliburn <jacliburn@bellsouth.net>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.telefonica.net ([213.4.149.66]:43108 "EHLO
	ctsmtpout4.frontal.correo" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S934158AbXC0ScB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 14:32:01 -0400
In-Reply-To: <200703271741.09949.jareguero@telefonica.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_NLWCGg8aPgC5yuR
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

El Martes, 27 de Marzo de 2007, Jose Alberto Reguero escribi=F3:
> El Martes, 27 de Marzo de 2007, Evgeniy Polyakov escribi=F3:
> > On Tue, Mar 27, 2007 at 04:29:11PM +0200, Jose Alberto Reguero
>
> (jareguero@telefonica.net) wrote:
> > > El Martes, 27 de Marzo de 2007, Evgeniy Polyakov escribi=C3=B3:
> > > > On Mon, Mar 26, 2007 at 11:03:21PM +0200, Jose Alberto Reguero
> > >
> > > (jareguero@telefonica.net) wrote:
> > > > > I had two python programs, server.py and client.py(attached)
> > > > >
> > > > > With server.py in  a kernel 2.6.21-rc5 x86_64 and client.py in the
> > > > > same machine,  server.py get the message.
> > > > >
> > > > > With server.py in  a kerner 2.6.21-rc5 x86_64 and client.py in
> > > > > another machine, server.py don't get the message.
> > > > >
> > > > > The same with the programs in c(attached).
> > > > >
> > > > > With kernel 2.6.20.3 the programs work well.
> > > > >
> > > > > There are something wrong in the programs?
> > > >
> > > > Besides full absence of error checks and coding style issues it does
> > > > not seem to contain errors.
> > > >
> > > > And, btw, C program work with 2.6.21-rc5 (git tree
> > > > e0f2e3a06be513352cb4955313ed7e55909acd84) on x86_64.
> > > >
> > > > server.c application compiled with Debian 4.1.1-21 compiler on x86_=
64
> > > > sucessfully received message from 2.6.18-3 machine.
> > >
> > > Thanks. I thought it was a kernel BUG. It is a alt1 driver
> > > BUG(Attansic(R) L1 Ethernet Network Driver). The error happens with t=
he
> > > atl1 driver that comes with kernel 2.6.21-rc5. With he original driver
> > > from ASUS for M2V motherboard modified to compile with kernel
> > > 2.6.21-rc5 there is no problems.
> >
> > Did it work with in-kernel driver?
> > There is only one remotely related change in the driver:
> >
> > -	mta =3D ioread32((hw + REG_RX_HASH_TABLE) + (hash_reg << 2));
> > +	mta =3D ioread32((hw->hw_addr + REG_RX_HASH_TABLE) + (hash_reg << 2));
> >
> > If it worked before, then spurious ioread() from outside of our
> > univercity could lead to good/bad mta value (likely zero or ~0), so
> > appropriate multicast list update could succeed.
> >
> > If your programs never worked with this new driver, then it can not be
> > easily solved without hardware specifications.
> >
> > I added Jay Cliburn who submitted the driver to Cc list.
> >
> > > Jose Alberto
>
> The first time i try the kernel driver was with kernel 2.6.21-rc4, and
> don't work.  I can help to debug the problem, with some help.
>
> I have a M2V motherboard with built-in Attansic(R) L1 Ethernet Network
> Driver and a Athlon 64 X2 Dual Core processor.
>
> Jose Alberto
>
>

I found that the original driver has its own ether_crc_le function, that=20
return the value inverted. The attached patch solve the problem.

Jose Alberto




--Boundary-00=_NLWCGg8aPgC5yuR
Content-Type: text/x-diff;
  charset="iso-8859-15";
  name="atl1_hw.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="atl1_hw.diff"

--- linux-2.6.21-rc5/drivers/net/atl1/atl1_hw.c	2007-03-26 00:56:23.000000000 +0200
+++ linux-2.6.21-rc5.new/drivers/net/atl1/atl1_hw.c	2007-03-27 20:14:23.000000000 +0200
@@ -334,7 +334,6 @@
 	int i;
 
 	crc32 = ether_crc_le(6, mc_addr);
-	crc32 = ~crc32;
 	for (i = 0; i < 32; i++)
 		value |= (((crc32 >> i) & 1) << (31 - i));
 

--Boundary-00=_NLWCGg8aPgC5yuR--
