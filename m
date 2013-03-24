From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Sun, 24 Mar 2013 02:26:25 +0100
Message-ID: <20130324012625.GA17948@order.stressinduktion.org>
References: <514CE440.3010003@gmail.com> <1363996448.4431.73.camel@edumazet-glaptop> <514CF23A.3010702@gmail.com> <20130323021008.GC939@order.stressinduktion.org> <514D3581.4040001@gmail.com> <20130323150655.GA10779@order.stressinduktion.org> <69jo698argv8@mids.svenhartge.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Sven Hartge <sven@svenhartge.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54248 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030Ab3CXB01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 21:26:27 -0400
Content-Disposition: inline
In-Reply-To: <69jo698argv8@mids.svenhartge.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 24, 2013 at 01:36:33AM +0100, Sven Hartge wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> > On Sat, Mar 23, 2013 at 12:54:25AM -0400, rebelyouth wrote:
> >> I applied your patch on my the kernel 3.7.9 and look like the patch do 
> >> what you said before :
> >> 
> >> "This does not solve the real problem, which I have not yet understood 
> >> (wrong packets will be discarded now and will be hopefully resend). "
> >> 
> >> There are errors on the RX side of the server and the speed is 5~10% 
> >> less but the files are ok in nfsv4 , SFTP/FTP and samba.
> >> 
> >> Maybe the Atheros drivers for windows had a patch for the checksum 
> >> already in the drivers and the chipset  have some hardware bug, but for 
> >> me your patch is already an achievement and I really thank you for your 
> >> time and consideration.
> 
> > The upstream driver (which is a tarball I found with google
> > AR81Family-linux-v1.0.1.14.tar.gz) has this function ifdefed out. I have
> > a couple of more things I want to test as soon as I have access to the
> > hardware again.  If I don't find a better solution I will submit a patch
> > which disables rx checksumming as a whole for inclusion to net-next.
> 
> I remember having the some problem with an atl1e chip on my Asus
> PQ5-Pro. It would corrupt ethernet frames, resulting in dropped
> connections when using SSH (bailing out with a HMAC crypto error) etc.
> 
> After some conversations with an Atheros engineer (Jie Yang
> <Jie.Yang@Atheros.com>) I got the following patch, which I applied for
> some time to my local Debian kernel packages. It fixed the problem for
> me, until I switched the board to a newer one.
> 
> As far as I understand, this patch rips out any checksumming function
> and just advertises the chip as not using and providing any.

Yes, my patch does the same, just jumpes over the body of the function
and returns without updating the ip_summed field.

> My mail archive indicates, this bug has been fixed in the upstream atl1e
> driver since version l1c-linux-v1.0.0.11-test.tar.gz.

Yes, they ifdefed out the body of the function.

What we have found so far:

It seems packet content overwrites itself. We have not yet found a pattern
but it seems that some 16 bytes from the payload overwrite other parts
of the packet, even mulitple times (but the same 16 bytes though).

I also checked freebsd. Hardware rx checksumming is disabled there and
we did not see any checksum errors in the stack. So I assume they don't
have this problem.
