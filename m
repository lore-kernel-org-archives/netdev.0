From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/42] decnet: Fix set-but-unused variable.
Date: Sun, 17 Apr 2011 20:48:12 -0700 (PDT)
Message-ID: <20110417.204812.226773735.davem@davemloft.net>
References: <20110417.173250.183050174.davem@davemloft.net>
	<1303092729.5282.1005.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46093
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752016Ab1DRDsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 23:48:47 -0400
In-Reply-To: <1303092729.5282.1005.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 18 Apr 2011 03:12:09 +0100

> On Sun, 2011-04-17 at 17:32 -0700, David Miller wrote:
>> "next" in dn_rebuild_zone() is set but not actually used,
>> kill it off.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> ---
>>  net/decnet/dn_table.c |    3 +--
>>  1 files changed, 1 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
>> index 99d8d3a..d8ea583 100644
>> --- a/net/decnet/dn_table.c
>> +++ b/net/decnet/dn_table.c
>> @@ -124,11 +124,10 @@ static inline void dn_rebuild_zone(struct dn_zone *dz,
>>  				   int old_divisor)
>>  {
>>  	int i;
>> -	struct dn_fib_node *f, **fp, *next;
>> +	struct dn_fib_node *f, **fp;
>>  
>>  	for(i = 0; i < old_divisor; i++) {
>>  		for(f = old_ht[i]; f; f = f->fn_next) {
>> -			next = f->fn_next;
>>  			for(fp = dn_chain_p(f->fn_key, dz);
>>  				*fp && dn_key_leq((*fp)->fn_key, f->fn_key);
>>  				fp = &(*fp)->fn_next)
> 
> This function is rebuilding a hash table after the number of buckets is
> changed.  After moving each element into a new bucket, it needs to carry
> on iterating over the old bucket.  Therefore the 'next' variable is
> really needed and the second for-loop should use it: 'f = next', not
> 'f = f->fn_next'.

Good catch, I committed the following:

--------------------
decnet: Don't leak entries when rebuilding zone.

As noticed by Ben Hutchings, when we move entries from
one table to another we leak all except the first entry.

Put back the "next" variable removed by commit
9bf9055eb716f85372c41b3fbc51f90bc7653740 ("decnet: Fix set-but-unused
variable.") and use it properly.

Reported-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/decnet/dn_table.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index d8ea583..bd0a52d 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -123,11 +123,12 @@ static inline void dn_rebuild_zone(struct dn_zone *dz,
 				   struct dn_fib_node **old_ht,
 				   int old_divisor)
 {
+	struct dn_fib_node *f, **fp, *next;
 	int i;
-	struct dn_fib_node *f, **fp;
 
 	for(i = 0; i < old_divisor; i++) {
-		for(f = old_ht[i]; f; f = f->fn_next) {
+		for(f = old_ht[i]; f; f = next) {
+			next = f->fn_next;
 			for(fp = dn_chain_p(f->fn_key, dz);
 				*fp && dn_key_leq((*fp)->fn_key, f->fn_key);
 				fp = &(*fp)->fn_next)
-- 
1.7.4.3

