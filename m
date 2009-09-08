From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: appletalk:  IPDDP_ENCAP and IPDDP_DECAP variables are confusing
Date: Tue, 8 Sep 2009 14:37:37 -0400 (EDT)
Message-ID: <alpine.LFD.2.00.0909081431010.11397@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from astoria.ccjclearline.com ([64.235.106.9]:38009 "EHLO
	astoria.ccjclearline.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355AbZIHShi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 14:37:38 -0400
Received: from cpe002129687b04-cm001225dbafb6.cpe.net.cable.rogers.com ([99.235.241.187] helo=crashcourse.ca)
	by astoria.ccjclearline.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.69)
	(envelope-from <rpjday@crashcourse.ca>)
	id 1Ml5ZU-0001pX-1E
	for netdev@vger.kernel.org; Tue, 08 Sep 2009 14:37:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  (i pointed out the first part of this to arnaldo but, after i looked
at it more closely, it's a bit messier than i thought so i'll just
toss it out to the list and let someone here figure out what to do
with it.)

  from my latest tree scanning script looking for unused Kconfig
variables, we learn that:

$ grep -r IPDDP_DECAP drivers
drivers/net/appletalk/ipddp.c:static int ipddp_mode = IPDDP_DECAP;
drivers/net/appletalk/ipddp.c:	if(ipddp_mode == IPDDP_DECAP)
drivers/net/appletalk/ipddp.c:	if(ipddp_mode == IPDDP_DECAP)
drivers/net/appletalk/Kconfig:config IPDDP_DECAP
drivers/net/appletalk/ipddp.h:#define IPDDP_DECAP	2
$

which suggests that the Kconfig variable "IPDDP_DECAP" is utterly
redundant as the corresponding CONFIG_IPDDP_DECAP is not used anywhere
so the obvious solution is to simply remove that Kconfig variable.

  until you search for the corresponding IPDDP_ENCAP variable:

$ grep -r IPDDP_ENCAP drivers
drivers/net/appletalk/ipddp.c:#ifdef CONFIG_IPDDP_ENCAP
drivers/net/appletalk/ipddp.c:static int ipddp_mode = IPDDP_ENCAP;
drivers/net/appletalk/ipddp.c:	if(ipddp_mode == IPDDP_ENCAP)
drivers/net/appletalk/Kconfig:config IPDDP_ENCAP
drivers/net/appletalk/ipddp.h:#define IPDDP_ENCAP	1
$

  the difference is this one *is* tested in ipddp.c, thusly:

#ifdef CONFIG_IPDDP_ENCAP
static int ipddp_mode = IPDDP_ENCAP;
#else
static int ipddp_mode = IPDDP_DECAP;
#endif

  that makes it seem that those two settings should be mutually
exclusive, but that's not how they're defined in the Kconfig file:

=====

config IPDDP_ENCAP
        bool "IP to Appletalk-IP Encapsulation support"
        depends on IPDDP
        help
          If you say Y here, the AppleTalk-IP code will be able to encapsulate
          IP packets inside AppleTalk frames; this is useful if your Linux box          is stuck on an AppleTalk network (which hopefully contains a
          decapsulator somewhere). Please see
          <file:Documentation/networking/ipddp.txt> for more information. If
          you said Y to "AppleTalk-IP driver support" above and you say Y
          here, then you cannot say Y to "AppleTalk-IP to IP Decapsulation
          support", below.

config IPDDP_DECAP
        bool "Appletalk-IP to IP Decapsulation support"
        depends on IPDDP
        help
          If you say Y here, the AppleTalk-IP code will be able to decapsulate
          AppleTalk-IP frames to IP packets; this is useful if you want your
          Linux box to act as an Internet gateway for an AppleTalk network.
          Please see <file:Documentation/networking/ipddp.txt> for more
          information.  If you said Y to "AppleTalk-IP driver support" above
          and you say Y here, then you cannot say Y to "IP to AppleTalk-IP
          Encapsulation support", above.

=====

  i'm confused. would someone like to suggest how that can be cleaned
up?

rday
--


========================================================================
Robert P. J. Day                               Waterloo, Ontario, CANADA

        Linux Consulting, Training and Annoying Kernel Pedantry.

Web page:                                          http://crashcourse.ca
Twitter:                                       http://twitter.com/rpjday
========================================================================
