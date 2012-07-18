From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/7] net-tcp: Fast Open base
Date: Wed, 18 Jul 2012 21:55:49 +0200
Message-ID: <1342641349.2626.3555.camel@edumazet-glaptop>
References: <1342473410-6265-1-git-send-email-ycheng@google.com>
	 <1342473410-6265-2-git-send-email-ycheng@google.com>
	 <20120716.231644.1189536600250332545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:46731 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755853Ab2GRTzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 15:55:55 -0400
Received: by yhmm54 with SMTP id m54so1998510yhm.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 12:55:54 -0700 (PDT)
In-Reply-To: <20120716.231644.1189536600250332545.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-16 at 23:16 -0700, David Miller wrote:
> From: Yuchung Cheng <ycheng@google.com>
> Date: Mon, 16 Jul 2012 14:16:44 -0700
> 
> > +#define TCPOPT_EXP		254	/* Experimental */
> > +/* Magic number to be after the option value for sharing TCP
> > + * experimental options. See draft-ietf-tcpm-experimental-options-00.txt
> > + */
> > +#define TCPOPT_FASTOPEN_MAGIC	0xF989
> 
> If I apply this, we're stuck supporting this experimental number
> forever.
> 
> Because somewhere, someone will have a kernel running using this
> number, so we have to support this option value as well as whatever
> the official one is.
> 
> Therefore I think the only logical thing we can do is only deploy
> this once an official option number is choosen.

Hi David

This is a chicken and egg problem.

IANA wont grant an official number like that in 2012+. Maybe if billions
of Android/linux devices use TFO in 2015 IANA will grant an official
number.

So we chose to follow Joe touch proposal
(http://tools.ietf.org/html/draft-ietf-tcpm-experimental-options-01) and
the magic 0xF989 was generated according to section 3) to avoid possible
clashes with other experimental options using code option 254

(Code options 253 & 254 are reserved for experimental use.
Linux Cookie extension uses 253 without a magic cookie so 253 cannot be
shared. By the way I wonder if anybody uses it... oh well...) 

Only servers will need to cope with this experimental option plus the
official one (_if_ IANA accepts to unblock one of the many reserved
options, in two or three years)

Yuchung only posted the Client side in this patch series. But we already
run the server side, and supporting the official TFO option plus the
experimental one is adding less than 10 lines of code.

So the plan would be :

1) Use the experimental 254 + magic on TFO Clients/Servers in 2012

2) When/If IANA grants an official number, add its support to servers
   (keeping support for experimental option as well)

3) One/two years later, switch client side to use this official number

4) Ten years later, remove experimental from server side.

Thanks !

PS :

TFO is not mandatory : If the initial SYN TFO option is not understood
by a server, it will reply with a SYN/ACK without the option and cookie,
and client will proceed as today.
