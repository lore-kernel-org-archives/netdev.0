From: "Jerome Borsboom" <j.borsboom@erasmusmc.nl>
Subject: Re: [PATCH] parse ip:port strings correctly in in4_pton
Date: Tue, 17 Apr 2007 10:27:17 +0200
Message-ID: <4624A105.26924.380F9F@j.borsboom.erasmusmc.nl>
References: <Pine.LNX.4.64.0704161001280.1519@knorkaan.xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Jerome Borsboom <j.borsboom@erasmusmc.nl>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.erasmusmc.nl ([156.83.10.20]:61230 "EHLO
	lists.erasmusmc.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752851AbXDQIhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 04:37:35 -0400
Received: from localhost (localhost.erasmusmc.nl [127.0.0.1])
	by lists.erasmusmc.nl (Postfix) with ESMTP id 20054EB64C4
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 10:28:20 +0200 (CEST)
Received: from lists.erasmusmc.nl ([127.0.0.1])
	by localhost (lists.erasmusmc.nl [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7mdfT590VHaq for <netdev@vger.kernel.org>;
	Tue, 17 Apr 2007 10:28:19 +0200 (CEST)
Received: from rbox6.erasmusmc.nl (rbox6.erasmusmc.nl [156.83.10.16])
	by lists.erasmusmc.nl (Postfix) with ESMTP id EEA52EB64BB
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 10:28:19 +0200 (CEST)
In-reply-to: <46233E7C.10407@trash.net>
Content-description: Mail message body
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Jerome Borsboom wrote:
> > in4_pton converts a textual representation of an ip4 address into an
> > integer representation. However, when the textual representation is of
> > in the form ip:port, c.f. 192.168.1.1:5060, and 'delim' is set to -1,
> > the function bails out when parsing the colon.
> > 
> > It makes sense to allow the colon as a delimiting character without
> > explicitly having to set it through the 'delim' variable as there can be
> > no ambiguity in the point where the ip address is completely parsed.
> > Furthermore, this function is indeed called from nf_conntrack_sip.c in
> > this way to parse textual ip:port combinations which fails as stated above.
> 
> 
> What about IPv6? in6_pton behaves similar and is also used by
> nf_conntrack_sip.
> 

I have looked a bit more into this. The current behaviour of 
in6_pton is correct. As I said before, the colon is the separator 
within the IPv6 address and hence cannot be used to indicate a tcp 
or udp port. RFC 2732 states that when a tcp or udp port is included 
in an IPv6 URL it must be in the form '[IPv6-address]:port'. Here 
the rectangular braces make clear where the ip-address part ends and 
the port part begins. However, in[46]_pton are made to only change 
the representation of an ip-address and do not and should not bother 
about any other stuff like the rectangular braces in an IPv6 
reference or the colon in an IPv4+port combination. My patch 
corrects the unnecessary error in the case in an IPv4-address+port 
combination.

Related to this is the fact that nf_conntrack_sip wrongly assumes 
unbraced IPv6 adresses. RFC 3261 states that in all cases where an 
IPv6 reference is used, it should be enclosed in rectangular braces. 
Current behaviour is clearly wrong. I will see if I can come up with 
a patch to correct this error in nf_conntrack_sip.
