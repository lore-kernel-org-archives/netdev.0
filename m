From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Tue, 06 Sep 2011 21:43:06 +0200
Message-ID: <1315338186.3400.20.camel@edumazet-laptop>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315335019.2576.3048.camel@schen9-DESK>
	 <1315335660.3400.7.camel@edumazet-laptop>
	 <1315337580.2576.3066.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yan, Zheng" <zheng.z.yan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>, alex.shi@intel.com
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44036 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688Ab1IFTne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 15:43:34 -0400
Received: by wwf5 with SMTP id 5so6629823wwf.1
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2011 12:43:33 -0700 (PDT)
In-Reply-To: <1315337580.2576.3066.camel@schen9-DESK>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 septembre 2011 =C3=A0 12:33 -0700, Tim Chen a =C3=A9crit :

> Yes, I think locking the sendmsg for the entire duration of
> unix_stream_sendmsg makes a lot of sense.  It simplifies the logic a =
lot
> more.  I'll try to cook something up in the next couple of days.

Thats not really possible, we cant hold a spinlock and call
sock_alloc_send_skb() and/or memcpy_fromiovec(), wich might sleep.

You would need to prepare the full skb list, then :
- stick the ref on the last skb of the list.

Transfert the whole skb list in other->sk_receive_queue in one go,
instead of one after another.

Unfortunately, this would break streaming (big send(), and another
thread doing the receive)

Listen, I am wondering why hackbench even triggers SCM code. This is
really odd. We should not have a _single_ pid/cred ref/unref at all.
