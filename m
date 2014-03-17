From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next] net: sched: use no more than one page in
 struct fw_head
Date: Mon, 17 Mar 2014 09:16:32 -0700
Message-ID: <1395072992.9668.59.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140314132834.GS21124@linux.vnet.ibm.com>
	 <1394804798.21721.64.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140314153810.GX21124@linux.vnet.ibm.com>
	 <20140314185005.GA17041@linux.vnet.ibm.com>
	 <20140314185917.GA18933@linux.vnet.ibm.com>
	 <1394826958.9668.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1394985990.9668.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140317135101.GA8956@casper.infradead.org>
	 <1395065631.9668.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140317152852.GB8956@casper.infradead.org>
	 <20140317155024.GD8956@casper.infradead.org>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6DF5DA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Thomas Graf' <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	John Fastabend <john.fastabend@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:60476 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826AbaCQQQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 12:16:34 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so5859162pbb.36
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 09:16:33 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6DF5DA@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-17 at 16:00 +0000, David Laight wrote:

> Actually the -Os forces the divide.

Yep, this might be the case.

> With -O3 the generated code I get for amd64 is a multiply by reciprocal
> to get the quotient followed by an open coded multiply by 0x1ff and
> then a subtract. 13 instructions, only a few of which are register renames
> or are non-dependant.

I think its more 4 arithmetic instructions : 2 multiplies, one shift,
one sub.

Note that when John adds an rcu_head, the 0x1ff becomes 0x1fd

   	89 f8                	mov    %edi,%eax
   	ba b3 21 c1 80       	mov    $0x80c121b3,%edx
   	f7 e2                	mul    %edx
   	c1 ea 08             	shr    $0x8,%edx
  	69 d2 fd 01 00 00    	imul   $0x1fd,%edx,%edx
  	29 d7                	sub    %edx,%edi
  	89 f8                	mov    %edi,%eax
