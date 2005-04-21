From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPSEC]: Kill nested read lock by deleting xfrm_init_tempsel
Date: Fri, 22 Apr 2005 01:53:43 +0200
Message-ID: <42683D07.6090808@trash.net>
References: <20050328233917.GB15369@gondor.apana.org.au>	<424B40C2.90304@trash.net>	<20050331004658.GA26395@gondor.apana.org.au>	<20050331212325.5e996432.davem@davemloft.net>	<20050402004956.GA24339@gondor.apana.org.au>	<20050401172007.7296eced.davem@davemloft.net>	<20050402020947.GA24998@gondor.apana.org.au>	<42501E51.3000401@trash.net>	<20050405103918.GA24863@gondor.apana.org.au>	<4252EEA2.5020107@trash.net>	<20050406022155.GA12952@gondor.apana.org.au> <20050421163526.7a29a76f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010608010000090806080304"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, kuznet@ms2.inr.ac.ru,
        jmorris@redhat.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050421163526.7a29a76f.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010608010000090806080304
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

David S. Miller wrote:
> On Wed, 6 Apr 2005 12:21:55 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
>>Thanks.  Just one more issue that I can think of, the check should
>>only be done when tmpl->id.spi != 0.  Otherwise the presence of
>>valid states with differing state selectors will prevent new
>>sessions from starting up.
> 
> Is it really worthwhile, right now, to change that tmpl->id.daddr to
> daddr?  That seems to be all that Patrick's most recent patch does.

Yes, tmpl->id.daddr might be 0, in which case the destination
of the packet or previous tunnel mode transforms is used. daddr
always contains the correct adress, so we should use it to check
for duplicate SPIs. But as Herbert noted, we shouldn't perform
the check if tmpl->id.spi == 0, so here is a new patch.

Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------010608010000090806080304
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== net/xfrm/xfrm_state.c 1.60 vs edited =====
--- 1.60/net/xfrm/xfrm_state.c	2005-04-01 07:19:54 +02:00
+++ edited/net/xfrm/xfrm_state.c	2005-04-22 01:51:37 +02:00
@@ -357,8 +357,9 @@
 
 	x = best;
 	if (!x && !error && !acquire_in_progress) {
-		x0 = afinfo->state_lookup(&tmpl->id.daddr, tmpl->id.spi, tmpl->id.proto);
-		if (x0 != NULL) {
+		if (tmpl->id.spi &&
+		    (x0 = afinfo->state_lookup(daddr, tmpl->id.spi,
+		                               tmpl->id.proto)) != NULL) {
 			xfrm_state_put(x0);
 			error = -EEXIST;
 			goto out;

--------------010608010000090806080304--
