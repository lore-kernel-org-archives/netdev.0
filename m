From: "David S. Miller" <davem@redhat.com>
Subject: Re: is sk->reuse truly a boolean?
Date: Thu, 22 May 2003 00:10:27 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030522.001027.55734466.davem@redhat.com>
References: <20030520155744.GE801@conectiva.com.br>
	<20030521.011520.49126007.yoshfuji@linux-ipv6.org>
	<20030520162906.GF801@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <20030520162906.GF801@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
   Date: Tue, 20 May 2003 13:29:07 -0300

   Another one I found in this audit:
   
   sk->no_check, as per setsockopt is a boolean, but sunrpc code wants tree
   values, does that need receiving this three values from userspace? if so we
   have a bug in setsockopt, but without looking at sunrpc code I guess this is
   only internal...

This UDP_CSUM_NORCV value made sense when we did UDP checksumming
at packet receive time, but now that we delay checksumming until
user recvmsg() call runs it is quite useless.

net/sunrpc/xprt.c:udp_data_ready() wants to see packets which have
not been checksummed yet, so it may do this and copy at the same
time.  This is the only behavior made by UDP, it never checks
sk->no_check value.

So UDP_CSUM_NORCV and the sk->no_check setting in net/sunrpc/xprt.c
can be both deleted.  It is true for 2.4.x too, and you probably want
to run this patch by the NFS guys first so they do not have a heart
attack when they notice this hit the tree :-)
