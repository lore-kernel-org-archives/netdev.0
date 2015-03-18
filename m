From: "'tgraf@suug.ch'" <tgraf@suug.ch>
Subject: Re: [v1 PATCH 1/14] rhashtable: Remove shift from bucket_table
Date: Wed, 18 Mar 2015 10:44:28 +0000
Message-ID: <20150318104428.GN17829@casper.infradead.org>
References: <20150317112726.GC11671@gondor.apana.org.au>
 <20150317115749.GJ17829@casper.infradead.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CB02567@AcuExch.aculab.com>
 <20150317122033.GA12612@gondor.apana.org.au>
 <20150317124012.GH11089@casper.infradead.org>
 <20150317215638.GA16776@gondor.apana.org.au>
 <20150318095102.GL17829@casper.infradead.org>
 <20150318095516.GA22634@gondor.apana.org.au>
 <20150318100812.GM17829@casper.infradead.org>
 <20150318101209.GA23236@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53868 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123AbbCRKo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 06:44:29 -0400
Content-Disposition: inline
In-Reply-To: <20150318101209.GA23236@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/18/15 at 09:12pm, Herbert Xu wrote:
> On Wed, Mar 18, 2015 at 10:08:12AM +0000, 'tgraf@suug.ch' wrote:
> >
> > With this fixed up I can see what you mean. So if we are
> > to only do a chain length based decision, the limit would
> > have to grow together with the table size.
> 
> All we could just use a flat limit of 16 since our maximum table
> size is 2^32 (actually a bit less) and 16 should be plenty for
> that.
> 
> Remember this limit is only there to detect when somebody has
> stolen our secret is trying to DoS us.  So if we can keep them
> under 16 per-bucket it should be sufficient to defeat any attack.

Agreed, that is certainly sufficient to avoid attacks. I didn't
want to give up on getting rid of the need for a table wide
nelemes *inside* rhashtable if we have to maintain chain length
anyway but I can see the difficulties.

The only approach that seems to work is to count the number of
buckets with a chain length above a limit that is relative to the
table size or something alike which requires to count on table
level and if we have to do that we might as well just count the
number of elements in the table.

> Of course I will also add a patch to limit the number of elements
> to the table size (so maximum utilisation is 100%).  This will come
> after we allow insertions to fail.

I'm also attaching distribution of chain length for table sizes
for completion's sake.

Percentage of buckets with more than 1 entry:

1: 0%
2: 50%
3: 25%
4: 25%
5: 28%
6: 28%
7: 31%
8: 26%
9: 25%
10: 27%
11: 26%
12: 26%
13: 26%
14: 26%
15: 26%
16: 26%
17: 26%
18: 26%
19: 26%
20: 26%
21: 26%
22: 26%
23: 26%

Distribution of chain lengths:
1:
      1 2
2:
      2 2
3:
      1 2
      1 3
4:
      3 2
      1 3
5:
      6 2
      4 3
6:
     11 2
      4 3
      1 4
7:
     27 2
      8 3
      2 4
8:
     50 2
     15 3
      3 4
      1 5
9:
    101 2
     33 3
      6 4
      1 5
10:
    201 2
     61 3
     17 4
      2 5
11:
    361 2
    134 3
     29 4
      5 5
      1 6
12:
    784 2
    242 3
     49 4
     14 5
      3 6
13:
   1552 2
    472 3
    118 4
     28 5
      5 6
      1 7
14:
   2965 2
    996 3
    262 4
     51 5
      9 6
      1 7
      1 8
15:
   6010 2
   2029 3
    510 4
     90 5
     21 6
      2 7
16:
  11993 2
   4068 3
   1014 4
    175 5
     40 6
      5 7
      1 8
17:
  24123 2
   8100 3
   1969 4
    403 5
     79 6
     10 7
      3 8
18:
  48127 2
  16145 3
   3930 4
    825 5
    137 6
     25 7
      1 8
      1 9
19:
  96558 2
  32250 3
   7990 4
   1619 5
    264 6
     40 7
      7 8
20:
 193267 2
  64476 3
  16051 4
   3140 5
    544 6
     71 7
      9 8
      1 9
21:
 385293 2
 128850 3
  32366 4
   6344 5
   1017 6
    128 7
     21 8
      2 9
22:
 769535 2
 257779 3
  64534 4
  13052 5
   2177 6
    322 7
     25 8
      1 9
23:
1540606 2
 514743 3
 130192 4
  26207 5
   4403 6
    635 7
     73 8
     11 9
24:
3073982 2
1032727 3
 262044 4
  53475 5
   9179 6
   1353 7
    184 8
     14 9
      2 10
      1 11
25:
6124258 2
2071733 3
 534130 4
 111862 5
  19754 6
   3030 7
    419 8
     56 9
      5 10
      1 12
